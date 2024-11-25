import Text.Printf

data Expr
  = Num Integer
  | Add Expr Expr
  | Sub Expr Expr
  | Mul Expr Expr
  | Div Expr Expr
  | Mod Expr Expr
  | And Expr Expr
  | Or  Expr Expr
  | Inv Expr
  deriving Show

instance Num Expr
  -- a hack to get a quick-and-dirty parser
  where
    a + b = Add a b
    a * b = Mul a b
    a - b = Sub a b
    fromInteger = Num
    -- not used in Expr, but required by Num
    abs a       = undefined
    signum      = undefined

data Token
  = PUSH_IMMEDIATE Integer
  | ADD | SUB | MUL | DIV | MOD
  | AND | OR  | INVERT
  | HALT_CPU
  deriving Show

compile :: Expr -> [Token]
compile e =
    case e of
      Num i     -> [PUSH_IMMEDIATE i]
      Add e1 e2 -> ADD : (compile e2)++(compile e1)
      Sub e1 e2 -> SUB : (compile e2)++(compile e1)
      Mul e1 e2 -> MUL : (compile e2)++(compile e1)
      Div e1 e2 -> DIV : (compile e2)++(compile e1)
      Mod e1 e2 -> MOD : (compile e2)++(compile e1)
      And e1 e2 -> AND : (compile e2)++(compile e1)
      Or  e1 e2 -> OR  : (compile e2)++(compile e1)
      Inv e1    -> INVERT :            (compile e1)

format :: String -> Integer -> Integer -> String
format comment op arg =
  printf "%05b_0_%010b // %s" op arg comment

dump :: Token -> String
dump t =
  let
    f = format (show t)
  in
    case t of
      PUSH_IMMEDIATE i -> f  0 i
      ADD              -> f  1 0
      SUB              -> f  2 0
      MUL              -> f  3 0
      DIV              -> f  4 0
      MOD              -> f  5 0
      AND              -> f  6 0
      OR               -> f  7 0
      INVERT           -> f 16 0
      HALT_CPU         -> f 31 0

eg = id
   $ sequence_
   $ map putStrLn
   $ map dump
   $ reverse
   $ (HALT_CPU:)
   $ compile
   $ 13 + (-8)

cmp x = id
   $ sequence_
   $ map putStrLn
   $ map dump
   $ reverse
   $ (HALT_CPU:)
   $ compile
   $ x
