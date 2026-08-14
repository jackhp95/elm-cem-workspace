module Mini.Component.Button exposing
    ( view, el
    , Is, Attrs, Content, IconSlot, ChildAdmittedBy
    , Variant, variant
    , disabled, weight, weightAsNumber, onClick
    , icon, child
    )

{-| The `mini-button` component — strict per-component surface.

An action chip trigger.

@docs view, el
@docs Is, Attrs, Content, IconSlot, ChildAdmittedBy
@docs Variant, variant
@docs disabled, weight, weightAsNumber, onClick
@docs icon, child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import Mini.Attributes as A
import Mini.Events as Ev
import Mini.Html as H
import Mini.Internal.Types.Button
import Mini.Kind exposing (Available, Brand, Ctx, Used)
import Mini.Values


{-| The kind row `mini-button` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Mini.Internal.Types.Button.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Mini.Internal.Types.Button.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    Mini.Internal.Types.Button.Content


{-| The kinds the `icon` slot admits.
-}
type alias IconSlot =
    Mini.Internal.Types.Button.IconSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Mini.Internal.Types.Button.ChildAdmittedBy childAdm


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    Mini.Internal.Types.Button.Variant


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.button


{-| Required-content (and action) constructor — omissions are unwritable.
-}
el :
    { content : Element Content (ChildAdmittedBy childAdm) msg }
    -> List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
el required_ attrs children =
    view attrs (required_.content :: children)


{-| Visual variant.
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)


{-| See `Mini.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `Mini.Attributes.weight`.
-}
weight : String -> Attr { c | weight : Supported } msg
weight =
    A.weight


{-| See `Mini.Attributes.weightAsNumber`.
-}
weightAsNumber : Float -> Attr { c | weight : Supported } msg
weightAsNumber =
    A.weightAsNumber


{-| See `Mini.Events.onClick`.
-}
onClick : msg -> Attr { c | onClick : Supported } msg
onClick =
    Ev.onClick


{-| Place an element into the named `icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
icon : Element IconSlot admittedBy msg -> Element free freeAdmittedBy msg
icon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "icon") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
