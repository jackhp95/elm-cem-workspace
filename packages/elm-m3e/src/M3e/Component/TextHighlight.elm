module M3e.Component.TextHighlight exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , Mode, mode
    , caseSensitive, disabled, term, onHighlight
    , child
    )

{-| The `m3e-text-highlight` component — strict per-component surface.

Highlights text which matches a given search term.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs Mode, mode
@docs caseSensitive, disabled, term, onHighlight
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.TextHighlight
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-text-highlight` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.TextHighlight.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.TextHighlight.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.TextHighlight.ChildAdmittedBy childAdm


{-| The `mode` values valid on this component (compile-tight narrowing).
-}
type alias Mode =
    M3e.Internal.Types.TextHighlight.Mode


{-| Standard constructor: `[attributes] [children]`. The default slot is
kind-permissive (`any`): children of any kind compose, but each child's OWN
admittedBy must still admit this context — a restricted-parent element is
rejected here at compile time.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.textHighlight


{-| The mode in which to highlight text. (default: `"contains"`)
-}
mode : Value Mode -> Attr { c | mode : Supported } msg
mode value_ =
    Ir.attribute "mode" (Val.toString value_)


{-| See `M3e.Attributes.caseSensitive`.
-}
caseSensitive : Bool -> Attr { c | caseSensitive : Supported } msg
caseSensitive =
    A.caseSensitive


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `M3e.Attributes.term`.
-}
term : String -> Attr { c | term : Supported } msg
term =
    A.term


{-| See `M3e.Events.onHighlight`.
-}
onHighlight : msg -> Attr { c | onHighlight : Supported } msg
onHighlight =
    Ev.onHighlight


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
