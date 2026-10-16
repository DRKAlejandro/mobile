// Servicio de rutas del módulo mapas2.
//
// Dos modos: recta (Haversine local, siempre disponible) y calles
// (OSRM público vía package:http, con fallback a recta si falla).
import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/punto_mapa.dart';

/// Resultado de una petición de ruta vial.
class ResultadoRutaVial {
  const ResultadoRutaVial({
    required this.trazado,
    required this.distanciaM,
    this.error,
  });

  final List<LatLng> trazado;
  final double distanciaM;

  /// null = éxito; texto = motivo del fallo (para el aviso en UI).
  final String? error;
}

/// Calcula rutas rectas y viales (OSRM) entre puntos.
class RutaOsmService {
  RutaOsmService({http.Client? cliente}) : _cliente = cliente ?? http.Client();

  final http.Client _cliente;

  /// Distancia Haversine en metros entre dos coordenadas.
  static double haversineM(LatLng a, LatLng b) {
    const radioTierraM = 6371000.0;
    final dLat = _radianes(b.latitude - a.latitude);
    final dLng = _radianes(b.longitude - a.longitude);
    final lat1 = _radianes(a.latitude);
    final lat2 = _radianes(b.latitude);
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLng / 2) * math.sin(dLng / 2);
    return 2 * radioTierraM * math.asin(math.sqrt(h));
  }

  /// Suma Haversine del recorrido en orden de visita.
  static double distanciaRectaM(List<PuntoMapa> puntos) {
    var total = 0.0;
    for (var i = 1; i < puntos.length; i++) {
      total += haversineM(
        puntos[i - 1].posicion,
        puntos[i].posicion,
      );
    }
    return total;
  }

  /// Crea la ruta recta local (siempre disponible, sin red).
  static RutaMapa rutaRecta(List<PuntoMapa> puntos) {
    if (puntos.length < 2) {
      throw ArgumentError('Se requieren al menos 2 puntos');
    }
    return RutaMapa(
      puntoIds: puntos.map((p) => p.id).toList(),
      trazado: puntos.map((p) => p.posicion).toList(),
      distanciaM: distanciaRectaM(puntos),
      modo: ModoRuta.recta,
    );
  }

  /// Pide la ruta vial real a OSRM; en fallo devuelve [error] para el aviso.
  Future<ResultadoRutaVial> rutaVial(List<PuntoMapa> puntos) async {
    if (puntos.length < 2) {
      return const ResultadoRutaVial(
        trazado: [],
        distanciaM: 0,
        error: 'Agrega al menos 2 puntos para trazar la ruta.',
      );
    }
    final coords =
        puntos.map((p) => '${p.longitud},${p.latitud}').join(';');
    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/$coords'
      '?overview=full&geometries=geojson&steps=false',
    );
    try {
      final respuesta = await _cliente
          .get(
            uri,
            headers: {'User-Agent': 'first_project-mapas2-didactico/1.0'},
          )
          .timeout(const Duration(seconds: 10));
      if (respuesta.statusCode != 200) {
        return const ResultadoRutaVial(
          trazado: [],
          distanciaM: 0,
          error: 'Servicio de rutas no disponible: se conserva la recta.',
        );
      }
      final cuerpo = jsonDecode(respuesta.body) as Map<String, dynamic>;
      if (cuerpo['code'] != 'Ok') {
        return const ResultadoRutaVial(
          trazado: [],
          distanciaM: 0,
          error: 'Sin ruta vial entre esos puntos: se conserva la recta.',
        );
      }
      final rutas = cuerpo['routes'] as List<dynamic>;
      if (rutas.isEmpty) {
        return const ResultadoRutaVial(
          trazado: [],
          distanciaM: 0,
          error: 'Sin ruta vial entre esos puntos: se conserva la recta.',
        );
      }
      final primera = rutas.first as Map<String, dynamic>;
      final geometria = primera['geometry'] as Map<String, dynamic>;
      final coordsJson = geometria['coordinates'] as List<dynamic>;
      final trazado = coordsJson
          .map((c) => LatLng(
                (c[1] as num).toDouble(),
                (c[0] as num).toDouble(),
              ))
          .toList();
      return ResultadoRutaVial(
        trazado: trazado,
        distanciaM: (primera['distance'] as num).toDouble(),
      );
    } catch (_) {
      return const ResultadoRutaVial(
        trazado: [],
        distanciaM: 0,
        error: 'Sin conexión al servicio de rutas: se conserva la recta.',
      );
    }
  }

  static double _radianes(double grados) => grados * math.pi / 180;
}
