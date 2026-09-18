# Módulo 2.5 · RadioButton, CheckBox y Select

## Contenido
- `Radio`: elige **una** opción entre varias (excluyentes).
- `Checkbox`: activa o desactiva **una** opción (aceptar términos).
- `DropdownButtonFormField`: elige una opción de una lista desplegable.
- Resumen visible que refleja el estado elegido en todo momento.

## Conceptos clave
- El grupo de radio comparte una sola variable (`_radio`).
- La casilla guarda un `bool`; el desplegable, el valor elegido.
- Todo vive en el `State` local: sin gestores externos (YAGNI).

## Cómo probar la demo
1. Cambia entre **Opción 1 / Opción 2**.
2. Marca o desmarca **"Acepto los términos"**.
3. Elige un país en el desplegable → el resumen se actualiza.

## Permisos / dependencias
- Ninguno: solo SDK de Flutter. Contenido migrado del `HomeScreen`
  monolítico original (ver tag `legacy-homescreen-before-menu`).
