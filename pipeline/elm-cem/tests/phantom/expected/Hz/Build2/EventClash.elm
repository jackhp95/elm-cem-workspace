module Hz.Build2.EventClash exposing (Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy, build, toElement, withClass, withId, withOnError, withOnHzError, withOnHzLoad, withOnLoad, withSlot, withStyle, withChild)

{-| The **EventClash** family — COMPOSED builders (DAG-rework Task 3 dual-emit).

One module carrying every member's builder surface
(degenerate single-member family — flat, un-prefixed surface),
sourced through `Hz.Component2.EventClash` (the family façade) rather
than the per-element `Hz.Element.*` modules. This is the Shape A
`Build2` cutover; it emits ALONGSIDE the shipped per-element `Hz.Build.*`
surface and does not replace it (until Task 4 materialize).

@docs Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy, build, toElement, withClass, withId, withOnError, withOnHzError, withOnHzLoad, withOnLoad, withSlot, withStyle, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Hz.Attributes as A
import Hz.Component2.EventClash as Component
import Hz.Events as Ev
import Hz.Forge.Internal as B
import Hz.Kind exposing (Available, Brand, Ctx, Used)
import Hz.Values


{-| -}
type alias Is s =
    Component.EventClashIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.EventClashBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.EventClashAttrCaps


{-| -}
type alias SlotCaps =
    Component.EventClashSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.EventClashChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.EventClashContent


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "hz-event-clash" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.EventClashIs kind) admittedBy msg
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
withOnError : msg -> Builder { a | onError : Available } slotCaps msg kind -> Builder { a | onError : Used } slotCaps msg kind
withOnError value_ =
    B.withAttribute (Ev.onError value_)


{-| -}
withOnHzError : msg -> Builder { a | onHzError : Available } slotCaps msg kind -> Builder { a | onHzError : Used } slotCaps msg kind
withOnHzError value_ =
    B.withAttribute (Ev.onHzError value_)


{-| -}
withOnLoad : msg -> Builder { a | onLoad : Available } slotCaps msg kind -> Builder { a | onLoad : Used } slotCaps msg kind
withOnLoad value_ =
    B.withAttribute (Ev.onLoad value_)


{-| -}
withOnHzLoad : msg -> Builder { a | onHzLoad : Available } slotCaps msg kind -> Builder { a | onHzLoad : Used } slotCaps msg kind
withOnHzLoad value_ =
    B.withAttribute (Ev.onHzLoad value_)
