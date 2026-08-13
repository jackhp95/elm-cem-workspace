module M3e.Component.SplitButton exposing
    ( view, el
    , Is, Attrs, LeadingButtonSlot, TrailingButtonSlot, ChildAdmittedBy
    , Size, size, Variant, variant
    , leadingButton, trailingButton
    )

{-| The `m3e-split-button` component — strict per-component surface.

A button used to show an action with a menu of related actions.

@docs view, el
@docs Is, Attrs, LeadingButtonSlot, TrailingButtonSlot, ChildAdmittedBy
@docs Size, size, Variant, variant
@docs leadingButton, trailingButton

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.SplitButton
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-split-button` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.SplitButton.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.SplitButton.Attrs


{-| The kinds the `leading-button` slot admits.
-}
type alias LeadingButtonSlot =
    M3e.Internal.Types.SplitButton.LeadingButtonSlot


{-| The kinds the `trailing-button` slot admits.
-}
type alias TrailingButtonSlot =
    M3e.Internal.Types.SplitButton.TrailingButtonSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.SplitButton.ChildAdmittedBy childAdm


{-| The `size` values valid on this component (compile-tight narrowing).
-}
type alias Size =
    M3e.Internal.Types.SplitButton.Size


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    M3e.Internal.Types.SplitButton.Variant


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.splitButton


{-| Required-content (and action) constructor — omissions are unwritable.
-}
el :
    { leadingButton : Element LeadingButtonSlot (ChildAdmittedBy childAdm) msg
    , trailingButton : Element TrailingButtonSlot (ChildAdmittedBy childAdm) msg
    }
    -> List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
el required_ attrs children =
    view attrs (Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "leading-button") (El.toNode required_.leadingButton)) :: Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "trailing-button") (El.toNode required_.trailingButton)) :: children)


{-| The size of the button. (default: `"small"`)
-}
size : Value Size -> Attr { c | size : Supported } msg
size value_ =
    Ir.attribute "size" (Val.toString value_)


{-| The appearance variant of the button. (default: `"filled"`)
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)


{-| Place an element into the named `leading-button` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
leadingButton : Element LeadingButtonSlot admittedBy msg -> Element free freeAdmittedBy msg
leadingButton element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "leading-button") (El.toNode element))


{-| Place an element into the named `trailing-button` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
trailingButton : Element TrailingButtonSlot admittedBy msg -> Element free freeAdmittedBy msg
trailingButton element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "trailing-button") (El.toNode element))
