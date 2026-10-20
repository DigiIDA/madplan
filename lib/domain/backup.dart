import 'dart:convert';

import 'models.dart';

const backupFormat = 'madplan-opskrifter';
const backupVersion = 1;
const _notABackup = 'Filen er ikke en Madplan-backup';

String encodeBackup(List<Recipe> recipes) =>
    const JsonEncoder.withIndent('  ').convert({
      'format': backupFormat,
      'version': backupVersion,
      'recipes': [for (final recipe in recipes) recipe.toJson()],
    });

List<Recipe> decodeBackup(String text) {
  final json = jsonDecode(text);
  if (json is! Map<String, dynamic> || json['format'] != backupFormat) {
    throw const FormatException(_notABackup);
  }
  try {
    return [
      for (final item in json['recipes'] as List)
        Recipe.fromJson(item as Map<String, dynamic>),
    ];
  } on TypeError {
    throw const FormatException('$_notABackup – opskrifterne er ødelagte');
  }
}
