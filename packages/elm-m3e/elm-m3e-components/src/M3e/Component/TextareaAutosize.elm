module M3e.Component.TextareaAutosize exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , disabled, for, maxRows, minRows
    )

{-| The `m3e-textarea-autosize` component — strict per-component surface.

A non-visual element used to automatically resize a `textarea` to fit its content.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs disabled, for, maxRows, minRows

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.TextareaAutosize
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-textarea-autosize` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.TextareaAutosize.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.TextareaAutosize.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.TextareaAutosize.ChildAdmittedBy childAdm


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.textareaAutosize


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


{-| See `M3e.Attributes.maxRows`.
-}
maxRows : Float -> Attr { c | maxRows : Supported } msg
maxRows =
    A.maxRows


{-| See `M3e.Attributes.minRows`.
-}
minRows : Float -> Attr { c | minRows : Supported } msg
minRows =
    A.minRows
