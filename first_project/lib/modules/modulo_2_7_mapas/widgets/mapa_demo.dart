// Mapa de la demo de localización (módulo 2.7).
// Mapa interactivo real centrado en [centro]; si no hay datos reales,
// el badge SIMULADO de la pantalla indica el modo ilustrativo.
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Mapa interactivo de la demo 2.7.
class MapaDemo extends StatelessWidget {
  const MapaDemo({required this.centro, required this.esReal, super.key});

  /// Punto central del mapa (real o ilustrativo).
  final LatLng centro;

  /// Si es `false`, la pantalla muestra el badge SIMULADO.
  final bool esReal;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition:
              CameraPosition(target: centro, zoom: 14),
          markers: {
            Marker(
              markerId: const MarkerId('demo'),
              position: centro,
              infoWindow: InfoWindow(
                title: esReal ? 'Tu posición real' : 'Posición ilustrativa',
              ),
            ),
          },
          myLocationEnabled: esReal,
          myLocationButtonEnabled: esReal,
        ),
      ),
    );
  }
}
