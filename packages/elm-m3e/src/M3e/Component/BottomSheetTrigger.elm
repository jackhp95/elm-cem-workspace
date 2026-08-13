module M3e.Component.BottomSheetTrigger exposing
    ( view
    , Is, Attrs, Content, ChildAdmittedBy
    , detent, for, secondary
    , child
    )

{-| The `m3e-bottom-sheet-trigger` component — strict per-component surface.

An element, nested within a clickable element, used to trigger a bottom sheet.

@docs view
@docs Is, Attrs, Content, ChildAdmittedBy
@docs detent, for, secondary
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.BottomSheetTrigger
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-bottom-sheet-trigger` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.BottomSheetTrigger.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.BottomSheetTrigger.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.BottomSheetTrigger.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.BottomSheetTrigger.ChildAdmittedBy childAdm


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.bottomSheetTrigger


{-| See `M3e.Attributes.detent`.
-}
detent : Float -> Attr { c | detent : Supported } msg
detent =
    A.detent


{-| See `M3e.Attributes.for`.
-}
for : String -> Attr { c | for : Supported } msg
for =
    A.for


{-| See `M3e.Attributes.secondary`.
-}
secondary : Bool -> Attr { c | secondary : Supported } msg
secondary =
    A.secondary


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
