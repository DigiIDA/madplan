enum Dimension { mass, volume, count }

enum Unit {
  g('g', Dimension.mass, 1),
  kg('kg', Dimension.mass, 1000),
  ml('ml', Dimension.volume, 1),
  cl('cl', Dimension.volume, 10),
  dl('dl', Dimension.volume, 100),
  l('l', Dimension.volume, 1000),
  tsk('tsk', Dimension.volume, 5),
  spsk('spsk', Dimension.volume, 15),
  stk('stk', Dimension.count, 1);

  const Unit(this.label, this.dimension, this.baseFactor);

  final String label;
  final Dimension dimension;
  final double baseFactor;

  static const _aliases = <String, Unit>{
    'gr': Unit.g,
    'gram': Unit.g,
    'kilo': Unit.kg,
    'liter': Unit.l,
    'teske': Unit.tsk,
    'spiseske': Unit.spsk,
  };

  static Unit? tryParse(String text) {
    final word = text.toLowerCase().replaceAll('.', '');
    for (final unit in Unit.values) {
      if (unit.label == word) return unit;
    }
    return _aliases[word];
  }
}
