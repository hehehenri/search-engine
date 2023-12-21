let install_uuid =
  [%rapper
    execute 
      {sql| CREATE EXTENSION IF NOT EXISTS "uuid-ossp"; |sql}
  ]

let create_tokens_table =
  [%rapper
    execute
      {sql|
        CREATE TABLE tokens (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          content TEXT NOT NULL,
          kind VARCHAR(255) NOT NULL,
          occurrences INT NOT NULL,
          document_url TEXT NOT NULL,
          created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
        )
      |sql}
  ]

(* TODO: how bad is to store each token individually? *)
let insert_token =
  [%rapper
    execute
      {sql|
        INSERT INTO tokens (@string{content}, @string{kind}, @int{occurrences}, @string{document_url})
        VALUES (%string{content}, %string{kind}, %int{occurrences}, %string{document_url})
      |sql}
  ]  

let get_all_tokens =
  [%rapper
    get_many
      {sql|
        SELECT
          @string{id},
          @string{content},
          @string{kind},
          @int{occurrences},
          @string{document_url},
          @string{created_at}
        FROM tokens
      |sql}
      function_out]
    (fun ~id ~content ~kind ~occurrences ~document_url ~created_at ->
      Identifiers.Token.({
        id; content; kind; occurrences; document_url; created_at
      }))

(* TODO: manage to store multiple tokens at the same time *)
(* let insert_tokens ~tokens = *)
(*   let tokens = tokens_to_yojson tokens *)
(*     |> Yojson.Safe.to_string in *)
  
(*   [%rapper  *)
(*     execute *)
(*       {sql| *)
(*         INSERT INTO tokens ( *)
(*           SELECT * FROM JSONB_POPULATE_RECORDSET( *)
(*             NULL::tokens,  *)
(*             %string{tokens} *)
(*           ) *)
(*         ) *)
(*       |sql} *)
(*   ] *)
