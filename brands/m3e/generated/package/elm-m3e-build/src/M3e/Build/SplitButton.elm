module M3e.Build.SplitButton exposing (Builder, AttrCaps, SlotCaps, Is, LeadingButtonSlot, TrailingButtonSlot, ChildAdmittedBy, build, toElement, withClass, withId, withSize, withSlot, withStyle, withVariant, leadingButton, trailingButton, withLeadingButton, withTrailingButton)

{-| The **SplitButton** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `M3e.Component.SplitButton`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, LeadingButtonSlot, TrailingButtonSlot, ChildAdmittedBy, build, toElement, withClass, withId, withSize, withSlot, withStyle, withVariant, leadingButton, trailingButton, withLeadingButton, withTrailingButton

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.SplitButton as Component
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.SplitButtonIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.SplitButtonBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.SplitButtonAttrCaps


{-| -}
type alias SlotCaps =
    Component.SplitButtonSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.SplitButtonChildAdmittedBy childAdm


{-| -}
type alias LeadingButtonSlot =
    Component.SplitButtonLeadingButtonSlot


{-| -}
type alias TrailingButtonSlot =
    Component.SplitButtonTrailingButtonSlot


{-| -}
build :
    { leadingButton : Element Component.SplitButtonLeadingButtonSlot (Component.SplitButtonChildAdmittedBy childAdm) msg
    , trailingButton : Element Component.SplitButtonTrailingButtonSlot (Component.SplitButtonChildAdmittedBy childAdm) msg
    }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-split-button" [] [ El.toNode (Component.splitButtonLeadingButton required_.leadingButton), El.toNode (Component.splitButtonTrailingButton required_.trailingButton) ]


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.SplitButtonIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
leadingButton :
    B.Builder childRow childAttrCaps childSlotCaps Component.SplitButtonLeadingButtonSlot msg
    -> Element free freeAdmittedBy msg
leadingButton builder =
    Component.splitButtonLeadingButton (B.toElement builder)


{-| -}
trailingButton :
    B.Builder childRow childAttrCaps childSlotCaps Component.SplitButtonTrailingButtonSlot msg
    -> Element free freeAdmittedBy msg
trailingButton builder =
    Component.splitButtonTrailingButton (B.toElement builder)


{-| -}
withLeadingButton :
    B.Builder childRow childAttrCaps childSlotCaps Component.SplitButtonLeadingButtonSlot msg
    -> Builder attrCaps { s | leadingButton : Available } msg kind
    -> Builder attrCaps { s | leadingButton : Used } msg kind
withLeadingButton slotBuilder builder_ =
    B.withChild (El.toNode (Component.splitButtonLeadingButton (B.toElement slotBuilder))) builder_


{-| -}
withTrailingButton :
    B.Builder childRow childAttrCaps childSlotCaps Component.SplitButtonTrailingButtonSlot msg
    -> Builder attrCaps { s | trailingButton : Available } msg kind
    -> Builder attrCaps { s | trailingButton : Used } msg kind
withTrailingButton slotBuilder builder_ =
    B.withChild (El.toNode (Component.splitButtonTrailingButton (B.toElement slotBuilder))) builder_


{-| -}
withClass : String -> Builder { a | class : Available } slotCaps msg kind -> Builder { a | class : Used } slotCaps msg kind
withClass value_ =
    B.withAttribute (A.class value_)


{-| -}
withId : String -> Builder { a | id : Available } slotCaps msg kind -> Builder { a | id : Used } slotCaps msg kind
withId value_ =
    B.withAttribute (A.id value_)


{-| -}
withSlot : String -> Builder { a | slot : Available } slotCaps msg kind -> Builder { a | slot : Used } slotCaps msg kind
withSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
withStyle : String -> String -> Builder { a | style : Available } slotCaps msg kind -> Builder { a | style : Used } slotCaps msg kind
withStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
withSize : Value Component.SplitButtonSize -> Builder { a | size : Available } slotCaps msg kind -> Builder { a | size : Used } slotCaps msg kind
withSize value_ =
    B.withAttribute (Component.splitButtonSize value_)


{-| -}
withVariant : Value Component.SplitButtonVariant -> Builder { a | variant : Available } slotCaps msg kind -> Builder { a | variant : Used } slotCaps msg kind
withVariant value_ =
    B.withAttribute (Component.splitButtonVariant value_)
