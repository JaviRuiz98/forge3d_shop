-- LayerForge · Supabase setup
-- Ejecutar una sola vez en Supabase SQL Editor sobre un proyecto nuevo.
create extension if not exists pgcrypto;

do $$ begin create type public.app_role as enum ('ADMIN','CUSTOMER'); exception when duplicate_object then null; end $$;
do $$ begin create type public.order_status as enum ('pending','confirmed','manufacturing','ready','shipped','delivered','cancelled'); exception when duplicate_object then null; end $$;

create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 full_name text, phone text, role public.app_role not null default 'CUSTOMER',
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.categories (
 id uuid primary key default gen_random_uuid(), name text not null unique, slug text not null unique,
 description text, active boolean not null default true, sort_order int not null default 0,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.materials (
 id uuid primary key default gen_random_uuid(), name text not null unique, slug text not null unique, description text, active boolean not null default true
);
create table if not exists public.colors (
 id uuid primary key default gen_random_uuid(), name text not null unique, hex text check (hex is null or hex ~ '^#[0-9A-Fa-f]{6}$'), active boolean not null default true
);
create table if not exists public.products (
 id uuid primary key default gen_random_uuid(), category_id uuid references public.categories(id) on delete set null,
 name text not null, slug text not null unique, sku text not null unique, short_description text, description text, technical_description text,
 price_cents int not null check(price_cents>=0), tax_rate numeric(5,2) not null default 21.00 check(tax_rate>=0), stock int not null default 0 check(stock>=0),
 dimensions text, weight_grams int check(weight_grams is null or weight_grams>=0), lead_time_hours int check(lead_time_hours is null or lead_time_hours>=0),
 published boolean not null default false, featured boolean not null default false, is_new boolean not null default false, customizable boolean not null default false,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.product_images (
 id uuid primary key default gen_random_uuid(), product_id uuid not null references public.products(id) on delete cascade,
 url text not null, alt text, sort_order int not null default 0, created_at timestamptz not null default now()
);
create table if not exists public.product_variants (
 id uuid primary key default gen_random_uuid(), product_id uuid not null references public.products(id) on delete cascade,
 material_id uuid references public.materials(id) on delete set null, color_id uuid references public.colors(id) on delete set null,
 sku text unique, price_delta_cents int not null default 0, stock int not null default 0 check(stock>=0), active boolean not null default true,
 unique(product_id, material_id, color_id)
);
create table if not exists public.addresses (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
 label text, first_name text not null, last_name text not null, phone text, address1 text not null, address2 text, city text not null,
 province text not null, postal_code text not null, country text not null default 'España', is_default boolean not null default false, created_at timestamptz not null default now()
);
create table if not exists public.orders (
 id uuid primary key default gen_random_uuid(), order_number bigint generated always as identity unique, user_id uuid references auth.users(id) on delete set null,
 status public.order_status not null default 'pending', email text not null, phone text, shipping_address jsonb not null,
 notes text, subtotal_cents int not null check(subtotal_cents>=0), tax_cents int not null check(tax_cents>=0), shipping_cents int not null default 0 check(shipping_cents>=0), total_cents int not null check(total_cents>=0),
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.order_items (
 id uuid primary key default gen_random_uuid(), order_id uuid not null references public.orders(id) on delete cascade,
 product_id uuid references public.products(id) on delete set null, variant_id uuid references public.product_variants(id) on delete set null,
 product_name text not null, sku text, quantity int not null check(quantity>0), unit_price_cents int not null check(unit_price_cents>=0), line_total_cents int not null check(line_total_cents>=0), customization jsonb
);
create table if not exists public.favorites (
 user_id uuid not null references auth.users(id) on delete cascade, product_id uuid not null references public.products(id) on delete cascade,
 created_at timestamptz not null default now(), primary key(user_id,product_id)
);
create table if not exists public.cart_items (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
 product_id uuid not null references public.products(id) on delete cascade, variant_id uuid references public.product_variants(id) on delete cascade,
 quantity int not null default 1 check(quantity>0), customization jsonb, created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 unique(user_id, product_id, variant_id)
);
create table if not exists public.custom_product_requests (
 id uuid primary key default gen_random_uuid(), user_id uuid references auth.users(id) on delete set null,
 email text, title text not null, description text not null, dimensions text, material text, color text, finish text, custom_text text,
 source_file_path text, source_file_type text check(source_file_type is null or source_file_type in ('STL','OBJ','3MF')),
 status text not null default 'new' check(status in ('new','reviewing','quoted','accepted','rejected','closed')), created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create index if not exists idx_products_category on public.products(category_id);
create index if not exists idx_products_published_featured on public.products(published,featured);
create index if not exists idx_products_price on public.products(price_cents);
create index if not exists idx_orders_user_created on public.orders(user_id,created_at desc);
create index if not exists idx_order_items_order on public.order_items(order_id);
create index if not exists idx_cart_user on public.cart_items(user_id);
create index if not exists idx_custom_requests_user on public.custom_product_requests(user_id);

create or replace function public.set_updated_at() returns trigger language plpgsql as $$ begin new.updated_at=now(); return new; end $$;
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$ begin insert into public.profiles(id,full_name,role) values(new.id,coalesce(new.raw_user_meta_data->>'full_name',''),'CUSTOMER') on conflict(id) do nothing; return new; end $$;
create or replace function public.current_role() returns public.app_role language sql stable security definer set search_path=public as $$ select p.role from public.profiles p where p.id=auth.uid(); $$;
create or replace function public.is_admin() returns boolean language sql stable security definer set search_path=public as $$ select coalesce(public.current_role()='ADMIN', false); $$;
revoke all on function public.current_role() from public; grant execute on function public.current_role() to authenticated;
revoke all on function public.is_admin() from public; grant execute on function public.is_admin() to anon, authenticated;

drop trigger if exists on_auth_user_created on auth.users; create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();
create or replace function public.add_updated_trigger(tbl regclass) returns void language plpgsql as $$ begin execute format('drop trigger if exists set_updated_at on %s',tbl);execute format('create trigger set_updated_at before update on %s for each row execute function public.set_updated_at()',tbl);end $$;
select public.add_updated_trigger('public.profiles');select public.add_updated_trigger('public.categories');select public.add_updated_trigger('public.products');select public.add_updated_trigger('public.orders');select public.add_updated_trigger('public.cart_items');select public.add_updated_trigger('public.custom_product_requests');drop function public.add_updated_trigger(regclass);

alter table public.profiles enable row level security; alter table public.categories enable row level security; alter table public.materials enable row level security; alter table public.colors enable row level security; alter table public.products enable row level security; alter table public.product_images enable row level security; alter table public.product_variants enable row level security; alter table public.addresses enable row level security; alter table public.orders enable row level security; alter table public.order_items enable row level security; alter table public.favorites enable row level security; alter table public.cart_items enable row level security; alter table public.custom_product_requests enable row level security;

-- Public catalog reads
drop policy if exists "public categories read" on public.categories; create policy "public categories read" on public.categories for select using(active or public.is_admin());
drop policy if exists "public materials read" on public.materials; create policy "public materials read" on public.materials for select using(active or public.is_admin());
drop policy if exists "public colors read" on public.colors; create policy "public colors read" on public.colors for select using(active or public.is_admin());
drop policy if exists "public products read" on public.products; create policy "public products read" on public.products for select using(published or public.is_admin());
drop policy if exists "public images read" on public.product_images; create policy "public images read" on public.product_images for select using(exists(select 1 from public.products p where p.id=product_id and (p.published or public.is_admin())));
drop policy if exists "public variants read" on public.product_variants; create policy "public variants read" on public.product_variants for select using(active and exists(select 1 from public.products p where p.id=product_id and p.published) or public.is_admin());

-- Own-account policies. Crucially, customers cannot update profiles.role.
drop policy if exists "profile own read" on public.profiles; create policy "profile own read" on public.profiles for select using(id=auth.uid() or public.is_admin());
drop policy if exists "profile own update" on public.profiles; create policy "profile own update" on public.profiles for update using(id=auth.uid()) with check(id=auth.uid() and role=public.current_role());
drop policy if exists "admin profiles update" on public.profiles; create policy "admin profiles update" on public.profiles for update using(public.is_admin()) with check(public.is_admin());

drop policy if exists "addresses own all" on public.addresses; create policy "addresses own all" on public.addresses for all using(user_id=auth.uid() or public.is_admin()) with check(user_id=auth.uid() or public.is_admin());
drop policy if exists "orders own read" on public.orders; create policy "orders own read" on public.orders for select using(user_id=auth.uid() or public.is_admin());
drop policy if exists "order items own read" on public.order_items; create policy "order items own read" on public.order_items for select using(public.is_admin() or exists(select 1 from public.orders o where o.id=order_id and o.user_id=auth.uid()));
drop policy if exists "favorites own all" on public.favorites; create policy "favorites own all" on public.favorites for all using(user_id=auth.uid()) with check(user_id=auth.uid());
drop policy if exists "cart own all" on public.cart_items; create policy "cart own all" on public.cart_items for all using(user_id=auth.uid()) with check(user_id=auth.uid());
drop policy if exists "custom request own insert" on public.custom_product_requests; create policy "custom request own insert" on public.custom_product_requests for insert with check(user_id=auth.uid() or user_id is null);
drop policy if exists "custom request own read" on public.custom_product_requests; create policy "custom request own read" on public.custom_product_requests for select using(user_id=auth.uid() or public.is_admin());

-- Admin CRUD for catalog and orders
create policy "admin categories write" on public.categories for all using(public.is_admin()) with check(public.is_admin());
create policy "admin materials write" on public.materials for all using(public.is_admin()) with check(public.is_admin());
create policy "admin colors write" on public.colors for all using(public.is_admin()) with check(public.is_admin());
create policy "admin products write" on public.products for all using(public.is_admin()) with check(public.is_admin());
create policy "admin images write" on public.product_images for all using(public.is_admin()) with check(public.is_admin());
create policy "admin variants write" on public.product_variants for all using(public.is_admin()) with check(public.is_admin());
create policy "admin orders write" on public.orders for all using(public.is_admin()) with check(public.is_admin());
create policy "admin order items write" on public.order_items for all using(public.is_admin()) with check(public.is_admin());
create policy "admin custom requests write" on public.custom_product_requests for all using(public.is_admin()) with check(public.is_admin());

insert into public.categories(name,slug,description,sort_order) values
('Soportes','soportes','Soportes impresos para dispositivos y equipos.',10),('Organización','organizacion','Organizadores y gestión de espacio.',20),('Adaptadores','adaptadores','Interfaces y adaptadores mecánicos.',30),('Electrónica','electronica','Cajas y accesorios para electrónica.',40),('Decoración','decoracion','Objetos decorativos funcionales.',50)
on conflict(slug) do nothing;
insert into public.materials(name,slug,description) values ('PLA','pla','Rígido y versátil'),('PETG','petg','Resistente y tenaz'),('ABS','abs','Técnico y mecanizable'),('TPU','tpu','Flexible'),('ASA','asa','Resistente a UV y exterior'),('Resina','resina','Alta definición') on conflict(slug) do nothing;
insert into public.colors(name,hex) values ('Grafito','#27272A'),('Negro','#09090B'),('Blanco','#FAFAFA'),('Azul','#2563EB'),('Arena','#D6C7A1') on conflict(name) do nothing;

-- IMPORTANTE: no se crea un ADMIN automáticamente. Tras registrarte, ejecuta manualmente:
-- update public.profiles set role='ADMIN' where id=(select id from auth.users where email='TU_EMAIL');
