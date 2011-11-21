-- Return text/plain response with process and thread IDs.

import Control.Concurrent
import System.Posix.Process (getProcessID)

import Network.FastCGI

test :: CGI CGIResult
test = do setHeader "Content-type" "text/plain"
          pid <- liftIO getProcessID
          threadId <- liftIO myThreadId
          let tid = concat $ drop 1 $ words $ show threadId
          output $ unlines [ "Process ID: " ++ show pid,
	                     "Thread ID:  " ++ tid]

main = runFastCGIConcurrent' forkOS 5 test

