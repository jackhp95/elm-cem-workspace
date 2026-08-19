module M3e.Events exposing
    ( onActiveChange, onActiveChangeWith, onBeforeinput, onBeforeinputWith, onBeforetoggle, onBeforetoggleWith, onCancel, onCancelWith, onChange, onChangeWith, onClear, onClearWith, onClick, onClickWith, onClosed, onClosedWith, onClosing, onClosingWith, onHighlight, onHighlightWith, onInput, onInputWith, onInvalid, onInvalidWith, onOpened, onOpenedWith, onOpening, onOpeningWith, onPage, onPageWith, onQuery, onQueryWith, onRemove, onRemoveWith, onToggle, onToggleWith, onValueChange, onValueChangeWith, onViewChange, onViewChangeWith
    , delegate
    )

{-| Events as capabilities: each setter is an open producer admitted only by
elements whose closed `Attrs` row lists the event — `onClick` on a
non-interactive element is a compile error.

`delegate` is the ONE loud escape for bubbling: it forgets an event's
capability so it can be placed on a container and rely on DOM bubbling from an
interactive descendant. Pair it with a real interactive child and a keyboard
path (lint-checked).

@docs onActiveChange, onActiveChangeWith, onBeforeinput, onBeforeinputWith, onBeforetoggle, onBeforetoggleWith, onCancel, onCancelWith, onChange, onChangeWith, onClear, onClearWith, onClick, onClickWith, onClosed, onClosedWith, onClosing, onClosingWith, onHighlight, onHighlightWith, onInput, onInputWith, onInvalid, onInvalidWith, onOpened, onOpenedWith, onOpening, onOpeningWith, onPage, onPageWith, onQuery, onQueryWith, onRemove, onRemoveWith, onToggle, onToggleWith, onValueChange, onValueChangeWith, onViewChange, onViewChangeWith
@docs delegate

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Json.Decode


{-| The `active-change` event.
-}
onActiveChange : msg -> Attr { c | onActiveChange : Supported } msg
onActiveChange msg =
    Ir.on "active-change" (Json.Decode.succeed msg)


{-| The `active-change` event with a custom payload decoder.
-}
onActiveChangeWith : Json.Decode.Decoder msg -> Attr { c | onActiveChange : Supported } msg
onActiveChangeWith =
    Ir.on "active-change"


{-| The `beforeinput` event.
-}
onBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
onBeforeinput msg =
    Ir.on "beforeinput" (Json.Decode.succeed msg)


{-| The `beforeinput` event with a custom payload decoder.
-}
onBeforeinputWith : Json.Decode.Decoder msg -> Attr { c | onBeforeinput : Supported } msg
onBeforeinputWith =
    Ir.on "beforeinput"


{-| The `beforetoggle` event.
-}
onBeforetoggle : msg -> Attr { c | onBeforetoggle : Supported } msg
onBeforetoggle msg =
    Ir.on "beforetoggle" (Json.Decode.succeed msg)


{-| The `beforetoggle` event with a custom payload decoder.
-}
onBeforetoggleWith : Json.Decode.Decoder msg -> Attr { c | onBeforetoggle : Supported } msg
onBeforetoggleWith =
    Ir.on "beforetoggle"


{-| The `cancel` event.
-}
onCancel : msg -> Attr { c | onCancel : Supported } msg
onCancel msg =
    Ir.on "cancel" (Json.Decode.succeed msg)


{-| The `cancel` event with a custom payload decoder.
-}
onCancelWith : Json.Decode.Decoder msg -> Attr { c | onCancel : Supported } msg
onCancelWith =
    Ir.on "cancel"


{-| The `change` event.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange msg =
    Ir.on "change" (Json.Decode.succeed msg)


{-| The `change` event with a custom payload decoder.
-}
onChangeWith : Json.Decode.Decoder msg -> Attr { c | onChange : Supported } msg
onChangeWith =
    Ir.on "change"


{-| The `clear` event.
-}
onClear : msg -> Attr { c | onClear : Supported } msg
onClear msg =
    Ir.on "clear" (Json.Decode.succeed msg)


{-| The `clear` event with a custom payload decoder.
-}
onClearWith : Json.Decode.Decoder msg -> Attr { c | onClear : Supported } msg
onClearWith =
    Ir.on "clear"


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


{-| The `closed` event.
-}
onClosed : msg -> Attr { c | onClosed : Supported } msg
onClosed msg =
    Ir.on "closed" (Json.Decode.succeed msg)


{-| The `closed` event with a custom payload decoder.
-}
onClosedWith : Json.Decode.Decoder msg -> Attr { c | onClosed : Supported } msg
onClosedWith =
    Ir.on "closed"


{-| The `closing` event.
-}
onClosing : msg -> Attr { c | onClosing : Supported } msg
onClosing msg =
    Ir.on "closing" (Json.Decode.succeed msg)


{-| The `closing` event with a custom payload decoder.
-}
onClosingWith : Json.Decode.Decoder msg -> Attr { c | onClosing : Supported } msg
onClosingWith =
    Ir.on "closing"


{-| The `highlight` event.
-}
onHighlight : msg -> Attr { c | onHighlight : Supported } msg
onHighlight msg =
    Ir.on "highlight" (Json.Decode.succeed msg)


{-| The `highlight` event with a custom payload decoder.
-}
onHighlightWith : Json.Decode.Decoder msg -> Attr { c | onHighlight : Supported } msg
onHighlightWith =
    Ir.on "highlight"


{-| The `input` event.
-}
onInput : msg -> Attr { c | onInput : Supported } msg
onInput msg =
    Ir.on "input" (Json.Decode.succeed msg)


{-| The `input` event with a custom payload decoder.
-}
onInputWith : Json.Decode.Decoder msg -> Attr { c | onInput : Supported } msg
onInputWith =
    Ir.on "input"


{-| The `invalid` event.
-}
onInvalid : msg -> Attr { c | onInvalid : Supported } msg
onInvalid msg =
    Ir.on "invalid" (Json.Decode.succeed msg)


{-| The `invalid` event with a custom payload decoder.
-}
onInvalidWith : Json.Decode.Decoder msg -> Attr { c | onInvalid : Supported } msg
onInvalidWith =
    Ir.on "invalid"


{-| The `opened` event.
-}
onOpened : msg -> Attr { c | onOpened : Supported } msg
onOpened msg =
    Ir.on "opened" (Json.Decode.succeed msg)


{-| The `opened` event with a custom payload decoder.
-}
onOpenedWith : Json.Decode.Decoder msg -> Attr { c | onOpened : Supported } msg
onOpenedWith =
    Ir.on "opened"


{-| The `opening` event.
-}
onOpening : msg -> Attr { c | onOpening : Supported } msg
onOpening msg =
    Ir.on "opening" (Json.Decode.succeed msg)


{-| The `opening` event with a custom payload decoder.
-}
onOpeningWith : Json.Decode.Decoder msg -> Attr { c | onOpening : Supported } msg
onOpeningWith =
    Ir.on "opening"


{-| The `page` event.
-}
onPage : msg -> Attr { c | onPage : Supported } msg
onPage msg =
    Ir.on "page" (Json.Decode.succeed msg)


{-| The `page` event with a custom payload decoder.
-}
onPageWith : Json.Decode.Decoder msg -> Attr { c | onPage : Supported } msg
onPageWith =
    Ir.on "page"


{-| The `query` event.
-}
onQuery : msg -> Attr { c | onQuery : Supported } msg
onQuery msg =
    Ir.on "query" (Json.Decode.succeed msg)


{-| The `query` event with a custom payload decoder.
-}
onQueryWith : Json.Decode.Decoder msg -> Attr { c | onQuery : Supported } msg
onQueryWith =
    Ir.on "query"


{-| The `remove` event.
-}
onRemove : msg -> Attr { c | onRemove : Supported } msg
onRemove msg =
    Ir.on "remove" (Json.Decode.succeed msg)


{-| The `remove` event with a custom payload decoder.
-}
onRemoveWith : Json.Decode.Decoder msg -> Attr { c | onRemove : Supported } msg
onRemoveWith =
    Ir.on "remove"


{-| The `toggle` event.
-}
onToggle : msg -> Attr { c | onToggle : Supported } msg
onToggle msg =
    Ir.on "toggle" (Json.Decode.succeed msg)


{-| The `toggle` event with a custom payload decoder.
-}
onToggleWith : Json.Decode.Decoder msg -> Attr { c | onToggle : Supported } msg
onToggleWith =
    Ir.on "toggle"


{-| The `value-change` event.
-}
onValueChange : msg -> Attr { c | onValueChange : Supported } msg
onValueChange msg =
    Ir.on "value-change" (Json.Decode.succeed msg)


{-| The `value-change` event with a custom payload decoder.
-}
onValueChangeWith : Json.Decode.Decoder msg -> Attr { c | onValueChange : Supported } msg
onValueChangeWith =
    Ir.on "value-change"


{-| The `view-change` event.
-}
onViewChange : msg -> Attr { c | onViewChange : Supported } msg
onViewChange msg =
    Ir.on "view-change" (Json.Decode.succeed msg)


{-| The `view-change` event with a custom payload decoder.
-}
onViewChangeWith : Json.Decode.Decoder msg -> Attr { c | onViewChange : Supported } msg
onViewChangeWith =
    Ir.on "view-change"


{-| Forget an event's capability row (the bubbling escape).
-}
delegate : Attr capability msg -> Attr anyCapability msg
delegate attr =
    Ir.recast attr
