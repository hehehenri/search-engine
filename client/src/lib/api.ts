const api = "http://localhost:8080/";

export const index = async (url: string) => {
  const payload = { url };

  await fetch(api, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    },
    body: JSON.stringify(payload),
  });
} 

export default { index }
