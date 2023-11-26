module Main where

import qualified Lexer (Token, tokenize)
import Doc (parseUrl)
import Debug.Trace
import Data.Map as Map

type FreqMap = Map String Int

updateFreq :: [Lexer.Token] -> FreqMap -> FreqMap
updateFreq [] freq = freq
updateFreq (token:tokens) freq =
  let newFreq = Map.insertWith (+) (show token) 1 freq in
  updateFreq tokens newFreq

genFreq :: [Lexer.Token] -> FreqMap
genFreq t = updateFreq t Map.empty

main :: IO ()
main = do
  doc <- Doc.parseUrl "https://www.haskell.org/"
  let tokens = Lexer.tokenize doc
      freq = genFreq tokens in
    putStr $ show freq
