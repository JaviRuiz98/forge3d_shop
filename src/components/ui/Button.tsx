import Link from 'next/link';
import { ButtonHTMLAttributes } from 'react';
export function Button({className='',...props}:ButtonHTMLAttributes<HTMLButtonElement>){return <button className={`inline-flex min-h-11 items-center justify-center rounded-xl bg-white px-5 py-2.5 text-sm font-semibold text-zinc-950 transition hover:bg-cyan-300 disabled:opacity-50 ${className}`} {...props}/>}
export function LinkButton({href,children,className=''}:{href:string;children:React.ReactNode;className?:string}){return <Link href={href} className={`inline-flex min-h-11 items-center justify-center rounded-xl bg-white px-5 py-2.5 text-sm font-semibold text-zinc-950 transition hover:bg-cyan-300 ${className}`}>{children}</Link>}
