// Configuración del módulo 2.13 · Claves de Supabase sin secretos en el repo.
// Qué muestra: leer URL y anon-key desde `--dart-define` (inyectados al
// ejecutar) en vez de hardcodearlas. Sin flags → la pantalla avisa
// "Falta configurar" en lugar de fallar (research R-03).
//
// Uso:
//   flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co
//               --dart-define=SUPABASE_ANON_KEY=tu-anon-key

/// Claves de conexión al proyecto Supabase del estudiante/docente.
class SupabaseConfig {
  const SupabaseConfig._();

  /// URL del proyecto (p. ej. https://xyzcompany.supabase.co).
  static const String url = String.fromEnvironment('SUPABASE_URL');

  /// Clave anónima pública (anon-key, segura para apps cliente).
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// `true` cuando faltan los flags y no se puede conectar.
  static bool get faltaConfiguracion => url.isEmpty || anonKey.isEmpty;
}
