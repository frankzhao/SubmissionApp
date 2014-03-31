--
-- Uwe R. Zimmer
-- Australia, 2012
--
-- The main function is convert_to_Words. 
-- Try for instance: convert_to_Words 1235543222355643
--
-- Instead of a list of words, you can also produce a single string with convert_to_String.
--
-- Adapted from Integerroduction to Functional Programming,
-- by Richard Bird & Philip Wadler.
--

module Num_Words (
   Words, Number_in_Words,
   convert_to_Words,  -- :: Integer -> Number_in_Words
   convert_to_String  -- :: Integer -> String
   ) where

data Words = Zero | One | Two | Three | Four | Five | Six | Seven | Eight | Nine |
             Ten | Eleven | Twelve | Thirteen | Fourteen | Fifteen | Sixteen | Seventeen | Eighteen | Nineteen |
             Twenty | Thirty | Forty | Fifty | Sixty | Seventy | Eighty | Ninety |
             Hundred | Thousand | Million | Billion | Trillion | Quadrillion | Quintillion | Sextillion | Septillion |
             And | Comma | Minus
               deriving (Show)
            
type Number_in_Words = [Words]

to_String :: Number_in_Words -> String
to_String number = case number of
   []    -> ""
   n: ns -> show n ++ to_String ns

digits :: Integer -> Words
digits x = case x of
   0 -> Zero
   1 -> One
   2 -> Two
   3 -> Three
   4 -> Four
   5 -> Five
   6 -> Six
   7 -> Seven
   8 -> Eight
   9 -> Nine
   _ -> error "no digit for given index"
   
x_teen :: Integer -> Words
x_teen x = case x of
   0 -> Ten
   1 -> Eleven
   2 -> Twelve
   3 -> Thirteen
   4 -> Fourteen
   5 -> Fifteen
   6 -> Sixteen
   7 -> Seventeen
   8 -> Eighteen
   9 -> Nineteen
   _ -> error "no teen for given index"
   
x_ty :: Integer -> Words
x_ty x = case x of
   2 -> Twenty
   3 -> Thirty
   4 -> Forty
   5 -> Fifty
   6 -> Sixty
   7 -> Seventy
   8 -> Eighty
   9 -> Ninety
   _ -> error "no x_ty for given index"
   
order_term :: Integer -> Words
order_term order = case order of
   3  -> Thousand
   6  -> Million
   9  -> Billion
   12 -> Trillion
   15 -> Quadrillion
   18 -> Quintillion
   21 -> Sextillion
   24 -> Septillion
   _ -> error "No order term for given order"

max_order = 24 :: Integer

split_order :: Integer -> Integer -> (Integer, Integer)
split_order order n = (n `div` 10^order, n `mod` 10^order)

convert_tens :: Integer -> Number_in_Words
convert_tens n = case split_order 1 n of
   (0   , digit) -> [digits digit]
   (1   , digit) -> [x_teen digit]
   (tens, 0    ) -> [x_ty tens]
   (tens, digit) -> (x_ty tens) : [digits digit]

convert_hundreds :: Integer -> Number_in_Words
convert_hundreds n = case split_order 2 n of
   (0       , tens) ->                                       convert_tens tens
   (hundreds, 0   ) -> (digits hundreds) : [Hundred]
   (hundreds, tens) -> (digits hundreds) : (Hundred : (And : convert_tens tens))

link :: Integer -> Words
link rest
     | rest < 100 = And
     | otherwise  = Comma

convert_orders :: Integer -> Integer -> Number_in_Words
convert_orders order n = case order of
   0 -> convert_hundreds n
   _ -> case split_order order n of
      (0  , rest) ->                                                           convert_orders (order-3) rest
      (num, 0   ) -> convert_hundreds num ++ [order_term order]
      (num, rest) -> convert_hundreds num ++ (order_term order  : (link rest : convert_orders (order-3) rest))
   
convert_to_Words :: Integer -> Number_in_Words
convert_to_Words n
   | n >= 10^(max_order + 3) = error "Integer out of range for function: convert_to_Words (don't know any more order terms)"
   | n <  0 = Minus : convert_orders max_order (abs n)
   | n >= 0 =         convert_orders max_order n
   | otherwise = error "Program error: Non-exhaustive guards in function: convert_to_Words"

convert_to_String :: Integer -> String
convert_to_String n = to_String (convert_to_Words n)