type Expression = [Token]

data Token = Plus | Minus | Times | Divided_By | Power | Num {number :: Double}
   deriving (Show)
   
instance Eq Token where
      (==) left right = case (left, right) of
         (Plus      , Plus      ) -> True
         (Minus     , Minus     ) -> True
         (Times     , Times     ) -> True
         (Divided_By, Divided_By) -> True
         (Power     , Power     ) -> True       
         (Num x     , Num y     ) -> round_to_digits (x - y) float_precision == 0
         _                        -> False 
         where
            -- Number of counting digits after decimal point
            float_precision = 12 :: Integer 
            -- Rounding a given number to a certain number of digits
            round_to_digits :: Double -> Integer -> Double
            round_to_digits x d = fromIntegral (round (x * scaling)) / scaling
               where 
                  scaling = 10 ^ d :: Double
