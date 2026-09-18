# Módulo 2.4 · Input, Label y Button

## Contenido
- `TextField`: captura lo que escribe el usuario (con `TextEditingController`).
- Etiqueta (`labelText`): identifica qué se pide en el campo.
- `ElevatedButton`: ejecuta la acción y refleja el texto como resultado.

## Conceptos clave
- El controlador se crea en el `State` y se libera en `dispose()`.
- `trim()` evita reflejar espacios vacíos como contenido.
- El resultado visible confirma que la interacción funcionó.

## Cómo probar la demo
1. Escribe tu nombre en el campo.
2. Pulsa **"Mostrar"** (o Enter) → tu texto aparece en **Resultado**.
3. Prueba con el campo vacío → verás el mensaje de ayuda.

## Permisos / dependencias
- Ninguno: solo SDK de Flutter. Contenido migrado del `HomeScreen`
  monolítico original (ver tag `legacy-homescreen-before-menu`).
