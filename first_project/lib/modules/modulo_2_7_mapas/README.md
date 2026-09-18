# Módulo 2.7 · Localización y mapas

## Contenido
- Posición GPS real (`geolocator`: `getCurrentPosition`).
- Mapa interactivo real (`google_maps_flutter`) con marcador.
- Flujo de permiso de ubicación explicado **antes** de solicitarlo.
- Fallback ilustrativo con badge **SIMULADO** (sin permiso/señal/key).

## Conceptos clave
- El permiso (`PermisosService.solicitarUbicacion`) forma parte de la demo:
  concedido → datos reales; denegado → ejemplo etiquetado.
- `accuracy` indica la precisión en metros de la lectura.
- Todo error queda contenido en la pantalla (FR-012).

## Cómo probar la demo
1. Lee la nota de permisos y pulsa **"Localizarme"**.
2. Concede el permiso → mapa centrado en tu posición **REAL** + precisión.
3. Deniega el permiso (o sin GPS) → posición ilustrativa de CDMX con
   badge **SIMULADO**.

## Permisos / dependencias
- `google_maps_flutter`, `geolocator`, `permission_handler`.
- Android: `ACCESS_FINE_LOCATION` (+ `ACCESS_COARSE_LOCATION`) y la key en
  `AndroidManifest.xml`. iOS: `NSLocationWhenInUseUsageDescription` en
  `Info.plist` (+ key según `AppDelegate`).

## API key de demostración (reemplazable)
- El repo incluye una key demo **restringida** (paquete/presupuesto) para
  que el mapa funcione al clonar (decisión 2026-09-15).
- Para usar tu propia key de Google Maps:
  1. Créala en Google Cloud Console (Maps SDK for Android / iOS).
  2. Sustituye `TU_API_KEY_DEMO_AQUI` en
     `android/app/src/main/AndroidManifest.xml` (y la de iOS).
  3. Sin key válida, la app sigue funcionando con el fallback simulado.
