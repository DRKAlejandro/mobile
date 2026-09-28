// Falso en memoria del módulo 2.13 · Para tests y demo sin red.
// Qué muestra: la misma interfaz [CancionService] con las mismas reglas
// y errores, pero guardando en una lista local. Permite `flutter test`
// en verde sin Supabase (research R-05).
import '../models/cancion.dart';
import 'cancion_service.dart';

/// Implementación en memoria (paridad total con el contrato real).
class MemoriaCancionService implements CancionService {
  /// Siembra inicial (p. ej. 2 canciones de ejemplo en tests).
  MemoriaCancionService([List<Cancion>? iniciales]) {
    if (iniciales != null) _canciones.addAll(iniciales);
    _siguienteId = _canciones.fold<int>(1, (max, c) {
      final id = c.id ?? 0;
      return id >= max ? id + 1 : max;
    });
  }

  final List<Cancion> _canciones = [];
  int _siguienteId = 1;

  /// Error a lanzar en la próxima operación (para simular fallos).
  /// Se consume una sola vez.
  Exception? fallarSiguienteCon;

  /// Solo lectura para aserciones en tests.
  List<Cancion> get canciones => List.unmodifiable(_canciones);

  void _quizasFallar() {
    final error = fallarSiguienteCon;
    if (error != null) {
      fallarSiguienteCon = null;
      throw error;
    }
  }

  @override
  Future<List<Cancion>> listar() async {
    _quizasFallar();
    final copia = List<Cancion>.from(_canciones);
    copia.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    return copia;
  }

  @override
  Future<Cancion> crear({
    required String titulo,
    required String artista,
    String? album,
    int? anio,
    int? duracionSeg,
    bool favorita = false,
  }) async {
    _quizasFallar();
    if (titulo.trim().isEmpty || artista.trim().isEmpty) {
      throw const CamposObligatorios('Título y artista son obligatorios.');
    }
    final cancion = Cancion(
      id: _siguienteId++,
      titulo: titulo.trim(),
      artista: artista.trim(),
      album: album?.trim().isEmpty ?? true ? null : album!.trim(),
      anio: anio,
      duracionSeg: duracionSeg,
      favorita: favorita,
      createdAt: DateTime.now(),
    );
    _canciones.add(cancion);
    return cancion;
  }

  @override
  Future<Cancion> actualizar(Cancion cancion) async {
    _quizasFallar();
    if (cancion.id == null) throw const CancionNoEncontrada(null);
    final indice = _canciones.indexWhere((c) => c.id == cancion.id);
    if (indice == -1) throw CancionNoEncontrada(cancion.id);
    if (cancion.titulo.trim().isEmpty || cancion.artista.trim().isEmpty) {
      throw const CamposObligatorios('Título y artista son obligatorios.');
    }
    _canciones[indice] = cancion;
    return cancion;
  }

  @override
  Future<void> alternarFavorita(int id, bool valor) async {
    _quizasFallar();
    final indice = _canciones.indexWhere((c) => c.id == id);
    if (indice == -1) throw CancionNoEncontrada(id);
    _canciones[indice] = _canciones[indice].copyWith(favorita: valor);
  }

  @override
  Future<void> eliminar(int id) async {
    _quizasFallar();
    final indice = _canciones.indexWhere((c) => c.id == id);
    if (indice == -1) throw CancionNoEncontrada(id);
    _canciones.removeAt(indice);
  }
}
