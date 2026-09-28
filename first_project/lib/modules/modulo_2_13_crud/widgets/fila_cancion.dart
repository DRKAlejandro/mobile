// Widget del módulo 2.13 · Fila de canción en la lista.
// Estilo biblioteca musical: portada con gradiente + nota musical y la
// estrella de favorita (toggle, FR-008b) como insignia sobre la portada;
// editar/borrar al final de la fila.
import 'package:flutter/material.dart';

import '../models/cancion.dart';

/// Fila de la lista de canciones con acciones por registro.
class FilaCancion extends StatelessWidget {
  const FilaCancion({
    super.key,
    required this.cancion,
    required this.onFavorita,
    required this.onEditar,
    required this.onBorrar,
  });

  /// Canción a mostrar.
  final Cancion cancion;

  /// Toggle de favorita (nuevo valor deseado).
  final ValueChanged<bool> onFavorita;

  /// Abrir edición.
  final VoidCallback onEditar;

  /// Pedir borrado (la pantalla confirma, FR-007).
  final VoidCallback onBorrar;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final detalles = [
      if (cancion.album != null && cancion.album!.isNotEmpty) cancion.album!,
      if (cancion.anio != null) cancion.anio.toString(),
      if (cancion.duracionTexto.isNotEmpty) cancion.duracionTexto,
    ].join(' · ');

    return Card(
      child: ListTile(
        leading: Semantics(
          button: true,
          label: cancion.favorita
              ? 'Quitar de favoritas: ${cancion.titulo}'
              : 'Marcar favorita: ${cancion.titulo}',
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onFavorita(!cancion.favorita),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6D28D9), Color(0xFFEC4899)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.music_note, color: Colors.white),
                ),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    cancion.favorita ? Icons.star : Icons.star_border,
                    size: 18,
                    color: cancion.favorita
                        ? Colors.amber.shade700
                        : scheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
        title: Text(
          cancion.titulo,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(cancion.artista),
            if (detalles.isNotEmpty)
              Text(detalles, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              button: true,
              label: 'Editar ${cancion.titulo}',
              child: IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: onEditar,
              ),
            ),
            Semantics(
              button: true,
              label: 'Eliminar ${cancion.titulo}',
              child: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onBorrar,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
