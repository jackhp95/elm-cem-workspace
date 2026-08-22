module M3e.Build.PseudoCheckbox exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withChecked, withClass, withDisabled, withId, withIndeterminate, withSlot, withStyle)

{-| The **PseudoCheckbox** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `M3e.Component.PseudoCheckbox`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withChecked, withClass, withDisabled, withId, withIndeterminate, withSlot, withStyle

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.PseudoCheckbox as Component
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.PseudoCheckboxIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.PseudoCheckboxBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.PseudoCheckboxAttrCaps


{-| -}
type alias SlotCaps =
    Component.PseudoCheckboxSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.PseudoCheckboxChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-pseudo-checkbox" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.PseudoCheckboxIs kind) admittedBy msg
toElement =
    B.toElement


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
withChecked : Bool -> Builder { a | checked : Available } slotCaps msg kind -> Builder { a | checked : Used } slotCaps msg kind
withChecked value_ =
    B.withAttribute (A.checked value_)


{-| -}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withIndeterminate : Bool -> Builder { a | indeterminate : Available } slotCaps msg kind -> Builder { a | indeterminate : Used } slotCaps msg kind
withIndeterminate value_ =
    B.withAttribute (A.indeterminate value_)
