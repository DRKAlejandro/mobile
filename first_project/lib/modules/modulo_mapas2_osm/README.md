# Módulo mapas2 · Mapas y rutas abiertas (OSM)

## Contenido
- Mapa interactivo OpenStreetMap (`flutter_map`, sin API key) centrado en SLP.
- Puntos en modo mixto: toque sobre el mapa, ejemplos de SLP y lista editable.
- Rutas conmutables: recta local (Haversine) y vial real (OSRM público).
- GPS híbrido: SLP fijo + posición real con botón "Mi ubicación" (permiso previo).

## Conceptos clave
- Las teselas OSM se cargan por internet y exigen atribución visible.
- `PuntoMapa` vive solo en la sesión; al salir del módulo se descarta.
- `RutaMapa` tiene modo (`recta`/`calles`) y estado (`ok`/`cargando`/`error`).
- Si OSRM falla, se conserva la recta y se muestra un aviso (fallback didáctico).

## Cómo probar la demo
1. Abre **Mapas2** desde el menú → mapa de SLP con la tarjeta didáctica.
2. Toca el mapa → aparece `Punto N`; o pulsa **Agregar ejemplos** (3 de SLP).
3. Toca un marcador → ves su título y descripción.
4. Pulsa **Trazar recta** → línea + distancia estimada.
5. Activa **Ruta por calles** → trazado vial + distancia vial (o aviso que conserva la recta).
6. Pulsa **Mi ubicación** y concede el permiso → punto azul + centrado.
7. Sin internet → aviso claro con reintento, sin pantallas negras.

## Permisos / dependencias
- `flutter_map`, `latlong2` (mapa abierto), `geolocator`, `permission_handler`, `http` (OSRM).
- Android: `ACCESS_FINE_LOCATION` (+ `ACCESS_COARSE_LOCATION`); iOS: `NSLocationWhenInUseUsageDescription`.
- Sin claves de pago ni configuración externa obligatoria.
