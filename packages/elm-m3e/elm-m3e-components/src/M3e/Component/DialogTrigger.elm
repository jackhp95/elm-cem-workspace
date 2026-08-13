module M3e.Component.DialogTrigger exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , for
    )

{-| The `m3e-dialog-trigger` component — strict per-component surface.

An element, nested within a clickable element, used to open a dialog.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs for

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.DialogTrigger
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-dialog-trigger` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.DialogTrigger.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.DialogTrigger.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.DialogTrigger.ChildAdmittedBy childAdm


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.dialogTrigger


{-| See `M3e.Attributes.for`.
-}
for : String -> Attr { c | for : Supported } msg
for =
    A.for
