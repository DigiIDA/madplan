import 'package:flutter_test/flutter_test.dart';
import 'package:madplan/domain/models.dart';
import 'package:madplan/domain/parse.dart';
import 'package:madplan/domain/planning.dart';
import 'package:madplan/domain/quantity.dart';

Recipe recipe(String name, String ingredients) =>
    Recipe(id: name, name: name, ingredients: parseIngredients(ingredients));

Stock stock(String text) => toStock(parseIngredients(text));

final cream = ItemKey('fløde', Dimension.volume);
final pasta = ItemKey('pasta', Dimension.mass);
final eggs = ItemKey('æg', Dimension.count);

void main() {
  test('toStock sums the same item across units', () {
    final result = stock('1 dl fløde\n50 ml fløde\n1 kg pasta\n200 g pasta');
    expect(result[cream], 150);
    expect(result[pasta], 1200);
  });

  test('singular and plural names count as the same item', () {
    final items = shoppingList(
      needs: stock('500 g gulerødder\n2 tomater'),
      pantry: stock('200 g gulerod\n2 tomat'),
      packSizes: const {},
    );
    expect(items.single.key.name, 'gulerødder');
    expect(items.single.missing, 300);
  });

  test('subtract keeps only positive remainders', () {
    final result = subtract(stock('3 æg\n100 g pasta'), stock('3 æg'));
    expect(result.keys, [pasta]);
  });

  group('shoppingList', () {
    final needs = stock('3 dl fløde\n500 g pasta\n4 æg');

    test('lists what the pantry lacks', () {
      final items = shoppingList(
        needs: needs,
        pantry: stock('200 g pasta\n4 æg'),
        packSizes: const {},
      );
      expect(items.map((item) => item.key), [cream, pasta]);
      expect(items.last.missing, 300);
      expect(items.last.toBuy, 300);
    });

    test('rounds up to whole packs', () {
      final items = shoppingList(
        needs: needs,
        pantry: const {},
        packSizes: {cream: 250, eggs: 6},
      );
      final creamItem = items.firstWhere((item) => item.key == cream);
      expect(creamItem.packs, 2);
      expect(creamItem.toBuy, 500);
      final eggItem = items.firstWhere((item) => item.key == eggs);
      expect(eggItem.packs, 1);
    });

    test('does not add a pack on exact multiples', () {
      final items = shoppingList(
        needs: stock('5 dl fløde'),
        pantry: const {},
        packSizes: {cream: 250},
      );
      expect(items.single.packs, 2);
    });
  });

  test('computeLeftovers returns pack surplus and unused pantry', () {
    final needs = stock('3 dl fløde\n4 æg');
    final pantry = stock('100 g pasta');
    final shopping = shoppingList(
      needs: needs,
      pantry: pantry,
      packSizes: {cream: 250, eggs: 6},
    );
    final result = computeLeftovers(
      needs: needs,
      pantry: pantry,
      shopping: shopping,
    );
    expect(result, {cream: 200, eggs: 2, pasta: 100});
  });

  group('suggestRecipes', () {
    final carbonara = recipe('Carbonara', '400 g pasta\n3 æg\n100 g bacon');
    final pancakes = recipe('Pandekager', '3 æg\n5 dl mælk\n250 g mel');
    final soup = recipe('Suppe', '1 kg gulerødder');

    test('ranks by share of ingredients you have and lists the rest', () {
      final result = suggestRecipes(stock('500 g pasta\n6 æg'), [
        pancakes,
        carbonara,
        soup,
      ]);
      expect(result.map((s) => s.recipe.name), ['Carbonara', 'Pandekager']);
      expect(result.first.missing.keys.single.name, 'bacon');
    });

    test('reports the missing amount for partial matches', () {
      final result = suggestRecipes(stock('2 æg'), [pancakes]);
      expect(result.single.missing[eggs], 1);
    });
  });
}
