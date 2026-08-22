module M3e.Build.StateLayer exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withDisableHover, withDisabled, withEnablePressed, withFor, withId, withSlot, withStyle)

{-| The **StateLayer** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `M3e.Component.StateLayer`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withDisableHover, withDisabled, withEnablePressed, withFor, withId, withSlot, withStyle

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.StateLayer as Component
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.StateLayerIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.StateLayerBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.StateLayerAttrCaps


{-| -}
type alias SlotCaps =
    Component.StateLayerSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.StateLayerChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-state-layer" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.StateLayerIs kind) admittedBy msg
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
withDisableHover : Bool -> Builder { a | disableHover : Available } slotCaps msg kind -> Builder { a | disableHover : Used } slotCaps msg kind
withDisableHover value_ =
    B.withAttribute (A.disableHover value_)


{-| -}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withEnablePressed : Bool -> Builder { a | enablePressed : Available } slotCaps msg kind -> Builder { a | enablePressed : Used } slotCaps msg kind
withEnablePressed value_ =
    B.withAttribute (A.enablePressed value_)


{-| -}
withFor : String -> Builder { a | for : Available } slotCaps msg kind -> Builder { a | for : Used } slotCaps msg kind
withFor value_ =
    B.withAttribute (A.for value_)
