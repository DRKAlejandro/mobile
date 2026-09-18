// Valores ilustrativos para el fallback simulado (FR-013).
// Se usan cuando no hay hardware, señal o permiso; siempre junto a
// un [SimuladoBadge] con esReal: false. No requieren precisión real.

/// Punto de ejemplo (Ciudad de México).
class PosicionSimulada {
  /// Latitud ilustrativa.
  static const double latitud = 19.4326;

  /// Longitud ilustrativa.
  static const double longitud = -99.1332;

  /// Texto listo para mostrar: "19.4326, -99.1332 (simulado)".
  static const String texto = '19.4326, -99.1332 (simulado)';
}

/// Lectura de ejemplo del acelerómetro (móvil quieto boca arriba).
class AcelerometroSimulado {
  /// Eje X en m/s².
  static const double x = 0.0;

  /// Eje Y en m/s².
  static const double y = 0.0;

  /// Eje Z en m/s² (≈ gravedad).
  static const double z = 9.8;
}

/// Estado de ejemplo para el módulo 2.9.
class EstadoSimulado {
  /// Tipo de red ilustrativo.
  static const String red = 'Wi-Fi (simulado)';

  /// Nivel de batería ilustrativo.
  static const int bateria = 78;

  /// Mensaje cuando el dispositivo no tiene vibrador.
  static const String sinVibrador =
      'Este dispositivo no tiene vibrador: vibración simulada con animación.';
}
