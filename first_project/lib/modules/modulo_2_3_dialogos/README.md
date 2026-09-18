# Módulo 2.3 · Diálogos y notificaciones

## Contenido
- Diálogos en-app (`AlertDialog`): confirmar o descartar una acción.
- `SnackBar`: retroalimentación breve tras la elección.
- Notificaciones reales del sistema (`flutter_local_notifications`): avisan
  incluso fuera de la app, con permiso previo del usuario.

## Conceptos clave
- `showDialog` es asíncrono: devuelve la elección del usuario.
- El permiso `POST_NOTIFICATIONS` (Android 13+) se pide **bajo demanda**,
  después de explicar para qué sirve.
- Canal de notificación (`demo_canal`): agrupa los avisos de la demo.

## Cómo probar la demo
1. Pulsa **"Mostrar diálogo"** → elige Confirmar o Descartar → observa el
   resultado visible y el `SnackBar`.
2. Pulsa **"Enviar notificación real"** → acepta el permiso → observa el
   aviso del sistema. El badge cambia a **REAL**.
3. Deniega el permiso → verás la explicación y el aviso solo en-app
   (fallback, sin bloquear la pantalla).

## Permisos / dependencias
- `flutter_local_notifications`, `permission_handler`
  (vía `PermisosService`).
- Android: `POST_NOTIFICATIONS`. iOS: permiso de notificaciones en tiempo
  de ejecución (sin clave extra en `Info.plist`).
