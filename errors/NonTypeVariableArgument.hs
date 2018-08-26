module NonTypeVariableArgument where

import Data.List.NonEmpty

{-
First error on `1` is fixed by helping the type inference,

test :: NonEmpty Int

Second error is because the second argument to `:|` should be a list.
-}
test = 1 :| 2{-
Original error from repl:

*Main Lexer Lib Parser Syntax Data.List.NonEmpty Data.List.NonEmpty Data.List.NonEmpty> 1 :| 2  

<interactive>:121:1: error:                                                                                                                                         src/Synta   ismatcheation or mismatched brackebrackets
    • Non type-variable argument in the constraint: Num [a]                                                                                                                  atc
      (Use FlexibleContexts to permit this)                                                                                                                         r mismatc
    • When checking the inferred type
-}
