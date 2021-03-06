-- Solution to Day 14 of the Advent Of Code 2017

module Main where

import Data.Function (on)
import Data.List (foldl', foldl1')
import Data.Maybe (fromMaybe, mapMaybe, fromJust)
import Data.Bits (xor)
import Data.Char (ord)
import Text.Printf (printf)


import Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map


import Graph


key :: Input
key = "ffayrhll"



main :: IO ()
main = do
  let grid = initGrid key
  putStrLn $ "part 1: " ++ show (part1 grid)
  putStrLn $ "part 2: " ++ show (part2 grid)


type Input = String
type Grid = [Line]
type Line = String
type Coord = (Int,Int)


part1 :: Grid -> Int
part1 = sum . map (length . filter (== '#'))


part2 :: Grid -> Int
part2 gr =
  let graph = intoGraph 0 emptyGraph (repeat '0') gr
  in length $ groups graph


----------------------------------------------------------------------
-- init Grid

initGrid :: Input -> Grid
initGrid key = [ concatMap charToFrag (knotHash (key ++ "-" ++ show row)) | row <- [0..127] ]


----------------------------------------------------------------------
-- make Grid into a Graph (scanning lines to find adjacent nodes)

intoGraph :: Int -> Graph -> Line -> Grid -> Graph
intoGraph _ gr _ [] = gr
intoGraph y gr above (l:ls) =
  let gr' = scanLine (0,y) '0' above l gr
  in intoGraph (y+1) gr' l ls


scanLine :: Coord -> Char ->  Line -> Line -> Graph -> Graph
scanLine (x,y) prev above line gr = go prev above line
  where
    go _ [] _ = gr
    go _ _ [] = gr
    go _ (_:as) ('0':ls) =
      scanLine (x+1,y) '0' as ls gr
    go '0' ('0':as) ('#':ls) =
      let gr' = insertCon (coordId (x,y), coordId (x,y)) gr
      in scanLine (x+1,y) '#' as ls gr'
    go '0' ('#':as) ('#':ls) =
      let gr' = insertCon (coordId (x,y-1), coordId (x,y)) gr
      in scanLine (x+1,y) '#' as ls gr'
    go '#' ('0':as) ('#':ls) =
      let gr' = insertCon (coordId (x-1,y), coordId (x,y)) gr
      in scanLine (x+1,y) '#' as ls gr'
    go '#' ('#':as) ('#':ls) =
      let gr' = insertCon (coordId (x-1,y), coordId (x,y)) gr
          gr'' = insertCon (coordId (x,y-1), coordId (x,y)) gr'
      in scanLine (x+1,y) '#' as ls gr''


coordId :: Coord -> Int
coordId (x,y) = y * 128 + x


----------------------------------------------------------------------
-- hash algorithm

knotHash :: String -> String
knotHash inp = concatMap (printf "%02x") hashedBlocks
  where inp' = concat . replicate 64 $ final inp
        step1 = steps [0..255] inp'
        hashedBlocks = hash <$> blocks step1


hash :: [Int] -> Int
hash = foldl1' xor


blocks :: [a] -> [[a]]
blocks [] = []
blocks xs = let (b, xs') = splitAt 16 xs in b : blocks xs'


final :: String -> [Int]
final inp = map ord  inp ++ [17, 31, 73, 47, 23]


steps :: [a] -> [Int] -> [a]
steps list = go 0 (0, list)
  where
    go _ (_, xs) []        = xs
    go sk (pos, xs) (l:ls) = go (sk+1) (step len sk l (pos, xs)) ls
    len                    = length list


step :: Int -> Int -> Int -> (Int, [a]) -> (Int, [a])
step listLen skip l (cur, list) = (cur', list')
  where
    (end, start)  = splitAt (listLen - cur) $ take listLen $ reverse sel ++ notSel
    (sel, notSel) = splitAt l $ drop cur $ list ++ list
    list' = start ++ end
    cur' = (cur + skip + l) `mod` listLen


charToFrag :: Char -> String
charToFrag '0' = "0000"
charToFrag '1' = "000#"
charToFrag '2' = "00#0"
charToFrag '3' = "00##"
charToFrag '4' = "0#00"
charToFrag '5' = "0#0#"
charToFrag '6' = "0##0"
charToFrag '7' = "0###"
charToFrag '8' = "#000"
charToFrag '9' = "#00#"
charToFrag 'a' = "#0#0"
charToFrag 'b' = "#0##"
charToFrag 'c' = "##00"
charToFrag 'd' = "##0#"
charToFrag 'e' = "###0"
charToFrag 'f' = "####"
