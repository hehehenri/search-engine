import type { Load } from "@sveltejs/kit";
import { error } from "@sveltejs/kit";

export type URI = string;

export const load: Load = async ({ params }) => {  
  if (!params.uri) throw error(404, 'URI not provided.');
  if (!params.query) throw error(404, 'Query not provided.');

  const uri = decodeURIComponent(params.uri);
  
  return { uri };
}
