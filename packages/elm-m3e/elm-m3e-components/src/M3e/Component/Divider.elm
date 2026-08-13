module M3e.Component.Divider exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , inset, insetEnd, insetStart, vertical
    )

{-| The `m3e-divider` component — strict per-component surface.

A thin line that separates content in lists or other containers.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs inset, insetEnd, insetStart, vertical

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.Divider
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-divider` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Divider.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Divider.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Divider.ChildAdmittedBy childAdm


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.divider


{-| See `M3e.Attributes.inset`.
-}
inset : Bool -> Attr { c | inset : Supported } msg
inset =
    A.inset


{-| See `M3e.Attributes.insetEnd`.
-}
insetEnd : Bool -> Attr { c | insetEnd : Supported } msg
insetEnd =
    A.insetEnd


{-| See `M3e.Attributes.insetStart`.
-}
insetStart : Bool -> Attr { c | insetStart : Supported } msg
insetStart =
    A.insetStart


{-| See `M3e.Attributes.vertical`.
-}
vertical : Bool -> Attr { c | vertical : Supported } msg
vertical =
    A.vertical
