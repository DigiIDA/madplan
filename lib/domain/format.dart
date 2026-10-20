import 'models.dart';
import 'quantity.dart';

const _maxDecimals = 2;

final _trailingZeros = RegExp(r'\.?0+$');

String formatNumber(double value) => value
    .toStringAsFixed(_maxDecimals)
    .replaceFirst(_trailingZeros, '')
    .replaceAll('.', ',');

String formatBase(double base, Dimension dimension) {
  final unit = Unit.readable(base, dimension);
  return '${formatNumber(base / unit.baseFactor)} ${unit.label}';
}

String formatItem(ItemKey key, double base) =>
    '${formatBase(base, key.dimension)} ${key.name}';

String formatIngredient(Ingredient ingredient) => ingredient.unit == Unit.stk
    ? '${formatNumber(ingredient.amount)} ${ingredient.name}'
    : '${formatNumber(ingredient.amount)} ${ingredient.unit.label} '
          '${ingredient.name}';
