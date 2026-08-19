module StringNotValue exposing (broken)

{-| THE regression, expressed as a compile failure.

`disable-pagination` is constrained to three values by a config `attrTypes` list
override. Before the fix its setter was `String -> Attr`, so this line compiled — and
so did `disablePagination "yes"`, `""`, and every other string. The override bought
nothing, silently, and `<Lib>.Values` had no row to show for it.

A `Value <Row>` setter makes a raw string unrepresentable, which is the whole point of
writing the override in the first place.

-}

import Eo
import Eo.Attributes


broken =
    Eo.bar [ Eo.Attributes.disablePagination "true" ] []
