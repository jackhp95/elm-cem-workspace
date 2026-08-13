module M3e.Component.TabPanel exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , child
    )

{-| The `m3e-tab-panel` component — strict per-component surface.

A panel presented for a tab.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.TabPanel
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-tab-panel` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.TabPanel.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.TabPanel.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.TabPanel.ChildAdmittedBy childAdm


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
    H.tabPanel


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
