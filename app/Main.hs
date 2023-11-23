module Main where

import qualified Lexer (tokenize)
import Debug.Trace

main :: IO ()
main = do
  let tokens = Lexer.tokenize "pogchamp limao 12 limao3. kewk;;"
    in print tokens
  
