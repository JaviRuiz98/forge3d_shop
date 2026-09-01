import type {MetadataRoute} from 'next';

export default function robots():MetadataRoute.Robots {
  const site = process.env.NEXT_PUBLIC_SITE_URL ?? 'https://javiruiz98.github.io/forge3d_shop';
  return {
    rules:{userAgent:'*',allow:'/',disallow:['/admin/']},
    sitemap:`${site}/sitemap.xml`,
  };
}
