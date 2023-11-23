module Lexer(tokenize) where

import Data.Char
import Text.Read.Lex
import Debug.Trace

data Token = Word String | Symbol String | Number String deriving(Show)

nextToken :: String -> (Maybe Token, String)
nextToken "" = (Nothing, "")
nextToken buff@(c:cs)
  | isSpace (trace "INFO: skipping space" c) = nextToken cs
  | isAlpha (trace ("INFO: word init found: " ++ [c]) c) =
            let (word, rest) = span isAlphaNum buff in
            (Just (Lexer.Word word), rest)
  | isDigit (trace ("INFO: number init found: " ++ [c]) c) =
            let (num, rest) = span isDigit buff in
            (Just (Lexer.Number num), rest)
  | isSymbolChar (trace ("INFO: symbol init found: " ++ [c]) c) =
            let (symb, rest) = span isSymbolChar buff in
            (Just (Lexer.Symbol symb), rest)
  | otherwise = error $ "ERROR: unexpected character: " ++ [c]

-- TODO: does the order matters?
appendToken :: Maybe Token -> [Token] -> [Token]
appendToken token tokens =
            case token of Just token -> token:tokens
                          Nothing -> tokens

appendNextToken :: String -> [Token] -> [Token]
appendNextToken doc tokens =
            let (token, doc) = nextToken doc in
            let token = trace ("INFO: token found: " ++ show token) token in
            let tokens = appendToken token tokens in
            tokens

tokenize' :: String -> [Token] -> [Token]
tokenize' "" tokens = tokens
tokenize' buff tokens =
            let tokens = appendNextToken buff tokens in
            tokenize' buff tokens

tokenize :: String -> [Token]
tokenize doc = tokenize' doc []
            
