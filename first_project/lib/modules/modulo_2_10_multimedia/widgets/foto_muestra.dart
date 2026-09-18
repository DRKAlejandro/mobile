// Muestra la foto capturada (módulo 2.10).
// Si aún no hay foto, muestra un marcador ilustrativo.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Vista previa de la foto real o marcador de ejemplo.
class FotoMuestra extends StatelessWidget {
  const FotoMuestra({required this.foto, super.key});

  /// Foto capturada (null = aún sin capturar).
  final XFile? foto;

  @override
  Widget build(BuildContext context) {
    if (foto == null) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Aún sin foto: pulsa "Tomar foto".',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(File(foto!.path), height: 220, fit: BoxFit.cover),
    );
  }
}
