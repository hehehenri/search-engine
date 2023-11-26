module Main where

import qualified Lexer (Token, tokenize)
import Doc (parseUrl)
import Debug.Trace
import Data.Map as Map

type FreqMap = Map String Int

updateFreq :: [Lexer.Token] -> FreqMap
updateFreq =
  Prelude.foldl increment Map.empty
  where
    increment :: FreqMap -> Lexer.Token -> FreqMap 
    increment freq token = Map.insertWith (+) (show token) 1 freq
-- updateFreq [] freq = freq
-- updateFreq (token:tokens) freq =
--   let newFreq = Map.insertWith (+) (show token) 1 freq in
--   updateFreq tokens newFreq

main :: IO ()
main = do
  doc <- Doc.parseUrl "https://www.haskell.org/"
  let tokens = Lexer.tokenize doc
      freq = updateFreq tokens in
    putStr $ show freq
