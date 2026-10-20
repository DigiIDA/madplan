import 'models.dart';
import 'quantity.dart';

const _maxDecimals = 2;
const _gramsPerKilo = 1000.0;
const _mlPerLitre = 1000.0;
const _mlPerDecilitre = 100.0;

final _trailingZeros = RegExp(r'\.?0+$');

String formatNumber(double value) => value
    .toStringAsFixed(_maxDecimals)
    .replaceFirst(_trailingZeros, '')
    .replaceAll('.', ',');

String formatBase(double base, Dimension dimension) => switch (dimension) {
  Dimension.mass when base >= _gramsPerKilo =>
    '${formatNumber(base / _gramsPerKilo)} kg',
  Dimension.mass => '${formatNumber(base)} g',
  Dimension.volume when base >= _mlPerLitre =>
    '${formatNumber(base / _mlPerLitre)} l',
  Dimension.volume when base >= _mlPerDecilitre =>
    '${formatNumber(base / _mlPerDecilitre)} dl',
  Dimension.volume => '${formatNumber(base)} ml',
  Dimension.count => '${formatNumber(base)} stk',
};

String formatItem(ItemKey key, double base) =>
    '${formatBase(base, key.dimension)} ${key.name}';

String formatIngredient(Ingredient ingredient) => ingredient.unit == Unit.stk
    ? '${formatNumber(ingredient.amount)} ${ingredient.name}'
    : '${formatNumber(ingredient.amount)} ${ingredient.unit.label} '
          '${ingredient.name}';
