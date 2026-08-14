module Hz.Component.Blocked exposing
    ( view
    , Is, Attrs, Content, ChildAdmittedBy
    , label
    , child
    )

{-| The `hz-blocked` component — strict per-component surface.

Tests the KERNEL-BLOCKED guard: attributes whose DOM name elm/virtual-dom rewrites or ignores get no setter on any surface, while a legitimate sibling attribute on the same element still does.

@docs view
@docs Is, Attrs, Content, ChildAdmittedBy
@docs label
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Hz.Attributes as A
import Hz.Html as H
import Hz.Internal.Types.Blocked
import Hz.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `hz-blocked` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Hz.Internal.Types.Blocked.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Hz.Internal.Types.Blocked.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    Hz.Internal.Types.Blocked.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Hz.Internal.Types.Blocked.ChildAdmittedBy childAdm


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.blocked


{-| See `Hz.Attributes.label`.
-}
label : String -> Attr { c | label : Supported } msg
label =
    A.label


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
