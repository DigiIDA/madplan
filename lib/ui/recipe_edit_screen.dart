import 'package:flutter/material.dart';

import '../domain/format.dart';
import '../domain/models.dart';
import '../domain/parse.dart';
import '../state/app_state.dart';
import 'theme.dart';
import 'widgets.dart';

const _ingredientLines = 6;
const _instructionLines = 4;

class RecipeEditScreen extends StatefulWidget {
  const RecipeEditScreen({super.key, required this.state, this.recipe});

  final AppState state;
  final Recipe? recipe;

  @override
  State<RecipeEditScreen> createState() => _RecipeEditScreenState();
}

class _RecipeEditScreenState extends State<RecipeEditScreen> {
  late final _name = TextEditingController(text: widget.recipe?.name);
  late final _ingredients = TextEditingController(
    text: widget.recipe?.ingredients.map(formatIngredient).join('\n'),
  );
  late final _instructions = TextEditingController(
    text: widget.recipe?.instructions,
  );
  late var _servings = widget.recipe?.servings ?? defaultServings;

  @override
  void dispose() {
    _name.dispose();
    _ingredients.dispose();
    _instructions.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    final ingredients = parseIngredients(_ingredients.text);
    if (name.isEmpty || ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giv opskriften et navn og mindst én ingrediens'),
        ),
      );
      return;
    }
    widget.state.saveRecipe(
      Recipe(
        id: widget.recipe?.id ?? newId(),
        name: name,
        ingredients: ingredients,
        instructions: _instructions.text.trim(),
        servings: _servings,
      ),
    );
    Navigator.of(context).pop();
  }

  Future<void> _delete(Recipe recipe) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Slet ${recipe.name}?'),
        content: const Text('Retten fjernes også fra madplanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuller'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Palette.rust),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Slet'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    widget.state.deleteRecipe(recipe.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe == null ? 'Ny opskrift' : 'Rediger'),
        actions: [
          if (recipe != null)
            IconButton(
              tooltip: 'Slet opskrift',
              icon: const Icon(Icons.delete_outline, color: Palette.rust),
              onPressed: () => _delete(recipe),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.m),
        children: [
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Navn på retten'),
          ),
          const SizedBox(height: Spacing.s),
          Row(
            children: [
              const Expanded(child: Text('Opskriften er til')),
              ServingsStepper(
                value: _servings,
                onChanged: (value) => setState(() => _servings = value),
              ),
            ],
          ),
          const SizedBox(height: Spacing.s),
          TextField(
            controller: _ingredients,
            minLines: _ingredientLines,
            maxLines: null,
            decoration: const InputDecoration(
              labelText: 'Ingredienser',
              hintText: '100 g gulerødder\n2 dl mælk\n3 æg',
              helperText: 'Én ingrediens pr. linje',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: Spacing.s),
          ListenableBuilder(
            listenable: _ingredients,
            builder: (context, _) => Wrap(
              spacing: Spacing.s,
              runSpacing: Spacing.s,
              children: [
                for (final item in parseIngredients(_ingredients.text))
                  Chip(label: Text(formatIngredient(item))),
              ],
            ),
          ),
          const SizedBox(height: Spacing.m),
          TextField(
            controller: _instructions,
            minLines: _instructionLines,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Fremgangsmåde (valgfri)',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: Spacing.l),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: const Text('Gem opskrift'),
          ),
        ],
      ),
    );
  }
}
