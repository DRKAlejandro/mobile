// Configuración de Supabase sin secretos en el repo (T004).
// Lee URL y anon-key desde `--dart-define` inyectados al ejecutar,
// igual que `first_project/.../supabase_config.dart`.
// Sin flags → `faltaConfiguracion` es true y la app muestra el aviso
// "Falta configurar" en lugar de fallar.
//
// Uso:
//   flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co
//               --dart-define=SUPABASE_ANON_KEY=tu-anon-key

/// Claves de conexión al proyecto Supabase de la pizzería.
class SupabaseConfig {
  const SupabaseConfig._();

  /// URL del proyecto (p. ej. https://xyzcompany.supabase.co).
  static const String url = String.fromEnvironment('SUPABASE_URL');

  /// Clave anónima pública (anon-key, segura para apps cliente).
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// `true` cuando faltan los flags y no se puede conectar.
  static bool get faltaConfiguracion => url.isEmpty || anonKey.isEmpty;
}
