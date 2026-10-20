import 'package:flutter_test/flutter_test.dart';
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
      ..setPackSize((
        name: 'mælk',
        dimension: Dimension.volume,
      ), parseIngredient('1 l mælk'));

    final reloaded = AppState.load(prefs);
    expect(reloaded.planRecipes.single.name, 'Omelet');
    expect(reloaded.pantry.single.name, 'æg');
    expect(reloaded.shopping.map((item) => item.key.name), ['mælk', 'æg']);
    expect(
      reloaded.leftovers[(name: 'mælk', dimension: Dimension.volume)],
      900,
    );
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
    const eggs = (name: 'æg', dimension: Dimension.count);
    final state = AppState.load(await freshPrefs())..toggleChecked(eggs);
    expect(state.isChecked(eggs), isTrue);
    state.clearPlan();
    expect(state.isChecked(eggs), isFalse);
  });
}
