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

--eval :: Expression -> Expression
--eval _ = error "This has not yet been implemented"

eval :: Expression -> Expression 
eval list = case list of 
	
	Num x: op: Num y: op_next: ts -> eval ((eval [Num x, op, Num y]) ++ op_next : ts) 
	Num x: op: Num y: ts -> case op of 
		Plus -> Num (x + y): ts  
		Minus -> Num (x - y): ts 
		_ -> Num (x - y): ts
	Num x: op_2: op_3: Num y: op_next2: zs -> eval ((eval [Num x, op_2, op_3, Num y]) ++  op_next2 : zs) 
	Num x: op_2: op_3: Num y: zs -> case (op_2, op_3) of 
		(Plus, Minus) -> (eval [Num x, op_2, Num (-y)]) ++ zs 
		(Minus, Plus) -> (eval [Num x, op_3, Num (-y)]) ++ zs
		_ -> (eval [Num x, op_3, Num (-y)]) ++ zs
	_ -> eval list
		
tokenizer :: String -> Expression
tokenizer s = case s of
   ""    -> []
   c: cs -> case c of
      ' ' ->                tokenizer cs
      '+' -> Plus         : tokenizer cs
      '-' -> Minus        : tokenizer cs
      '*' -> Times        : tokenizer cs
      '/' -> Divided_By   : tokenizer cs
      '^' -> Power        : tokenizer cs
      _   -> Num (read w) : tokenizer ws
      where 
         (w, ws) = extract_number ("", s)
         where
            extract_number :: (String, String) -> (String, String)
            extract_number (number, string) = case string of
               ""                                              -> (number, string)
               c: cs |  c `elem` ['0'..'9'] ++ ['.', 'e', 'E'] ||
                       (c `elem` ['+', '-'] && number /= "" && (last number) `elem` ['e', 'E']) 
									                                    -> extract_number (number ++ [c], cs)
                     | c `elem` [' ', '+', '-', '*', '/', '^'] -> (number, string)
							| otherwise                               -> error "Unknown symbol in string"
   
expression_to_string :: Expression -> String
expression_to_string expr = case expr of
   []    -> ""
   e: es -> case e of
      Plus       -> " + "     ++ expression_to_string es
      Minus      -> " - "     ++ expression_to_string es
      Times      -> " * "     ++ expression_to_string es
      Divided_By -> " / "     ++ expression_to_string es
      Power      -> " ^ "     ++ expression_to_string es
      Num x      -> (show x)  ++ expression_to_string es

eval_string_expression :: String -> String
eval_string_expression s = expression_to_string (eval (tokenizer s))