
import Text.ParserCombinators.Parsec;
import Data.Digest.MD5
import Network.HTTP
import Network.HTTP.Headers
import Network.URI
import qualified Text.Json as J
import Data.Maybe
import qualified Data.Map as M
import Data.Map ( (!) )
import Data.ByteString.Lazy.Char8 ( pack )
import Control.Monad ( liftM )
import Data.Char

data DeliciousRecord = DeliciousRecord { hash :: String
                                       , top_tags :: [(String,Int)]
                                       , total_posts :: Int
                                       , url :: String }
                       deriving ( Show, Ord, Eq )

data DeliciousBookmark = DeliciousBookmark { bookmark_url :: String
                                           , description :: String
                                           , tags :: [String] }
                         deriving ( Show, Eq, Ord )

url_fragment :: String
url_fragment = "http://del.icio.us/feeds/json/url/data?hash="

bookmarks_fragment :: String
bookmarks_fragment = "http://del.icio.us/feeds/json/"

request_for_bookmarks :: String -> Request
request_for_bookmarks user = Request ( fromJust . parseURI $
                                       bookmarks_fragment ++ user ++ "?raw" )
                             GET [] ""

request_for_url_data :: String -> Request
request_for_url_data u = Request ( fromJust . parseURI $
                                   url_fragment ++ (show . md5 . pack $ u ) )
                         GET [] ""

fetch_bookmarks :: String -> IO [DeliciousBookmark]
fetch_bookmarks user = do { res <- simpleHTTP . request_for_bookmarks $ user
                          ; case res of
                              Right (Response (2,0,0) _ _ body) ->
                                  return $ process_bookmarks_body body
                          }

parse_crufty_json :: String -> J.Value
parse_crufty_json = parse_json . unescape . utf8_decode
    where
      parse_json = \s -> case (parse J.json "" s) of
                           Left err -> error . show $ err
                           Right v -> v

process_bookmarks_body :: String -> [DeliciousBookmark]
process_bookmarks_body body =
    case parse_crufty_json body of
      J.Array a ->
          map (process_bookmark . uno) a

process_bookmark :: M.Map String J.Value -> DeliciousBookmark
process_bookmark m =
    DeliciousBookmark { bookmark_url = uns $ M.findWithDefault blank "u" m
                      , description = uns $ M.findWithDefault blank "d" m 
                      , tags = map uns $ una $ M.findWithDefault empty_array "t" m }

fetch_url_data :: String -> IO DeliciousRecord
fetch_url_data url = do { res <- simpleHTTP . request_for_url_data $ url
                        ; case res of
                            Right res@(Response (2,0,0) _ _ body) ->
                                return $ process_body body
                        }

process_body :: String -> DeliciousRecord
process_body body =
    case parse_crufty_json body of
      J.Array a ->
          case a of
            [] ->
                DeliciousRecord "" [] 0 ""
            [o] ->
                DeliciousRecord { hash = uns $ M.findWithDefault blank "hash" $ uno o
                                , top_tags = to_tag_list . uno $ M.findWithDefault empty "top_tags" $ uno o
                                , url = uns $ M.findWithDefault blank "url" $ uno o
                                , total_posts = unn $ M.findWithDefault zero "total_posts" $ uno o }

blank :: J.Value
blank = J.String ""

to_tag_list :: M.Map String J.Value -> [(String,Int)]
to_tag_list m = map (\(s,n) -> (s, unn n)) $ M.toList m

zero :: J.Value
zero = J.Number 0

empty :: J.Value
empty = J.Object M.empty

empty_array :: J.Value
empty_array = J.Array []

unn :: J.Value -> Int
unn (J.Number n) = fromInteger . round $ n

uno :: J.Value -> M.Map String J.Value
uno (J.Object o) = o

una :: J.Value -> [J.Value]
una (J.Array a) = a

uns :: J.Value -> String
uns (J.String s) = s

unescape :: String -> String
unescape s = unescape_ [] s

unescape_ :: String -> String -> String
unescape_ s [] = reverse s
unescape_ t ('\\':'\'':ss) = unescape_ ('\'':t) ss
unescape_ t (s:ss) = unescape_ (s:t) ss

utf8_decode :: String -> String
utf8_decode s = utf8_decode_ [] s

utf8_decode_ :: String -> String -> String
utf8_decode_ s [] = reverse s
utf8_decode_ c dl@(d:ds) | d < '\128' = utf8_decode_ (d:c) ds
                         | d > '\191' && d < '\224' = utf8_decode_ ((_56 d1 d2):c) t2
                         | d > '\223' && d < '\240' = utf8_decode_ ((_466 d1 d2 d3):c) t3
                         | d > '\239' && d < '\256' = utf8_decode_ ((_3666 d1 d2 d3 d4):c) t4
    where
      d1 = d
      d2 = dl !! 1
      d3 = dl !! 2
      d4 = dl !! 3
      t1 = ds
      t2 = drop 2 dl
      t3 = drop 3 dl
      t4 = drop 4 dl

_56 :: Char -> Char -> Char
_56 d1 d2 = chr ((c1*2^6) + c2)
    where
      c1 = (ord d1) - 192
      c2 = (ord d2) - 128

_466 :: Char -> Char -> Char -> Char
_466 d1 d2 d3 = chr ((c1 * 2^12) + (c2 * 2^6) + c3)
    where
      c1 = (ord d1) - 224
      c2 = (ord d2) - 128
      c3 = (ord d3) - 128

_3666 :: Char -> Char -> Char -> Char -> Char
_3666 d1 d2 d3 d4 = chr ((c1*2^18) + (c2*2^12) + (c3*2^6) + c4)
    where
      c1 = (ord d1) - 240
      c2 = (ord d2) - 128
      c3 = (ord d3) - 128
      c4 = (ord d4) - 128