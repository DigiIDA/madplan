import 'package:flutter/material.dart';

import '../domain/format.dart';
import '../domain/planning.dart';
import 'theme.dart';

const _percent = 100;

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: Spacing.l, bottom: Spacing.s),
    child: Text(text, style: Theme.of(context).textTheme.titleLarge),
  );
}

class EmptyHint extends StatelessWidget {
  const EmptyHint(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(Spacing.l),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    ),
  );
}

class SuggestionCard extends StatelessWidget {
  const SuggestionCard({
    super.key,
    required this.suggestion,
    required this.onAddToPlan,
  });

  final Suggestion suggestion;
  final VoidCallback onAddToPlan;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final missing = suggestion.missing.entries
        .map((entry) => formatItem(entry.key, entry.value))
        .join(', ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.m,
          Spacing.m,
          Spacing.s,
          Spacing.s,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    suggestion.recipe.name,
                    style: textTheme.titleLarge,
                  ),
                ),
                Chip(
                  backgroundColor: Palette.sun,
                  side: BorderSide.none,
                  label: Text(
                    '${(suggestion.coverage * _percent).round()} %',
                  ),
                ),
              ],
            ),
            Text(
              missing.isEmpty
                  ? 'Du har alt, du skal bruge.'
                  : 'Skal suppleres med: $missing',
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onAddToPlan,
                icon: const Icon(Icons.playlist_add),
                label: const Text('Læg på madplan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
