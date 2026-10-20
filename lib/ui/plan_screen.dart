import 'package:flutter/material.dart';

import '../domain/format.dart';
import '../domain/planning.dart';
import '../state/app_state.dart';
import 'theme.dart';
import 'widgets.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key, required this.state});

  final AppState state;

  Future<void> _pickRecipe(BuildContext context) async {
    final recipes = state.recipes;
    if (recipes.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Opret først en opskrift')));
      return;
    }
    final id = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          for (final recipe in recipes)
            ListTile(
              title: Text(recipe.name),
              onTap: () => Navigator.of(context).pop(recipe.id),
            ),
        ],
      ),
    );
    if (id != null) state.addToPlan(id);
  }

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ryd madplanen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuller'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Ryd'),
          ),
        ],
      ),
    );
    if (confirmed == true) state.clearPlan();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state,
    builder: (context, _) {
      final plan = state.planRecipes;
      return Scaffold(
        appBar: AppBar(
          title: const Text('Madplan'),
          actions: [
            if (plan.isNotEmpty)
              IconButton(
                tooltip: 'Ryd madplan',
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: () => _confirmClear(context),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _pickRecipe(context),
          icon: const Icon(Icons.add),
          label: const Text('Tilføj dag'),
        ),
        body: plan.isEmpty
            ? const EmptyHint(
                'Madplanen er tom.\n'
                'Tilføj en ret for hver dag, du vil planlægge.',
              )
            : _PlanBody(state: state),
      );
    },
  );
}

class _PlanBody extends StatelessWidget {
  const _PlanBody({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final plan = state.planRecipes;
    final leftovers = state.leftovers;
    final suggestions = suggestRecipes(leftovers, state.recipes);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Spacing.m,
        Spacing.s,
        Spacing.m,
        Spacing.fabClearance,
      ),
      children: [
        for (final (index, recipe) in plan.indexed)
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Palette.sun,
                foregroundColor: Palette.espresso,
                child: Text('${index + 1}'),
              ),
              title: Text(
                recipe.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              subtitle: Text('Dag ${index + 1}'),
              trailing: IconButton(
                tooltip: 'Fjern fra madplan',
                icon: const Icon(Icons.close),
                onPressed: () => state.removeFromPlan(index),
              ),
            ),
          ),
        const SectionTitle('Til overs efter madplanen'),
        Text(
          'Beregnet ud fra dit køleskab og pakningsstørrelserne '
          'på indkøbslisten.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: Spacing.s),
        if (leftovers.isEmpty)
          const Text('Intet til overs – alt bliver brugt.')
        else
          Wrap(
            spacing: Spacing.s,
            runSpacing: Spacing.s,
            children: [
              for (final entry in leftovers.entries)
                Chip(label: Text(formatItem(entry.key, entry.value))),
            ],
          ),
        if (leftovers.isNotEmpty) ...[
          const SectionTitle('Forslag til resterne'),
          if (suggestions.isEmpty)
            const Text('Ingen af dine opskrifter bruger resterne endnu.'),
          for (final suggestion in suggestions)
            SuggestionCard(
              suggestion: suggestion,
              onAddToPlan: () => state.addToPlan(suggestion.recipe.id),
            ),
        ],
      ],
    );
  }
}
