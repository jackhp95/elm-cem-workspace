module MapFormRowIsTokenNames exposing (broken)

{-| A MAP override's row is over TOKEN NAMES, never over the strings they write.

`Eo.Values.true` writes `"true"`, and so does `Eo.Values.always` — `strict`'s override
maps `always` → `"true"`. If the row had been built from the emitted VALUES rather than
the token names, `true` and `always` would have collapsed onto one row field and this
would compile.

It must not. The token/value split is a naming affordance for the Elm caller, not a
widening of what the attribute admits: `strict` admits `always`/`never`/`auto` and
nothing else, even though two of those write the same strings some other attribute's
tokens write.

-}

import Eo
import Eo.Attributes
import Eo.Values


broken =
    Eo.gate [ Eo.Attributes.strict Eo.Values.true ] []
