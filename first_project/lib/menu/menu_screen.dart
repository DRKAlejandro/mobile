// Pantalla del menú (US1, FR-001/FR-002):
// muestra las 7 tarjetas de módulos 2.3–2.9 desde el catálogo [kModulos].
// Cada tarjeta navega por ruta nombrada; volver preserva el scroll/estado.
import 'package:flutter/material.dart';

import 'module_catalog.dart';

/// Menú principal de la app.
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desarrollo móvil'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Módulos',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Toca una tarjeta para abrir su pantalla de detalle.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              for (final modulo in kModulos) _ModuloCard(modulo: modulo),
            ],
          ),
        ),
      ),
    );
  }
}

/// Una tarjeta por módulo: número, título, descripción e icono (FR-001).
class _ModuloCard extends StatelessWidget {
  const _ModuloCard({required this.modulo});

  final ModuloMenu modulo;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      // Etiqueta semántica para lector de pantalla (contrato item 6).
      label: 'Módulo ${modulo.numero}: ${modulo.titulo}',
      button: true,
        child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          // Acento único amarillo chispa (004): avatar compartido.
          leading: CircleAvatar(
            backgroundColor:
                Theme.of(context).colorScheme.secondaryContainer,
            child: Icon(
              modulo.icono,
              size: 28,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
          title: Text('${modulo.numero} · ${modulo.titulo}'),
          subtitle: Text(modulo.descripcionCorta),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, modulo.ruta),
        ),
      ),
    );
  }
}
