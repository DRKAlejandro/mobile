# Módulo 2.13 · CRUD Canciones

Sistema ligero para **agregar canciones** que enseña las 4 operaciones CRUD
(Crear, Leer, Actualizar, Borrar) contra una tabla remota de **Supabase**.

## Qué enseña

| Letra | Operación | Dónde verla |
|-------|-----------|-------------|
| C | `crear()` | Botón + → formulario → `insert` |
| R | `listar()` | Lista inicial + búsqueda → `select` |
| U | `actualizar()` / `alternarFavorita()` | Editar y estrella → `update` |
| D | `eliminar()` | Basurero con confirmación → `delete` |

Patrones de apoyo: servicio con interfaz inyectable (`CancionService`),
falso en memoria para tests (`MemoriaCancionService`) y errores propios
contenidos en la pantalla (como el módulo 2.12).

## Puesta en marcha (5 min)

1. **Crea un proyecto gratuito** en supabase.com (región cercana).
2. **Crea la tabla**: SQL Editor → New query → pega TODO el contenido de
   `first_project/base de datos/tabla_canciones.sql` → Run.
   Verás `total = 4, favoritas >= 1` en la verificación final.
   El script es re-ejecutable (no falla si lo corres dos veces).
3. **Copia tus claves**: Project Settings → API → `Project URL` y `anon-key`.
4. **Ejecuta la app con tus claves** (nunca se guardan en el repo):

```powershell
flutter run --dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co --dart-define=SUPABASE_ANON_KEY=tu-anon-key
```

Sin los flags verás el aviso "Falta configurar Supabase" (esperado, no es un error).

## Estructura

```text
modulo_2_13_crud/
├── screen.dart            # Pantalla: explicación + búsqueda + lista + FAB
├── models/cancion.dart    # Modelo (fromJson/toJson espejo de columnas SQL)
├── services/
│   ├── cancion_service.dart          # Interfaz + excepciones propias
│   ├── supabase_cancion_service.dart # Implementación real (PostgREST)
│   └── memoria_cancion_service.dart  # Falso en memoria (tests/demo sin red)
├── widgets/
│   ├── fila_cancion.dart      # Fila con estrella, editar y borrar
│   └── formulario_cancion.dart # Diálogo alta/edición con validación
├── supabase_config.dart   # Lee --dart-define (sin secretos en código)
└── README.md              # Este archivo
```

## Nota sobre seguridad (RLS)

Las políticas del SQL son **abiertas a propósito y solo para clase**:
todos comparten la misma lista sin login. En una app real se activaría
Auth y se restringiría por usuario (`auth.uid()`). Ver comentarios
`-- SOLO USO DIDÁCTICO` dentro del `.sql`.
