// Módulo 2.8 · Acelerómetro (FR-009).
// Qué muestra: lecturas reales x/y/z del acelerómetro (sensors_plus)
// con muestreo reducido ~10 Hz y stream cancelado en dispose().
// Sin hardware (emulador/web) → fallback ilustrativo con badge SIMULADO.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../shared/services/sensores_fallback.dart';
import '../../shared/widgets/concepto_card.dart';
import '../../shared/widgets/error_contenido.dart';
import '../../shared/widgets/simulado_badge.dart';
import 'widgets/lectura_ejes.dart';

/// Pantalla del módulo 2.8.
class Modulo28AcelerometroScreen extends StatefulWidget {
  const Modulo28AcelerometroScreen({super.key});

  @override
  State<Modulo28AcelerometroScreen> createState() =>
      _Modulo28AcelerometroScreenState();
}

class _Modulo28AcelerometroScreenState
    extends State<Modulo28AcelerometroScreen> {
  /// Suscripción al acelerómetro (se cancela en dispose).
  StreamSubscription<AccelerometerEvent>? _suscripcion;

  /// Última lectura real (null = aún sin datos → fallback).
  AccelerometerEvent? _ultimo;

  /// `true` al recibir al menos una lectura real del hardware.
  bool _esReal = false;

  /// Instante de la última actualización de UI (throttling ~10 Hz).
  DateTime _ultimaUi = DateTime.fromMillisecondsSinceEpoch(0);

  /// Error contenido en esta pantalla (FR-012).
  String? _error;

  @override
  void initState() {
    super.initState();
    // Suscripción con throttling simple: la UI se actualiza ~10 Hz
    // aunque el sensor emita más rápido (performance goals del plan).
    try {
      _suscripcion = accelerometerEventStream().listen(
        (evento) {
          final ahora = DateTime.now();
          if (ahora.difference(_ultimaUi).inMilliseconds < 100) return;
          _ultimaUi = ahora;
          if (!mounted) return;
          setState(() {
            _ultimo = evento;
            _esReal = true;
          });
        },
        onError: (Object e) {
          if (!mounted) return;
          setState(() => _error = 'Sensor no disponible: $e');
        },
      );
    } catch (e) {
      _error = 'Sensor no disponible en este dispositivo: $e';
    }
  }

  @override
  void dispose() {
    // Patrón de ciclo de vida descrito en el README: liberar el stream.
    _suscripcion?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Valores visibles: reales o fallback ilustrativo etiquetado.
    final x = _ultimo?.x ?? AcelerometroSimulado.x;
    final y = _ultimo?.y ?? AcelerometroSimulado.y;
    final z = _ultimo?.z ?? AcelerometroSimulado.z;

    return Scaffold(
      appBar: AppBar(title: const Text('2.8 · Acelerómetro')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ConceptoCard(
                queEs:
                    'El acelerómetro mide la aceleración en tres ejes: X '
                    '(lados), Y (arriba/abajo) y Z (frente/atrás), en m/s². '
                    'Detecta cómo se mueve o inclina el móvil.',
                paraQueSirve:
                    'En desarrollo móvil sirve para juegos con movimiento, '
                    'contar pasos o rotar la pantalla (p. ej. inclinar para '
                    'manejar un juego de carreras).',
                ejemploUso:
                    'Inclina o mueve el dispositivo y observa los valores '
                    'X/Y/Z en vivo. En emulador verás el ejemplo simulado.',
              ),
              const SizedBox(height: 12),
              if (_error != null) ...[
                ErrorContenido(mensaje: _error!),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  SimuladoBadge(esReal: _esReal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _esReal
                          ? 'Lectura real del sensor en vivo (~10 Hz).'
                          : 'Sin hardware: valores ilustrativos de ejemplo.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LecturaEjes(x: x, y: y, z: z),
            ],
          ),
        ),
      ),
    );
  }
}
