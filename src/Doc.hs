module Doc(parseUrl, extractAnchors) where

import Text.HTML.TagSoup
import Data.Char (toLower)
import qualified Data.Map as Map
import Http(fetchUrl)
import Data.Maybe

isAnchorTag :: Tag String -> Bool
isAnchorTag (TagOpen "a" _) = True
isAnchorTag _ = False

extractHref :: Tag String -> Maybe String
extractHref (TagOpen _ attrs) = lookup "href" attrs

extractAnchors :: [Tag String] -> [String]
extractAnchors tags = mapMaybe extractHref (filter isAnchorTag tags)

cleanupText :: String -> String
cleanupText = map toLower . unwords . words

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
