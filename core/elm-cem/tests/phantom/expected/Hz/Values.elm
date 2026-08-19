module Hz.Values exposing
    ( Value
    , toString
    , Position
    , positionFromString, positionValues
    , blank_, parent_, self_, top_, top
    , positionBlank_, positionParent_, positionSelf_, positionTop_, positionTop
    )

{-| The enum-value vocabulary: every token minted once (open row), plus the
library-wide union row per enum attribute, plus attribute-prefixed
portmanteaus (`variantFilled`, `shapeRounded`, …) for IDE discovery.
General setters close over the union; per-component setters narrow — both
are fed by these same tokens.

`Value` is re-exported here so annotating a token never requires an
`HtmlIr.Value` import.

@docs Value
@docs toString
@docs Position
@docs positionFromString, positionValues
@docs blank_, parent_, self_, top_, top
@docs positionBlank_, positionParent_, positionSelf_, positionTop_, positionTop

-}

import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value


{-| The phantom-tagged enum token. Re-exported so callers never import `HtmlIr.Value` directly.
-}
type alias Value tags =
    HtmlIr.Value.Value tags


{-| The token's underlying string — the safe out-bound direction. Re-exported so callers never import `HtmlIr.Value` directly.
-}
toString : Value tags -> String
toString =
    HtmlIr.Value.toString


{-| The union row for `position` (from `PlacementPosition`).
-}
type alias Position =
    { blank_ : Supported
    , parent_ : Supported
    , self_ : Supported
    , top_ : Supported
    , top : Supported
    }


{-| Parse a `position` value from the string it writes to the DOM. The inverse of `toString`.
-}
positionFromString : String -> Maybe (Value Position)
positionFromString s =
    case s of
        "_blank" ->
            Just blank_

        "_parent" ->
            Just parent_

        "_self" ->
            Just self_

        "_top" ->
            Just top_

        "top" ->
            Just top

        _ ->
            Nothing


{-| Every `position` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
positionValues : List (Value Position)
positionValues =
    [ blank_, parent_, self_, top_, top ]


{-| The `_blank` token.
-}
blank_ : Value { v | blank_ : Supported }
blank_ =
    Ir.token "_blank"


{-| The `_parent` token.
-}
parent_ : Value { v | parent_ : Supported }
parent_ =
    Ir.token "_parent"


{-| The `_self` token.
-}
self_ : Value { v | self_ : Supported }
self_ =
    Ir.token "_self"


{-| The `_top` token.
-}
top_ : Value { v | top_ : Supported }
top_ =
    Ir.token "_top"


{-| The `top` token.
-}
top : Value { v | top : Supported }
top =
    Ir.token "top"


{-| The `_blank` value of the `position` enum — same open row as `blank_`, prefixed for discovery.
-}
positionBlank_ : Value { v | blank_ : Supported }
positionBlank_ =
    Ir.token "_blank"


{-| The `_parent` value of the `position` enum — same open row as `parent_`, prefixed for discovery.
-}
positionParent_ : Value { v | parent_ : Supported }
positionParent_ =
    Ir.token "_parent"


{-| The `_self` value of the `position` enum — same open row as `self_`, prefixed for discovery.
-}
positionSelf_ : Value { v | self_ : Supported }
positionSelf_ =
    Ir.token "_self"


{-| The `_top` value of the `position` enum — same open row as `top_`, prefixed for discovery.
-}
positionTop_ : Value { v | top_ : Supported }
positionTop_ =
    Ir.token "_top"


{-| The `top` value of the `position` enum — same open row as `top`, prefixed for discovery.
-}
positionTop : Value { v | top : Supported }
positionTop =
    Ir.token "top"
