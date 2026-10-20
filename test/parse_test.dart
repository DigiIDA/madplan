import 'package:flutter_test/flutter_test.dart';
import 'package:madplan/domain/models.dart';
import 'package:madplan/domain/parse.dart';
import 'package:madplan/domain/quantity.dart';

void main() {
  group('parseIngredient', () {
    test('reads amount, unit and name', () {
      final item = parseIngredient('100 g Gulerødder')!;
      expect(item.amount, 100);
      expect(item.unit, Unit.g);
      expect(item.name, 'gulerødder');
    });

    test('accepts unit glued to the number and comma decimals', () {
      final item = parseIngredient('2,5dl mælk')!;
      expect(item.amount, 2.5);
      expect(item.unit, Unit.dl);
      expect(item.name, 'mælk');
    });

    test('treats a missing unit as pieces', () {
      final item = parseIngredient('3 æg')!;
      expect(item.unit, Unit.stk);
      expect(item.name, 'æg');
    });

    test('keeps a non-unit word as part of the name', () {
      final item = parseIngredient('2 store løg')!;
      expect(item.unit, Unit.stk);
      expect(item.name, 'store løg');
    });

    test('defaults to one piece without a number', () {
      final item = parseIngredient('salt')!;
      expect(item.amount, 1);
      expect(item.name, 'salt');
    });

    test('ignores empty lines and lone numbers', () {
      expect(parseIngredient('   '), isNull);
      expect(parseIngredient('2'), isNull);
    });
  });

  test('parseIngredients splits lines', () {
    final items = parseIngredients('100 g smør\n\n2 dl fløde\n');
    expect(items.map((item) => item.name), ['smør', 'fløde']);
  });

  group('parsePackSize', () {
    final cream = ItemKey('fløde', Dimension.volume);
    final eggs = ItemKey('æg', Dimension.count);

    test('accepts a matching dimension', () {
      expect(parsePackSize('2,5 dl', cream)!.baseAmount, 250);
      expect(parsePackSize('6', eggs)!.baseAmount, 6);
    });

    test('rejects a mismatched dimension', () {
      expect(parsePackSize('2,5', cream), isNull);
      expect(parsePackSize('500 g', eggs), isNull);
    });
  });
}
