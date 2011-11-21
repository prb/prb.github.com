--
-- Reduced but acceptable profile of the Atom syndication format[1]
-- suitable for blog publishing.
-- 
-- Primary assumptions:
--
-- * Content comes in either the plain "text" flavor or the "xhtml"
--   flavor.
-- 
-- * The atom:generator structure always includes uri and version.
-- 
-- * The atom:link structures only and always include rel and href
--   attributes.
-- 
-- * contributor is not supported.
-- 
-- * Entities are expected to be formatted correctly (text escaped,
--   dates rendered, ids prepared) before being put in this structure.
--   This includes attribute values.
--
-- * atom:source is not supported.
--
-- * Pretty printing is irrelevant.
-- 
-- REFERENCES:
-- 
--   [1] http://www.atomenabled.org/developers/syndication/atom-format-spec.php
--


--module Text.Atom where

import Maybe

data AtomElement = Feed [AtomElement]
                 | Entry [AtomElement]
                 | Content AtomContent -- text or xhtml only
                 | Author { author_name :: String, -- only authors, never contributors
                            author_uri :: Maybe String,
                            author_email :: Maybe String }
                 | Category String -- only term; ignore others
                 | Generator { gen_name :: String,
                               gen_uri :: String,
                               gen_version :: String }
                 | Id String
                 | Icon String
                 | Link { rel :: String,
                          href :: String }
                 | Logo String
                 | Published String
                 | Rights AtomContent
                 | Subtitle AtomContent
                 | Summary AtomContent
                 | Updated String
                   deriving (Show)               


data AtomContent = AtomContent { contentType :: ContentType,
                                 body :: String }
                 deriving (Show)

data ContentType = XHTML | TEXT
                 deriving (Eq,Show,Enum)


toXml :: AtomElement -> String
toXml (Feed xs) = start_feed ++ concat(map toXml xs) ++ end_feed
toXml (Entry xs) = wrap "entry" (concat(map toXml xs))
toXml (Category s) = clopen "category" ("term",s)
toXml (Id s) = wrap "id" s
toXml (Icon s) = wrap "icon" s
toXml (Link r h) = clopen_ "link" [("rel",r),("href",h)]
toXml (Logo s) = wrap "logo" s
toXml (Published s) = wrap "published" s
toXml (Updated s) = wrap "updated" s
toXml (Author s u e) = wrap "author" ((wrap "name" s)
                                      ++ (wrap_m "uri" u)
                                      ++ (wrap_m "email" e))
toXml (Generator n u v) = wrap_ "generator" [("uri",u),("version",v)] n
toXml (Content a) = atom_text "content" a
toXml (Rights a) = atom_text "rights" a
toXml (Subtitle a) = atom_text "subtitle" a
toXml (Summary a) = atom_text "summary" a

atom_text :: String -> AtomContent -> String
atom_text s (AtomContent XHTML t) = wrap_ s [("type","xhtml")] (start_div ++ t ++ end_div)
atom_text s (AtomContent TEXT t) = wrap_ s [("type","text")] t

clopen :: String -> (String,String) -> String
clopen s (n,v) = "<" ++ (prefix s) ++ " " ++ n ++ "=\"" ++ v ++ "\"/>"

clopen_ :: String -> [(String,String)] -> String
clopen_ s [] = "<" ++ (prefix s) ++ "/>"
clopen_ s xs = "<" ++ (prefix s) ++ (nv_to_s "" xs) ++ "/>"

wrap :: String -> String -> String
wrap s t = "<" ++ (prefix s) ++ ">" ++ t ++ "</" ++ (prefix s) ++ ">"

wrap_m :: String -> Maybe String -> String
wrap_m s Nothing = ""
wrap_m s (Just t) = wrap s t

wrap_ :: String -> [(String,String)] -> String -> String
wrap_ s [] t = wrap s t
wrap_ s xs t = "<" ++ (prefix s) ++ (nv_to_s "" xs) ++ ('>':t) ++ "</" ++ (prefix s) ++ ">"

nv_to_s :: String -> [(String,String)] -> String
nv_to_s t [] = t
nv_to_s t (x:xs) = nv_to_s (t ++ (' ':((fst x) ++ "=\"" ++ (snd x) ++ "\"")))  xs

start_div :: String
start_div = "<div xmlns=\"http://www.w3.org/1999/xhtml\">"

end_div :: String
end_div =  "</div>"

_prefix :: String
_prefix = "atom"

prefix :: String -> String
prefix s = _prefix ++ (':':s)

start_feed :: String
start_feed = ('<':(prefix "feed")) ++ " xmlns:" ++ _prefix ++ "=\"http://www.w3.org/2005/Atom\">"

end_feed :: String
end_feed = "</" ++ (prefix "feed") ++ ">"

