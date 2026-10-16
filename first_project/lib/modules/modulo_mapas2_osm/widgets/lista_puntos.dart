// Lista editable de puntos + información del recorrido (módulo mapas2).
import 'package:flutter/material.dart';

import '../models/punto_mapa.dart';

/// Muestra los puntos en orden de visita con borrado y el dato de la ruta.
class ListaPuntos extends StatelessWidget {
  const ListaPuntos({
    required this.puntos,
    this.ruta,
    this.onBorrar,
    super.key,
  });

  final List<PuntoMapa> puntos;
  final RutaMapa? ruta;
  final ValueChanged<String>? onBorrar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ruta != null)
          Container(
            key: const Key('mapas2-info-recorrido'),
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Orden: ${puntos.map((p) => 'P${puntos.indexOf(p) + 1}').join(' → ')}'
              ' · Distancia: ${ruta!.distanciaTexto}'
              '${ruta!.modo == ModoRuta.calles ? ' · Ruta por © OpenStreetMap contributors · OSRM' : ''}',
            ),
          ),
        if (puntos.isEmpty)
          const Text(
            'Sin puntos: toca el mapa o usa "Agregar ejemplos".',
          ),
        for (final punto in puntos)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                child: Text('P${puntos.indexOf(punto) + 1}'),
              ),
              title: Text(punto.titulo),
              subtitle: punto.descripcion.isEmpty
                  ? null
                  : Text(punto.descripcion),
              trailing: IconButton(
                key: Key('mapas2-borrar-${punto.id}'),
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Borrar ${punto.titulo}',
                onPressed: () => onBorrar?.call(punto.id),
              ),
            ),
          ),
      ],
    );
  }
}
