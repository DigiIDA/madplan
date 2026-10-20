import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:madplan/domain/format.dart';
import 'package:madplan/domain/models.dart';
import 'package:madplan/domain/parse.dart';
import 'package:madplan/domain/quantity.dart';
import 'package:madplan/state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> freshPrefs() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

final omelet = Recipe(
  id: 'omelet',
  name: 'Omelet',
  ingredients: parseIngredients('3 æg\n1 dl mælk'),
);

void main() {
  test('persists and reloads everything', () async {
    final prefs = await freshPrefs();
    AppState.load(prefs)
      ..saveRecipe(omelet)
      ..addToPlan(omelet.id)
      ..addPantry(parseIngredient('2 æg')!)
      ..setPackSize(
        ItemKey('mælk', Dimension.volume),
        parseIngredient('1 l mælk'),
      );

    final reloaded = AppState.load(prefs);
    expect(reloaded.planRecipes.single.name, 'Omelet');
    expect(reloaded.pantry.single.name, 'æg');
    expect(reloaded.shopping.map((item) => item.key.name), ['mælk', 'æg']);
    expect(reloaded.leftovers[ItemKey('mælk', Dimension.volume)], 900);
  });

  test('moving checked purchases into the pantry merges and clears', () async {
    final eggs = ItemKey('æg', Dimension.count);
    final milk = ItemKey('mælk', Dimension.volume);
    final state = AppState.load(await freshPrefs())
      ..saveRecipe(omelet)
      ..addToPlan(omelet.id)
      ..addPantry(parseIngredient('2 æggene')!)
      ..setPackSize(milk, parseIngredient('1 l mælk'))
      ..toggleChecked(eggs)
      ..toggleChecked(milk)
      ..moveCheckedToPantry();

    expect(state.pantry.map(formatIngredient), ['1 l mælk', '3 æg']);
    expect(state.shopping, isEmpty);
    expect(state.isChecked(eggs), isFalse);
  });

  test('moving leaves unchecked items on the list', () async {
    final state = AppState.load(await freshPrefs())
      ..saveRecipe(omelet)
      ..addToPlan(omelet.id)
      ..toggleChecked(ItemKey('æg', Dimension.count))
      ..moveCheckedToPantry();

    expect(state.pantry.map(formatIngredient), ['3 æg']);
    expect(state.shopping.single.key.name, 'mælk');
  });

  test('plan days start at the recipe servings and scale needs', () async {
    final eggs = ItemKey('æg', Dimension.count);
    final state = AppState.load(await freshPrefs())
      ..saveRecipe(omelet)
      ..addToPlan(omelet.id);
    expect(state.plannedMeals.single.servings, defaultServings);
    expect(state.needs[eggs], 3);

    state.setServings(0, 2);
    expect(state.needs[eggs], 1.5);
    state.setServings(0, 0);
    expect(state.plannedMeals.single.servings, 2);
  });

  test('loads data saved before servings existed', () async {
    SharedPreferences.setMockInitialValues({
      'madplan_state_v1': jsonEncode({
        'recipes': [
          {
            'id': 'omelet',
            'name': 'Omelet',
            'ingredients': [
              {'name': 'æg', 'amount': 3, 'unit': 'stk'},
            ],
          },
        ],
        'plan': ['omelet'],
      }),
    });
    final state = AppState.load(await SharedPreferences.getInstance());
    expect(state.recipes.single.servings, defaultServings);
    expect(state.plannedMeals.single.servings, defaultServings);
  });

  test('importing replaces matching ids and adds new recipes', () async {
    const pancakes = Recipe(
      id: 'pancakes',
      name: 'Pandekager',
      ingredients: [],
    );
    const renamed = Recipe(
      id: 'omelet',
      name: 'Omelet deluxe',
      ingredients: [],
    );
    final state = AppState.load(await freshPrefs())..saveRecipe(omelet);

    expect(state.importRecipes([renamed, pancakes]), 2);
    expect(state.recipes.map((recipe) => recipe.name), [
      'Omelet deluxe',
      'Pandekager',
    ]);
  });

  test('deleting a recipe removes it from the plan', () async {
    final state = AppState.load(await freshPrefs())
      ..saveRecipe(omelet)
      ..addToPlan(omelet.id)
      ..deleteRecipe(omelet.id);
    expect(state.recipes, isEmpty);
    expect(state.planRecipes, isEmpty);
  });

  test('toggleChecked flips and clearPlan resets', () async {
    final eggs = ItemKey('æg', Dimension.count);
    final state = AppState.load(await freshPrefs())..toggleChecked(eggs);
    expect(state.isChecked(eggs), isTrue);
    state.clearPlan();
    expect(state.isChecked(eggs), isFalse);
  });
}
