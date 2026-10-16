-- =============================================================
-- pizza_pizza · Esquema `pizzería` para Supabase (8 tablas)
-- =============================================================
-- Cómo usar (SQL Editor de Supabase → New query → pegar todo → Run):
--   1. Ejecuta este archivo COMPLETO y en orden. Las 4 partes son
--      obligatorias y dependen entre sí (ver "Por qué todo" abajo).
--   2. Verifica con la consulta del final:
--      sucursales=1, categorias=3, ingredientes=8, pizzas=5,
--      pizza_ingredientes=15, usuarios>=1, pedidos>=1, pedido_detalle>=2.
--   3. En Authentication → Providers habilita Email, y ejecuta la app con:
--      flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co
--                  --dart-define=SUPABASE_ANON_KEY=tu-anon-key
--
-- Por qué TODO:
--   - Solo las tablas (parte 1) NO bastan: Supabase activa RLS por
--     defecto y sin políticas el rol `anon` (el que usa la app) no
--     puede leer ni escribir. Síntoma: GET devuelve 200 con `[]`
--     vacío aunque la URL y la key sean correctas.
--   - Sin el seed (parte 3), la conexión es correcta pero no hay
--     sucursal ni pizzas que mostrar.
--   - Sin la verificación (parte 4) no sabes si el seed quedó
--     completo o a medias.
-- Re-ejecución: el archivo es idempotente. El catálogo usa
-- `on conflict do nothing` (nombres UNIQUE) y el pedido demo se
-- borra y recrea por email, así que puedes correrlo N veces.
-- =============================================================

-- -------------------------------------------------------------
-- 1. TABLAS (idempotentes: no fallan si ya existen).
-- Orden respeta las llaves foráneas:
-- usuarios, sucursales, categorias → pizzas → ingredientes →
-- pizza_ingredientes → pedidos → pedido_detalle.
-- -------------------------------------------------------------

create table if not exists usuarios (
  id bigint generated always as identity primary key,
  -- Vínculo con Supabase Auth (auth.users.id). La app lo llena al
  -- registrarse / entrar. NUNCA guarda contraseñas (FR-012).
  auth_id uuid not null unique,
  nombre text not null check (char_length(nombre) > 0 and char_length(nombre) <= 80),
  email text not null unique check (email like '%@%'),
  telefono text check (telefono is null or char_length(telefono) <= 20),
  created_at timestamptz not null default now()
);

create table if not exists sucursales (
  id bigint generated always as identity primary key,
  nombre text not null unique check (char_length(nombre) > 0 and char_length(nombre) <= 80),
  direccion text not null check (char_length(direccion) > 0 and char_length(direccion) <= 200),
  telefono text check (telefono is null or char_length(telefono) <= 20),
  horario text check (horario is null or char_length(horario) <= 80),
  -- Coordenadas listas para el mapa futuro (este spec no usa mapas).
  latitud double precision not null check (latitud between -90 and 90),
  longitud double precision not null check (longitud between -180 and 180),
  created_at timestamptz not null default now()
);

create table if not exists categorias (
  id bigint generated always as identity primary key,
  nombre text not null unique check (char_length(nombre) > 0 and char_length(nombre) <= 40),
  descripcion text check (descripcion is null or char_length(descripcion) <= 200)
);

create table if not exists pizzas (
  id bigint generated always as identity primary key,
  categoria_id bigint not null references categorias (id) on delete restrict,
  nombre text not null unique check (char_length(nombre) > 0 and char_length(nombre) <= 80),
  descripcion text check (descripcion is null or char_length(descripcion) <= 300),
  precio numeric(10, 2) not null check (precio > 0),
  disponible boolean not null default true,
  imagen_url text check (imagen_url is null or char_length(imagen_url) <= 500),
  created_at timestamptz not null default now()
);

create table if not exists ingredientes (
  id bigint generated always as identity primary key,
  nombre text not null unique check (char_length(nombre) > 0 and char_length(nombre) <= 40)
);

-- Pivote muchos-a-muchos: qué lleva cada pizza (FR-015).
create table if not exists pizza_ingredientes (
  pizza_id bigint not null references pizzas (id) on delete cascade,
  ingrediente_id bigint not null references ingredientes (id) on delete restrict,
  primary key (pizza_id, ingrediente_id)
);

create table if not exists pedidos (
  id bigint generated always as identity primary key,
  usuario_id bigint not null references usuarios (id) on delete restrict,
  sucursal_id bigint not null references sucursales (id) on delete restrict,
  estado text not null default 'pendiente'
    check (estado in ('pendiente', 'en_preparacion', 'entregado', 'cancelado')),
  total numeric(10, 2) not null check (total >= 0),
  created_at timestamptz not null default now()
);

-- Líneas del pedido. `precio_unitario` congela el precio histórico
-- aunque el catálogo cambie después (FR-011).
create table if not exists pedido_detalle (
  id bigint generated always as identity primary key,
  pedido_id bigint not null references pedidos (id) on delete cascade,
  pizza_id bigint not null references pizzas (id) on delete restrict,
  cantidad int not null check (cantidad > 0),
  precio_unitario numeric(10, 2) not null check (precio_unitario > 0),
  subtotal numeric(10, 2) not null check (subtotal = cantidad * precio_unitario)
);

-- -------------------------------------------------------------
-- 2. SEGURIDAD RLS + políticas (patrón didáctico first_project).
-- `enable row level security` cierra cada tabla por defecto y cada
-- `create policy ... to anon` reabre lo que la app necesita:
--   - Catálogo y sucursal: solo LECTURA pública (el menú se muestra
--     sin sesión).
--   - usuarios / pedidos / pedido_detalle: CRUD completo porque la
--     app crea el perfil y los pedidos desde el cliente.
-- Los `drop policy if exists` permiten re-ejecutar sin error.
-- -- SOLO USO DIDÁCTICO: jamás usar políticas abiertas en producción.
-- Para endurecer: activar Auth por email y usar `auth.uid()` en las
-- políticas en vez de `(true)`.
-- -------------------------------------------------------------

alter table sucursales enable row level security;
alter table categorias enable row level security;
alter table pizzas enable row level security;
alter table ingredientes enable row level security;
alter table pizza_ingredientes enable row level security;
alter table usuarios enable row level security;
alter table pedidos enable row level security;
alter table pedido_detalle enable row level security;

-- Catálogo público de solo lectura (5 tablas × 1 política).
drop policy if exists "sucursales_select" on sucursales;
create policy "sucursales_select" on sucursales for select to anon using (true);

drop policy if exists "categorias_select" on categorias;
create policy "categorias_select" on categorias for select to anon using (true);

drop policy if exists "pizzas_select" on pizzas;
create policy "pizzas_select" on pizzas for select to anon using (true);

drop policy if exists "ingredientes_select" on ingredientes;
create policy "ingredientes_select" on ingredientes for select to anon using (true);

drop policy if exists "pizza_ingredientes_select" on pizza_ingredientes;
-- SOLO USO DIDÁCTICO (ver nota arriba).
create policy "pizza_ingredientes_select" on pizza_ingredientes for select to anon using (true);

-- Perfil y pedidos: CRUD completo didáctico (3 tablas × 4 políticas).
drop policy if exists "usuarios_select" on usuarios;
create policy "usuarios_select" on usuarios for select to anon using (true);
drop policy if exists "usuarios_insert" on usuarios;
create policy "usuarios_insert" on usuarios for insert to anon with check (true);
drop policy if exists "usuarios_update" on usuarios;
create policy "usuarios_update" on usuarios for update to anon using (true) with check (true);
drop policy if exists "usuarios_delete" on usuarios;
create policy "usuarios_delete" on usuarios for delete to anon using (true);

drop policy if exists "pedidos_select" on pedidos;
create policy "pedidos_select" on pedidos for select to anon using (true);
drop policy if exists "pedidos_insert" on pedidos;
create policy "pedidos_insert" on pedidos for insert to anon with check (true);
drop policy if exists "pedidos_update" on pedidos;
create policy "pedidos_update" on pedidos for update to anon using (true) with check (true);
drop policy if exists "pedidos_delete" on pedidos;
create policy "pedidos_delete" on pedidos for delete to anon using (true);

drop policy if exists "pedido_detalle_select" on pedido_detalle;
create policy "pedido_detalle_select" on pedido_detalle for select to anon using (true);
drop policy if exists "pedido_detalle_insert" on pedido_detalle;
-- SOLO USO DIDÁCTICO (ver nota arriba).
create policy "pedido_detalle_insert" on pedido_detalle for insert to anon with check (true);
drop policy if exists "pedido_detalle_update" on pedido_detalle;
create policy "pedido_detalle_update" on pedido_detalle for update to anon using (true) with check (true);
drop policy if exists "pedido_detalle_delete" on pedido_detalle;
create policy "pedido_detalle_delete" on pedido_detalle for delete to anon using (true);

-- -------------------------------------------------------------
-- 3. DATOS DE EJEMPLO (seed mínimo FR-016).
-- Catálogo con `on conflict do nothing`: seguro re-ejecutar.
-- El pedido demo se borra y recrea por email: también re-ejecutable.
-- -------------------------------------------------------------

-- 3a. La tienda (1 sucursal con coordenadas para el mapa futuro).
insert into sucursales (nombre, direccion, telefono, horario, latitud, longitud)
values (
  'Pizza Pizza Centro',
  'Av. Juárez 123, Centro, CDMX',
  '5551234567',
  'Lun–Dom 12:00–23:00',
  19.4326,
  -99.1332
)
on conflict (nombre) do nothing;

-- 3b. Categorías (3).
insert into categorias (nombre, descripcion)
values
  ('Clásicas', 'Las de siempre, para todos los gustos'),
  ('Especiales', 'Creaciones de la casa'),
  ('Vegetarianas', 'Sin carne, con mucho sabor')
on conflict (nombre) do nothing;

-- 3c. Ingredientes (8).
insert into ingredientes (nombre)
values
  ('mozzarella'),
  ('pepperoni'),
  ('jamón'),
  ('champiñones'),
  ('cebolla'),
  ('albahaca'),
  ('aceitunas'),
  ('piña')
on conflict (nombre) do nothing;

-- 3d. Pizzas (5) con su categoría por nombre.
insert into pizzas (categoria_id, nombre, descripcion, precio)
values
  ((select id from categorias where nombre = 'Vegetarianas'),
   'Margarita', 'Mozzarella fundido y albahaca fresca', 159.00),
  ((select id from categorias where nombre = 'Clásicas'),
   'Pepperoni Clásica', 'Doble pepperoni con mozzarella', 199.00),
  ((select id from categorias where nombre = 'Clásicas'),
   'Hawaiana', 'Jamón y piña con mozzarella', 179.00),
  ((select id from categorias where nombre = 'Especiales'),
   'Funghi Especial', 'Champiñones, jamón y cebolla', 219.00),
  ((select id from categorias where nombre = 'Vegetarianas'),
   'Veggie Suprema', 'Champiñones, cebolla y aceitunas', 189.00)
on conflict (nombre) do nothing;

-- 3e. Composición de cada pizza (15 relaciones).
insert into pizza_ingredientes (pizza_id, ingrediente_id)
values
  ((select id from pizzas where nombre = 'Margarita'),
   (select id from ingredientes where nombre = 'mozzarella')),
  ((select id from pizzas where nombre = 'Margarita'),
   (select id from ingredientes where nombre = 'albahaca')),
  ((select id from pizzas where nombre = 'Pepperoni Clásica'),
   (select id from ingredientes where nombre = 'mozzarella')),
  ((select id from pizzas where nombre = 'Pepperoni Clásica'),
   (select id from ingredientes where nombre = 'pepperoni')),
  ((select id from pizzas where nombre = 'Pepperoni Clásica'),
   (select id from ingredientes where nombre = 'cebolla')),
  ((select id from pizzas where nombre = 'Hawaiana'),
   (select id from ingredientes where nombre = 'mozzarella')),
  ((select id from pizzas where nombre = 'Hawaiana'),
   (select id from ingredientes where nombre = 'jamón')),
  ((select id from pizzas where nombre = 'Hawaiana'),
   (select id from ingredientes where nombre = 'piña')),
  ((select id from pizzas where nombre = 'Funghi Especial'),
   (select id from ingredientes where nombre = 'mozzarella')),
  ((select id from pizzas where nombre = 'Funghi Especial'),
   (select id from ingredientes where nombre = 'champiñones')),
  ((select id from pizzas where nombre = 'Funghi Especial'),
   (select id from ingredientes where nombre = 'jamón')),
  ((select id from pizzas where nombre = 'Funghi Especial'),
   (select id from ingredientes where nombre = 'cebolla')),
  ((select id from pizzas where nombre = 'Veggie Suprema'),
   (select id from ingredientes where nombre = 'mozzarella')),
  ((select id from pizzas where nombre = 'Veggie Suprema'),
   (select id from ingredientes where nombre = 'champiñones')),
  ((select id from pizzas where nombre = 'Veggie Suprema'),
   (select id from ingredientes where nombre = 'aceitunas'))
on conflict do nothing;

-- 3f. Pedido demo (se recrea en cada ejecución).
delete from pedido_detalle
where pedido_id in (
  select p.id from pedidos p
  join usuarios u on u.id = p.usuario_id
  where u.email = 'demo@pizzapizza.mx'
);
delete from pedidos
where usuario_id in (select id from usuarios where email = 'demo@pizzapizza.mx');
delete from usuarios where email = 'demo@pizzapizza.mx';

-- `auth_id` ficticio: en la app real lo pone Supabase Auth al registrarse.
insert into usuarios (auth_id, nombre, email, telefono)
values (
  '00000000-0000-0000-0000-000000000001',
  'Demo Pizza',
  'demo@pizzapizza.mx',
  '5551234567'
)
on conflict (email) do nothing;

-- Pedido: 1 Pepperoni (199) + 1 Margarita (159) = 358.00.
insert into pedidos (usuario_id, sucursal_id, estado, total)
values (
  (select id from usuarios where email = 'demo@pizzapizza.mx'),
  (select id from sucursales where nombre = 'Pizza Pizza Centro'),
  'entregado',
  358.00
);

insert into pedido_detalle (pedido_id, pizza_id, cantidad, precio_unitario, subtotal)
values
  ((select p.id from pedidos p
    join usuarios u on u.id = p.usuario_id
    where u.email = 'demo@pizzapizza.mx'
    order by p.id desc limit 1),
   (select id from pizzas where nombre = 'Pepperoni Clásica'),
   1, 199.00, 199.00),
  ((select p.id from pedidos p
    join usuarios u on u.id = p.usuario_id
    where u.email = 'demo@pizzapizza.mx'
    order by p.id desc limit 1),
   (select id from pizzas where nombre = 'Margarita'),
   1, 159.00, 159.00);

-- -------------------------------------------------------------
-- 4. VERIFICACIÓN (SC-003 / contrato sql-schema.md).
-- Esperado: 1, 3, 8, 5, 15, >=1, >=1, >=2.
-- -------------------------------------------------------------
select 'sucursales' as tabla, count(*) as total from sucursales
union all select 'categorias', count(*) from categorias
union all select 'ingredientes', count(*) from ingredientes
union all select 'pizzas', count(*) from pizzas
union all select 'pizza_ingredientes', count(*) from pizza_ingredientes
union all select 'usuarios', count(*) from usuarios
union all select 'pedidos', count(*) from pedidos
union all select 'pedido_detalle', count(*) from pedido_detalle;

-- El pedido demo cuadra: sucursal → pedido → detalle → pizza.
select
  s.nombre as sucursal,
  p.estado as estado,
  d.cantidad as cantidad,
  z.nombre as pizza,
  d.subtotal as subtotal,
  p.total as total_pedido
from pedidos p
join sucursales s on s.id = p.sucursal_id
join pedido_detalle d on d.pedido_id = p.id
join pizzas z on z.id = d.pizza_id
join usuarios u on u.id = p.usuario_id
where u.email = 'demo@pizzapizza.mx';

-- Coordenadas listas para el mapa futuro.
select nombre, latitud, longitud from sucursales;
