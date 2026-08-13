module M3e.Component.RichTooltipAction exposing
    ( view, el
    , Is, Attrs, Content, ChildAdmittedBy
    , disableRestoreFocus
    , child
    )

{-| The `m3e-rich-tooltip-action` component — strict per-component surface.

An element, nested within a clickable element, used to dismiss a parenting rich tooltip.

@docs view, el
@docs Is, Attrs, Content, ChildAdmittedBy
@docs disableRestoreFocus
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.RichTooltipAction
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-rich-tooltip-action` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.RichTooltipAction.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.RichTooltipAction.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.RichTooltipAction.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.RichTooltipAction.ChildAdmittedBy childAdm


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.richTooltipAction


{-| Required-content (and action) constructor — omissions are unwritable.
-}
el :
    { content : Element Content (ChildAdmittedBy childAdm) msg }
    -> List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
el required_ attrs children =
    view attrs (required_.content :: children)


{-| See `M3e.Attributes.disableRestoreFocus`.
-}
disableRestoreFocus : Bool -> Attr { c | disableRestoreFocus : Supported } msg
disableRestoreFocus =
    A.disableRestoreFocus


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
