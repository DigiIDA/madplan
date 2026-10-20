import 'package:flutter_test/flutter_test.dart';
import 'package:madplan/domain/names.dart';

void main() {
  test('singular, plural and definite forms share a match key', () {
    const groups = [
      ['gulerod', 'gulerødder', 'gulerødderne'],
      ['æble', 'æbler', 'æblerne'],
      ['tomat', 'tomater', 'tomaterne'],
      ['kartoffel', 'kartofler'],
      ['æg', 'æggene'],
      ['løg', 'løgene'],
      ['nød', 'nødder'],
      ['bønne', 'bønner'],
      ['pære', 'pærer'],
      ['rød peberfrugt', 'røde peberfrugter'],
      ['løg', 'store løg', 'små løg', 'mellemstore løg', 'økologiske løg'],
      ['gulerødder', 'store økologiske gulerødder'],
      ['citron', 'lille citron'],
      ['basilikum', 'frisk basilikum'],
    ];
    for (final group in groups) {
      expect(group.map(matchKey).toSet(), hasLength(1), reason: '$group');
    }
  });

  test('different foods keep different keys', () {
    const pairs = [
      ['peber', 'pære'],
      ['mel', 'mælk'],
      ['ost', 'flødeost'],
      ['te', 't'],
      ['røde løg', 'løg'],
      ['hakkede tomater', 'tomater'],
    ];
    for (final [a, b] in pairs) {
      expect(matchKey(a), isNot(matchKey(b)), reason: '$a vs $b');
    }
  });

  test('a name made only of descriptive words is kept', () {
    expect(matchKey('store'), isNotEmpty);
  });
}
