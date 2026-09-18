// Modelo del módulo 2.12 · Ficha Pokémon (data-model.md).
// Qué muestra: datos de un pokémon con origen real (PokeAPI) o
// ilustrativo local (kPikachuSimulado vive en el servicio).
// Altura en metros (API: decímetros) y peso en kilos (API: hectogramos).
/// Habilidad con marca de oculta (ej. Lightning Rod de pikachu).
class Habilidad {
  const Habilidad({required this.nombre, required this.oculta});

  /// Nombre en inglés tal cual lo devuelve la API (p. ej. 'static').
  final String nombre;

  /// `true` si es habilidad oculta (`is_hidden`).
  final bool oculta;
}

/// Estadística base (ej. hp = 35 en pikachu).
class Stat {
  const Stat({required this.nombre, required this.valor});

  /// Nombre en inglés tal cual lo devuelve la API (p. ej. 'speed').
  final String nombre;

  /// Valor base (`base_stat`).
  final int valor;
}

/// Ficha visual de un pokémon (entidad Pokemon de data-model.md).
class Pokemon {
  const Pokemon({
    required this.id,
    required this.nombre,
    required this.imagenUrl,
    required this.tipos,
    required this.alturaM,
    required this.pesoKg,
    required this.habilidades,
    required this.stats,
    required this.esReal,
  });

  /// Número de pokédex (> 0).
  final int id;

  /// Nombre en minúsculas de la API (la UI lo capitaliza al mostrar).
  final String nombre;

  /// Arte oficial (`official-artwork`) con fallback al sprite clásico.
  /// Vacía si la API no trae imagen (la UI muestra un icono).
  final String imagenUrl;

  /// Tipos ordenados por `slot` (p. ej. ['electric']).
  final List<String> tipos;

  /// Altura en metros con un decimal (`height / 10`).
  final double alturaM;

  /// Peso en kilos con un decimal (`weight / 10`).
  final double pesoKg;

  /// Habilidades con su marca de oculta.
  final List<Habilidad> habilidades;

  /// Estadísticas base (6 en la API actual).
  final List<Stat> stats;

  /// `true` → dato real de PokeAPI; `false` → ilustrativo local.
  final bool esReal;

  /// Construye desde el JSON de `GET /pokemon/{nombre-o-id}`.
  factory Pokemon.fromJson(Map<String, dynamic> json, {bool esReal = true}) {
    final sprites = (json['sprites'] as Map<String, dynamic>?) ?? {};
    final other = (sprites['other'] as Map<String, dynamic>?) ?? {};
    final artwork =
        (other['official-artwork'] as Map<String, dynamic>?) ?? {};
    final imagen = (artwork['front_default'] as String?) ??
        (sprites['front_default'] as String?) ??
        '';

    final tiposJson = (json['types'] as List<dynamic>?) ?? [];
    final tiposOrdenados = List<Map<String, dynamic>>.from(
      tiposJson.map((t) => t as Map<String, dynamic>),
    )..sort(
        (a, b) => ((a['slot'] as int?) ?? 0).compareTo((b['slot'] as int?) ?? 0),
      );

    /// Pasa decímetros/hectogramos a metros/kilos con un decimal.
    double unDecimal(num valor) =>
        double.parse((valor / 10).toStringAsFixed(1));

    return Pokemon(
      id: (json['id'] as int?) ?? 0,
      nombre: (json['name'] as String?) ?? '',
      imagenUrl: imagen,
      tipos: tiposOrdenados
          .map((t) => ((t['type'] as Map<String, dynamic>?)?['name'] as String?) ?? '')
          .where((nombre) => nombre.isNotEmpty)
          .toList(),
      alturaM: unDecimal((json['height'] as num?) ?? 0),
      pesoKg: unDecimal((json['weight'] as num?) ?? 0),
      habilidades: ((json['abilities'] as List<dynamic>?) ?? []).map((a) {
        final mapa = a as Map<String, dynamic>;
        return Habilidad(
          nombre: ((mapa['ability'] as Map<String, dynamic>?)?['name']
                  as String?) ??
              '',
          oculta: (mapa['is_hidden'] as bool?) ?? false,
        );
      }).toList(),
      stats: ((json['stats'] as List<dynamic>?) ?? []).map((s) {
        final mapa = s as Map<String, dynamic>;
        return Stat(
          nombre:
              ((mapa['stat'] as Map<String, dynamic>?)?['name'] as String?) ??
                  '',
          valor: (mapa['base_stat'] as int?) ?? 0,
        );
      }).toList(),
      esReal: esReal,
    );
  }
}
