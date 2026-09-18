// Error contenido por pantalla (FR-012):
// si una demo falla, se muestra un mensaje explicativo aquí
// sin romper el menú ni las demás pantallas.
import 'package:flutter/material.dart';

/// Caja de error local a la pantalla del módulo.
class ErrorContenido extends StatelessWidget {
  const ErrorContenido({required this.mensaje, super.key});

  /// Mensaje explicativo en español, en lenguaje claro.
  final String mensaje;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.error),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: scheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              mensaje,
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
