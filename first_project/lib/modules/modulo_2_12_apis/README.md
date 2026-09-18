# Módulo 2.12 · APIs y Servicios Web

## Contenido
- APIs y servicios web con ejemplo real: consulta HTTP `GET` a la PokeAPI
  (pública, sin clave ni registro) y lectura de su respuesta JSON.
- Herramienta visual: ficha de pokémon (imagen oficial, tipos, altura, peso,
  habilidades y estadísticas) con buscador, ejemplos y aleatorio.
- Sin persistencia: la ficha es solo de sesión (como 2.10).

## Conceptos clave
- Solicitud (`GET https://pokeapi.co/api/v2/pokemon/{nombre-o-id}`) y
  respuesta (JSON con `id`, `name`, `types`, `abilities`, `stats`, `sprites`).
- `package:http` + `timeout(10 s)` + `jsonDecode` con `fromJson` manual.
- Estados visibles: carga, resultado, no encontrado (404) y error de
  conexión (con ficha ilustrativa de pikachu + badge SIMULADO).
- Entrada normalizada (`trim().toLowerCase()`); vacío se valida sin llamar.

## Cómo probar la demo
1. Al abrir ya ves a **pikachu** (auto-carga) con badge REAL.
2. Busca `Charizard` (con mayúscula) → ficha real (normalización).
3. Toca un acceso directo (`mewtwo`) o el **aleatorio** (1–1025).
4. Busca `xyz123` → mensaje de no encontrado + Reintentar.
5. Activa modo avión y reintenta → ficha pikachu SIMULADA + mensaje.
6. Rota el dispositivo o agranda el texto → sin recortes, con scroll.

## Permisos / dependencias
- `http: ^1.6.0`. Permiso Android `INTERNET` (normal, sin diálogo).
- Requiere internet para datos reales; sin red muestra el respaldo simulado.
