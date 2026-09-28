// Módulo 2.13 · CRUD Canciones (FR-001–FR-013).
// Qué muestra: explicación del concepto CRUD + lista de canciones con
// búsqueda por texto, toggle de favorita, alta/edición con validación y
// borrado con confirmación, todo contra la tabla `canciones` de Supabase.
// Sin configurar (dart-define) → aviso didáctico; sin tabla → mensaje que
// apunta a `base de datos/`; sin red → error contenido con Reintentar.
// El servicio se inyecta por constructor (defecto: Supabase) para probar
// la pantalla sin red con [MemoriaCancionService].
import 'package:flutter/material.dart';

import 'models/cancion.dart';
import 'services/cancion_service.dart';
import 'services/supabase_cancion_service.dart';
import 'widgets/fila_cancion.dart';
import 'widgets/formulario_cancion.dart';

/// Pantalla del módulo 2.13.
class Modulo213CrudScreen extends StatefulWidget {
  const Modulo213CrudScreen({super.key, this.servicio});

  /// Servicio inyectado (tests/demo sin red). Defecto: Supabase.
  final CancionService? servicio;

  @override
  State<Modulo213CrudScreen> createState() => _Modulo213CrudScreenState();
}

class _Modulo213CrudScreenState extends State<Modulo213CrudScreen> {
  CancionService get _servicio =>
      widget.servicio ?? SupabaseCancionService();

  final TextEditingController _busqueda = TextEditingController();

  /// Canciones cargadas (solo-sesión; la verdad está en Supabase).
  List<Cancion> _canciones = [];

  /// Texto de búsqueda (filtrado en cliente, FR-004b).
  String _filtro = '';

  /// `true` durante cualquier operación (indicador de carga).
  bool _cargando = true;

  /// Error de conexión con Reintentar (`null` = sin error).
  String? _error;

  /// Falta `--dart-define` (aviso persistente, no reintentable).
  bool _faltaConfig = false;

  /// La tabla aún no existe (apunta al script SQL).
  bool _tablaAusente = false;

  @override
  void initState() {
    super.initState();
    _busqueda.addListener(() => setState(() => _filtro = _busqueda.text));
    _cargar();
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  /// Lista filtrada por título o artista (minúsculas).
  List<Cancion> get _visibles {
    final f = _filtro.trim().toLowerCase();
    if (f.isEmpty) return _canciones;
    return _canciones
        .where((c) =>
            c.titulo.toLowerCase().contains(f) ||
            c.artista.toLowerCase().contains(f))
        .toList();
  }

  /// Recarga la lista y refleja carga/resultado/error.
  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
      _faltaConfig = false;
      _tablaAusente = false;
    });
    try {
      final canciones = await _servicio.listar();
      if (!mounted) return;
      setState(() => _canciones = canciones);
    } on FaltaConfiguracion {
      if (!mounted) return;
      setState(() => _faltaConfig = true);
    } on TablaAusente {
      if (!mounted) return;
      setState(() => _tablaAusente = true);
    } on ErrorConexion catch (e) {
      if (!mounted) return;
      setState(() => _error = e.detalle.isEmpty
          ? 'Sin conexión con la base de datos. Reintenta con internet.'
          : 'Sin conexión: ${e.detalle}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'No se pudo cargar la lista: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  /// Alta o edición: abre el formulario y guarda el resultado.
  Future<void> _guardarCancion({Cancion? original}) async {
    final resultado = await showDialog<Cancion>(
      context: context,
      builder: (_) => FormularioCancion(original: original),
    );
    if (resultado == null || !mounted) return;
    setState(() => _cargando = true);
    try {
      if (original == null) {
        await _servicio.crear(
          titulo: resultado.titulo,
          artista: resultado.artista,
          album: resultado.album,
          anio: resultado.anio,
          duracionSeg: resultado.duracionSeg,
          favorita: resultado.favorita,
        );
        _avisar('Canción agregada.');
      } else {
        await _servicio.actualizar(resultado);
        _avisar('Cambios guardados.');
      }
      await _cargar();
    } on CamposObligatorios catch (e) {
      _avisar(e.detalle);
    } on ErrorConexion {
      _avisar('Sin conexión: no se pudo guardar.');
    } catch (e) {
      _avisar('No se pudo guardar: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  /// Borrado con confirmación explícita (FR-007).
  Future<void> _borrarCancion(Cancion cancion) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar canción'),
        content: Text(
            '¿Eliminar "${cancion.titulo}" de ${cancion.artista}? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted || cancion.id == null) return;
    setState(() => _cargando = true);
    try {
      await _servicio.eliminar(cancion.id!);
      _avisar('Canción eliminada.');
      await _cargar();
    } on ErrorConexion {
      _avisar('Sin conexión: no se pudo eliminar.');
    } catch (e) {
      _avisar('No se pudo eliminar: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  /// Toggle de favorita con persistencia inmediata (FR-008b).
  Future<void> _alternarFavorita(Cancion cancion, bool valor) async {
    if (cancion.id == null) return;
    setState(() {
      _canciones = _canciones
          .map((c) => c.id == cancion.id ? c.copyWith(favorita: valor) : c)
          .toList();
    });
    try {
      await _servicio.alternarFavorita(cancion.id!, valor);
      _avisar(valor ? 'Marcada como favorita.' : 'Quitada de favoritas.');
    } on ErrorConexion {
      _avisar('Sin conexión: no se guardó el cambio.');
      await _cargar();
    } catch (e) {
      _avisar('No se pudo cambiar favorita: $e');
      await _cargar();
    }
  }

  void _avisar(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  /// Cabecera estilo biblioteca musical: portada con gradiente nocturno,
  /// icono de biblioteca, total de canciones y favoritas (vive con la lista).
  Widget _cabeceraBiblioteca() {
    final favoritas = _canciones.where((c) => c.favorita).length;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0x26FFFFFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.library_music,
                color: Colors.white, size: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mi biblioteca',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_canciones.length} canciones · $favoritas favoritas',
                  style: const TextStyle(color: Color(0xB3FFFFFF)),
                ),
              ],
            ),
          ),
          const Icon(Icons.album_outlined,
              color: Color(0xB3FFFFFF), size: 28),
        ],
      ),
    );
  }

  /// Ficha del concepto con estilo de tarjeta de biblioteca: títulos en el
  /// color primario e iconos por sección, cuerpo en texto normal (sin rojos).
  Widget _explicacion() {
    final scheme = Theme.of(context).colorScheme;
    final titulo = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: scheme.primary,
        );
    final cuerpo = Theme.of(context).textTheme.bodyMedium;
    Widget seccion(IconData icono, String nombre, String texto) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icono, size: 20, color: scheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nombre, style: titulo),
                    const SizedBox(height: 2),
                    Text(texto, style: cuerpo),
                  ],
                ),
              ),
            ],
          ),
        );
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school_outlined, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Ficha del concepto',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            seccion(
              Icons.swap_vert,
              '¿Qué es?',
              'CRUD son las 4 operaciones básicas sobre datos: Crear (Create), Leer (Read), Actualizar (Update) y Borrar (Delete).',
            ),
            seccion(
              Icons.cloud_outlined,
              '¿Para qué sirve?',
              'Casi toda app móvil guarda datos en un servidor: contactos, notas, publicaciones. Aquí las canciones viven en una tabla de Supabase compartida por todos.',
            ),
            seccion(
              Icons.play_circle_outline,
              'Tu misión',
              'Agrega tu primera canción con el botón +, búscala, márcala favorita con la estrella, edítala y elimínala. Cada cambio se guarda en la nube.',
            ),
          ],
        ),
      ),
    );
  }

  /// Aviso persistente cuando faltan los flags de conexión.
  Widget _avisoConfig() => Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: Text(
            'Falta configurar Supabase: ejecuta con --dart-define=SUPABASE_URL y '
            '--dart-define=SUPABASE_ANON_KEY (ver README del módulo).',
          ),
        ),
      );

  /// Aviso cuando la tabla aún no existe en el proyecto Supabase.
  Widget _avisoTabla() => Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: Text(
            'La tabla "canciones" aún no existe: ejecuta el script de la '
            'carpeta "base de datos" en el SQL Editor de Supabase y pulsa Reintentar.',
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final visibles = _visibles;
    return Scaffold(
      appBar: AppBar(title: const Text('2.13 · CRUD Canciones')),
      floatingActionButton: Semantics(
        button: true,
        label: 'Agregar canción',
        child: FloatingActionButton(
          onPressed: _cargando ? null : () => _guardarCancion(),
          child: const Icon(Icons.add),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _cabeceraBiblioteca(),
              const SizedBox(height: 12),
              _explicacion(),
              const SizedBox(height: 12),
              if (_faltaConfig) ...[
                _avisoConfig(),
                const SizedBox(height: 12),
              ],
              if (_tablaAusente) ...[
                _avisoTabla(),
                const SizedBox(height: 12),
              ],
              if (_error != null) ...[
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(child: Text(_error!)),
                        TextButton(
                          onPressed: _cargar,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Semantics(
                textField: true,
                label: 'Buscar por título o artista',
                child: TextField(
                  controller: _busqueda,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    labelText: 'Buscar por título o artista',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_cargando && _canciones.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: 'Cargando canciones',
                    ),
                  ),
                )
              else if (_tablaAusente || _faltaConfig)
                const SizedBox.shrink()
              else if (_canciones.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Aún no hay canciones. ¡Agrega la primera con el botón +!',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else if (visibles.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Sin resultados para esa búsqueda.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                for (final cancion in visibles)
                  FilaCancion(
                    key: ValueKey(cancion.id),
                    cancion: cancion,
                    onFavorita: (v) => _alternarFavorita(cancion, v),
                    onEditar: () => _guardarCancion(original: cancion),
                    onBorrar: () => _borrarCancion(cancion),
                  ),
              if (_cargando && _canciones.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        semanticsLabel: 'Actualizando lista',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
