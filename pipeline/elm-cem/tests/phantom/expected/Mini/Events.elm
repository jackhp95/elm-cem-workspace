module Mini.Events exposing
    ( onClick, onClickWith
    , delegate
    )

{-| Events as capabilities: each setter is an open producer admitted only by
elements whose closed `Attrs` row lists the event — `onClick` on a
non-interactive element is a compile error.

`delegate` is the ONE loud escape for bubbling: it forgets an event's
capability so it can be placed on a container and rely on DOM bubbling from an
interactive descendant. Pair it with a real interactive child and a keyboard
path (lint-checked).

@docs onClick, onClickWith
@docs delegate

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Json.Decode


{-| The `click` event.
-}
onClick : msg -> Attr { c | onClick : Supported } msg
onClick msg =
    Ir.on "click" (Json.Decode.succeed msg)


{-| The `click` event with a custom payload decoder.
-}
onClickWith : Json.Decode.Decoder msg -> Attr { c | onClick : Supported } msg
onClickWith =
    Ir.on "click"


{-| Forget an event's capability row (the bubbling escape).
-}
delegate : Attr capability msg -> Attr anyCapability msg
delegate attr =
    Ir.recast attr
