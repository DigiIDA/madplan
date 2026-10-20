const _minStemLength = 3;
const _irregularEndings = {'rødderne': 'rod', 'rødder': 'rod'};
const _pluralSuffixes = ['erne', 'ene', 'er', 'e', 'r'];

final _doubleLetters = RegExp(r'(.)\1+');

String _replaceIrregular(String word) {
  for (final MapEntry(key: ending, value: base) in _irregularEndings.entries) {
    if (word.endsWith(ending)) {
      return word.substring(0, word.length - ending.length) + base;
    }
  }
  return word;
}

String _stripPlural(String word) {
  for (final suffix in _pluralSuffixes) {
    if (word.endsWith(suffix) &&
        word.length - suffix.length >= _minStemLength) {
      return word.substring(0, word.length - suffix.length);
    }
  }
  return word;
}

String _contractEl(String stem) =>
    stem.endsWith('el') ? '${stem.substring(0, stem.length - 2)}l' : stem;

String _stem(String word) => _contractEl(
  _stripPlural(_replaceIrregular(word)),
).replaceAllMapped(_doubleLetters, (match) => match.group(1)!);

String matchKey(String name) => name.split(' ').map(_stem).join(' ');
