// Módulo mapas2 · Mapa con OpenStreetMap (sin API key).
//
// Qué muestra: mapa OSM interactivo centrado en SLP (P1), puntos en modo
// mixto: toque + ejemplos + lista (P2) y rutas conmutables recta/calles
// con distancia (P3). Estado solo-sesión: al salir todo se descarta.
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../shared/services/permisos_service.dart';
import '../../shared/widgets/concepto_card.dart';
import '../../shared/widgets/error_contenido.dart';
import 'models/punto_mapa.dart';
import 'services/ruta_osm_service.dart';
import 'widgets/lista_puntos.dart';
import 'widgets/mapa_osm.dart';

/// Pantalla del módulo mapas2.
class Mapas2OsmScreen extends StatefulWidget {
  const Mapas2OsmScreen({super.key, this.servicioRutas});

  /// Servicio inyectable (permite pruebas sin red).
  final RutaOsmService? servicioRutas;

  @override
  State<Mapas2OsmScreen> createState() => _Mapas2OsmScreenState();
}

class _Mapas2OsmScreenState extends State<Mapas2OsmScreen> {
  final MapController _controller = MapController();

  /// Puntos de la sesión en orden de visita.
  final List<PuntoMapa> _puntos = [];
  int _contador = 0;

  RutaMapa? _ruta;
  bool _modoCalles = false;
  bool _cargandoRuta = false;

  LatLng? _ubicacionReal;
  String _notaUbicacion =
      'Mapa centrado en San Luis Potosí. Pulsa "Mi ubicación" para ver tu posición real.';

  /// Aviso visible (sin internet, <2 puntos, OSRM caído, permiso).
  String? _aviso;

  RutaOsmService get _servicio =>
      widget.servicioRutas ?? RutaOsmService();

  /// Crea un punto por toque sobre el mapa (P2).
  void _agregarPorToque(LatLng posicion) {
    setState(() {
      _contador++;
      _puntos.add(PuntoMapa(
        id: 'p$_contador',
        latitud: posicion.latitude,
        longitud: posicion.longitude,
        titulo: 'Punto $_contador',
        descripcion:
            '${posicion.latitude.toStringAsFixed(4)}, ${posicion.longitude.toStringAsFixed(4)}',
        origen: OrigenPunto.toque,
      ));
      _aviso = null;
    });
  }

  /// Agrega los 3 ejemplos de SLP (P2).
  void _agregarEjemplos() {
    setState(() {
      for (final ejemplo in PuntosEjemploSlp.crear()) {
        _contador++;
        _puntos.add(PuntoMapa(
          id: 'p$_contador',
          latitud: ejemplo.latitud,
          longitud: ejemplo.longitud,
          titulo: ejemplo.titulo,
          descripcion: ejemplo.descripcion,
          origen: OrigenPunto.ejemplo,
        ));
      }
      _aviso = null;
    });
  }

  /// Muestra la información del punto (P2).
  void _verPunto(PuntoMapa punto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(punto.titulo),
        content: Text(
          punto.descripcion.isEmpty ? 'Sin descripción.' : punto.descripcion,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _borrarPunto(String id) {
    setState(() {
      _puntos.removeWhere((p) => p.id == id);
      if (_puntos.length < 2) _ruta = null;
    });
  }

  void _limpiarTodo() {
    setState(() {
      _puntos.clear();
      _ruta = null;
      _modoCalles = false;
      _aviso = null;
    });
  }

  /// Traza la recta local con distancia Haversine (P3, por defecto).
  void _trazarRecta() {
    if (_puntos.length < 2) {
      setState(() {
        _aviso = 'Agrega al menos 2 puntos para trazar la ruta.';
      });
      return;
    }
    setState(() {
      _ruta = RutaOsmService.rutaRecta(List.of(_puntos));
      _modoCalles = false;
      _aviso = null;
    });
  }

  /// Conmuta a ruta vial real (OSRM) con fallback a recta (P3).
  Future<void> _conmutarCalles(bool activas) async {
    if (_puntos.length < 2) {
      setState(() {
        _aviso = 'Agrega al menos 2 puntos para trazar la ruta.';
      });
      return;
    }
    if (!activas) {
      _trazarRecta();
      return;
    }
    setState(() {
      _modoCalles = true;
      _cargandoRuta = true;
      _aviso = null;
    });
    final resultado = await _servicio.rutaVial(List.of(_puntos));
    if (!mounted) return;
    setState(() {
      _cargandoRuta = false;
      if (resultado.error == null) {
        _ruta = RutaMapa(
          puntoIds: _puntos.map((p) => p.id).toList(),
          trazado: resultado.trazado,
          distanciaM: resultado.distanciaM,
          modo: ModoRuta.calles,
        );
      } else {
        // Fallback: se conserva la recta y se avisa (contrato OSRM).
        _modoCalles = false;
        _ruta = RutaOsmService.rutaRecta(List.of(_puntos));
        _aviso = resultado.error;
      }
    });
  }

  void _limpiarRuta() {
    setState(() {
      _ruta = null;
      _modoCalles = false;
    });
  }

  /// GPS híbrido: tiempo real si hay permiso, si no SLP fijo (P1).
  Future<void> _miUbicacion() async {
    setState(() => _aviso = null);
    try {
      final permiso = await PermisosService().solicitarUbicacion();
      if (!mounted) return;
      if (!permiso.concedido) {
        setState(() => _notaUbicacion = '${permiso.mensaje} Se mantiene SLP.');
        return;
      }
      final posicion = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      final destino = LatLng(posicion.latitude, posicion.longitude);
      setState(() {
        _ubicacionReal = destino;
        _notaUbicacion =
            'Ubicación real con precisión de ${posicion.accuracy.toStringAsFixed(0)} m.';
      });
      _controller.move(destino, 15);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _aviso = 'No se pudo obtener tu posición: $e. Se mantiene SLP.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapas2 · OpenStreetMap')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ConceptoCard(
                key: Key('mapas2-concepto'),
                queEs:
                    'OpenStreetMap es un mapa abierto y gratuito: muestra '
                    'calles sin necesidad de claves de pago. Se usa con '
                    'teselas (imágenes) que se cargan por internet.',
                paraQueSirve:
                    'En desarrollo móvil sirve para mostrar ubicaciones, '
                    'agregar puntos de interés y trazar rutas (reparto, '
                    'turismo o logística) sin depender de Google Maps.',
                ejemploUso:
                    'Toca el mapa para agregar puntos, usa "Agregar '
                    'ejemplos" para SLP, traza la recta y conmuta a "Ruta '
                    'por calles" para ver la diferencia.',
              ),
              const SizedBox(height: 12),
              Text(_notaUbicacion),
              const SizedBox(height: 12),
              if (_aviso != null) ...[
                ErrorContenido(
                  key: const Key('mapas2-aviso'),
                  mensaje: _aviso!,
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                height: 320,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MapaOsm(
                    key: const Key('mapas2-mapa'),
                    centro: _ubicacionReal ?? CentroSlp.posicion,
                    puntos: _puntos,
                    ruta: _ruta,
                    ubicacionReal: _ubicacionReal,
                    controller: _controller,
                    onTapMapa: _agregarPorToque,
                    onTapPunto: _verPunto,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '© OpenStreetMap contributors',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    key: const Key('mapas2-agregar-ejemplos'),
                    onPressed: _agregarEjemplos,
                    child: const Text('Agregar ejemplos'),
                  ),
                  ElevatedButton(
                    key: const Key('mapas2-trazar-recta'),
                    onPressed: _trazarRecta,
                    child: const Text('Trazar recta'),
                  ),
                  ElevatedButton(
                    key: const Key('mapas2-limpiar-ruta'),
                    onPressed: _limpiarRuta,
                    child: const Text('Limpiar ruta'),
                  ),
                  ElevatedButton(
                    key: const Key('mapas2-limpiar-todo'),
                    onPressed: _limpiarTodo,
                    child: const Text('Limpiar todo'),
                  ),
                  ElevatedButton(
                    key: const Key('mapas2-mi-ubicacion'),
                    onPressed: _miUbicacion,
                    child: const Text('Mi ubicación'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Ruta por calles'),
                  Switch(
                    key: const Key('mapas2-modo-calles'),
                    value: _modoCalles,
                    onChanged: _conmutarCalles,
                  ),
                  if (_cargandoRuta)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              ListaPuntos(
                key: const Key('mapas2-lista-puntos'),
                puntos: _puntos,
                ruta: _ruta,
                onBorrar: _borrarPunto,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
