module FromStringWrongRow exposing (bad)

{-| `dirFromString` returns `Maybe (Value Dir)`. `Dir` has no `filled` field, so
this must NOT unify with a `Variant` annotation. If it compiles, `fromString` is
handing back an open row and the closure is a lie.
-}

import Mini.Values


bad : Maybe (Mini.Values.Value Mini.Values.Variant)
bad =
    Mini.Values.dirFromString "ltr"
