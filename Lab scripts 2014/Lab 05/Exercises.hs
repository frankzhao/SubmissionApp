-- "A" : "reasonably broken string"
resolve_string :: String
resolve_string = 'A' : "reasonably broken string"
resolve_string' :: [String]
resolve_string' = "A" : ["reasonably broken string"]

-- [1, 2, 3] : [4, 5, 6] : [7, 8, 9]
resolve_integer_List :: [Integer]
resolve_integer_List = 1 : 2 : 3 : 4 : 5 : 6 : [7, 8, 9]
resolve_integer_List' :: [[Integer]]
resolve_integer_List' = [1, 2, 3] : [4, 5, 6] : [[7, 8, 9]]

-- (4.0, "Teddy") : (pi, "Duck")
resolve_tuple :: [(Float, String)]
resolve_tuple = (4.0, "Teddy") : [(pi, "Duck")]

-- 9:8:[]:7:6:[]:[]
resolve_list_of_lists :: [[Integer]]
resolve_list_of_lists = (9:8:[]):(7:6:[]):[[]]

maybe_devide :: Maybe Integer -> Maybe Integer -> Maybe Integer
maybe_devide maybe_x maybe_y = case (maybe_x, maybe_y) of
   (Nothing, _) -> Nothing
   (_, Nothing) -> Nothing
   (Just x, Just y) 
      | y /= 0    -> Just (x `div` y)
      | otherwise -> Nothing
   
swap_first_two :: [a] -> [a]
swap_first_two list = case list of
   x: y: xs -> y: x: xs
   _        -> error "Less than two elements in the list"
   
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

binding_power :: Token -> Integer
binding_power token = case token of
   Plus       -> 1
   Minus      -> 1
   Times      -> 2
   Divided_By -> 2
   Power      -> 3
   Num _      -> error ("No binding power for: " ++ (show token))

eval :: Expression -> Expression
eval expr = case expr of
   
   Num x: op: Num y: op_next: remaining_expr
      | (binding_power op) >= (binding_power op_next)
         -> eval ((eval [Num x, op, Num y]) ++ op_next: remaining_expr)
      | otherwise                                           
         -> eval (Num x: op: eval (Num y: op_next: remaining_expr))
   
   [Num x, op, Num y] -> case op of
      Plus       -> [Num (x +  y)]
      Minus      -> [Num (x -  y)]
      Times      -> [Num (x *  y)]
      Divided_By -> [Num (x /  y)]
      Power      -> [Num (x ** y)]
      Num _      -> error "Number cannot occur between numbers"
   
   Minus: Num x: remaining_expr
      -> eval (Num (-x) : remaining_expr)
   Num x: op: Minus: Num y: remaining_expr 
      -> eval (Num x: op: Num (-y): remaining_expr)
      
   [Num _] -> expr
   
   _ -> error "Invalid expression"

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
                       (c `elem` ['+', '-'] && (number /= "" && (last number) `elem` ['e', 'E']) 
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