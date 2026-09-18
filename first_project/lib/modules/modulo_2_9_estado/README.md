# Módulo 2.9 · Red, batería y vibración

## Contenido
- Estado de red (`connectivity_plus`): tipo de conexión en vivo.
- Nivel y estado de carga de la batería (`battery_plus`).
- Vibración corta con comprobación previa (`vibration.hasVibrator`).
- Fallbacks ilustrativos con badge **SIMULADO** cuando no es posible.

## Conceptos clave
- `onConnectivityChanged` avisa cuando la red cambia (se cancela en
  `dispose()`).
- La batería se lee una vez al abrir (`batteryLevel`, `batteryState`).
- Vibrar sin comprobar `hasVibrator` rompería en dispositivos sin vibrador:
  por eso el check previo es contenido de la demo.

## Cómo probar la demo
1. Observa tu red y batería **REALES** al abrir.
2. Activa/desactiva el Wi-Fi → la red se actualiza en vivo.
3. Pulsa **"Vibrar 500 ms"** → vibración real o mensaje alternativo
   si no hay vibrador.

## Permisos / dependencias
- `connectivity_plus`, `battery_plus`, `vibration`.
- Android: `ACCESS_NETWORK_STATE`, `VIBRATE`. Sin permisos en iOS para
  esta demo.
