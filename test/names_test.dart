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
    ];
    for (final [a, b] in pairs) {
      expect(matchKey(a), isNot(matchKey(b)), reason: '$a vs $b');
    }
  });
}
