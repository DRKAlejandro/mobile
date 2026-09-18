// Bloque reutilizable de explicación (FR-003):
// qué es el concepto, para qué sirve y un ejemplo de uso práctico.
import 'package:flutter/material.dart';

/// Tarjeta de explicación con las 3 partes obligatorias.
class ConceptoCard extends StatelessWidget {
  const ConceptoCard({
    required this.queEs,
    required this.paraQueSirve,
    required this.ejemploUso,
    super.key,
  });

  /// Qué es el concepto (2–4 líneas, vocabulario sencillo).
  final String queEs;

  /// Para qué sirve en desarrollo móvil + 1 caso real.
  final String paraQueSirve;

  /// Ejemplo práctico paso a paso observable en la demo.
  final String ejemploUso;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Seccion(titulo: '¿Qué es?', texto: queEs),
            const SizedBox(height: 12),
            _Seccion(titulo: '¿Para qué sirve?', texto: paraQueSirve),
            const SizedBox(height: 12),
            _Seccion(titulo: 'Ejemplo de uso', texto: ejemploUso),
          ],
        ),
      ),
    );
  }
}

/// Una sección título + texto de la tarjeta de concepto.
class _Seccion extends StatelessWidget {
  const _Seccion({required this.titulo, required this.texto});

  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(texto),
      ],
    );
  }
}
