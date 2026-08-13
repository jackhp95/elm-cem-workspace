module M3e.Component.Tooltip exposing
    ( view, el
    , Is, Attrs, Content, ChildAdmittedBy
    , Position, position, TouchGestures, touchGestures
    , disabled, for, hideDelay, showDelay
    , child
    )

{-| The `m3e-tooltip` component — strict per-component surface.

Adds additional context to a button or other UI element.

@docs view, el
@docs Is, Attrs, Content, ChildAdmittedBy
@docs Position, position, TouchGestures, touchGestures
@docs disabled, for, hideDelay, showDelay
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.Tooltip
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-tooltip` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Tooltip.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Tooltip.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.Tooltip.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Tooltip.ChildAdmittedBy childAdm


{-| The `position` values valid on this component (compile-tight narrowing).
-}
type alias Position =
    M3e.Internal.Types.Tooltip.Position


{-| The `touchGestures` values valid on this component (compile-tight narrowing).
-}
type alias TouchGestures =
    M3e.Internal.Types.Tooltip.TouchGestures


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.tooltip


{-| Required-content (and action) constructor — omissions are unwritable.
-}
el :
    { content : Element Content (ChildAdmittedBy childAdm) msg }
    -> List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
el required_ attrs children =
    view attrs (required_.content :: children)


{-| The position of the tooltip. (default: `"below"`)
-}
position : Value Position -> Attr { c | position : Supported } msg
position value_ =
    Ir.attribute "position" (Val.toString value_)


{-| The mode in which to handle touch gestures. (default: `"auto"`)
-}
touchGestures : Value TouchGestures -> Attr { c | touchGestures : Supported } msg
touchGestures value_ =
    Ir.attribute "touch-gestures" (Val.toString value_)


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `M3e.Attributes.for`.
-}
for : String -> Attr { c | for : Supported } msg
for =
    A.for


{-| See `M3e.Attributes.hideDelay`.
-}
hideDelay : Float -> Attr { c | hideDelay : Supported } msg
hideDelay =
    A.hideDelay


{-| See `M3e.Attributes.showDelay`.
-}
showDelay : Float -> Attr { c | showDelay : Supported } msg
showDelay =
    A.showDelay


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
