// Implementación real del módulo 2.13 · CRUD contra Supabase.
// Qué muestra: cada letra CRUD mapeada a PostgREST
// (`from('canciones').select/insert/update/delete`) con timeout de 10 s
// y errores traducidos a las excepciones propias del contrato.
import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cancion.dart';
import 'cancion_service.dart';

/// Servicio CRUD contra la tabla `canciones` de Supabase.
class SupabaseCancionService implements CancionService {
  /// Timeout de red (mismo criterio del módulo 2.12).
  static const Duration timeout = Duration(seconds: 10);

  /// Nombre de la tabla remota (contrato tabla-canciones-sql.md).
  static const String tabla = 'canciones';

  SupabaseClient get _cliente {
    try {
      return Supabase.instance.client;
    } catch (_) {
      throw const FaltaConfiguracion();
    }
  }

  /// Traduce errores del cliente a excepciones propias del módulo.
  /// Las excepciones propias que ya vienen de guardas locales se
  /// propagan tal cual (p. ej. [FaltaConfiguracion]).
  Never _traducir(Object error) {
    if (error is CamposObligatorios ||
        error is CancionNoEncontrada ||
        error is ErrorConexion ||
        error is FaltaConfiguracion ||
        error is TablaAusente ||
        error is ErrorValidacion) {
      throw error;
    }
    if (error is TimeoutException) {
      throw ErrorConexion('Tiempo de espera agotado (10 s). ${error.message ?? ''}');
    }
    if (error is PostgrestException) {
      // Tabla inexistente: 42P01 o mensaje "relation ... does not exist".
      if (error.code == '42P01' ||
          (error.message.contains('does not exist'))) {
        throw TablaAusente();
      }
      // Violación de checks/not-null: 23502 / 23514.
      if (error.code == '23502' || error.code == '23514') {
        throw ErrorValidacion(error.message);
      }
      throw ErrorConexion(error.message);
    }
    if (error is AuthException) throw ErrorConexion(error.message);
    throw ErrorConexion(error.toString());
  }

  @override
  Future<List<Cancion>> listar() async {
    try {
      final filas = await _cliente
          .from(tabla)
          .select()
          .order('created_at', ascending: false)
          .timeout(timeout);
      return (filas as List)
          .map((f) => Cancion.fromJson(Map<String, dynamic>.from(f as Map)))
          .toList();
    } catch (e) {
      _traducir(e);
    }
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
    if (titulo.trim().isEmpty || artista.trim().isEmpty) {
      throw const CamposObligatorios('Título y artista son obligatorios.');
    }
    try {
      final fila = await _cliente
          .from(tabla)
          .insert({
            'titulo': titulo.trim(),
            'artista': artista.trim(),
            'album': (album == null || album.trim().isEmpty) ? null : album.trim(),
            'anio': anio,
            'duracion_seg': duracionSeg,
            'favorita': favorita,
          })
          .select()
          .single()
          .timeout(timeout);
      return Cancion.fromJson(Map<String, dynamic>.from(fila));
    } catch (e) {
      _traducir(e);
    }
  }

  @override
  Future<Cancion> actualizar(Cancion cancion) async {
    if (cancion.id == null) throw const CancionNoEncontrada(null);
    if (cancion.titulo.trim().isEmpty || cancion.artista.trim().isEmpty) {
      throw const CamposObligatorios('Título y artista son obligatorios.');
    }
    try {
      final fila = await _cliente
          .from(tabla)
          .update({
            'titulo': cancion.titulo.trim(),
            'artista': cancion.artista.trim(),
            'album': cancion.album,
            'anio': cancion.anio,
            'duracion_seg': cancion.duracionSeg,
            'favorita': cancion.favorita,
          })
          .eq('id', cancion.id!)
          .select()
          .single()
          .timeout(timeout);
      return Cancion.fromJson(Map<String, dynamic>.from(fila));
    } catch (e) {
      _traducir(e);
    }
  }

  @override
  Future<void> alternarFavorita(int id, bool valor) async {
    try {
      await _cliente
          .from(tabla)
          .update({'favorita': valor})
          .eq('id', id)
          .timeout(timeout);
    } catch (e) {
      _traducir(e);
    }
  }

  @override
  Future<void> eliminar(int id) async {
    try {
      await _cliente.from(tabla).delete().eq('id', id).timeout(timeout);
    } catch (e) {
      _traducir(e);
    }
  }
}
