import 'parse.dart';

const _maxIngredientWords = 8;
const _maxNameLength = 60;

const _ingredientHeadings = {'ingredienser', 'du skal bruge', 'til retten'};
const _instructionHeadings = {
  'fremgangsmåde',
  'sådan gør du',
  'tilberedning',
  'metode',
  'opskrift',
};

final _bullet = RegExp(r'^[•·*\-–]\s*');
final _headingPunctuation = RegExp(r'[:.]$');
final _pageNumber = RegExp(r'^\d+$');
final _servings = RegExp(
  r'^(?:til\s+)?(\d+)\s*(?:personer|pers\.?|portioner|port\.?)?$',
  caseSensitive: false,
);
final _numberedStep = RegExp(r'^\d+[.)]\s');
final _sentenceEnd = RegExp(r'[.!?]$');
final _startsUppercase = RegExp(r'^[A-ZÆØÅ]');
final _whitespace = RegExp(r'\s+');

enum _Section { none, ingredients, instructions }

class ScannedRecipe {
  const ScannedRecipe({
    required this.name,
    required this.servings,
    required this.ingredientLines,
    required this.instructions,
  });

  final String? name;
  final int? servings;
  final List<String> ingredientLines;
  final String instructions;
}

_Section? _headingSection(String line) {
  final heading = line.toLowerCase().replaceFirst(_headingPunctuation, '');
  if (_ingredientHeadings.contains(heading)) return _Section.ingredients;
  if (_instructionHeadings.contains(heading)) return _Section.instructions;
  return null;
}

bool _startsParagraph(String line, List<String> paragraphs) =>
    paragraphs.isEmpty ||
    _numberedStep.hasMatch(line) ||
    (_sentenceEnd.hasMatch(paragraphs.last) && _startsUppercase.hasMatch(line));

ScannedRecipe parseRecipeText(String text) {
  String? name;
  int? servings;
  var section = _Section.none;
  final ingredients = <String>[];
  final paragraphs = <String>[];

  for (final raw in text.split('\n')) {
    final line = raw.trim().replaceFirst(_bullet, '').trim();
    if (line.isEmpty || _pageNumber.hasMatch(line)) continue;

    final heading = _headingSection(line);
    if (heading != null) {
      section = heading;
      continue;
    }

    final servingsMatch = _servings.firstMatch(line);
    if (servings == null && servingsMatch != null && line.contains(' ')) {
      servings = int.parse(servingsMatch.group(1)!);
      continue;
    }

    final short = line.split(_whitespace).length <= _maxIngredientWords;
    final isIngredient =
        section != _Section.instructions &&
        !_numberedStep.hasMatch(line) &&
        short &&
        (section == _Section.ingredients || hasLeadingQuantity(line));
    if (isIngredient) {
      ingredients.add(line);
    } else if (name == null &&
        ingredients.isEmpty &&
        paragraphs.isEmpty &&
        line.length <= _maxNameLength) {
      name = line;
    } else if (_startsParagraph(line, paragraphs)) {
      paragraphs.add(line);
    } else {
      paragraphs.last = '${paragraphs.last} $line';
    }
  }

  return ScannedRecipe(
    name: name,
    servings: servings,
    ingredientLines: ingredients,
    instructions: paragraphs.join('\n'),
  );
}

String appendText(String existing, String addition) => [
  existing.trimRight(),
  addition.trim(),
].where((part) => part.isNotEmpty).join('\n');
