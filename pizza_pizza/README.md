# Pizza Pizza 🍕

App de pizzería en Flutter (tema anaranjado). Alcance actual: **login,
registro y bienvenida** + esquema SQL de la tienda en Supabase
(sucursal, categorías, pizzas, ingredientes, pedidos y usuarios).

Spec y diseño: `specs/006-pizzeria-auth-tienda/` (spec, plan, contratos,
quickstart, tasks).

## Requisitos

- Flutter 3.47+ / Dart 3.13+
- Proyecto Supabase con proveedor **Email** habilitado
  (Dashboard → Authentication → Providers → Email)

## 1. Base de datos

1. Supabase → **SQL Editor** → **New query**.
2. Pega todo el archivo `base de datos/tabla_pizzeria.sql` → **Run**.
3. Verifica los conteos del final: sucursales=1, categorias=3,
   ingredientes=8, pizzas=5, pizza_ingredientes=15, usuarios≥1,
   pedidos≥1, pedido_detalle≥2.

El archivo es re-ejecutable (idempotente).

## 2. Ejecutar la app

Las claves **nunca van en el repo**: se inyectan con `--dart-define`
(Dashboard → Connect → Server API: Project URL + anon/public key).

```powershell
flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co --dart-define=SUPABASE_ANON_KEY=tu-anon-key
```

Sin flags la app arranca igual y muestra el aviso "Falta configurar".

## 3. Calidad

```powershell
flutter analyze   # sin errores
flutter test      # todo en verde
```

## Estructura

```text
lib/
├── main.dart              # init Supabase + rutas /login /registro /home
├── config/                # SupabaseConfig (--dart-define)
├── theme/                 # AppTheme (naranja, Material 3)
├── services/              # AuthService (Supabase Auth + perfil usuarios)
├── login/ registro/ home/ # las 3 pantallas
└── shared/widgets/        # campos, botón primario, avisos
base de datos/tabla_pizzeria.sql
test/                       # widget tests (login, registro, home, sesión)
```
