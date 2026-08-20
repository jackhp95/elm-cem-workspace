module Cem.Internal.Gate exposing (isAllowed)

{-| Shared allow-listed-module-prefix gate.

Six rules independently need the same check: is a module name (or the
current module under visit) inside one of a config's allow-listed prefixes,
either exactly or as a sub-module? Hoisted here since the check was
byte-identical (module-name/param aliasing aside) in
`NoUnsafeImportOutsideAllowed`, `NoSeamOutsideAllowedModules`,
`NoInternalImportOutsideAllowed`, `ExtractToSeam`, `NoMergedPipeAndSetter`,
and `NoNonLayoutTailwindClasses` (there under the name `isAllowedModule`).

@docs isAllowed

-}


{-| Is `moduleName` exactly one of `allowed`'s entries, or a sub-module of one
(`"Lib.Button"` is allowed by `["Lib"]`, matched via a `"Lib."` prefix so a
sibling like `"Lib2"` is NOT wrongly allowed by `"Lib"`)?
-}
isAllowed : List String -> String -> Bool
isAllowed allowed moduleName =
    List.any
        (\prefix -> moduleName == prefix || String.startsWith (prefix ++ ".") moduleName)
        allowed
