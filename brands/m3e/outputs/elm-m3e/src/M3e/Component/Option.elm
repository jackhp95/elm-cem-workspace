module M3e.Component.Option exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
    , HighlightMode, highlightMode
    , disableHighlight, disabled, selected, term, value, defaultSelected, defaultValue
    , child
    )

{-| The `m3e-option` component — strict per-component surface.

An option that can be selected.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
@docs HighlightMode, highlightMode
@docs disableHighlight, disabled, selected, term, value, defaultSelected, defaultValue
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.Option
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-option` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Option.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Option.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.Option.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Option.ChildAdmittedBy childAdm


{-| The `highlightMode` values valid on this component (compile-tight narrowing).
-}
type alias HighlightMode =
    M3e.Internal.Types.Option.HighlightMode


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Option.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.Option.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    {}


{-| Required-content (and action) constructor — omissions are unwritable.
-}
component :
    { content : Element Content (ChildAdmittedBy childAdm) msg }
    -> List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component required_ attrs children =
    H.option attrs (required_.content :: children)


{-| The mode in which to highlight a term. (default: `"contains"`)
-}
highlightMode : Value HighlightMode -> Attr { c | highlightMode : Supported } msg
highlightMode value_ =
    Ir.attribute "highlight-mode" (Val.toString value_)


{-| See `M3e.Attributes.disableHighlight`.
-}
disableHighlight : Bool -> Attr { c | disableHighlight : Supported } msg
disableHighlight =
    A.disableHighlight


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `M3e.Attributes.selected`.
-}
selected : Bool -> Attr { c | selected : Supported } msg
selected =
    A.selected


{-| See `M3e.Attributes.term`.
-}
term : String -> Attr { c | term : Supported } msg
term =
    A.term


{-| See `M3e.Attributes.value`.
-}
value : String -> Attr { c | value : Supported } msg
value =
    A.value


{-| See `M3e.Attributes.defaultSelected`.
-}
defaultSelected : Bool -> Attr { c | selected : Supported } msg
defaultSelected =
    A.defaultSelected


{-| See `M3e.Attributes.defaultValue`.
-}
defaultValue : String -> Attr { c | value : Supported } msg
defaultValue =
    A.defaultValue


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
