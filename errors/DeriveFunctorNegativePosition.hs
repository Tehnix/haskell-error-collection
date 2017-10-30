{-# LANGUAGE DeriveFunctor #-}

module DeriveFunctorNegativePosition where

data MakeInt a =
  MakeInt (a -> Int)
  deriving (Functor)
