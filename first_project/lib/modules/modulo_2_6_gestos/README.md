# Módulo 2.6 · Gestos

## Contenido
- `GestureDetector`: detecta toque simple, doble toque, pulsación larga
  y deslizamiento (horizontal/vertical con dirección).
- Cada gesto se identifica en texto visible inmediatamente.

## Conceptos clave
- Cada callback (`onTap`, `onDoubleTap`, `onLongPress`,
  `onHorizontalDragEnd`…) corresponde a un gesto distinto.
- La **velocidad** del arrastre (`primaryVelocity`) indica la dirección.
- La zona de gestos es un área dedicada y etiquetada para el lector
  de pantalla.

## Cómo probar la demo
1. Toca una vez → verás **"toque simple"**.
2. Toca dos veces rápido → **"doble toque"**.
3. Mantén pulsado → **"pulsación larga"**.
4. Desliza en cada dirección → **"deslizamiento hacia …"**.

## Permisos / dependencias
- Ninguno: solo SDK de Flutter.
