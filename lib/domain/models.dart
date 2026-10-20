import 'quantity.dart';

typedef ItemKey = ({String name, Dimension dimension});

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

  final String name;
  final double amount;
  final Unit unit;

  ItemKey get key => (name: name, dimension: unit.dimension);

  double get baseAmount => amount * unit.baseFactor;

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
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json['id'] as String,
    name: json['name'] as String,
    ingredients: [
      for (final item in json['ingredients'] as List)
        Ingredient.fromJson(item as Map<String, dynamic>),
    ],
    instructions: json['instructions'] as String? ?? '',
  );

  final String id;
  final String name;
  final List<Ingredient> ingredients;
  final String instructions;

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'ingredients': [for (final item in ingredients) item.toJson()],
    'instructions': instructions,
  };
}
