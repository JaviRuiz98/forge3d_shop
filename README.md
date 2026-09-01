# LayerForge

Tienda ecommerce moderna para piezas fabricadas mediante impresión 3D. Proyecto base completo en Next.js + TypeScript + Tailwind + Supabase.

## Branding

**LayerForge** combina *Layer* (fabricación por capas) y *Forge* (fabricar/dar forma). El isotipo representa un volumen hexagonal con dos capas internas. Paleta: fondo `#09090B`, índigo `#818CF8`, cian `#22D3EE`, blanco técnico `#FAFAFA`. Se incluyen `public/brand/layerforge-logo.svg`, `layerforge-mark.svg` y `public/favicon.svg`.

## 1. Requisitos

- Node.js 20+ (recomendado 22 LTS)
- npm 10+
- Proyecto Supabase

## 2. Preparar Supabase

1. Abre **Supabase → SQL Editor**.
2. Copia íntegramente `supabase/setup.sql`.
3. Ejecútalo una sola vez.
4. En **Authentication → URL Configuration** configura la URL local `http://localhost:3000` y, cuando despliegues, tu dominio real.

El SQL crea tablas, UUID, claves foráneas, índices, constraints, triggers, datos iniciales y RLS. Los usuarios nuevos reciben siempre `CUSTOMER`; nunca se confía en `raw_user_meta_data` para asignar privilegios.

## 3. Variables de entorno

`.env` ya incluye la URL y la **publishable key** proporcionadas. Esta clave está diseñada para frontend y la seguridad efectiva reside en RLS. Nunca añadas `service_role`, contraseñas ni secretos administrativos al cliente.

## 4. Instalar y ejecutar

```bash
npm install
npm run dev
```

Abre `http://localhost:3000`.

Comprobaciones adicionales:

```bash
npm run typecheck
npm run lint
npm run build
```

## 5. Crear el primer administrador

1. Registra una cuenta desde `/cuenta`.
2. Confirma el email si tu proyecto Supabase exige confirmación.
3. En SQL Editor ejecuta, cambiando el email:

```sql
update public.profiles
set role = 'ADMIN'
where id = (select id from auth.users where email = 'tu@email.com');
```

Después entra en `/admin`. Un cliente no puede convertir su propia cuenta en ADMIN: las políticas comparan el rol anterior y las operaciones administrativas usan `is_admin()` en PostgreSQL.

## 6. Estructura

```text
src/
  app/                 App Router: home, catálogo, producto, carrito, checkout, cuenta, admin
  components/          UI, layout, catálogo y providers
  data/                datos demo frontend
  lib/                 Supabase y utilidades
  types/               modelos TypeScript
public/
  brand/               identidad SVG
  products/            imágenes demo propias
supabase/
  setup.sql             instalación integral de BBDD y RLS
```

## 7. Qué funciona ya

- Home responsive y marca propia
- Catálogo con búsqueda, filtros, orden y drawer móvil
- Fichas de producto con variantes y cantidad
- Carrito persistente en `localStorage`
- Checkout de demostración (sin procesar dinero)
- Registro/login/logout con Supabase Auth
- Área privada base
- Panel admin con comprobación de rol en `profiles`
- Esquema Supabase para productos, imágenes, variantes, materiales, colores, pedidos, direcciones, favoritos, carrito y solicitudes a medida
- SEO base, Open Graph, sitemap y robots
- Assets de demostración locales: sin depender de hotlinks

## 8. Siguiente capa recomendada antes de producción

- Conectar catálogo y CRUD admin directamente a las tablas Supabase (la UI demo usa `src/data/demo.ts` para arrancar sin configuración previa).
- Integrar Supabase Storage para imágenes de producto y, más adelante, STL/OBJ/3MF con buckets privados y URLs firmadas.
- Implementar un backend/Edge Function para crear pedidos y calcular precios en servidor: **no confiar en importes enviados desde el navegador**.
- Integrar Stripe Checkout o Payment Intents / PayPal mediante funciones de servidor; nunca almacenar datos bancarios.
- Incorporar email transaccional, transporte, devoluciones y textos legales.
- Sustituir `https://layerforge.example` en metadata/sitemap por el dominio final.

## 9. Despliegue

Compatible con Vercel y cualquier plataforma Node que soporte Next.js. Añade las variables `NEXT_PUBLIC_SUPABASE_URL` y `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` en el panel del proveedor y ejecuta `npm run build`.

## Decisiones UX

El catálogo usa filtros visibles en escritorio y un drawer con botón de aplicar en móvil; las variantes usan controles explícitos y el contenido técnico queda separado para mantener legible la decisión de compra. Se ha priorizado tamaño táctil, ausencia de diálogos que desborden, navegación rápida y carga de imágenes optimizada mediante `next/image`.

## Despliegue en GitHub Pages

Este proyecto está preparado para exportación estática de Next.js y despliegue automático en GitHub Pages mediante `.github/workflows/deploy-pages.yml`.

1. Sube el proyecto al repositorio `javiruiz98/forge3d_shop` en la rama `main`.
2. En GitHub abre **Settings → Pages** y selecciona **GitHub Actions** como fuente.
3. En **Settings → Secrets and variables → Actions**, crea estos Repository secrets:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`
4. Haz `git push`. El workflow compilará la aplicación con `NEXT_PUBLIC_BASE_PATH=/forge3d_shop`, generará `out/` y la publicará.
5. La URL resultante será `https://javiruiz98.github.io/forge3d_shop/`.

Para desarrollo local sigue usando `npm run dev`; no es necesario establecer `NEXT_PUBLIC_BASE_PATH` localmente.
