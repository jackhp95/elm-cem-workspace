module TypedHtml.Events exposing
    ( onChange, onChangeWith, onCheck, onCheckWith, onClick, onClickWith, onInput, onInputWith
    , delegate
    )

{-| Events as capabilities: each setter is an open producer admitted only by
elements whose closed `Attrs` row lists the event — `onClick` on a
non-interactive element is a compile error.

`delegate` is the ONE loud escape for bubbling: it forgets an event's
capability so it can be placed on a container and rely on DOM bubbling from an
interactive descendant. Pair it with a real interactive child and a keyboard
path (lint-checked).

@docs onChange, onChangeWith, onCheck, onCheckWith, onClick, onClickWith, onInput, onInputWith
@docs delegate

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Json.Decode


{-| The `change` event, decoding the standard `Bool` payload.
-}
onCheck : (Bool -> msg) -> Attr { c | onCheck : Supported } msg
onCheck tagger =
    Ir.on "change" (Json.Decode.map tagger (Json.Decode.at [ "target", "checked" ] Json.Decode.bool))


{-| The `change` event with a custom payload decoder.
-}
onCheckWith : Json.Decode.Decoder msg -> Attr { c | onCheck : Supported } msg
onCheckWith =
    Ir.on "change"


{-| The `change` event, decoding the standard `String` payload.
-}
onChange : (String -> msg) -> Attr { c | onChange : Supported } msg
onChange tagger =
    Ir.on "change" (Json.Decode.map tagger (Json.Decode.at [ "target", "value" ] Json.Decode.string))


{-| The `change` event with a custom payload decoder.
-}
onChangeWith : Json.Decode.Decoder msg -> Attr { c | onChange : Supported } msg
onChangeWith =
    Ir.on "change"


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


{-| The `input` event, decoding the standard `String` payload.
-}
onInput : (String -> msg) -> Attr { c | onInput : Supported } msg
onInput tagger =
    Ir.on "input" (Json.Decode.map tagger (Json.Decode.at [ "target", "value" ] Json.Decode.string))


{-| The `input` event with a custom payload decoder.
-}
onInputWith : Json.Decode.Decoder msg -> Attr { c | onInput : Supported } msg
onInputWith =
    Ir.on "input"


{-| Forget an event's capability row (the bubbling escape).
-}
delegate : Attr capability msg -> Attr anyCapability msg
delegate attr =
    Ir.recast attr
