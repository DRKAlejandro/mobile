# Módulo 2.10 · Multimedia: cámara, audio y video

## Contenido
- Cámara: captura de foto real con permiso previo (`image_picker`).
- Audio: grabación con el micrófono (`record`) y reproducción (`audioplayers`).
- Video: reproducción de un video de ejemplo incluido en la app (`video_player`), sin conexión.
- Todo valor real lleva badge **REAL**; sin permiso/hardware, ilustración con **SIMULADO**.

## Conceptos clave
- El permiso se pide **bajo demanda** después de explicar para qué sirve.
- Foto y audio viven **solo en sesión** (caché/temporal): se descartan al salir.
- Los recursos (grabador, reproductores, controlador de video) se liberan en `dispose()`.

## Cómo probar la demo
1. **Foto**: pulsa "Tomar foto" → acepta el permiso → observa tu foto real. Deniega el permiso → verás la explicación y el marcador ilustrativo.
2. **Audio**: pulsa "Grabar" → habla → "Detener" → "Reproducir" → escucha tu grabación.
3. **Video**: pulsa "Reproducir" → el ejemplo se reproduce offline con play/pausa.

## Permisos / dependencias
- `image_picker`, `record`, `audioplayers`, `video_player`, `permission_handler`
  (vía `PermisosService`: `solicitarCamara`, `solicitarMicrofono`).
- Android: `CAMERA`, `RECORD_AUDIO`. iOS: `NSCameraUsageDescription`,
  `NSMicrophoneUsageDescription`.

## Video de ejemplo (reemplazable)
- `assets/video_ejemplo.mp4` (2.7 MB, 5 s): muestra gratuita de
  https://download.samplelib.com/mp4/sample-5s.mp4 (samplelib, videos de
  muestra libres). Declarado en `pubspec.yaml` bajo `assets/`.
- Para usar otro clip, sustituye el archivo manteniendo el nombre o actualiza
  la ruta en `screen.dart` y `pubspec.yaml`.
