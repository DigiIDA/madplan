import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../domain/scan.dart';

const _spinnerSize = 24.0;
const _spinnerStroke = 2.5;

class ScanRecipeButton extends StatefulWidget {
  const ScanRecipeButton({super.key, required this.onScanned});

  final ValueChanged<ScannedRecipe> onScanned;

  @override
  State<ScanRecipeButton> createState() => _ScanRecipeButtonState();
}

class _ScanRecipeButtonState extends State<ScanRecipeButton> {
  var _scanning = false;

  Future<ImageSource?> _chooseSource() => showModalBottomSheet<ImageSource>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Tag billede'),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Vælg fra galleri'),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
        ],
      ),
    ),
  );

  Future<String> _recognise(String path) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(
        InputImage.fromFilePath(path),
      );
      return result.text;
    } finally {
      await recognizer.close();
    }
  }

  Future<void> _scan() async {
    final messenger = ScaffoldMessenger.of(context);
    final source = await _chooseSource();
    if (source == null) return;
    setState(() => _scanning = true);
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      final scanned = parseRecipeText(await _recognise(image.path));
      if (scanned.ingredientLines.isEmpty && scanned.instructions.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Kunne ikke læse en opskrift – prøv et skarpere billede',
            ),
          ),
        );
        return;
      }
      widget.onScanned(scanned);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Fandt ${scanned.ingredientLines.length} ingredienser – '
            'tjek og ret dem før du gemmer',
          ),
        ),
      );
    } on PlatformException catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Scanning fejlede: ${error.message}')),
      );
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  @override
  Widget build(BuildContext context) => _scanning
      ? const Padding(
          padding: EdgeInsets.all(_spinnerSize / 2),
          child: SizedBox.square(
            dimension: _spinnerSize,
            child: CircularProgressIndicator(strokeWidth: _spinnerStroke),
          ),
        )
      : IconButton(
          tooltip: 'Scan opskrift',
          icon: const Icon(Icons.document_scanner_outlined),
          onPressed: _scan,
        );
}
