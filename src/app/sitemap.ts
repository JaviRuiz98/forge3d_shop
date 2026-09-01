import type {MetadataRoute} from 'next';
import {products} from '@/data/demo';

export default function sitemap():MetadataRoute.Sitemap {
  const site = process.env.NEXT_PUBLIC_SITE_URL ?? 'https://javiruiz98.github.io/forge3d_shop';
  return [
    {url:`${site}/`,lastModified:new Date()},
    {url:`${site}/catalogo/`,lastModified:new Date()},
    {url:`${site}/personalizado/`,lastModified:new Date()},
    ...products.map(p=>({url:`${site}/producto/${p.slug}/`,lastModified:new Date()})),
  ];
}
