module Lexer(tokenize) where

import Data.Char
import Text.Read.Lex
import Debug.Trace

data Token = Word String | Symbol String | Number String deriving(Show)

tokenize :: String -> [Token]
tokenize buffer@(c:cs)
  | isAlpha (trace ("INFO: lexing alpha: " ++ [c]) c) =
              let (word, rest) = span isAlphaNum buffer in
              Lexer.Word word : tokenize rest
  | isDigit (trace ("INFO: lexing digit: " ++ [c]) c) =
              let (number, rest) = span isDigit buffer in
              Lexer.Number number : tokenize rest
  | isSymbolChar (trace ("INFO: lexing symbol:" ++ [c]) c) =
              let (symbols, rest) = span isSymbolChar buffer in
              Lexer.Symbol symbols : tokenize rest
  | isSpace (trace "INFO: skipping space" c) =
              let _ = traceId "INFO: skipping space" in
              tokenize cs  
  | otherwise = error $ "Invalid character: " ++ [c]
