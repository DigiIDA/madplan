import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:madplan/domain/models.dart';
import 'package:madplan/domain/parse.dart';
import 'package:madplan/main.dart';
import 'package:madplan/state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('bottom menu switches screens and pantry accepts input', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MadplanApp(state: AppState.load(prefs)));

    for (final label in ['Opskrifter', 'Madplan', 'Køleskab', 'Indkøb']) {
      expect(find.widgetWithText(NavigationDestination, label), findsOneWidget);
    }

    await tester.tap(find.widgetWithText(NavigationDestination, 'Køleskab'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '500 g pasta');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(InputChip, '500 g pasta'), findsOneWidget);
  });

  testWidgets('checked purchases move to the pantry with one tap', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final state = AppState.load(prefs)
      ..saveRecipe(
        Recipe(
          id: 'pasta',
          name: 'Pasta',
          ingredients: parseIngredients('400 g pasta'),
        ),
      )
      ..addToPlan('pasta');
    await tester.pumpWidget(MadplanApp(state: state));

    await tester.tap(find.widgetWithText(NavigationDestination, 'Indkøb'));
    await tester.pumpAndSettle();
    expect(find.byType(FloatingActionButton), findsNothing);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Læg 1 i køleskabet'));
    await tester.pumpAndSettle();

    expect(find.text('Du har alt, hvad madplanen kræver.'), findsOneWidget);
    expect(state.pantry.single.name, 'pasta');
  });
}
