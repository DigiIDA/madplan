import 'package:flutter_test/flutter_test.dart';
import 'package:madplan/domain/format.dart';
import 'package:madplan/domain/models.dart';
import 'package:madplan/domain/quantity.dart';

void main() {
  test('formatNumber uses Danish decimals and trims zeros', () {
    expect(formatNumber(2), '2');
    expect(formatNumber(2.5), '2,5');
    expect(formatNumber(0.126), '0,13');
  });

  test('formatBase picks a readable unit', () {
    expect(formatBase(1500, Dimension.mass), '1,5 kg');
    expect(formatBase(250, Dimension.mass), '250 g');
    expect(formatBase(2000, Dimension.volume), '2 l');
    expect(formatBase(250, Dimension.volume), '2,5 dl');
    expect(formatBase(15, Dimension.volume), '15 ml');
    expect(formatBase(3, Dimension.count), '3 stk');
  });

  test('formatIngredient round-trips the entered unit', () {
    const carrots = Ingredient(name: 'gulerødder', amount: 100, unit: Unit.g);
    const eggs = Ingredient(name: 'æg', amount: 3, unit: Unit.stk);
    expect(formatIngredient(carrots), '100 g gulerødder');
    expect(formatIngredient(eggs), '3 æg');
  });
}
