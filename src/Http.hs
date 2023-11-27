module Http(fetchUrl) where

import Network.HTTP.Conduit (simpleHttp)

fetchUrl :: String -> IO String
fetchUrl url = do  
  response <- simpleHttp url
  return $ show response
