module Main where

import qualified Lexer (tokenize)

main :: IO ()
main = 
  let _ = Lexer.tokenize "pogchamp limao 12 limao3. kewk;;" in
  return ()
