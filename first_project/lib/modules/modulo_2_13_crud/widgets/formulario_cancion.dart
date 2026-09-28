// Widget del módulo 2.13 · Formulario de alta/edición de canción.
// Qué muestra: diálogo con título/artista obligatorios y álbum/año/
// duración/favorita opcionales, con validación local (FR-008).
// Devuelve la [Cancion] capturada o `null` si se cancela.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/cancion.dart';

/// Diálogo de alta (sin [original]) o edición (con [original]).
class FormularioCancion extends StatefulWidget {
  const FormularioCancion({super.key, this.original});

  /// Canción a editar (`null` = alta nueva).
  final Cancion? original;

  @override
  State<FormularioCancion> createState() => _FormularioCancionState();
}

class _FormularioCancionState extends State<FormularioCancion> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titulo;
  late final TextEditingController _artista;
  late final TextEditingController _album;
  late final TextEditingController _anio;
  late final TextEditingController _duracion;
  late bool _favorita;

  @override
  void initState() {
    super.initState();
    final o = widget.original;
    _titulo = TextEditingController(text: o?.titulo ?? '');
    _artista = TextEditingController(text: o?.artista ?? '');
    _album = TextEditingController(text: o?.album ?? '');
    _anio = TextEditingController(text: o?.anio?.toString() ?? '');
    _duracion = TextEditingController(text: o?.duracionSeg?.toString() ?? '');
    _favorita = o?.favorita ?? false;
  }

  @override
  void dispose() {
    _titulo.dispose();
    _artista.dispose();
    _album.dispose();
    _anio.dispose();
    _duracion.dispose();
    super.dispose();
  }

  /// Valida año opcional: vacío o número de 4 dígitos entre 1900 y hoy.
  String? _validarAnio(String? valor) {
    final texto = (valor ?? '').trim();
    if (texto.isEmpty) return null;
    final anio = int.tryParse(texto);
    final hoy = DateTime.now().year;
    if (anio == null || texto.length != 4 || anio < 1900 || anio > hoy) {
      return 'Año de 4 dígitos entre 1900 y $hoy.';
    }
    return null;
  }

  /// Valida duración opcional: vacía o entero > 0 (segundos).
  String? _validarDuracion(String? valor) {
    final texto = (valor ?? '').trim();
    if (texto.isEmpty) return null;
    final segundos = int.tryParse(texto);
    if (segundos == null || segundos <= 0) {
      return 'Segundos: número mayor que 0.';
    }
    return null;
  }

  void _guardar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final album = _album.text.trim();
    final anioTexto = _anio.text.trim();
    final duracionTexto = _duracion.text.trim();
    final resultado = Cancion(
      id: widget.original?.id,
      titulo: _titulo.text.trim(),
      artista: _artista.text.trim(),
      album: album.isEmpty ? null : album,
      anio: anioTexto.isEmpty ? null : int.parse(anioTexto),
      duracionSeg: duracionTexto.isEmpty ? null : int.parse(duracionTexto),
      favorita: _favorita,
      createdAt: widget.original?.createdAt,
    );
    Navigator.of(context).pop(resultado);
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.original != null;
    return AlertDialog(
      title: Text(esEdicion ? 'Editar canción' : 'Agregar canción'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titulo,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  hintText: 'p. ej. Imagine',
                ),
                validator: (v) => (v ?? '').trim().isEmpty
                    ? 'El título es obligatorio.'
                    : null,
              ),
              TextFormField(
                controller: _artista,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Artista *',
                  hintText: 'p. ej. John Lennon',
                ),
                validator: (v) => (v ?? '').trim().isEmpty
                    ? 'El artista es obligatorio.'
                    : null,
              ),
              TextFormField(
                controller: _album,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Álbum (opcional)',
                ),
              ),
              TextFormField(
                controller: _anio,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Año (opcional)',
                  hintText: 'p. ej. 1971',
                ),
                validator: _validarAnio,
              ),
              TextFormField(
                controller: _duracion,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Duración en segundos (opcional)',
                  hintText: 'p. ej. 183',
                ),
                validator: _validarDuracion,
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Favorita'),
                value: _favorita,
                onChanged: (v) => setState(() => _favorita = v ?? false),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardar,
          child: Text(esEdicion ? 'Guardar cambios' : 'Agregar'),
        ),
      ],
    );
  }
}
