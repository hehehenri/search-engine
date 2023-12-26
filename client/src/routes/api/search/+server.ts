export type Payload = {
  url: string;
  query: string;
}

export async function POST(payload: Payload) {
  console.log("hit on server");

  let api = "https://api.publicapis.org/entries";
  const resp = await fetch(api);

  console.log({fetched: resp})

  return resp;
}
