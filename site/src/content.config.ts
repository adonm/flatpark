import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

// Flat content pages (about, policies, trust, guides, conduct, legal).
// Each markdown file's name is its route slug; the Footer is built from this
// collection, so `group` + `order` are what place a page in the footer.
const pages = defineCollection({
  loader: glob({ pattern: '*.md', base: './src/content/pages' }),
  schema: z.object({
    title: z.string(),
    description: z.string(),
    group: z.enum(['Project', 'Docs', 'Community', 'Legal']),
    order: z.number().default(0),
    hideFromFooter: z.boolean().default(false),
  }),
});

export const collections = { pages };
