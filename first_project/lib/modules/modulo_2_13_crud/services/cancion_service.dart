// Contrato del módulo 2.13 · Servicio CRUD de canciones
// (contracts/cancion-service.md).
// Qué muestra: interfaz mínima Crear/Leer/Actualizar/Borrar + toggle de
// favorita, con errores propios. La pantalla solo conoce esta interfaz:
// en producción se inyecta [SupabaseCancionService] y en tests
// [MemoriaCancionService] (sin red).
import '../models/cancion.dart';

/// Título o artista vacíos tras `trim()`: validación local, sin llamada.
class CamposObligatorios implements Exception {
  const CamposObligatorios(this.detalle);

  final String detalle;
}

/// El `id` no existe en la tabla (o es nulo en update/delete).
class CancionNoEncontrada implements Exception {
  const CancionNoEncontrada(this.id);

  final int? id;
}

/// Sin red, timeout (10 s) u otro fallo del servicio.
class ErrorConexion implements Exception {
  const ErrorConexion([this.detalle = '']);

  final String detalle;
}

/// Faltan `--dart-define` SUPABASE_URL / SUPABASE_ANON_KEY.
class FaltaConfiguracion implements Exception {
  const FaltaConfiguracion();
}

/// La tabla `canciones` aún no existe (falta ejecutar el SQL).
class TablaAusente implements Exception {
  const TablaAusente();
}

/// El servidor rechazó los datos (checks/not-null).
class ErrorValidacion implements Exception {
  const ErrorValidacion(this.detalle);

  final String detalle;
}

/// Operaciones CRUD sobre canciones (implementaciones: Supabase y memoria).
abstract class CancionService {
  /// Lista todas, más recientes primero (`created_at` desc).
  Future<List<Cancion>> listar();

  /// Crea una canción; el `id` lo asigna la base.
  Future<Cancion> crear({
    required String titulo,
    required String artista,
    String? album,
    int? anio,
    int? duracionSeg,
    bool favorita = false,
  });

  /// Actualiza todos los campos de una canción existente.
  Future<Cancion> actualizar(Cancion cancion);

  /// Update parcial: solo la columna `favorita`.
  Future<void> alternarFavorita(int id, bool valor);

  /// Borra la fila (la UI pide confirmación antes, FR-007).
  Future<void> eliminar(int id);
}
