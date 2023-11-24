module Main where

import qualified Lexer (tokenize)
import Debug.Trace

main :: IO ()
main = print $ Lexer.tokenize "pogchamp kekw omegalul"  
