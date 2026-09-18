# Módulo 2.8 · Acelerómetro

## Contenido
- Lecturas reales X/Y/Z del acelerómetro (`sensors_plus`), en m/s².
- Suscripción en `initState`, cancelación en `dispose()` (ciclo de vida).
- Muestreo reducido ~10 Hz (throttling) para no saturar la UI.
- Fallback ilustrativo con badge **SIMULADO** (emulador/web/sin hardware).

## Conceptos clave
- X = lados, Y = arriba/abajo, Z = frente/atrás (≈ 9.8 en reposo boca arriba).
- El sensor emite muy rápido: la UI solo se actualiza cada ~100 ms.
- `onError` del stream muestra el fallo contenido, sin romper la app.

## Cómo probar la demo
1. Abre la pantalla en un dispositivo real → valores **REALES** en vivo.
2. Inclina o mueve el móvil → X/Y/Z cambian al instante.
3. En emulador → valores ilustrativos (0.0, 0.0, 9.8) con badge **SIMULADO**.

## Permisos / dependencias
- `sensors_plus`. Sin permisos del sistema.
