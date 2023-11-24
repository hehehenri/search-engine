module Doc(parseUrl) where

import Network.HTTP.Conduit (simpleHttp)
import Text.HTML.TagSoup

fetchUrl :: String -> IO String
fetchUrl url = do  
  response <- simpleHttp url
  return $ show response

cleanupText :: String -> String
cleanupText = unwords . words

extractText :: [Tag String] -> String
extractText [] = ""
extractText (TagOpen "script" _ : rest) =
  extractText rest
extractText (TagText text : rest) =
  cleanupText text ++ extractText rest
extractText (_ : rest) =
  extractText rest

parseHtml :: String -> String
parseHtml html =
  extractText $ parseTags html

parseUrl :: String -> IO String
parseUrl url = do
  html <- fetchUrl url
  return $ parseHtml html
