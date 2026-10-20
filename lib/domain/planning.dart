import 'models.dart';

const _epsilon = 1e-9;

Stock toStock(Iterable<Ingredient> ingredients) {
  final stock = <ItemKey, double>{};
  for (final item in ingredients) {
    stock.update(
      item.key,
      (current) => current + item.baseAmount,
      ifAbsent: () => item.baseAmount,
    );
  }
  return stock;
}

Stock combine(Stock a, Stock b) {
  final result = {...a};
  b.forEach(
    (key, value) =>
        result.update(key, (current) => current + value, ifAbsent: () => value),
  );
  return result;
}

Stock subtract(Stock from, Stock remove) => {
  for (final entry in from.entries)
    if (entry.value - (remove[entry.key] ?? 0) > _epsilon)
      entry.key: entry.value - (remove[entry.key] ?? 0),
};

class ShoppingItem {
  const ShoppingItem({required this.key, required this.missing, this.packSize});

  final ItemKey key;
  final double missing;
  final double? packSize;

  int? get packs {
    final size = packSize;
    return size == null ? null : (missing / size - _epsilon).ceil();
  }

  double get toBuy {
    final size = packSize;
    return size == null ? missing : (missing / size - _epsilon).ceil() * size;
  }
}

List<ShoppingItem> shoppingList({
  required Stock needs,
  required Stock pantry,
  required Stock packSizes,
}) =>
    [
      for (final entry in subtract(needs, pantry).entries)
        ShoppingItem(
          key: entry.key,
          missing: entry.value,
          packSize: packSizes[entry.key],
        ),
    ]..sort((a, b) => a.key.name.compareTo(b.key.name));

Stock purchased(Iterable<ShoppingItem> items) => {
  for (final item in items) item.key: item.toBuy,
};

Stock computeLeftovers({
  required Stock needs,
  required Stock pantry,
  required Iterable<ShoppingItem> shopping,
}) => subtract(combine(pantry, purchased(shopping)), needs);

class Suggestion {
  const Suggestion({
    required this.recipe,
    required this.coverage,
    required this.missing,
  });

  final Recipe recipe;
  final double coverage;
  final Stock missing;
}

Suggestion _suggest(Stock have, Recipe recipe) {
  final needed = toStock(recipe.ingredients);
  final used = needed.keys.where((key) => (have[key] ?? 0) > _epsilon);
  return Suggestion(
    recipe: recipe,
    coverage: needed.isEmpty ? 0 : used.length / needed.length,
    missing: subtract(needed, have),
  );
}

int _byBestMatch(Suggestion a, Suggestion b) {
  final byCoverage = b.coverage.compareTo(a.coverage);
  return byCoverage != 0
      ? byCoverage
      : a.missing.length.compareTo(b.missing.length);
}

List<Suggestion> suggestRecipes(Stock have, Iterable<Recipe> recipes) => [
  for (final recipe in recipes) _suggest(have, recipe),
].where((suggestion) => suggestion.coverage > 0).toList()..sort(_byBestMatch);
