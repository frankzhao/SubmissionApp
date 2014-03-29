area_of_triangle :: Float -> Float -> Float -> Float
area_of_triangle a b c = sqrt (s * (s - a) * (s - b) * (s - c))
   where
      s = (a + b + c) / 2.0

data Quadrants = Origin | Quadrant_I | Quadrant_II | Quadrant_III | Quadrant_IV | 
                 X_Axis_Positive | X_Axis_Negative | Y_Axis_Positive | Y_Axis_Negative
   deriving (Show, Eq)

quadrant :: Float -> Float -> Quadrants
quadrant x y
   | x >  0 && y >  0 = Quadrant_I
   | x <  0 && y >  0 = Quadrant_II
   | x <  0 && y <  0 = Quadrant_III
   | x >  0 && y <  0 = Quadrant_IV
   | x == 0 && y == 0 = Origin
   | x == 0 && y >  0 = Y_Axis_Positive
   | x == 0 && y <  0 = Y_Axis_Negative
   | x >  0 && y == 0 = X_Axis_Positive
   | x <  0 && y == 0 = X_Axis_Negative
   | otherwise        = error "Program error: Non-exhaustive guards in function: quadrant"

angle_to_x_axis :: Float -> Float -> Float
angle_to_x_axis x y
   | x >  0.0             = atan (y/x)
   | x == 0.0 && y >  0.0 =  pi / 2.0
   | x == 0.0 && y == 0.0 = error "angle_to_x_axis undefined"
   | x == 0.0 && y <  0.0 = -pi / 2.0
   | x <  0.0 && y >  0.0 = atan (y/x) + pi
   | x <  0.0 && y == 0.0 = pi
   | x <  0.0 && y <  0.0 = atan (y/x) - pi
   | otherwise = error "Program error in angle_to_x_axis: predicates are not exhaustive"

angle_to_axis_using_qudrant :: Float -> Float -> Float
angle_to_axis_using_qudrant x y
	| quad == Quadrant_I      = atan (y/x)
	| quad == Quadrant_II     = atan (y/x) + pi
	| quad == Quadrant_III    = atan (y/x) - pi
	| quad == Quadrant_IV     = atan (y/x)
	| quad == Origin          = error "angle_to_x_axis undefined"
	| quad == Y_Axis_Positive =  pi / 2.0
	| quad == Y_Axis_Negative = -pi / 2.0
	| quad == X_Axis_Positive = 0.0
	| quad == X_Axis_Negative = pi
	| otherwise = error "Program error in angle_to_axis_using_qudrant: predicates are not exhaustive"
	where 
		quad = quadrant x y

angle_to_axis_using_pattern_matching :: Float -> Float -> Float
angle_to_axis_using_pattern_matching x y = case quadrant x y of
	Quadrant_I      -> atan (y/x)
	Quadrant_II     -> atan (y/x) + pi
	Quadrant_III    -> atan (y/x) - pi
	Quadrant_IV     -> atan (y/x)
	Origin          -> error "angle_to_x_axis undefined"
	Y_Axis_Positive ->  pi / 2.0
	Y_Axis_Negative -> -pi / 2.0
	X_Axis_Positive -> 0.0
	X_Axis_Negative -> pi

is_valid_triangle :: Float -> Float -> Float -> Bool
is_valid_triangle a b c = a + b >= c && a + c >= b && b + c >= a

area_of_triangle' :: Float -> Float -> Float -> Maybe Float
area_of_triangle' a b c 
   |      is_valid_triangle a b c  = Just (sqrt (s * (s - a) * (s - b) * (s - c)))
   | not (is_valid_triangle a b c) = Nothing
	| otherwise = error "Program error in area_of_triangle': predicates were not exhaustive"
   where
      s = (a + b + c) / 2.0