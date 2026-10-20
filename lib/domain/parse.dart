import 'models.dart';
import 'quantity.dart';

const _defaultAmount = 1.0;

const _vulgarFractions = {
  '½': 1 / 2,
  '¼': 1 / 4,
  '¾': 3 / 4,
  '⅓': 1 / 3,
  '⅔': 2 / 3,
  '⅛': 1 / 8,
};

double _number(String? text) =>
    text == null ? 0 : double.parse(text.replaceAll(',', '.'));

double _fraction(Match m, int numerator, int denominator) =>
    _number(m.group(numerator)) / _number(m.group(denominator));

final _quantityPatterns = <(RegExp, double Function(Match))>[
  (
    RegExp(r'^(\d+)\s+(\d+)/(\d+)'),
    (m) => _number(m.group(1)) + _fraction(m, 2, 3),
  ),
  (RegExp(r'^(\d+)/(\d+)'), (m) => _fraction(m, 1, 2)),
  (
    RegExp('^(\\d+)?\\s*([${_vulgarFractions.keys.join()}])'),
    (m) => _number(m.group(1)) + _vulgarFractions[m.group(2)]!,
  ),
  (RegExp(r'^(\d+(?:[.,]\d+)?)'), (m) => _number(m.group(1))),
];
final _rangeTail = RegExp(r'^\s*[-–]\s*[\d½¼¾⅓⅔⅛.,/]+');
final _whitespace = RegExp(r'\s+');

({double amount, String rest})? _leadingQuantity(String text) {
  for (final (pattern, value) in _quantityPatterns) {
    final match = pattern.firstMatch(text);
    if (match != null) {
      final rest = text.substring(match.end).replaceFirst(_rangeTail, '');
      return (amount: value(match), rest: rest.trim());
    }
  }
  return null;
}

bool hasLeadingQuantity(String text) => _leadingQuantity(text.trim()) != null;

String normalizeName(String raw) =>
    raw.trim().toLowerCase().replaceAll(_whitespace, ' ');

Ingredient? parseIngredient(String line) {
  final text = line.trim();
  if (text.isEmpty) return null;

  final quantity = _leadingQuantity(text);
  if (quantity == null) {
    return Ingredient(
      name: normalizeName(text),
      amount: _defaultAmount,
      unit: Unit.stk,
    );
  }

  final (:amount, :rest) = quantity;
  final words = rest.split(_whitespace);
  final unit = words.length > 1 ? Unit.tryParse(words.first) : null;
  if (unit != null) {
    return Ingredient(
      name: normalizeName(words.skip(1).join(' ')),
      amount: amount,
      unit: unit,
    );
  }

  final name = normalizeName(rest);
  if (name.isEmpty) return null;
  return Ingredient(name: name, amount: amount, unit: Unit.stk);
}

List<Ingredient> parseIngredients(String text) =>
    text.split('\n').map(parseIngredient).nonNulls.toList();

Ingredient? parsePackSize(String text, ItemKey key) {
  final pack = parseIngredient('$text ${key.name}');
  final matches = pack != null && pack.key == key && pack.amount > 0;
  return matches ? pack : null;
}
