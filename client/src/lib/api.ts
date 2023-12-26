const apiUrl = "http://localhost:8080/";

export const index = async (url: string) => {
  const payload = { url };
  const indexUrl = apiUrl+"/index";

  await fetch(indexUrl, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    },
    body: JSON.stringify(payload),
  });
} 

type SearchPayload = {
  uri: string;
  query: string;
}

export const search = async (payload: SearchPayload) => {
  await fetch("http://localhost:8080/search" , {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export default { index, search }
