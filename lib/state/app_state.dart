import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models.dart';
import '../domain/planning.dart';

const _storageKey = 'madplan_state_v1';

List<T> _decodeList<T>(
  Object? raw,
  T Function(Map<String, dynamic>) fromJson,
) => [
  for (final item in raw as List? ?? const [])
    fromJson(item as Map<String, dynamic>),
];

class AppState extends ChangeNotifier {
  AppState._(
    this._prefs, {
    List<Recipe> recipes = const [],
    List<Ingredient> pantry = const [],
    List<PlanEntry> plan = const [],
    List<Ingredient> packSizes = const [],
    Set<String> checked = const {},
  }) : _recipes = recipes,
       _pantry = pantry,
       _plan = plan,
       _packSizes = packSizes,
       _checked = checked;

  factory AppState.load(SharedPreferences prefs) {
    final raw = prefs.getString(_storageKey);
    if (raw == null) return AppState._(prefs);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final recipes = _decodeList(json['recipes'], Recipe.fromJson);
    final byId = {for (final recipe in recipes) recipe.id: recipe};
    return AppState._(
      prefs,
      recipes: recipes,
      pantry: _decodeList(json['pantry'], Ingredient.fromJson),
      plan: [
        for (final entry in json['plan'] as List? ?? const [])
          PlanEntry.fromJson(entry as Object, byId),
      ],
      packSizes: _decodeList(json['packSizes'], Ingredient.fromJson),
      checked: {
        for (final key in json['checked'] as List? ?? const []) key as String,
      },
    );
  }

  final SharedPreferences _prefs;
  List<Recipe> _recipes;
  List<Ingredient> _pantry;
  List<PlanEntry> _plan;
  List<Ingredient> _packSizes;
  Set<String> _checked;

  List<Recipe> get recipes => List.unmodifiable(_recipes);
  List<Ingredient> get pantry => List.unmodifiable(_pantry);

  List<PlannedMeal> get plannedMeals {
    final byId = {for (final recipe in _recipes) recipe.id: recipe};
    return [
      for (final entry in _plan)
        if (byId[entry.recipeId] case final recipe?)
          (recipe: recipe, servings: entry.servings),
    ];
  }

  List<Recipe> get planRecipes => [
    for (final meal in plannedMeals) meal.recipe,
  ];

  Stock get needs => toStock(
    plannedMeals.expand((meal) => meal.recipe.scaledTo(meal.servings)),
  );

  Stock get packSizes => {
    for (final pack in _packSizes) pack.key: pack.baseAmount,
  };

  List<ShoppingItem> get shopping => shoppingList(
    needs: needs,
    pantry: toStock(_pantry),
    packSizes: packSizes,
  );

  Stock get leftovers => computeLeftovers(
    needs: needs,
    pantry: toStock(_pantry),
    shopping: shopping,
  );

  bool isChecked(ItemKey key) => _checked.contains(key.id);

  void saveRecipe(Recipe recipe) {
    final exists = _recipes.any((existing) => existing.id == recipe.id);
    _recipes = exists
        ? [
            for (final existing in _recipes)
              existing.id == recipe.id ? recipe : existing,
          ]
        : [..._recipes, recipe];
    _commit();
  }

  void deleteRecipe(String id) {
    _recipes = [..._recipes.where((recipe) => recipe.id != id)];
    _plan = [..._plan.where((entry) => entry.recipeId != id)];
    _commit();
  }

  void addPantry(Ingredient item) {
    _pantry = [..._pantry, item];
    _commit();
  }

  void removePantry(int index) {
    _pantry = [..._pantry]..removeAt(index);
    _commit();
  }

  int get checkedCount => shopping.where((item) => isChecked(item.key)).length;

  void moveCheckedToPantry() {
    final bought = purchased(shopping.where((item) => isChecked(item.key)));
    if (bought.isEmpty) return;
    final current = toStock(_pantry);
    _pantry = [
      ..._pantry.where((item) => !bought.containsKey(item.key)),
      for (final MapEntry(:key, :value) in bought.entries)
        Ingredient.fromBase(key, value + (current[key] ?? 0)),
    ];
    _checked = {..._checked}..removeAll(bought.keys.map((key) => key.id));
    _commit();
  }

  void addToPlan(String recipeId) {
    final recipe = _recipes.firstWhere((recipe) => recipe.id == recipeId);
    _plan = [
      ..._plan,
      PlanEntry(recipeId: recipeId, servings: recipe.servings),
    ];
    _commit();
  }

  void setServings(int index, int servings) {
    if (servings < minServings) return;
    _plan = [..._plan]..[index] = _plan[index].withServings(servings);
    _commit();
  }

  void removeFromPlan(int index) {
    _plan = [..._plan]..removeAt(index);
    _commit();
  }

  void clearPlan() {
    _plan = const [];
    _checked = const {};
    _commit();
  }

  void setPackSize(ItemKey key, Ingredient? pack) {
    _packSizes = [
      ..._packSizes.where((existing) => existing.key != key),
      ?pack,
    ];
    _commit();
  }

  void toggleChecked(ItemKey key) {
    final id = key.id;
    _checked = _checked.contains(id)
        ? ({..._checked}..remove(id))
        : {..._checked, id};
    _commit();
  }

  Map<String, Object> _toJson() => {
    'recipes': [for (final recipe in _recipes) recipe.toJson()],
    'pantry': [for (final item in _pantry) item.toJson()],
    'plan': [for (final entry in _plan) entry.toJson()],
    'packSizes': [for (final pack in _packSizes) pack.toJson()],
    'checked': _checked.toList(),
  };

  void _commit() {
    unawaited(_prefs.setString(_storageKey, jsonEncode(_toJson())));
    notifyListeners();
  }
}
