-- =============================================================
-- Módulo 2.13 · CRUD Canciones — Tabla `canciones` para Supabase
-- =============================================================
-- Cómo usar (SQL Editor de Supabase → New query → pegar todo → Run):
--   1. Ejecuta este archivo COMPLETO y en orden. Las 4 partes son
--      obligatorias y dependen entre sí (ver "Por qué todo" abajo).
--   2. Verifica con la consulta del final (total = 24, favoritas >= 1).
--   3. Copia la Project URL y la publishable/anon-key
--      (Dashboard → Connect → Server API) y ejecuta la app con:
--      flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co
--                  --dart-define=SUPABASE_ANON_KEY=tu-publishable-key
--
-- Por qué TODO (lo comprobado en este proyecto):
--   - Solo la tabla (parte 1) NO basta: Supabase activa RLS por defecto
--     y sin políticas el rol `anon` (el que usa la app sin login) no
--     puede leer ni escribir. Síntoma real visto: GET devuelve 200 con
--     `[]` vacío y el POST devuelve 401, aunque la URL y la key sean
--     correctas. La app muestra lista vacía y nada se guarda.
--   - Sin el seed (parte 3), la conexión es correcta pero la lista sale
--     vacía con el mensaje "Agrega la primera": no es error, no hay filas.
--   - Sin la verificación (parte 4) no sabes si quedaste en 0, 24 o 52
--     filas (el INSERT duplica si se ejecuta dos veces: no tiene UNIQUE).
-- =============================================================

-- 1. Tabla (idempotente: no falla si ya existe).
-- Qué hace: crea `canciones` con id autogenerado, título/artista
-- obligatorios (1–120 caracteres), álbum/año/duración opcionales con
-- validación (año 1900–2100, duración > 0), favorita por defecto `false`
-- y fecha de creación automática.
-- Si se omite: todo lo demás falla con "relation canciones does not
-- exist" y la app muestra el aviso de tabla ausente.
create table if not exists canciones (
  id bigint generated always as identity primary key,
  titulo text not null check (char_length(titulo) > 0 and char_length(titulo) <= 120),
  artista text not null check (char_length(artista) > 0 and char_length(artista) <= 120),
  album text,
  anio int check (anio is null or (anio between 1900 and 2100)),
  duracion_seg int check (duracion_seg is null or duracion_seg > 0),
  favorita boolean not null default false,
  created_at timestamptz not null default now()
);

-- 2. Seguridad a nivel de fila (RLS) + 4 políticas (una por letra CRUD).
-- Qué hace: `enable row level security` cierra la tabla por defecto y cada
-- `create policy ... to anon` reabre UNA operación para la app sin login:
--   - canciones_select → leer la lista y la búsqueda (Read).
--   - canciones_insert → agregar con el botón + (Create).
--   - canciones_update → editar y toggle de favorita (Update).
--   - canciones_delete → borrar con confirmación (Delete).
-- Los `drop policy if exists` previos permiten re-ejecutar sin error.
-- Si se omite: la app "conecta" pero no sirve: el GET devuelve 200 con
-- `[]` y el POST/PUT/DELETE devuelve 401. En Postman se ve igual.
-- -- SOLO USO DIDÁCTICO: jamás usar políticas abiertas en producción.
-- Para endurecer: activar Auth por email y usar `auth.uid()` en las
-- políticas en vez de `(true)`.
alter table canciones enable row level security;

drop policy if exists "canciones_select" on canciones;
-- SOLO USO DIDÁCTICO (ver nota arriba).
create policy "canciones_select" on canciones for select to anon using (true);

drop policy if exists "canciones_insert" on canciones;
-- SOLO USO DIDÁCTICO (ver nota arriba).
create policy "canciones_insert" on canciones for insert to anon with check (true);

drop policy if exists "canciones_update" on canciones;
-- SOLO USO DIDÁCTICO (ver nota arriba).
create policy "canciones_update" on canciones for update to anon using (true) with check (true);

drop policy if exists "canciones_delete" on canciones;
-- SOLO USO DIDÁCTICO (ver nota arriba).
create policy "canciones_delete" on canciones for delete to anon using (true);

-- 3. Canciones de ejemplo (24 reales ES + EN; 3 favoritas para el toggle).
-- Qué hace: deja datos desde el primer minuto para probar lista, búsqueda
-- (filtra por título/artista), estrella de favorita y edición sin altas
-- manuales.
-- El `id` lo genera la base: no se indica en los inserts.
-- NOTA: ejecutar SOLO UNA VEZ sobre tabla vacía (si lo repites, duplica:
-- no hay UNIQUE; así se llegó a 52 filas una vez).
insert into canciones (titulo, artista, album, anio, duracion_seg, favorita) values
  ('Bohemian Rhapsody', 'Queen', 'A Night at the Opera', 1975, 354, true),
  ('Imagine', 'John Lennon', 'Imagine', 1971, 183, false),
  ('La Bamba', 'Ritchie Valens', 'La Bamba (BSO)', 1958, 126, false),
  ('Shape of You', 'Ed Sheeran', 'Divide', 2017, 233, false),
  ('De Musica Ligera', 'Soda Stereo', 'Cancion Animal', 1990, 211, true),
  ('Persiana Americana', 'Soda Stereo', 'Signos', 1986, 289, false),
  ('Eres', 'Cafe Tacvba', 'Re', 1994, 254, false),
  ('Bolero Falaz', 'Aterciopelados', 'La Pipa de la Paz', 1996, 190, false),
  ('La Camisa Negra', 'Juanes', 'Mi Sangre', 2004, 222, false),
  ('Limon y Sal', 'Julieta Venegas', 'Limon y Sal', 2006, 199, false),
  ('Color Esperanza', 'Diego Torres', 'Un Mundo Diferente', 2001, 245, false),
  ('Vivir Mi Vida', 'Marc Anthony', '3.0', 2013, 231, false),
  ('Despacito', 'Luis Fonsi', 'Vida', 2017, 229, true),
  ('La Bicicleta', 'Carlos Vives', 'Vives', 2016, 194, false),
  ('Gasolina', 'Daddy Yankee', 'Barrio Fino', 2004, 192, false),
  ('Oye Como Va', 'Santana', 'Abraxas', 1970, 264, false),
  ('Besame Mucho', 'Consuelo Velazquez', 'Single', 1940, 184, false),
  ('El Rey', 'Jose Alfredo Jimenez', 'El Versatil', 1971, 152, false),
  ('Billie Jean', 'Michael Jackson', 'Thriller', 1982, 294, false),
  ('Hotel California', 'Eagles', 'Hotel California', 1976, 391, false),
  ('Yesterday', 'The Beatles', 'Help!', 1965, 125, false),
  ('Smells Like Teen Spirit', 'Nirvana', 'Nevermind', 1991, 301, false),
  ('Rolling in the Deep', 'Adele', '21', 2010, 228, false),
  ('Counting Stars', 'OneRepublic', 'Native', 2013, 257, false);

-- 4. Verificación post-ejecución (esperado: total = 24, favoritas >= 1).
-- Qué hace: cuenta filas y favoritas para confirmar que tabla + seed
-- quedaron bien. Si da 0 → faltó el seed; si da 48/52 → se ejecutó de
-- más (limpiar con `delete from canciones;` y reinsertar una vez).
-- Para validar conexión+permisos desde fuera (Postman o PowerShell):
-- GET con headers `apikey` y `Authorization: Bearer` (la misma
-- publishable en ambos) debe devolver 200 con filas; un POST de prueba
-- debe devolver 201.
select count(*) as total, count(*) filter (where favorita) as favoritas from canciones;
