module Main where

import qualified Lexer (Token, tokenize)
import Doc (parseUrl)
import Debug.Trace
import qualified Data.Map as Map
import qualified Data.List as List

type FreqMap = Map.Map String Int

updateFreq :: [Lexer.Token] -> FreqMap
updateFreq =
  Prelude.foldl increment Map.empty
  where
    increment :: FreqMap -> Lexer.Token -> FreqMap 
    increment freq token = Map.insertWith (+) (show token) 1 freq

sortByFreq :: Ord v => [(k, v)] -> [(k, v)]
sortByFreq = List.sortBy (\ (_, f) (_, f') -> compare f' f)

main :: IO ()
main = do
  doc <- Doc.parseUrl "https://www.haskell.org/"
  let tokens = Lexer.tokenize doc in
    let freq = updateFreq tokens in
    let freqList = Map.toList freq in
    let sortedFreqList = sortByFreq freqList in
    print $ take 10 sortedFreqList
