// Módulo 2.6 · Gestos (FR-007).
// Qué muestra: GestureDetector detecta toque, doble toque, pulsación
// larga y deslizamiento (con dirección) en una zona dedicada.
// Demo: zona táctil que identifica el último gesto en texto visible.
import 'package:flutter/material.dart';

import '../../shared/widgets/concepto_card.dart';
import '../../shared/widgets/error_contenido.dart';
import 'widgets/zona_gestos.dart';

/// Pantalla del módulo 2.6.
class Modulo26GestosScreen extends StatefulWidget {
  const Modulo26GestosScreen({super.key});

  @override
  State<Modulo26GestosScreen> createState() => _Modulo26GestosScreenState();
}

class _Modulo26GestosScreenState extends State<Modulo26GestosScreen> {
  /// Último gesto identificado (null = aún sin interactuar).
  String? _ultimoGesto;

  /// Detalle extra (dirección del swipe o posición del toque).
  String _detalle = '';

  /// Error contenido en esta pantalla (FR-012).
  String? _error;

  void _registrar(String gesto, [String detalle = '']) {
    try {
      setState(() {
        _ultimoGesto = gesto;
        _detalle = detalle;
      });
    } catch (e) {
      setState(() => _error = 'No se pudo registrar el gesto: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('2.6 · Gestos')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ConceptoCard(
                queEs:
                    'Los gestos son toques sobre la pantalla: toque simple, '
                    'doble toque, pulsación larga y deslizamiento (swipe). '
                    'GestureDetector los detecta en una zona.',
                paraQueSirve:
                    'En desarrollo móvil sirven para interactuar sin botones: '
                    'abrir con un toque, acercar con doble toque o borrar '
                    'deslizando.',
                ejemploUso:
                    'Toca, toca dos veces, mantén pulsado o desliza dentro '
                    'de la zona: la pantalla identifica cada gesto.',
              ),
              const SizedBox(height: 12),
              if (_error != null) ...[
                ErrorContenido(mensaje: _error!),
                const SizedBox(height: 12),
              ],
              Text(
                _ultimoGesto == null
                    ? 'Último gesto: (interactúa con la zona)'
                    : 'Último gesto: $_ultimoGesto$_detalle',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ZonaGestos(onGesto: _registrar),
            ],
          ),
        ),
      ),
    );
  }
}
