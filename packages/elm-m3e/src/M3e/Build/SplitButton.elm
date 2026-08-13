module M3e.Build.SplitButton exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, LeadingButtonSlot, TrailingButtonSlot, ChildAdmittedBy
    , withClass, withId, withSize, withSlot, withStyle, withVariant
    , leadingButton, trailingButton
    , withLeadingButton, withTrailingButton
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, LeadingButtonSlot, TrailingButtonSlot, ChildAdmittedBy
@docs withClass, withId, withSize, withSlot, withStyle, withVariant
@docs leadingButton, trailingButton
@docs withLeadingButton, withTrailingButton

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.SplitButton as Component
import M3e.Internal.Types.SplitButton
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    M3e.Internal.Types.SplitButton.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.SplitButton.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    M3e.Internal.Types.SplitButton.AttrCaps


{-| -}
type alias SlotCaps =
    M3e.Internal.Types.SplitButton.SlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.SplitButton.ChildAdmittedBy childAdm


{-| -}
type alias LeadingButtonSlot =
    M3e.Internal.Types.SplitButton.LeadingButtonSlot


{-| -}
type alias TrailingButtonSlot =
    M3e.Internal.Types.SplitButton.TrailingButtonSlot


{-| -}
build :
    { leadingButton : Element Component.LeadingButtonSlot (Component.ChildAdmittedBy childAdm) msg
    , trailingButton : Element Component.TrailingButtonSlot (Component.ChildAdmittedBy childAdm) msg
    }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-split-button" [] [ El.toNode (Component.leadingButton required_.leadingButton), El.toNode (Component.trailingButton required_.trailingButton) ]


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| -}
leadingButton :
    B.Builder childRow childAttrCaps childSlotCaps Component.LeadingButtonSlot msg
    -> Element free freeAdmittedBy msg
leadingButton builder =
    Component.leadingButton (B.toElement builder)


{-| -}
trailingButton :
    B.Builder childRow childAttrCaps childSlotCaps Component.TrailingButtonSlot msg
    -> Element free freeAdmittedBy msg
trailingButton builder =
    Component.trailingButton (B.toElement builder)


{-| -}
withLeadingButton :
    B.Builder childRow childAttrCaps childSlotCaps Component.LeadingButtonSlot msg
    -> Builder attrCaps { s | leadingButton : Available } msg kind
    -> Builder attrCaps { s | leadingButton : Used } msg kind
withLeadingButton slotBuilder builder_ =
    B.withChild (El.toNode (Component.leadingButton (B.toElement slotBuilder))) builder_


{-| -}
withTrailingButton :
    B.Builder childRow childAttrCaps childSlotCaps Component.TrailingButtonSlot msg
    -> Builder attrCaps { s | trailingButton : Available } msg kind
    -> Builder attrCaps { s | trailingButton : Used } msg kind
withTrailingButton slotBuilder builder_ =
    B.withChild (El.toNode (Component.trailingButton (B.toElement slotBuilder))) builder_


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
withSize : Value Component.Size -> Builder { a | size : Available } slotCaps msg kind -> Builder { a | size : Used } slotCaps msg kind
withSize value_ =
    B.withAttribute (Component.size value_)


{-| -}
withVariant : Value Component.Variant -> Builder { a | variant : Available } slotCaps msg kind -> Builder { a | variant : Used } slotCaps msg kind
withVariant value_ =
    B.withAttribute (Component.variant value_)
