// Módulo 2.7 · Localización y mapas (FR-008).
// Qué muestra: GPS real (geolocator) + mapa interactivo (google_maps_flutter)
// con flujo de permiso explicado. Sin permiso/señal/key → fallback
// ilustrativo con badge SIMULADO (FR-013).
//
// API key: demo restringida en AndroidManifest (reemplazable por key propia,
// ver README del módulo y research.md §1).
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../shared/services/permisos_service.dart';
import '../../shared/services/sensores_fallback.dart';
import '../../shared/widgets/concepto_card.dart';
import '../../shared/widgets/error_contenido.dart';
import '../../shared/widgets/simulado_badge.dart';
import 'widgets/mapa_demo.dart';

/// Pantalla del módulo 2.7.
class Modulo27MapasScreen extends StatefulWidget {
  const Modulo27MapasScreen({super.key});

  @override
  State<Modulo27MapasScreen> createState() => _Modulo27MapasScreenState();
}

class _Modulo27MapasScreenState extends State<Modulo27MapasScreen> {
  /// Posición real obtenida (null = aún sin localizar o fallback).
  Position? _posicion;

  /// `true` → datos reales; `false` → fallback ilustrativo.
  bool _esReal = false;

  /// Nota visible del estado del permiso / GPS.
  String _notaPermiso = 'Pulsa "Localizarme" para ver tu posición en el mapa.';

  /// Error contenido en esta pantalla (FR-012).
  String? _error;

  /// Pide permiso con explicación previa y lee el GPS real.
  Future<void> _localizar() async {
    setState(() => _error = null);
    try {
      final permiso = await PermisosService().solicitarUbicacion();
      if (!mounted) return;
      if (!permiso.concedido) {
        // Fallback etiquetado cuando se deniega el permiso (FR-008/FR-013).
        setState(() {
          _esReal = false;
          _posicion = null;
          _notaPermiso = permiso.mensaje;
        });
        return;
      }
      final posicion = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _esReal = true;
        _posicion = posicion;
        _notaPermiso =
            'Ubicación real con precisión de ${posicion.accuracy.toStringAsFixed(0)} m.';
      });
    } catch (e) {
      if (!mounted) return;
      // Sin señal/GPS → fallback ilustrativo, sin romper la pantalla.
      setState(() {
        _esReal = false;
        _posicion = null;
        _notaPermiso =
            'Sin señal de GPS: se muestra la posición ilustrativa de ejemplo.';
        _error = 'No se pudo obtener la posición real: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Centro: posición real o punto ilustrativo (CDMX, ver sensores_fallback).
    final centro = _posicion == null
        ? const LatLng(
            PosicionSimulada.latitud, PosicionSimulada.longitud)
        : LatLng(_posicion!.latitude, _posicion!.longitude);
    final textoCoords = _posicion == null
        ? PosicionSimulada.texto
        : '${_posicion!.latitude.toStringAsFixed(4)}, '
            '${_posicion!.longitude.toStringAsFixed(4)}';

    return Scaffold(
      appBar: AppBar(title: const Text('2.7 · Localización y mapas')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ConceptoCard(
                queEs:
                    'La localización (GPS) dice dónde está el dispositivo. '
                    'El mapa interactivo muestra esa posición y permite '
                    'explorarla con gestos.',
                paraQueSirve:
                    'En desarrollo móvil sirve para reparto, transporte o '
                    'turismo (p. ej. mostrar tu ubicación en un mapa). '
                    'Requiere permiso de ubicación.',
                ejemploUso:
                    'Lee la nota de permisos, pulsa "Localizarme" y observa '
                    'el mapa: con permiso verás tu posición real; sin '
                    'permiso, el ejemplo simulado.',
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
                  Expanded(child: Text(textoCoords)),
                ],
              ),
              const SizedBox(height: 8),
              Text(_notaPermiso),
              const SizedBox(height: 12),
              MapaDemo(centro: centro, esReal: _esReal),
              const SizedBox(height: 12),
              Semantics(
                button: true,
                label: 'Localizarme en el mapa',
                child: ElevatedButton(
                  onPressed: _localizar,
                  child: const Text('Localizarme'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
