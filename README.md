# Helpful Haskell Errors (aka HHE)

NOTE: Suuuuuper early stage.

A collection of Haskell compiler errors along with an explanation of what went wrong. The motivation is to later build a tool that will parse the errors and then rewrite them to be both more explanatory and to point out possible fixes to the user.

The reason for doing this as an external tool instead of improving error messages directly in GHC is that an external tool will be able to move much quicker, and will hopefully be a lot less complex than adding it to the GHC machinery directly (which would see very slow release to users).

## Structure

Erroneous Haskell source files are located in `errors/src` and compiler error messages are kept in `errors/message`. The file names in `errors/src` all end in `.hs` and `errors/message` end in `.txt`, which the names before the filetype being identical.

For example `errors/src/DeriveFunctorNegativePosition.hs` belongs together with `errors/message/DeriveFunctorNegativePosition.yaml`.

## Generating the Error Message

Run,

```bash
stack ghc errors/src/MyFile.hs
```

on your file and take the compilation error and put it in your `errors/message` file.

The message files are all YAML files, following the format of, of `explanation` giving an explanation of why the error might have occurred, `resources` is a list of resources (i.e. websites) that help explain the error and finally `message` which is the compiler error message.

```yaml
explanation: |
  The code tries to derive a functor for a data type that has its arguments in negative position (i.e. it's contravariant).
resources:
  - https://www.example.com/resource-explaning-the-error
message: |
  src/DeriveFunctorNegativePosition.hs:5:13: error:
      • Can't make a derived instance of ‘Functor MakeInt’:
          Constructor ‘MakeInt’ must not use the type variable in a function argument
      • In the data declaration for ‘MakeInt’
```
