data Day_Names = Monday | Tuesday | Wednesday | Thursday | Friday | 
                 Saturday | Sunday 
   deriving (Eq, Enum, Show)

day_name_to_iso_day_no :: Day_Names -> Integer
day_name_to_iso_day_no day = case day of
   Monday    -> 1
   Tuesday   -> 2
   Wednesday -> 3
   Thursday  -> 4 
   Friday    -> 5
   Saturday  -> 6
   Sunday    -> 7

data Quadrants = Origin | Quadrant_I | Quadrant_II | Quadrant_III | Quadrant_IV | 
                 X_Axis_Positive | X_Axis_Negative | Y_Axis_Positive | Y_Axis_Negative

quadrant :: Float -> Float -> Quadrants
quadrant x y
   | x >  0 && y >  0 = Quadrant_I
   | x <  0 && y >  0 = Quadrant_II
   | x <  0 && y <  0 = Quadrant_III
   | x >  0 && y <  0 = Quadrant_IV
   | x == 0 && y == 0 = Origin
   | x == 0 && y >  0 = Y_Axis_Positive
   | x == 0 && y <  0 = Y_Axis_Negative
   | x /= 0 && y >  0 = X_Axis_Positive
   | x /= 0 && y <  0 = X_Axis_Negative
   | otherwise        = error "Program error: Non-exhaustive guards in function: quadrant"

angle_to_x_axis :: Float -> Float -> Float
angle_to_x_axis x y = case quadrant x y of
   Origin          -> error "angle_to_x_axis undefined"
   X_Axis_Positive -> 0
   X_Axis_Negative -> pi
   Y_Axis_Positive ->  pi / 2.0
   Y_Axis_Negative -> -pi / 2.0
   Quadrant_I      -> atan (y/x)
   Quadrant_II     -> atan (y/x) + pi
   Quadrant_III    -> atan (y/x) - pi
   Quadrant_IV     -> atan (y/x)

maybe_sqrt :: Maybe Float -> Maybe Float
maybe_sqrt maybe_x = case maybe_x of
   Just x 
      | x >= 0    -> Just (sqrt x)
      | otherwise -> Nothing
   Nothing -> Nothing
   
data List a = E | a :> (List a) 
   
deconstruct_list :: [a] -> (Maybe a, [a])
deconstruct_list list = case list of
   []    -> (Nothing, [])
   x: xs -> (Just x, xs)
