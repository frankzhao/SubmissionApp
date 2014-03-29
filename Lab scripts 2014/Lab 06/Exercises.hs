import Data.Char
import Integer_Subtypes

convert_to_upper_case :: String -> String
convert_to_upper_case string = case string of
   []    -> []
   c: cs -> (toUpper c) : convert_to_upper_case cs


count :: Char -> String -> Natural
count c s = count_tail 0 c s
   where
      count_tail :: Natural -> Char -> String -> Natural
      count_tail n c s = case s of
         [] -> n
         x: xs
            | x == c    -> count_tail (n + 1) c xs
            | otherwise -> count_tail n       c xs

product' :: [Integer] -> Integer
product' list = case list of
   []    -> 0
   [x]   -> x
   x: xs -> x * product' xs

product'' :: [Integer] -> Maybe Integer
product'' list = case list of
   []    -> Nothing
   [x]   -> Just x
   x: xs -> case product'' xs of
               Nothing  -> Nothing
               Just pxs -> Just (x * pxs) 
   
sum_of_products' :: [[Integer]] -> Integer
sum_of_products' list_of_lists = case list_of_lists of
   []    -> 0
   x: xs -> (product' x) + sum_of_products' xs
   
sum_of_products'' :: [[Integer]] -> Maybe Integer
sum_of_products'' list_of_lists = case list_of_lists of
   []    -> Just 0
   x: xs -> case product'' x of
               Nothing -> Nothing
               Just px -> case sum_of_products'' xs of
                             Nothing  -> Nothing
                             Just pxs -> Just (px + pxs)