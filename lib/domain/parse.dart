import 'models.dart';
import 'quantity.dart';

const _defaultAmount = 1.0;

final _leadingNumber = RegExp(r'^(\d+(?:[.,]\d+)?)\s*(.*)$');
final _whitespace = RegExp(r'\s+');

String normalizeName(String raw) =>
    raw.trim().toLowerCase().replaceAll(_whitespace, ' ');

Ingredient? parseIngredient(String line) {
  final text = line.trim();
  if (text.isEmpty) return null;

  final match = _leadingNumber.firstMatch(text);
  if (match == null) {
    return Ingredient(
      name: normalizeName(text),
      amount: _defaultAmount,
      unit: Unit.stk,
    );
  }

  final amount = double.parse(match.group(1)!.replaceAll(',', '.'));
  final rest = match.group(2)!.trim();
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
  final matches =
      pack != null &&
      pack.name == key.name &&
      pack.unit.dimension == key.dimension &&
      pack.amount > 0;
  return matches ? pack : null;
}
