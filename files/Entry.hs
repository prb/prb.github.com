-- Entry.hs: blog entry data structure and utility functions

module Blog.Entry where

import System.Time

data Entry = Entry { title :: AtomText, -- title
                     summary :: AtomText, -- summary
                     metadata :: Metadata, -- metadata
                     body :: AtomText, -- the body of the post
                     tags :: [String], -- tags for the entry; these
                                       -- will be empty if the entry
                                       -- is a comment
                     uid :: String, -- UID for the entry, generated
                                    -- after the fact
                     comments :: [Entry] -- comments; this may give
                                         -- threaded comments for
                                         -- free...
                   }

data Metadata = Metadata { created :: ClockTime,
                           publish :: ClockTime,
                           updated :: ClockTime,
                           author :: Author,
                           published :: Bool }

data Author = Author { name :: String, -- name; this will not match
                                       -- the global information when
                                       -- the entry is a comment
                       uri :: String, -- a link for the author
                       email :: String
                     }

data AtomText = AtomText { atomType :: AtomTextType,
                           text :: String
                         }

data AtomTextType = XHTML | HTML | TEXT
                    deriving (Eq,Enum,Bounded)

isPublished :: Entry -> IO Bool
isPublished e = do { now <- getClockTime
                   ; return ( (diffClockTimes now (publish (metadata e))) > noTimeDiff ) }


lastUpdated :: [Entry] -> ClockTime
lastUpdated e = maximum (map (updated.metadata) (filter (published.metadata) e))


