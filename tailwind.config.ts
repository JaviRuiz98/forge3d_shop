import type { Config } from 'tailwindcss';
export default {
  content: ['./src/**/*.{js,ts,jsx,tsx,mdx}'],
  theme: {
    extend: {
      boxShadow: { glow: '0 0 50px rgba(99,102,241,.16)' },
      backgroundImage: { grid: 'linear-gradient(rgba(255,255,255,.045) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,.045) 1px, transparent 1px)' }
    },
  },
  plugins: [],
} satisfies Config;
