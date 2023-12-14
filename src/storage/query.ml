let create_tokens_table =
  [%rapper
    execute
      {sql|
        CREATE TABLE tokens (
          token_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          content TEXT NOT NULL,
          kind VARCHAR(255),
          occurrences INT,
          document_url TEXT,
          timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
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
