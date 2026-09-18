// Módulo 2.9 · Red, batería y vibración (FR-010).
// Qué muestra: estado de red (connectivity_plus), nivel/estado de batería
// (battery_plus) y vibración con comprobación previa (vibration).
// Sin hardware/permiso → fallbacks ilustrativos con badge SIMULADO.
import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../../shared/services/sensores_fallback.dart';
import '../../shared/widgets/concepto_card.dart';
import '../../shared/widgets/error_contenido.dart';
import '../../shared/widgets/simulado_badge.dart';
import 'widgets/estado_tarjeta.dart';

/// Pantalla del módulo 2.9.
class Modulo29EstadoScreen extends StatefulWidget {
  const Modulo29EstadoScreen({super.key});

  @override
  State<Modulo29EstadoScreen> createState() => _Modulo29EstadoScreenState();
}

class _Modulo29EstadoScreenState extends State<Modulo29EstadoScreen> {
  /// Estado actual de conectividad (vacío = aún sin leer).
  List<ConnectivityResult> _red = [];

  /// Nivel de batería 0–100 (null = aún sin leer → fallback).
  int? _bateria;

  /// Estado de carga (null = aún sin leer).
  BatteryState? _estadoBateria;

  /// `true` si cada lectura es real (vs. fallback simulado).
  bool _redReal = false;
  bool _bateriaReal = false;

  /// Error contenido en esta pantalla (FR-012).
  String? _error;

  StreamSubscription<List<ConnectivityResult>>? _subRed;
  final Battery _battery = Battery();

  @override
  void initState() {
    super.initState();
    _leerEstadoInicial();
    try {
      _subRed = Connectivity().onConnectivityChanged.listen((estado) {
        if (!mounted) return;
        setState(() {
          _red = estado;
          _redReal = true;
        });
      });
    } catch (e) {
      setState(() => _error = 'No se pudo escuchar la red: $e');
    }
  }

  /// Lee red + batería una vez al abrir (con fallback etiquetado).
  Future<void> _leerEstadoInicial() async {
    try {
      final red = await Connectivity().checkConnectivity();
      if (!mounted) return;
      setState(() {
        _red = red;
        _redReal = true;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Red no disponible: $e');
      }
    }
    try {
      final nivel = await _battery.batteryLevel;
      final estado = await _battery.batteryState;
      if (!mounted) return;
      setState(() {
        _bateria = nivel;
        _estadoBateria = estado;
        _bateriaReal = true;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Batería no disponible: $e');
      }
    }
  }

  /// Vibra 500 ms si el dispositivo tiene vibrador (con check previo).
  Future<void> _vibrar() async {
    setState(() => _error = null);
    try {
      final tiene = await Vibration.hasVibrator();
      if (!mounted) return;
      if (tiene != true) {
        // Fallback explicativo cuando no hay vibrador (FR-010/FR-013).
        setState(() => _error = EstadoSimulado.sinVibrador);
        return;
      }
      await Vibration.vibrate(duration: 500);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vibración real de 500 ms')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'No se pudo vibrar: $e');
      }
    }
  }

  @override
  void dispose() {
    // Liberar la suscripción de red (patrón de ciclo de vida).
    _subRed?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textoRed =
        _red.isEmpty ? EstadoSimulado.red : _red.map((r) => r.name).join(', ');
    final textoBateria = _bateria == null
        ? '${EstadoSimulado.bateria}% (simulado)'
        : '$_bateria%${_estadoBateria == BatteryState.charging ? " (cargando)" : ""}';

    return Scaffold(
      appBar: AppBar(title: const Text('2.9 · Red, batería y vibración')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ConceptoCard(
                queEs:
                    'El móvil informa su estado: tipo de red (Wi-Fi/datos), '
                    'nivel y carga de batería, y si puede vibrar.',
                paraQueSirve:
                    'En desarrollo móvil sirve para ahorrar datos o batería '
                    '(p. ej. no descargar video sin Wi-Fi) y para avisar '
                    'con vibración.',
                ejemploUso:
                    'Observa tu red y batería reales; pulsa "Vibrar 500 ms" '
                    'y comprueba la vibración o el mensaje alternativo.',
              ),
              const SizedBox(height: 12),
              if (_error != null) ...[
                ErrorContenido(mensaje: _error!),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  SimuladoBadge(esReal: _redReal),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Red: $textoRed')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  SimuladoBadge(esReal: _bateriaReal),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Batería: $textoBateria')),
                ],
              ),
              const SizedBox(height: 12),
              EstadoTarjeta(
                red: textoRed,
                bateria: textoBateria,
              ),
              const SizedBox(height: 12),
              Semantics(
                button: true,
                label: 'Vibrar durante 500 milisegundos',
                child: ElevatedButton(
                  onPressed: _vibrar,
                  child: const Text('Vibrar 500 ms'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
