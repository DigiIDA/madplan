import 'package:flutter_test/flutter_test.dart';
import 'package:madplan/domain/scan.dart';

const cookbookPage = '''
112
Gulerodssuppe med ingefær
4 personer
Ingredienser
• 1 kg gulerødder
½ dl olivenolie
2 løg
1 ½ spsk revet ingefær
1 l grøntsagsbouillon
Salt og peber
Fremgangsmåde:
1. Skræl gulerødderne og skær dem i
skiver. Hak løgene.
2. Svits løg og ingefær i olien ved 200
grader i 5 minutter.
3. Tilsæt gulerødder og bouillon, og kog
suppen i 20 min. Blend og smag til.
''';

void main() {
  final recipe = parseRecipeText(cookbookPage);

  test('finds the title and servings', () {
    expect(recipe.name, 'Gulerodssuppe med ingefær');
    expect(recipe.servings, 4);
  });

  test('collects ingredient lines without bullets or headings', () {
    expect(recipe.ingredientLines, [
      '1 kg gulerødder',
      '½ dl olivenolie',
      '2 løg',
      '1 ½ spsk revet ingefær',
      '1 l grøntsagsbouillon',
      'Salt og peber',
    ]);
  });

  test('joins wrapped instruction lines into numbered steps', () {
    expect(recipe.instructions.split('\n'), [
      '1. Skræl gulerødderne og skær dem i skiver. Hak løgene.',
      '2. Svits løg og ingefær i olien ved 200 grader i 5 minutter.',
      '3. Tilsæt gulerødder og bouillon, og kog suppen i 20 min. '
          'Blend og smag til.',
    ]);
  });

  test('handles text with no recognisable recipe', () {
    final empty = parseRecipeText('');
    expect(empty.name, isNull);
    expect(empty.servings, isNull);
    expect(empty.ingredientLines, isEmpty);
    expect(empty.instructions, isEmpty);
  });

  test('appendText adds a scanned page below what is already there', () {
    expect(appendText('', '1 kg mel'), '1 kg mel');
    expect(appendText('2 æg\n', '1 kg mel'), '2 æg\n1 kg mel');
    expect(appendText('2 æg', ''), '2 æg');
  });
}
