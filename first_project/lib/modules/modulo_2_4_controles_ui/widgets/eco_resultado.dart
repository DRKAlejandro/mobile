// Resultado visible del eco de texto (módulo 2.4).
// Muestra lo que el usuario escribió al pulsar el botón.
import 'package:flutter/material.dart';

/// Etiqueta + texto reflejado por la demo de Input/Button.
class EcoResultado extends StatelessWidget {
  const EcoResultado({required this.texto, super.key});

  /// Texto a mostrar (vacío = aún sin interactuar).
  final String texto;

  @override
  Widget build(BuildContext context) {
    if (texto.isEmpty) {
      return const Text('Resultado: (pulsa "Mostrar" para ver tu texto)');
    }
    return Text(
      'Resultado: $texto',
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
