// Mapa OpenStreetMap del módulo mapas2.
//
// Muestra teselas OSM (sin API key), marcadores de puntos, línea de ruta
// y posición GPS opcional. El toque sobre el mapa crea puntos (P2) y el
// toque sobre un marcador muestra su información.
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/punto_mapa.dart';

/// Mapa interactivo con capas OSM + marcadores + ruta.
class MapaOsm extends StatelessWidget {
  const MapaOsm({
    required this.centro,
    required this.puntos,
    this.ruta,
    this.ubicacionReal,
    this.onTapMapa,
    this.onTapPunto,
    this.controller,
    super.key,
  });

  /// Centro inicial (SLP) o última posición centrada.
  final LatLng centro;

  /// Puntos de la sesión en orden de visita.
  final List<PuntoMapa> puntos;

  /// Ruta trazada (recta o vial) o null si no hay.
  final RutaMapa? ruta;

  /// Posición GPS real (null = solo punto fijo SLP).
  final LatLng? ubicacionReal;

  /// Se llama al tocar el mapa (crea un punto).
  final ValueChanged<LatLng>? onTapMapa;

  /// Se llama al tocar un marcador (muestra su info).
  final ValueChanged<PuntoMapa>? onTapPunto;

  final MapController? controller;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: centro,
        initialZoom: CentroSlp.zoom,
        onTap: (pos, latLng) => onTapMapa?.call(latLng),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.first_project',
        ),
        if (ruta != null && ruta!.trazado.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: ruta!.trazado,
                color: ruta!.modo == ModoRuta.calles
                    ? Colors.blue
                    : Colors.deepOrange,
                strokeWidth: 4,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            if (ubicacionReal != null)
              Marker(
                point: ubicacionReal!,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.my_location,
                  color: Colors.blue,
                  size: 32,
                ),
              ),
            for (var i = 0; i < puntos.length; i++)
              Marker(
                point: puntos[i].posicion,
                width: 56,
                height: 56,
                child: GestureDetector(
                  key: Key('mapas2-marcador-${puntos[i].id}'),
                  onTap: () => onTapPunto?.call(puntos[i]),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.red.shade700,
                        size: 32,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade700),
                        ),
                        child: Text(
                          'P${i + 1}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const RichAttributionWidget(
          attributions: [
            TextSourceAttribution('© OpenStreetMap contributors'),
          ],
        ),
      ],
    );
  }
}
