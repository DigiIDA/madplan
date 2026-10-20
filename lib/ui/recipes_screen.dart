import 'package:flutter/material.dart';

import '../domain/models.dart';
import '../state/app_state.dart';
import 'recipe_edit_screen.dart';
import 'theme.dart';
import 'widgets.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key, required this.state});

  final AppState state;

  void _openEditor(BuildContext context, Recipe? recipe) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => RecipeEditScreen(state: state, recipe: recipe),
        ),
      );

  void _addToPlan(BuildContext context, Recipe recipe) {
    state.addToPlan(recipe.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${recipe.name} er lagt på madplanen')),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Opskrifter')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _openEditor(context, null),
      icon: const Icon(Icons.add),
      label: const Text('Ny opskrift'),
    ),
    body: ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final recipes = state.recipes;
        if (recipes.isEmpty) {
          return const EmptyHint(
            'Ingen opskrifter endnu.\n'
            'Tryk på "Ny opskrift" for at komme i gang.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            Spacing.m,
            Spacing.s,
            Spacing.m,
            Spacing.fabClearance,
          ),
          itemCount: recipes.length,
          separatorBuilder: (_, _) => const SizedBox(height: Spacing.s),
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return Card(
              child: ListTile(
                title: Text(
                  recipe.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                subtitle: Text(
                  '${recipe.ingredients.length} ingredienser · '
                  '${recipe.servings} pers.',
                ),
                onTap: () => _openEditor(context, recipe),
                trailing: IconButton(
                  tooltip: 'Læg på madplan',
                  icon: const Icon(Icons.playlist_add, color: Palette.teal),
                  onPressed: () => _addToPlan(context, recipe),
                ),
              ),
            );
          },
        );
      },
    ),
  );
}
