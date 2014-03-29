ugly_quadratic_formula :: Float -> Float -> Float -> (Float, Float)
ugly_quadratic_formula a b c = ( (-b + sqrt (b*b - 4*a*c) )/ (2*a),  
                                 (-b - sqrt (b*b - 4*a*c) )/ (2*a) )

pretty_quadratic_formula :: Float -> Float -> Float -> (Float, Float)
pretty_quadratic_formula a b c = ( (-b + sqrt_discriminant) / denominator, 
                                   (-b - sqrt_discriminant) / denominator )
   where
      sqrt_discriminant = sqrt (b*b - 4*a*c)
      denominator       = 2*a

data Grades = Fail | Pass | Credit | Distinction | High_Distinction
   deriving Show

grade :: Integer -> Grades
grade mark
   | mark >= 80 && mark <= 100 = High_Distinction
   | mark >= 70 && mark <   80 = Distinction
   | mark >= 60 && mark <   70 = Credit
   | mark >= 50 && mark <   60 = Pass
   | mark >=  0 && mark <   50 = Fail
   | mark <   0 || mark >  100 = error "Program error: Not a valid mark"
   | otherwise = error "Program error: Non-exhaustive guards in function: grade"

grade' :: Integer -> Grades
grade' mark
   | mark >= 80 && mark <= 100 = High_Distinction
   | mark >= 70 && mark <   80 = Distinction
   | mark >= 60 && mark <   70 = Credit
   | mark >= 50 && mark <   60 = Pass
   | mark >=  0 && mark <   50 = Fail
   | otherwise = error "Program error: Not a valid mark"

grade'' :: Integer -> Grades
grade'' mark
   | mark > 100 = error "Program error: mark above 100"
   | mark >= 80 = High_Distinction
   | mark >= 70 = Distinction
   | mark >= 60 = Credit
   | mark >= 50 = Pass
   | mark >=  0 = Fail
   | otherwise  = error "Program error: mark below 0"

grade''' :: Integer -> Maybe Grades
grade''' mark
   | mark >= 80 && mark <= 100 = Just High_Distinction
   | mark >= 70 && mark <   80 = Just Distinction
   | mark >= 60 && mark <   70 = Just Credit
   | mark >= 50 && mark <   60 = Just Pass
   | mark >=  0 && mark <   50 = Just Fail
   | mark <   0 || mark >  100 = Nothing
   | otherwise = error "Program error: Non-exhaustive guards in function: grade"