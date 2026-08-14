module Hz.Component.Duplicate exposing
    ( view
    , Is, Attrs, Content, ChildAdmittedBy
    , value, defaultValue
    , child
    )

{-| The `hz-duplicate` component — strict per-component surface.

Tests K3: duplicate value attribute.

@docs view
@docs Is, Attrs, Content, ChildAdmittedBy
@docs value, defaultValue
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Hz.Attributes as A
import Hz.Html as H
import Hz.Internal.Types.Duplicate
import Hz.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `hz-duplicate` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Hz.Internal.Types.Duplicate.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Hz.Internal.Types.Duplicate.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    Hz.Internal.Types.Duplicate.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Hz.Internal.Types.Duplicate.ChildAdmittedBy childAdm


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.duplicate


{-| See `Hz.Attributes.value`.
-}
value : String -> Attr { c | value : Supported } msg
value =
    A.value


{-| See `Hz.Attributes.defaultValue`.
-}
defaultValue : String -> Attr { c | value : Supported } msg
defaultValue =
    A.defaultValue


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
