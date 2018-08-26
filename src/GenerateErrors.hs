{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module GenerateErrors where

import Control.Applicative ((<$>))
import qualified Control.Foldl as Fold
import Control.Monad (when)
import Data.Either (rights)
import qualified Data.List.NonEmpty as NonEmpty
import qualified Data.Text as Text
import Data.Yaml (FromJSON, ToJSON, encodeFile)
import Filesystem.Path (replaceExtension)
import GHC.Generics (Generic)
import Prelude hiding (FilePath, head, tail)
import Turtle hiding (d, e, f, fp, g, l, o, s, u, utc, w, x)

data MessageYaml = MessageYaml
  { explanation :: Text
  , resources :: [Text]
  , message :: Text
  } deriving (Generic)

instance FromJSON MessageYaml

instance ToJSON MessageYaml

messageFolder :: FilePath
messageFolder = "message"

errorFolder :: FilePath
errorFolder = "errors"

blankMessage :: Text -> MessageYaml
blankMessage = MessageYaml "PLACEHOLDER EXPLANATION" []

-- | Return the right value.
-- FIXME: Remove when stack updates to base-4.10.0.0.
fromRight :: b -> Either a b -> b
fromRight _ (Right b) = b
fromRight b _ = b

-- | Check if a message has already been generated for file.
ensureMessageExists :: (FilePath, Text) -> IO Bool
ensureMessageExists (f, buildOutput) = do
  let filepath =
        replaceExtension
          (collapse $ "." </> messageFolder </> filename f)
          "yaml"
  exists <- testfile filepath
  -- FIXME: Make output not contain "\n" etc.
  print buildOutput
  unless exists $
    encodeFile
      (Text.unpack . fromRight "" $ toText filepath)
      (blankMessage buildOutput)
  return exists

-- | Go through each file in `errors` and build them, noting down their compilation
-- errors and adding that output to a respective .yaml file in `message`, creating
-- Control.Applicative it if it does not exist and overwriting the `message`
-- field in the file if it already exists.
generateMessages :: IO ()
generateMessages = do
  files <- fold (ls errorFolder) Fold.list
  -- Grab all Haskell files in `errors`.
  let hsFiles = rights $ toText <$> filter (`hasExtension` "hs") files
  -- Build each of the Haskell source files.
  builds <- mapM buildFile hsFiles
  outputBuild builds
  mapM_ ensureMessageExists $ builds

-- | Run a shell command getting back the exit code, stdout and stderr.
runSh :: Text -> [Text] -> IO (ExitCode, Text, Text)
runSh x' args = procStrictWithErr x' args empty

-- | Build the Haskell source file with `stack ghc <filename>`.
buildFile :: Text -> IO (FilePath, Text)
buildFile f = do
  (_, _, err') <- runSh "stack" ["ghc", f]
  return (fromText f, err')

-- | Print out the output to stderr from the build.
outputBuild :: [(FilePath, Text)] -> IO ()
outputBuild = mapM_ (mapM_ echo . NonEmpty.toList . textToLines . snd)
