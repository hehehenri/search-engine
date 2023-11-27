module Crawler(scan) where

import Doc(extractAnchors)
import Http(fetchUrl)
import qualified Data.Map as Map
import qualified Data.Set as Set
import Text.HTML.TagSoup

type Pages = Map.Map String [Tag String]

updateUrls :: [String] -> [String] -> [String] -> [String]
updateUrls  anchors urlsToVisit visitedUrls =
  [url | url <- anchors, url `notElem` visitedUrls] ++ urlsToVisit

traverse :: [String] -> Pages -> IO Pages
traverse [] visitedPages = return visitedPages
traverse (url:urlsToVisit) visitedPages = do
  html <- fetchUrl url
  let tags = parseTags html 
      visitedPages = Map.insert url tags visitedPages 
      anchors = extractAnchors tags 
      urlsToVisit = updateUrls anchors  urlsToVisit $ Map.keys visitedPages in
    Crawler.traverse urlsToVisit visitedPages

scan :: String -> IO Pages
scan url = do
  Crawler.traverse [url] Map.empty
