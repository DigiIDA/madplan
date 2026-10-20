import 'package:flutter/material.dart';

import '../domain/format.dart';
import '../domain/parse.dart';
import '../domain/planning.dart';
import '../state/app_state.dart';
import 'theme.dart';
import 'widgets.dart';

String describe(ShoppingItem item) {
  final dimension = item.key.dimension;
  final size = item.packSize;
  final missing = formatBase(item.missing, dimension);
  return size == null
      ? 'Køb ${formatBase(item.toBuy, dimension)}'
      : 'Køb ${item.packs} pk à ${formatBase(size, dimension)} '
            '(skal bruge $missing)';
}

class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key, required this.state});

  final AppState state;

  Future<void> _editPackSize(BuildContext context, ShoppingItem item) =>
      showDialog<void>(
        context: context,
        builder: (_) => _PackSizeDialog(state: state, item: item),
      );

  void _moveToPantry(BuildContext context, int count) {
    state.moveCheckedToPantry();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          count == 1
              ? '1 vare er lagt i køleskabet'
              : '$count varer er lagt i køleskabet',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state,
    builder: (context, _) {
      final checked = state.checkedCount;
      return Scaffold(
        appBar: AppBar(title: const Text('Indkøb')),
        floatingActionButton: checked == 0
            ? null
            : FloatingActionButton.extended(
                onPressed: () => _moveToPantry(context, checked),
                icon: const Icon(Icons.kitchen),
                label: Text('Læg $checked i køleskabet'),
              ),
        body: _buildList(context),
      );
    },
  );

  Widget _buildList(BuildContext context) {
    if (state.planRecipes.isEmpty) {
      return const EmptyHint(
        'Læg retter på madplanen, så laver jeg indkøbslisten.',
      );
    }
    final items = state.shopping;
    if (items.isEmpty) {
      return const EmptyHint('Du har alt, hvad madplanen kræver.');
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Spacing.m,
        Spacing.m,
        Spacing.m,
        Spacing.fabClearance,
      ),
      children: [
        Text(
          'Kryds af, når du har købt en vare, og læg den i køleskabet. '
          'Tryk på pakken for at angive pakningsstørrelse.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: Spacing.s),
        for (final item in items)
          Card(
            child: CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              value: state.isChecked(item.key),
              onChanged: (_) => state.toggleChecked(item.key),
              title: Text(
                item.key.name,
                style: state.isChecked(item.key)
                    ? const TextStyle(decoration: TextDecoration.lineThrough)
                    : null,
              ),
              subtitle: Text(describe(item)),
              secondary: IconButton(
                tooltip: 'Pakningsstørrelse',
                icon: const Icon(
                  Icons.inventory_2_outlined,
                  color: Palette.burntOrange,
                ),
                onPressed: () => _editPackSize(context, item),
              ),
            ),
          ),
      ],
    );
  }
}

class _PackSizeDialog extends StatefulWidget {
  const _PackSizeDialog({required this.state, required this.item});

  final AppState state;
  final ShoppingItem item;

  @override
  State<_PackSizeDialog> createState() => _PackSizeDialogState();
}

class _PackSizeDialogState extends State<_PackSizeDialog> {
  late final _input = TextEditingController(
    text: switch (widget.item.packSize) {
      null => '',
      final size => formatBase(size, widget.item.key.dimension),
    },
  );
  String? _error;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _save() {
    final pack = parsePackSize(_input.text, widget.item.key);
    if (pack == null) {
      setState(() => _error = 'Skriv mængde og enhed, fx 2,5 dl');
      return;
    }
    widget.state.setPackSize(widget.item.key, pack);
    Navigator.of(context).pop();
  }

  void _remove() {
    widget.state.setPackSize(widget.item.key, null);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Pakning: ${widget.item.key.name}'),
    content: TextField(
      controller: _input,
      autofocus: true,
      onSubmitted: (_) => _save(),
      decoration: InputDecoration(hintText: '2,5 dl', errorText: _error),
    ),
    actions: [
      if (widget.item.packSize != null)
        TextButton(onPressed: _remove, child: const Text('Fjern')),
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Annuller'),
      ),
      FilledButton(onPressed: _save, child: const Text('Gem')),
    ],
  );
}
