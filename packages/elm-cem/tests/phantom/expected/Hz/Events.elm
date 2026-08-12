module Hz.Events exposing
    ( onError, onErrorWith, onHzError, onHzErrorWith, onHzLoad, onHzLoadWith, onLoad, onLoadWith
    , delegate
    )

{-| Events as capabilities: each setter is an open producer admitted only by
elements whose closed `Attrs` row lists the event — `onClick` on a
non-interactive element is a compile error.

`delegate` is the ONE loud escape for bubbling: it forgets an event's
capability so it can be placed on a container and rely on DOM bubbling from an
interactive descendant. Pair it with a real interactive child and a keyboard
path (lint-checked).

@docs onError, onErrorWith, onHzError, onHzErrorWith, onHzLoad, onHzLoadWith, onLoad, onLoadWith
@docs delegate

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Json.Decode


{-| The `error` event.
-}
onError : msg -> Attr { c | onError : Supported } msg
onError msg =
    Ir.on "error" (Json.Decode.succeed msg)


{-| The `error` event with a custom payload decoder.
-}
onErrorWith : Json.Decode.Decoder msg -> Attr { c | onError : Supported } msg
onErrorWith =
    Ir.on "error"


{-| The `hz-error` event.
-}
onHzError : msg -> Attr { c | onHzError : Supported } msg
onHzError msg =
    Ir.on "hz-error" (Json.Decode.succeed msg)


{-| The `hz-error` event with a custom payload decoder.
-}
onHzErrorWith : Json.Decode.Decoder msg -> Attr { c | onHzError : Supported } msg
onHzErrorWith =
    Ir.on "hz-error"


{-| The `hz-load` event.
-}
onHzLoad : msg -> Attr { c | onHzLoad : Supported } msg
onHzLoad msg =
    Ir.on "hz-load" (Json.Decode.succeed msg)


{-| The `hz-load` event with a custom payload decoder.
-}
onHzLoadWith : Json.Decode.Decoder msg -> Attr { c | onHzLoad : Supported } msg
onHzLoadWith =
    Ir.on "hz-load"


{-| The `load` event.
-}
onLoad : msg -> Attr { c | onLoad : Supported } msg
onLoad msg =
    Ir.on "load" (Json.Decode.succeed msg)


{-| The `load` event with a custom payload decoder.
-}
onLoadWith : Json.Decode.Decoder msg -> Attr { c | onLoad : Supported } msg
onLoadWith =
    Ir.on "load"


{-| Forget an event's capability row (the bubbling escape).
-}
delegate : Attr capability msg -> Attr anyCapability msg
delegate attr =
    Ir.recast attr
