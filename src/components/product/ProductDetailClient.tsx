'use client';

import Image from 'next/image';
import Link from 'next/link';
import {Minus, Plus, ShieldCheck, Truck} from 'lucide-react';
import {useState} from 'react';
import {useCart} from '@/components/providers/CartProvider';
import {ProductCard} from '@/components/catalog/ProductCard';
import {products} from '@/data/demo';
import {euro} from '@/lib/format';
import {publicAsset} from '@/lib/paths';
import type {Material, Product} from '@/types';

export function ProductDetailClient({p}:{p:Product}) {
  const [q,setQ]=useState(1);
  const [color,setColor]=useState(p.color ?? 'Negro');
  const [material,setMaterial]=useState<Material>(p.material ?? 'PLA');
  const {add}=useCart();

  return <div className="mx-auto max-w-7xl px-4 py-8 sm:px-6">
    <div className="mb-6 text-sm text-zinc-500"><Link href="/">Inicio</Link> / <Link href="/catalogo">Catálogo</Link> / {p.name}</div>
    <div className="grid gap-10 lg:grid-cols-[1.1fr_.9fr]">
      <div>
        <Image src={publicAsset(p.image)} alt={p.name} width={800} height={620} className="w-full rounded-3xl border border-white/10"/>
        <div className="mt-3 grid grid-cols-3 gap-3">{[1,2,3].map(i=><div key={i} className="aspect-[4/3] rounded-xl border border-white/10 bg-zinc-900 p-4"><Image src={publicAsset(p.image)} alt="Vista de producto" width={240} height={180} className="h-full w-full object-cover opacity-70"/></div>)}</div>
      </div>
      <div className="lg:sticky lg:top-24 lg:self-start">
        <p className="text-xs font-semibold tracking-widest text-cyan-300">{p.sku}</p>
        <h1 className="mt-2 text-4xl font-bold tracking-tight">{p.name}</h1>
        <p className="mt-3 text-zinc-400">{p.short}</p>
        <div className="mt-6 text-3xl font-bold">{euro.format(p.price)} <span className="text-sm font-normal text-zinc-500">IVA incluido</span></div>
        <div className="mt-7 grid gap-5">
          <label className="text-sm font-semibold">Material<select value={material} onChange={e=>setMaterial(e.target.value as Material)} className="mt-2 w-full rounded-xl border border-white/10 bg-zinc-900 p-3 font-normal"><option>PLA</option><option>PETG</option><option>ASA</option><option>TPU</option></select></label>
          <label className="text-sm font-semibold">Color<select value={color} onChange={e=>setColor(e.target.value)} className="mt-2 w-full rounded-xl border border-white/10 bg-zinc-900 p-3 font-normal"><option>Grafito</option><option>Negro</option><option>Blanco</option><option>Azul</option><option>Arena</option></select></label>
          <div className="flex gap-3"><div className="flex items-center rounded-xl border border-white/10"><button onClick={()=>setQ(Math.max(1,q-1))} className="p-3"><Minus size={18}/></button><span className="min-w-9 text-center">{q}</span><button onClick={()=>setQ(q+1)} className="p-3"><Plus size={18}/></button></div><button onClick={()=>add(p,q,color,material)} className="flex-1 rounded-xl bg-white px-5 font-semibold text-zinc-950 hover:bg-cyan-300">Añadir al carrito</button></div>
        </div>
        <div className="mt-6 grid grid-cols-2 gap-3 text-sm"><div className="rounded-xl border border-white/10 p-4"><Truck className="mb-3 text-cyan-300" size={20}/><strong>{p.leadTime}</strong><p className="mt-1 text-zinc-500">Fabricación estimada</p></div><div className="rounded-xl border border-white/10 p-4"><ShieldCheck className="mb-3 text-cyan-300" size={20}/><strong>{p.stock} ud.</strong><p className="mt-1 text-zinc-500">Disponibilidad</p></div></div>
      </div>
    </div>
    <div className="mt-14 grid gap-6 border-t border-white/10 pt-10 md:grid-cols-2"><div><h2 className="text-xl font-semibold">Descripción técnica</h2><p className="mt-4 leading-7 text-zinc-400">{p.description}</p></div><dl className="grid grid-cols-2 gap-4 rounded-2xl bg-zinc-900/60 p-6 text-sm"><div><dt className="text-zinc-500">Dimensiones</dt><dd className="mt-1">{p.dimensions}</dd></div><div><dt className="text-zinc-500">Peso</dt><dd className="mt-1">{p.weight}</dd></div><div><dt className="text-zinc-500">Material base</dt><dd className="mt-1">{p.material}</dd></div><div><dt className="text-zinc-500">Acabado</dt><dd className="mt-1">FDM técnico</dd></div></dl></div>
    <section className="mt-16"><h2 className="text-2xl font-bold">También puede encajarte</h2><div className="mt-6 grid gap-5 sm:grid-cols-2 lg:grid-cols-3">{products.filter(x=>x.id!==p.id).slice(0,3).map(x=><ProductCard key={x.id} p={x}/>)}</div></section>
  </div>;
}
