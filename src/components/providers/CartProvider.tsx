'use client';
import { CartItem, Material, Product } from '@/types';
import { createContext, useContext, useEffect, useMemo, useState } from 'react';
import { toast } from 'sonner';
type Ctx = { items: CartItem[]; count:number; subtotal:number; add:(p:Product,q?:number,color?:string,material?:Material)=>void; remove:(id:string)=>void; setQty:(id:string,q:number)=>void; clear:()=>void };
const CartContext=createContext<Ctx|null>(null);
export function CartProvider({children}:{children:React.ReactNode}){
 const [items,setItems]=useState<CartItem[]>([]); const [ready,setReady]=useState(false);
 useEffect(()=>{try{const raw=localStorage.getItem('layerforge-cart'); if(raw)setItems(JSON.parse(raw));}finally{setReady(true)}},[]);
 useEffect(()=>{if(ready)localStorage.setItem('layerforge-cart',JSON.stringify(items))},[items,ready]);
 const add=(product:Product,quantity=1,color=product.color,material=product.material)=>{setItems(prev=>{const i=prev.findIndex(x=>x.product.id===product.id&&x.color===color&&x.material===material);if(i<0)return [...prev,{product,quantity,color,material}];return prev.map((x,n)=>n===i?{...x,quantity:x.quantity+quantity}:x)});toast.success('Añadido al carrito')};
 const remove=(id:string)=>setItems(p=>p.filter(x=>x.product.id!==id)); const setQty=(id:string,q:number)=>setItems(p=>p.map(x=>x.product.id===id?{...x,quantity:Math.max(1,q)}:x));
 const value=useMemo(()=>({items,count:items.reduce((a,x)=>a+x.quantity,0),subtotal:items.reduce((a,x)=>a+x.product.price*x.quantity,0),add,remove,setQty,clear:()=>setItems([])}),[items]);
 return <CartContext.Provider value={value}>{children}</CartContext.Provider>;
}
export const useCart=()=>{const c=useContext(CartContext);if(!c)throw new Error('useCart fuera de CartProvider');return c};
