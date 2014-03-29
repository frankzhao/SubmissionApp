ninety_one :: Integer -> Integer
ninety_one i
	| i >  100 = i - 10
	| i <= 100 = ninety_one (ninety_one (i + 11))
	
boom :: Integer -> Integer -> Integer
boom a b
	| a <= 1 || b <= 1 = a
	| otherwise        = a * boom (boom (a - 1) b) (b - 1)
	
ninety_nine :: Integer -> Integer
ninety_nine i
	| i >= 100 = i - 1
	| i <  100 = ninety_nine (ninety_nine (i + 2))