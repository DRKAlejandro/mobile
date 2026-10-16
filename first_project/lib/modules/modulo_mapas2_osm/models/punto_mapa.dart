// Modelo de datos del módulo mapas2 (solo sesión, sin persistencia).
//
// PuntoMapa: marcador agregado por toque, ejemplo o lista manual.
// RutaMapa: conexión ordenada entre >=2 puntos en modo recta o calles.
import 'package:latlong2/latlong.dart';

/// Origen didáctico del punto (cómo se creó).
enum OrigenPunto { toque, ejemplo, manual }

/// Modo de trazado de la ruta.
enum ModoRuta { recta, calles }

/// Estado de la ruta (el modo calles pasa por cargando/error).
enum EstadoRuta { ok, cargando, error }

/// Centro inicial didáctico: San Luis Potosí, SLP.
abstract final class CentroSlp {
  static const double latitud = 22.1565;
  static const double longitud = -100.9855;
  static const double zoom = 13.0;

  static LatLng get posicion => const LatLng(latitud, longitud);
}

/// Punto de interés sobre el mapa.
class PuntoMapa {
  PuntoMapa({
    required this.id,
    required this.latitud,
    required this.longitud,
    required String titulo,
    this.descripcion = '',
    this.origen = OrigenPunto.toque,
  }) : titulo = titulo.trim().isEmpty
            ? 'Punto ${id.replaceAll(RegExp('[^0-9]'), '')}'
            : titulo.trim().length > 60
                ? titulo.trim().substring(0, 60)
                : titulo.trim() {
    if (latitud < -90 || latitud > 90) {
      throw ArgumentError('Latitud fuera de rango: $latitud');
    }
    if (longitud < -180 || longitud > 180) {
      throw ArgumentError('Longitud fuera de rango: $longitud');
    }
    if (descripcion.length > 200) {
      throw ArgumentError('Descripción de más de 200 caracteres');
    }
  }

  /// Identificador único en sesión (`p1`, `p2`...).
  final String id;
  final double latitud;
  final double longitud;

  /// Título no vacío, máx. 60 caracteres.
  final String titulo;
  final String descripcion;
  final OrigenPunto origen;

  LatLng get posicion => LatLng(latitud, longitud);
}

/// Ejemplos predefinidos de San Luis Potosí.
abstract final class PuntosEjemploSlp {
  static List<PuntoMapa> crear() => [
        PuntoMapa(
          id: 'p1',
          latitud: 22.1565,
          longitud: -100.9855,
          titulo: 'Centro Histórico',
          descripcion: 'Plaza principal de San Luis Potosí.',
          origen: OrigenPunto.ejemplo,
        ),
        PuntoMapa(
          id: 'p2',
          latitud: 22.1180,
          longitud: -101.0060,
          titulo: 'Parque Tangamanga',
          descripcion: 'Área verde grande de la ciudad.',
          origen: OrigenPunto.ejemplo,
        ),
        PuntoMapa(
          id: 'p3',
          latitud: 22.1520,
          longitud: -100.9730,
          titulo: 'UASLP',
          descripcion: 'Universidad de ejemplo.',
          origen: OrigenPunto.ejemplo,
        ),
      ];
}

/// Conexión visual ordenada entre puntos.
class RutaMapa {
  const RutaMapa({
    required this.puntoIds,
    required this.trazado,
    required this.distanciaM,
    this.modo = ModoRuta.recta,
    this.estado = EstadoRuta.ok,
  });

  /// Ids en orden de visita (mínimo 2).
  final List<String> puntoIds;

  /// Puntos del trazado listos para Polyline.
  final List<LatLng> trazado;
  final double distanciaM;
  final ModoRuta modo;
  final EstadoRuta estado;

  /// Etiqueta didáctica de distancia (`1.2 km (estimada)` o `(vial)`).
  String get distanciaTexto {
    final km = distanciaM / 1000;
    final valor = km < 10
        ? km.toStringAsFixed(1)
        : km.toStringAsFixed(0);
    final tipo = modo == ModoRuta.calles ? 'vial' : 'estimada';
    return '$valor km ($tipo)';
  }
}
