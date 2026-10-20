import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:madplan/domain/backup.dart';
import 'package:madplan/domain/format.dart';
import 'package:madplan/domain/models.dart';
import 'package:madplan/domain/parse.dart';

final soup = Recipe(
  id: 'soup',
  name: 'Gulerodssuppe',
  ingredients: parseIngredients('1 kg gulerødder\n2 dl fløde'),
  instructions: 'Kog og blend.',
  servings: 6,
);

void main() {
  test('recipes survive a round trip', () {
    final restored = decodeBackup(encodeBackup([soup])).single;
    expect(restored.id, soup.id);
    expect(restored.name, soup.name);
    expect(restored.instructions, soup.instructions);
    expect(restored.servings, 6);
    expect(restored.ingredients.map(formatIngredient), [
      '1 kg gulerødder',
      '2 dl fløde',
    ]);
  });

  test('rejects files that are not a Madplan backup', () {
    expect(() => decodeBackup('ikke json'), throwsFormatException);
    expect(() => decodeBackup('[1, 2]'), throwsFormatException);
    expect(
      () => decodeBackup(jsonEncode({'recipes': []})),
      throwsFormatException,
    );
  });

  test('rejects a backup with broken recipes', () {
    final broken = jsonEncode({
      'format': backupFormat,
      'version': backupVersion,
      'recipes': [
        {'id': 'x'},
      ],
    });
    expect(() => decodeBackup(broken), throwsFormatException);
  });
}
