module M3e.Build.CircularProgressIndicator exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withId, withIndeterminate, withMax, withSlot, withStyle, withValue, withVariant, withChild)

{-| The **CircularProgressIndicator** element — the flat per-element builder surface,
sourced through the **Progress** family façade
(`M3e.Component.Progress`). This module and the aggregated
`M3e.Build.Progress` are both first-class, permanent surfaces
(DAG-rework OQ-3/OQ-4).

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withId, withIndeterminate, withMax, withSlot, withStyle, withValue, withVariant, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Json.Encode
import M3e.Attributes as A
import M3e.Component.Progress as Component
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.CircularIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.CircularBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.CircularAttrCaps


{-| -}
type alias SlotCaps =
    Component.CircularSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.CircularChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-circular-progress-indicator" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.CircularIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
withChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


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
withIndeterminate : Bool -> Builder { a | indeterminate : Available } slotCaps msg kind -> Builder { a | indeterminate : Used } slotCaps msg kind
withIndeterminate value_ =
    B.withAttribute (A.indeterminate value_)


{-| -}
withMax : Float -> Builder { a | max : Available } slotCaps msg kind -> Builder { a | max : Used } slotCaps msg kind
withMax value_ =
    B.withAttribute (A.max value_)


{-| -}
withValue : Float -> Builder { a | value : Available } slotCaps msg kind -> Builder { a | value : Used } slotCaps msg kind
withValue value_ =
    B.withAttribute (Ir.property "value" (Json.Encode.float value_))


{-| -}
withVariant : Value Component.CircularVariant -> Builder { a | variant : Available } slotCaps msg kind -> Builder { a | variant : Used } slotCaps msg kind
withVariant value_ =
    B.withAttribute (Component.circularVariant value_)
