import 'names.dart';
import 'quantity.dart';

const defaultServings = 4;
const minServings = 1;

final class ItemKey {
  ItemKey(this.name, this.dimension) : match = matchKey(name);

  final String name;
  final Dimension dimension;
  final String match;

  String get id => '$match|${dimension.name}';

  @override
  bool operator ==(Object other) =>
      other is ItemKey && other.match == match && other.dimension == dimension;

  @override
  int get hashCode => Object.hash(match, dimension);
}

typedef Stock = Map<ItemKey, double>;

String newId() => DateTime.now().microsecondsSinceEpoch.toString();

class Ingredient {
  const Ingredient({
    required this.name,
    required this.amount,
    required this.unit,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
    name: json['name'] as String,
    amount: (json['amount'] as num).toDouble(),
    unit: Unit.values.byName(json['unit'] as String),
  );

  factory Ingredient.fromBase(ItemKey key, double base) {
    final unit = Unit.readable(base, key.dimension);
    return Ingredient(
      name: key.name,
      amount: base / unit.baseFactor,
      unit: unit,
    );
  }

  final String name;
  final double amount;
  final Unit unit;

  ItemKey get key => ItemKey(name, unit.dimension);

  double get baseAmount => amount * unit.baseFactor;

  Ingredient scaled(double factor) =>
      Ingredient(name: name, amount: amount * factor, unit: unit);

  Map<String, Object> toJson() => {
    'name': name,
    'amount': amount,
    'unit': unit.name,
  };
}

class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    this.instructions = '',
    this.servings = defaultServings,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json['id'] as String,
    name: json['name'] as String,
    ingredients: [
      for (final item in json['ingredients'] as List)
        Ingredient.fromJson(item as Map<String, dynamic>),
    ],
    instructions: json['instructions'] as String? ?? '',
    servings: json['servings'] as int? ?? defaultServings,
  );

  final String id;
  final String name;
  final List<Ingredient> ingredients;
  final String instructions;
  final int servings;

  List<Ingredient> scaledTo(int people) => [
    for (final item in ingredients) item.scaled(people / servings),
  ];

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'ingredients': [for (final item in ingredients) item.toJson()],
    'instructions': instructions,
    'servings': servings,
  };
}

class PlanEntry {
  const PlanEntry({required this.recipeId, required this.servings});

  factory PlanEntry.fromJson(Object json, Map<String, Recipe> recipes) =>
      switch (json) {
        final String id => PlanEntry(
          recipeId: id,
          servings: recipes[id]?.servings ?? defaultServings,
        ),
        final Map<String, dynamic> map => PlanEntry(
          recipeId: map['recipeId'] as String,
          servings: map['servings'] as int,
        ),
        _ => throw FormatException('Ukendt madplan-format: $json'),
      };

  final String recipeId;
  final int servings;

  PlanEntry withServings(int value) =>
      PlanEntry(recipeId: recipeId, servings: value);

  Map<String, Object> toJson() => {'recipeId': recipeId, 'servings': servings};
}

typedef PlannedMeal = ({Recipe recipe, int servings});
