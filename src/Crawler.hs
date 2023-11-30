module Crawler(scan) where

import Doc(extractAnchors)
import Http(fetchUrl)
import qualified Data.Map as Map
import qualified Data.Set as Set
import Text.HTML.TagSoup

type Pages = Map.Map String [Tag String]

parseUrl :: String -> Maybe String
parseUrl ('h':'t':'t':'p':'s':':':'/':'/':url) = Just url
parseUrl ('h':'t':'t':'p':':':'/':'/':url) = Just url
parseUrl _ = Nothing

getDomain :: String -> Maybe String
getDomain url = do
  url <- parseUrl url
  let (domain, path) = break (== '/') url
  return domain   

fromSameDomain :: String -> String -> Bool
fromSameDomain url url' =
  case (getDomain url, getDomain url') of
    (Just domain, Just domain') -> domain == domain'
    (_, _) -> False

updateUrls :: [String] -> [String] -> [String] -> [String]
updateUrls anchors urlsToVisit visitedUrls =
  [url | url <- anchors, url `notElem` visitedUrls && fromSameDomain url (head visitedUrls)] ++ urlsToVisit

traverse :: [String] -> Pages -> IO Pages
traverse [] visitedPages = return visitedPages
traverse (url:urlsToVisit) visitedPages = do
  putStrLn $ "INFO: url: " ++ url
  putStrLn $ "INFO: urlsToVisit: " ++ show urlsToVisit
  html <- fetchUrl url
  let tags = parseTags html 
      visitedPages = Map.insert url tags visitedPages 
      anchors = extractAnchors tags
      urlsToVisit = updateUrls anchors urlsToVisit $ Map.keys visitedPages in
    Crawler.traverse urlsToVisit visitedPages

scan :: String -> IO Pages
scan url = do
  Crawler.traverse [url] Map.empty
