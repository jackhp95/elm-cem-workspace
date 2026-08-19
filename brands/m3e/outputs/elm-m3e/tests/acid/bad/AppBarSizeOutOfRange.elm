module AppBarSizeOutOfRange exposing (broken)

{-| NEGATIVE probe — per-component VALUE narrowing.

Tokens in `M3e.Values` are minted once with an open row
(`small : Value { v | small : Supported }`) so they are reusable across
components, and each component closes the set it accepts. `M3e.Component.AppBar.size`
takes `Value M3e.Component.AppBar.Size` where

    type alias Size =
        { large : Supported, medium : Supported, small : Supported }

`M3e.Values.extraLarge` is a real, exported token — it is legal on the
components whose enum lists it — but not on an app bar. This MUST FAIL.

The probe would still be rejected if `extraLarge` did not exist at all, so the
positive half lives in `app/Good.elm`: `M3e.Component.AppBar.size M3e.Values.small`
compiles, which proves the token vocabulary is reachable and the rejection here
is the narrowing rather than a missing name.

-}

import M3e
import M3e.Component.AppBar
import M3e.Values


broken : M3e.Element (M3e.Component.AppBar.Is s) admittedBy msg
broken =
    M3e.appBar [ M3e.Component.AppBar.size M3e.Values.extraLarge ] []
