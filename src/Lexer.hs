module Lexer(tokenize) where

import Data.Char
import Text.Read.Lex

data Token = Word String | Symbol String | Number String deriving(Show)

nextToken :: String -> (Maybe Token, String)
nextToken "" = (Nothing, "")
nextToken buff@(c:cs)
  | isSpace c = nextToken cs
  | isAlpha c =
            let (word, rest) = span isAlphaNum buff in
            (Just (Lexer.Word word), rest)
  | isDigit c =
            let (num, rest) = span isDigit buff in
            (Just (Lexer.Number num), rest)
  | isSymbolChar c =
            let (symb, rest) = span isSymbolChar buff in
            (Just (Lexer.Symbol symb), rest)
  | otherwise = error $ "ERROR: unexpected character: " ++ [c]

-- TODO: does the order matters?
appendToken :: Maybe Token -> [Token] -> [Token]
appendToken maybeToken tokens =
            case maybeToken of
              Just token -> token:tokens
              Nothing -> tokens

appendNextToken :: String -> [Token] -> (String, [Token])
appendNextToken doc tokens =
            let (token, rest) = nextToken doc in
            let newTokens = appendToken token tokens in
            (rest, newTokens)

tokenize' :: String -> [Token] -> [Token]
tokenize' "" tokens = tokens
tokenize' buff tokens =
            let (newBuff, newTokens) = appendNextToken buff tokens in
            tokenize' newBuff newTokens

tokenize :: String -> [Token]
tokenize doc = tokenize' doc []
