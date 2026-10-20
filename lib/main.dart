import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'state/app_state.dart';
import 'ui/home_screen.dart';
import 'ui/theme.dart';

const _danish = Locale('da');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MadplanApp(state: AppState.load(prefs)));
}

class MadplanApp extends StatelessWidget {
  const MadplanApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Madplan',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    locale: _danish,
    supportedLocales: const [_danish],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: HomeScreen(state: state),
  );
}
