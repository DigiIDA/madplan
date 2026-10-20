import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../domain/backup.dart';
import '../state/app_state.dart';

enum _BackupAction { save, restore }

String _backupFileName() =>
    'madplan-opskrifter-${DateTime.now().toIso8601String().split('T').first}.json';

class BackupMenu extends StatelessWidget {
  const BackupMenu({super.key, required this.state});

  final AppState state;

  Future<void> _save(ScaffoldMessengerState messenger) async {
    final recipes = state.recipes;
    if (recipes.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Der er ingen opskrifter at gemme')),
      );
      return;
    }
    final saved = await FilePicker.saveFile(
      dialogTitle: 'Gem backup af opskrifter',
      fileName: _backupFileName(),
      bytes: utf8.encode(encodeBackup(recipes)),
      mimeType: 'application/json',
    );
    if (saved == null) return;
    messenger.showSnackBar(
      SnackBar(content: Text('Backup gemt med ${recipes.length} opskrifter')),
    );
  }

  Future<void> _restore(ScaffoldMessengerState messenger) async {
    final file = await FilePicker.pickFile(dialogTitle: 'Vælg backup');
    if (file == null) return;
    try {
      final recipes = decodeBackup(utf8.decode(await file.readAsBytes()));
      final count = state.importRecipes(recipes);
      messenger.showSnackBar(
        SnackBar(content: Text('$count opskrifter hentet fra backup')),
      );
    } on FormatException catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) => PopupMenuButton<_BackupAction>(
    tooltip: 'Backup',
    onSelected: (action) {
      final messenger = ScaffoldMessenger.of(context);
      switch (action) {
        case _BackupAction.save:
          unawaited(_save(messenger));
        case _BackupAction.restore:
          unawaited(_restore(messenger));
      }
    },
    itemBuilder: (_) => const [
      PopupMenuItem(
        value: _BackupAction.save,
        child: ListTile(
          leading: Icon(Icons.save_alt),
          title: Text('Gem backup'),
        ),
      ),
      PopupMenuItem(
        value: _BackupAction.restore,
        child: ListTile(
          leading: Icon(Icons.restore),
          title: Text('Hent backup'),
        ),
      ),
    ],
  );
}
