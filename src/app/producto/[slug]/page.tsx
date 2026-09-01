import {notFound} from 'next/navigation';
import {products} from '@/data/demo';
import {ProductDetailClient} from '@/components/product/ProductDetailClient';

export const dynamicParams = false;

export function generateStaticParams() {
  return products.map((p) => ({slug: p.slug}));
}

export default async function ProductPage({params}:{params:Promise<{slug:string}>}) {
  const {slug} = await params;
  const product = products.find((p) => p.slug === slug);
  if (!product) notFound();
  return <ProductDetailClient p={product}/>;
}
