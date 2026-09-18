// Resultado visible del diálogo de confirmación (módulo 2.3).
// Widget pequeño y comentado: muestra el estado actual de la demo.
import 'package:flutter/material.dart';

/// Texto que refleja si el diálogo se confirmó, descartó o sigue sin probar.
class ResultadoDialogo extends StatelessWidget {
  const ResultadoDialogo({required this.resultado, super.key});

  /// 'confirmado' | 'descartado' | null (sin probar).
  final String? resultado;

  @override
  Widget build(BuildContext context) {
    final texto = switch (resultado) {
      'confirmado' => 'Diálogo: confirmado ✓',
      'descartado' => 'Diálogo: descartado ✕',
      _ => 'Diálogo: aún sin probar',
    };
    return Text(texto, style: Theme.of(context).textTheme.titleMedium);
  }
}
