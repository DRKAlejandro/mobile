# Mobile — Herramientas de Desarrollo Móvil

Proyecto para compartir las herramientas de desarrollo móvil vistas en clase, con ejemplos didácticos y reutilizables en Flutter.

## Contenido

- `first_project/`: app Flutter con menú y catálogo de módulos:
  - 2.3 Diálogos
  - 2.4 Controles UI
  - 2.5 Selección
  - 2.6 Gestos
  - 2.7 Mapas (google_maps_flutter + geolocator)
  - 2.8 Acelerómetro / sensores (sensors_plus, con fallback simulado)
  - 2.9 Estado
  - 2.10 Multimedia (image_picker, record, audioplayers, video_player)
  - 2.11 Almacenamiento (shared_preferences)
  - 2.12 APIs (http + PokeAPI)
  - 2.13 CRUD canciones (Supabase, --dart-define)
  - Mapas2 Mapas y rutas abiertas (OSM: flutter_map + latlong2 + OSRM, sin API key)
- `pizza_pizza/`: app de pizzería (login, registro, bienvenida + esquema SQL Supabase en `base de datos/tabla_pizzeria.sql`).
- `first_project/lib/shared/`: widgets y servicios comunes (permisos, sensores, manejo de errores).
- `first_project/test/`: pruebas de navegación, menú y widgets.
- `presentacion_movil.pptx`: presentación de apoyo.

## Requisitos

- Flutter SDK ^3.13.0
- Dart ^3.13.0

## Uso

```sh
flutter pub get
flutter run
flutter test
```
