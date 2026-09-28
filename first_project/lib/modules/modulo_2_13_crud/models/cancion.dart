// Modelo del módulo 2.13 · Canción (data-model.md).
// Qué muestra: una canción con título/artista obligatorios y resto
// opcional; `id` y `createdAt` los asigna Supabase (solo lectura).
// Claves JSON espejo de las columnas SQL (`duracion_seg`, `created_at`).

/// Una canción del sistema ligero CRUD (spec FR-005, FR-010).
class Cancion {
  const Cancion({
    this.id,
    required this.titulo,
    required this.artista,
    this.album,
    this.anio,
    this.duracionSeg,
    this.favorita = false,
    this.createdAt,
  });

  /// Id generado por la base (`null` antes del alta).
  final int? id;

  /// Título (obligatorio, no vacío tras `trim()`, máx. 120).
  final String titulo;

  /// Artista (obligatorio, no vacío tras `trim()`, máx. 120).
  final String artista;

  /// Álbum (opcional).
  final String? album;

  /// Año de 4 dígitos (opcional).
  final int? anio;

  /// Duración en segundos (opcional, > 0).
  final int? duracionSeg;

  /// Marca de favorita (toggle en lista, FR-008b).
  final bool favorita;

  /// Fecha de creación asignada por la base (solo lectura).
  final DateTime? createdAt;

  /// Construye desde una fila de Supabase (claves = columnas SQL).
  factory Cancion.fromJson(Map<String, dynamic> json) {
    int? entero(dynamic valor) {
      if (valor == null) return null;
      if (valor is int) return valor;
      return int.tryParse(valor.toString());
    }

    return Cancion(
      id: entero(json['id']),
      titulo: (json['titulo'] ?? '').toString(),
      artista: (json['artista'] ?? '').toString(),
      album: json['album']?.toString(),
      anio: entero(json['anio']),
      duracionSeg: entero(json['duracion_seg']),
      favorita: json['favorita'] == true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
    );
  }

  /// Serializa para insert/update (sin `id` ni `created_at`: los genera la base).
  Map<String, dynamic> toJson() => {
        'titulo': titulo,
        'artista': artista,
        'album': album,
        'anio': anio,
        'duracion_seg': duracionSeg,
        'favorita': favorita,
      };

  /// Copia con cambios (para edición y toggle de favorita).
  Cancion copyWith({
    int? id,
    String? titulo,
    String? artista,
    String? album,
    int? anio,
    int? duracionSeg,
    bool? favorita,
    DateTime? createdAt,
  }) {
    return Cancion(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      artista: artista ?? this.artista,
      album: album ?? this.album,
      anio: anio ?? this.anio,
      duracionSeg: duracionSeg ?? this.duracionSeg,
      favorita: favorita ?? this.favorita,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Duración formateada `m:ss` ('' si no hay duración).
  String get duracionTexto {
    if (duracionSeg == null || duracionSeg! <= 0) return '';
    final minutos = duracionSeg! ~/ 60;
    final segundos = (duracionSeg! % 60).toString().padLeft(2, '0');
    return '$minutos:$segundos';
  }

  /// Valida título/artista no vacíos (FR-008). Devuelve la lista de errores.
  static List<String> validar({required String titulo, required String artista}) {
    final errores = <String>[];
    if (titulo.trim().isEmpty) errores.add('El título es obligatorio.');
    if (artista.trim().isEmpty) errores.add('El artista es obligatorio.');
    if (titulo.trim().length > 120) {
      errores.add('El título no supera 120 caracteres.');
    }
    if (artista.trim().length > 120) {
      errores.add('El artista no supera 120 caracteres.');
    }
    return errores;
  }
}
