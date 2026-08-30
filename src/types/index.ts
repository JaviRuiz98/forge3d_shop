export type Material = 'PLA' | 'PETG' | 'ABS' | 'TPU' | 'ASA' | 'Resina';
export type Product = {
  id: string; slug: string; name: string; sku: string; price: number; category: string;
  material: Material; color: string; stock: number; featured?: boolean; new?: boolean;
  bestseller?: boolean; rating: number; reviews: number; image: string; short: string;
  description: string; dimensions: string; weight: string; leadTime: string; customizable?: boolean;
};
export type CartItem = { product: Product; quantity: number; color?: string; material?: Material };
