module Mini.Component.Tab exposing
    ( view
    , Is, Attrs, Content, ChildAdmittedBy, AdmittedBy
    , child
    )

{-| The `mini-tab` component — strict per-component surface.

A single tab. Only valid inside mini-tabs.

@docs view
@docs Is, Attrs, Content, ChildAdmittedBy, AdmittedBy
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Mini.Attributes as A
import Mini.Html as H
import Mini.Internal.Types.Tab
import Mini.Kind exposing (Available, Brand, Ctx, Used)
import Mini.Values


{-| The kind row `mini-tab` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Mini.Internal.Types.Tab.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Mini.Internal.Types.Tab.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    Mini.Internal.Types.Tab.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Mini.Internal.Types.Tab.ChildAdmittedBy childAdm


{-| The CLOSED parent contexts this element is valid inside — `mini-tab` is
only writable as a direct child of `mini-tabs`.
-}
type alias AdmittedBy =
    Mini.Internal.Types.Tab.AdmittedBy


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) AdmittedBy msg
view =
    H.tab


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
