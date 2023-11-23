module Lexer(tokenize) where

import Data.Char
import Text.Read.Lex

data Token = Word String | Symbol String | Number String

tokenize :: String -> [Token]
tokenize buffer@(c:cs)
  | isAlpha c = let (word, rest) = span isAlphaNum buffer in
                Lexer.Word word : tokenize rest
  | isDigit c = let (number, rest) = span isDigit buffer in
                Lexer.Number number : tokenize rest
  | isSymbolChar c = let (symbols, rest) = span isSymbolChar buffer in
                     Lexer.Symbol symbols : tokenize rest
  | isSpace c = tokenize cs
  | otherwise = error $ "Invalid character: " ++ [c]
