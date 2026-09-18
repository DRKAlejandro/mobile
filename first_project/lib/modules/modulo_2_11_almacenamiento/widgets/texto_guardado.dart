// Tarjeta que muestra el texto guardado (módulo 2.11).
// Si existe valor previo al abrir, es la prueba de persistencia.
import 'package:flutter/material.dart';

/// Caja con el texto recuperado de las preferencias.
class TextoGuardado extends StatelessWidget {
  const TextoGuardado({
    required this.texto,
    required this.esPrevio,
    super.key,
  });

  /// Texto guardado (vacío = aún sin guardar).
  final String texto;

  /// `true` si el valor ya existía al abrir (persistió entre sesiones).
  final bool esPrevio;

  @override
  Widget build(BuildContext context) {
    if (texto.isEmpty) {
      return const Text('Guardado: (escribe y pulsa "Guardar")');
    }
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Guardado: $texto',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: scheme.onPrimaryContainer,
            ),
          ),
          if (esPrevio)
            Text(
              'Este valor persistió desde la sesión anterior.',
              style: TextStyle(color: scheme.onPrimaryContainer),
            ),
        ],
      ),
    );
  }
}
