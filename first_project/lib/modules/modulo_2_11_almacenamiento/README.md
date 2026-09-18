# Módulo 2.11 · Almacenamiento

## Contenido
- Preferencias locales (`shared_preferences`, API `SharedPreferencesAsync`):
  guardar y recuperar pares clave-valor simples que **persisten entre sesiones**.
- Es la única demo con persistencia de toda la app (decisión de diseño
  documentada en el spec 002): demuestra el verdadero valor del almacenamiento.

## Conceptos clave
- Clave única `demo_texto_2_11`: identifica el dato de ejemplo.
- `setString` guarda; `getString` recupera (`null` = aún sin guardar).
- Al abrir, la pantalla lee el valor previo: si existe, es la prueba visible
  de que el dato sobrevivió al reinicio.

## Cómo probar la demo
1. Escribe un texto y pulsa **"Guardar"** → confirmación visible.
2. Cierra la app por completo y reábela → el texto sigue visible con la nota
   "persistió desde la sesión anterior".
3. Guarda otro texto → reemplaza al anterior (misma clave).

## Permisos / dependencias
- `shared_preferences`. Sin permisos del sistema.
