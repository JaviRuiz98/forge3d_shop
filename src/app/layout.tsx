import type {Metadata} from 'next';
import './globals.css';
import {Header} from '@/components/layout/Header';
import {Footer} from '@/components/layout/Footer';
import {CartProvider} from '@/components/providers/CartProvider';
import {Toaster} from 'sonner';
import {basePath} from '@/lib/paths';

const siteUrl = process.env.NEXT_PUBLIC_SITE_URL ?? 'https://javiruiz98.github.io/forge3d_shop';

export const metadata:Metadata={
  metadataBase:new URL(siteUrl),
  title:{default:'LayerForge | Piezas impresas en 3D',template:'%s | LayerForge'},
  description:'Piezas técnicas, accesorios y fabricación 3D bajo demanda.',
  icons:{icon:`${basePath}/favicon.svg`},
  openGraph:{title:'LayerForge',description:'Fabricación digital útil, capa a capa.',type:'website',url:siteUrl},
};

export default function RootLayout({children}:{children:React.ReactNode}){
  return <html lang="es"><body><CartProvider><Header/><main>{children}</main><Footer/><Toaster richColors position="bottom-right"/></CartProvider></body></html>;
}
