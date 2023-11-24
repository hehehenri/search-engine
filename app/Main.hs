module Main where

import qualified Lexer (tokenize)
import qualified Doc (parseUrl)
import Debug.Trace

main :: IO ()
main = do
  doc <- Doc.parseUrl "https://www.haskell.org/"
  let tokens = Lexer.tokenize doc in
    putStr $ show tokens
