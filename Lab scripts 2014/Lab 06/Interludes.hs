import Data.Integer_Subtypes

sum' :: [Integer] -> Integer
sum' list =
   case list of
      []    -> 0
      x: xs -> x + sum' xs

sum_tail :: (Num a) => [a] -> a
sum_tail list = sum_with_extra_parameter 0 list 
   where 
      sum_with_extra_parameter accumulator list = case list of
         []    -> accumulator
         x: xs -> sum_with_extra_parameter (accumulator + x) xs
         
sum_tail' :: (Num a) => [a] -> a
sum_tail' list = case list of
   []       -> 0
   [x]      -> x
   x: y: zs -> sum_tail' ((x + y): zs)

factorial :: Natural -> Natural
factorial n
   | n == 0 = 1
   | n >  0 = n * factorial (n - 1)
	| otherwise = error "unreachable code reached for factorial"
	
forgot_base_case :: Natural -> Natural
forgot_base_case n = n * forgot_base_case (n - 1)

stepping_on_the_spot :: Natural -> Natural
stepping_on_the_spot n
   | n == 0 = 1
   | n >  0 = n * stepping_on_the_spot n
   | otherwise = error "unreachable code reached for factorial"

stepping_in_the_wrong_direction :: Natural -> Natural
stepping_in_the_wrong_direction n
   | n == 0 = 1
   | n >  0 = n * stepping_in_the_wrong_direction (n + 1)
  | otherwise = error "unreachable code reached for factorial"

data Creatures = Salmon | Puffin | Fox | Bear | Man
   deriving (Eq, Enum, Show)

happy_creatures :: Creatures -> String
happy_creatures creature = case creature of
   Salmon -> "the " ++ (show creature) ++ " who is always happy"
   _      -> "the " ++ (show creature) ++ " who dreams of eating "
                 ++ happy_creatures (pred creature) 
                 ++ " which makes the " ++ (show creature) ++ " happy"

euclidian_distance :: [Float] -> [Float] -> Float
euclidian_distance vec_A vec_B = sqrt (sum_squared_distances vec_A vec_B)
   where
      sum_squared_distances :: [Float] -> [Float] -> Float
      sum_squared_distances vector_A vector_B = case (vector_A, vector_B) of
         ([]   , []   ) -> 0.0
         ([]   , b: bs) -> b ^ 2     + sum_squared_distances [] bs
         (a: as, []   ) -> a ^ 2     + sum_squared_distances as []
         (a: as, b: bs) -> (a - b)^2 + sum_squared_distances as bs
  
euclidian_distance''' :: [Float] -> [Float] -> Float
euclidian_distance''' vec_A vec_B = sqrt (sum_squared_distances vec_A vec_B)
   where
      sum_squared_distances :: [Float] -> [Float] -> Float
      sum_squared_distances vector_A vector_B = case (vector_A, vector_B) of
         ([]   , []   ) -> 0.0
         ([]   , _    ) -> error "First list is shorter than second list"
         (_    , []   ) -> error "First list is longer than second list"
         (a: as, b: bs) -> (a - b)^2 + sum_squared_distances as bs
 
euclidian_distance' :: [Float] -> [Float] -> Maybe Float
euclidian_distance' vec_A vec_B = case sum_squared_distances vec_A vec_B of 
   Nothing  -> Nothing
   Just sum -> Just (sqrt sum)
   where
      sum_squared_distances :: [Float] -> [Float] -> Maybe Float
      sum_squared_distances vector_A vector_B = case (vector_A, vector_B) of
         ([]   , []   ) -> Just 0.0
         ([]   , _    ) -> Nothing
         (_    , []   ) -> Nothing
         (a: as, b: bs) -> case sum_squared_distances as bs of
                              Nothing  -> Nothing
                              Just sum -> Just ((a - b)^2 + sum)

euclidian_distance'' :: [Float] -> [Float] -> Maybe Float
euclidian_distance'' vec_A vec_B 
   | length vec_A == length vec_B = Just (sqrt (sum_squared_distances vec_A vec_B))
   | otherwise                    = Nothing
   where
      sum_squared_distances :: [Float] -> [Float] -> Float
      sum_squared_distances vector_A vector_B = case (vector_A, vector_B) of
         ([]   , []   ) -> 0.0
         (a: as, b: bs) -> (a - b)^2 + sum_squared_distances as bs
         _              -> error "Program error: Vectors cannot be of different lengths here, yet seem to be"

