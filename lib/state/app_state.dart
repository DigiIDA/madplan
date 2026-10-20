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
    List<String> plan = const [],
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
    return AppState._(
      prefs,
      recipes: _decodeList(json['recipes'], Recipe.fromJson),
      pantry: _decodeList(json['pantry'], Ingredient.fromJson),
      plan: [for (final id in json['plan'] as List? ?? const []) id as String],
      packSizes: _decodeList(json['packSizes'], Ingredient.fromJson),
      checked: {
        for (final key in json['checked'] as List? ?? const []) key as String,
      },
    );
  }

  final SharedPreferences _prefs;
  List<Recipe> _recipes;
  List<Ingredient> _pantry;
  List<String> _plan;
  List<Ingredient> _packSizes;
  Set<String> _checked;

  List<Recipe> get recipes => List.unmodifiable(_recipes);
  List<Ingredient> get pantry => List.unmodifiable(_pantry);

  List<Recipe> get planRecipes {
    final byId = {for (final recipe in _recipes) recipe.id: recipe};
    return [for (final id in _plan) ?byId[id]];
  }

  Stock get needs =>
      toStock(planRecipes.expand((recipe) => recipe.ingredients));

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
    _plan = [..._plan.where((planned) => planned != id)];
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

  void addToPlan(String recipeId) {
    _plan = [..._plan, recipeId];
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
    'plan': _plan,
    'packSizes': [for (final pack in _packSizes) pack.toJson()],
    'checked': _checked.toList(),
  };

  void _commit() {
    unawaited(_prefs.setString(_storageKey, jsonEncode(_toJson())));
    notifyListeners();
  }
}
