import 'package:flutter/material.dart';

import '../domain/format.dart';
import '../domain/parse.dart';
import '../domain/planning.dart';
import '../state/app_state.dart';
import 'theme.dart';
import 'widgets.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key, required this.state});

  final AppState state;

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _add() {
    final item = parseIngredient(_input.text);
    if (item == null) return;
    widget.state.addPantry(item);
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return Scaffold(
      appBar: AppBar(title: const Text('Køleskab')),
      body: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final pantry = state.pantry;
          final suggestions = suggestRecipes(toStock(pantry), state.recipes);
          return ListView(
            padding: const EdgeInsets.all(Spacing.m),
            children: [
              const Text('Skriv hvad du har derhjemme, fx "500 g pasta".'),
              const SizedBox(height: Spacing.s),
              TextField(
                controller: _input,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _add(),
                decoration: InputDecoration(
                  hintText: '500 g pasta',
                  suffixIcon: IconButton(
                    tooltip: 'Tilføj',
                    icon: const Icon(Icons.add_circle, color: Palette.teal),
                    onPressed: _add,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.m),
              Wrap(
                spacing: Spacing.s,
                runSpacing: Spacing.s,
                children: [
                  for (final (index, item) in pantry.indexed)
                    InputChip(
                      label: Text(formatIngredient(item)),
                      onDeleted: () => state.removePantry(index),
                    ),
                ],
              ),
              const SectionTitle('Det kan du lave'),
              if (suggestions.isEmpty)
                Text(
                  pantry.isEmpty
                      ? 'Tilføj madvarer, så foreslår jeg retter.'
                      : 'Ingen af dine opskrifter matcher det, du har.',
                ),
              for (final suggestion in suggestions)
                SuggestionCard(
                  suggestion: suggestion,
                  onAddToPlan: () => state.addToPlan(suggestion.recipe.id),
                ),
            ],
          );
        },
      ),
    );
  }
}
