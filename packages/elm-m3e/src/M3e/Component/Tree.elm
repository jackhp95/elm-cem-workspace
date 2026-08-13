module M3e.Component.Tree exposing
    ( view
    , Is, Attrs, Content, ChildAdmittedBy
    , cascade, multi, onChange
    , child
    )

{-| The `m3e-tree` component — strict per-component surface.

Presents hierarchical data in a tree structure.

@docs view
@docs Is, Attrs, Content, ChildAdmittedBy
@docs cascade, multi, onChange
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.Tree
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-tree` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Tree.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Tree.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.Tree.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Tree.ChildAdmittedBy childAdm


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.tree


{-| See `M3e.Attributes.cascade`.
-}
cascade : Bool -> Attr { c | cascade : Supported } msg
cascade =
    A.cascade


{-| See `M3e.Attributes.multi`.
-}
multi : Bool -> Attr { c | multi : Supported } msg
multi =
    A.multi


{-| See `M3e.Events.onChange`.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange =
    Ev.onChange


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
