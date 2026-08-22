module M3e.Build.Progress exposing (CircularBuilder, CircularAttrCaps, CircularSlotCaps, CircularIs, CircularChildAdmittedBy, circularBuild, circularToElement, circularWithClass, circularWithId, circularWithIndeterminate, circularWithMax, circularWithSlot, circularWithStyle, circularWithValue, circularWithVariant, circularWithChild, LinearBuilder, LinearAttrCaps, LinearSlotCaps, LinearIs, LinearChildAdmittedBy, linearBuild, linearToElement, linearWithBufferValue, linearWithClass, linearWithId, linearWithMax, linearWithMode, linearWithSlot, linearWithStyle, linearWithValue, linearWithVariant, LoadingBuilder, LoadingAttrCaps, LoadingSlotCaps, LoadingIs, LoadingChildAdmittedBy, loadingBuild, loadingToElement, loadingWithClass, loadingWithId, loadingWithSlot, loadingWithStyle, loadingWithVariant)

{-| The **Progress** family — the COMPOSED builder tier.

One module carrying every member's builder surface, member-prefixed
(the per-element flat surface lives at `M3e.Build.<Element>`), sourced through `M3e.Component.Progress`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs CircularBuilder, CircularAttrCaps, CircularSlotCaps, CircularIs, CircularChildAdmittedBy, circularBuild, circularToElement, circularWithClass, circularWithId, circularWithIndeterminate, circularWithMax, circularWithSlot, circularWithStyle, circularWithValue, circularWithVariant, circularWithChild, LinearBuilder, LinearAttrCaps, LinearSlotCaps, LinearIs, LinearChildAdmittedBy, linearBuild, linearToElement, linearWithBufferValue, linearWithClass, linearWithId, linearWithMax, linearWithMode, linearWithSlot, linearWithStyle, linearWithValue, linearWithVariant, LoadingBuilder, LoadingAttrCaps, LoadingSlotCaps, LoadingIs, LoadingChildAdmittedBy, loadingBuild, loadingToElement, loadingWithClass, loadingWithId, loadingWithSlot, loadingWithStyle, loadingWithVariant

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
type alias CircularIs s =
    Component.CircularIs s


{-| -}
type alias CircularBuilder attrCaps slotCaps msg kind =
    Component.CircularBuilder attrCaps slotCaps msg kind


{-| -}
type alias CircularAttrCaps =
    Component.CircularAttrCaps


{-| -}
type alias CircularSlotCaps =
    Component.CircularSlotCaps


{-| -}
type alias CircularChildAdmittedBy childAdm =
    Component.CircularChildAdmittedBy childAdm


{-| -}
circularBuild : CircularBuilder CircularAttrCaps CircularSlotCaps msg kind
circularBuild =
    B.init "m3e-circular-progress-indicator" [] []


{-| -}
circularToElement : CircularBuilder attrCaps slotCaps msg kind -> Element (Component.CircularIs kind) admittedBy msg
circularToElement =
    B.toElement


{-| -}
circularWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> CircularBuilder attrCaps slotCaps msg kind
    -> CircularBuilder attrCaps slotCaps msg kind
circularWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
circularWithClass : String -> CircularBuilder { a | class : Available } slotCaps msg kind -> CircularBuilder { a | class : Used } slotCaps msg kind
circularWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
circularWithId : String -> CircularBuilder { a | id : Available } slotCaps msg kind -> CircularBuilder { a | id : Used } slotCaps msg kind
circularWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
circularWithSlot : String -> CircularBuilder { a | slot : Available } slotCaps msg kind -> CircularBuilder { a | slot : Used } slotCaps msg kind
circularWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
circularWithStyle : String -> String -> CircularBuilder { a | style : Available } slotCaps msg kind -> CircularBuilder { a | style : Used } slotCaps msg kind
circularWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
circularWithIndeterminate : Bool -> CircularBuilder { a | indeterminate : Available } slotCaps msg kind -> CircularBuilder { a | indeterminate : Used } slotCaps msg kind
circularWithIndeterminate value_ =
    B.withAttribute (A.indeterminate value_)


{-| -}
circularWithMax : Float -> CircularBuilder { a | max : Available } slotCaps msg kind -> CircularBuilder { a | max : Used } slotCaps msg kind
circularWithMax value_ =
    B.withAttribute (A.max value_)


{-| -}
circularWithValue : Float -> CircularBuilder { a | value : Available } slotCaps msg kind -> CircularBuilder { a | value : Used } slotCaps msg kind
circularWithValue value_ =
    B.withAttribute (Ir.property "value" (Json.Encode.float value_))


{-| -}
circularWithVariant : Value Component.CircularVariant -> CircularBuilder { a | variant : Available } slotCaps msg kind -> CircularBuilder { a | variant : Used } slotCaps msg kind
circularWithVariant value_ =
    B.withAttribute (Component.circularVariant value_)


{-| -}
type alias LinearIs s =
    Component.LinearIs s


{-| -}
type alias LinearBuilder attrCaps slotCaps msg kind =
    Component.LinearBuilder attrCaps slotCaps msg kind


{-| -}
type alias LinearAttrCaps =
    Component.LinearAttrCaps


{-| -}
type alias LinearSlotCaps =
    Component.LinearSlotCaps


{-| -}
type alias LinearChildAdmittedBy childAdm =
    Component.LinearChildAdmittedBy childAdm


{-| -}
linearBuild : LinearBuilder LinearAttrCaps LinearSlotCaps msg kind
linearBuild =
    B.init "m3e-linear-progress-indicator" [] []


{-| -}
linearToElement : LinearBuilder attrCaps slotCaps msg kind -> Element (Component.LinearIs kind) admittedBy msg
linearToElement =
    B.toElement


{-| -}
linearWithClass : String -> LinearBuilder { a | class : Available } slotCaps msg kind -> LinearBuilder { a | class : Used } slotCaps msg kind
linearWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
linearWithId : String -> LinearBuilder { a | id : Available } slotCaps msg kind -> LinearBuilder { a | id : Used } slotCaps msg kind
linearWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
linearWithSlot : String -> LinearBuilder { a | slot : Available } slotCaps msg kind -> LinearBuilder { a | slot : Used } slotCaps msg kind
linearWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
linearWithStyle : String -> String -> LinearBuilder { a | style : Available } slotCaps msg kind -> LinearBuilder { a | style : Used } slotCaps msg kind
linearWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
linearWithBufferValue : Float -> LinearBuilder { a | bufferValue : Available } slotCaps msg kind -> LinearBuilder { a | bufferValue : Used } slotCaps msg kind
linearWithBufferValue value_ =
    B.withAttribute (A.bufferValue value_)


{-| -}
linearWithMax : Float -> LinearBuilder { a | max : Available } slotCaps msg kind -> LinearBuilder { a | max : Used } slotCaps msg kind
linearWithMax value_ =
    B.withAttribute (A.max value_)


{-| -}
linearWithMode : Value Component.LinearMode -> LinearBuilder { a | mode : Available } slotCaps msg kind -> LinearBuilder { a | mode : Used } slotCaps msg kind
linearWithMode value_ =
    B.withAttribute (Component.linearMode value_)


{-| -}
linearWithValue : Float -> LinearBuilder { a | value : Available } slotCaps msg kind -> LinearBuilder { a | value : Used } slotCaps msg kind
linearWithValue value_ =
    B.withAttribute (Ir.property "value" (Json.Encode.float value_))


{-| -}
linearWithVariant : Value Component.LinearVariant -> LinearBuilder { a | variant : Available } slotCaps msg kind -> LinearBuilder { a | variant : Used } slotCaps msg kind
linearWithVariant value_ =
    B.withAttribute (Component.linearVariant value_)


{-| -}
type alias LoadingIs s =
    Component.LoadingIs s


{-| -}
type alias LoadingBuilder attrCaps slotCaps msg kind =
    Component.LoadingBuilder attrCaps slotCaps msg kind


{-| -}
type alias LoadingAttrCaps =
    Component.LoadingAttrCaps


{-| -}
type alias LoadingSlotCaps =
    Component.LoadingSlotCaps


{-| -}
type alias LoadingChildAdmittedBy childAdm =
    Component.LoadingChildAdmittedBy childAdm


{-| -}
loadingBuild : LoadingBuilder LoadingAttrCaps LoadingSlotCaps msg kind
loadingBuild =
    B.init "m3e-loading-indicator" [] []


{-| -}
loadingToElement : LoadingBuilder attrCaps slotCaps msg kind -> Element (Component.LoadingIs kind) admittedBy msg
loadingToElement =
    B.toElement


{-| -}
loadingWithClass : String -> LoadingBuilder { a | class : Available } slotCaps msg kind -> LoadingBuilder { a | class : Used } slotCaps msg kind
loadingWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
loadingWithId : String -> LoadingBuilder { a | id : Available } slotCaps msg kind -> LoadingBuilder { a | id : Used } slotCaps msg kind
loadingWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
loadingWithSlot : String -> LoadingBuilder { a | slot : Available } slotCaps msg kind -> LoadingBuilder { a | slot : Used } slotCaps msg kind
loadingWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
loadingWithStyle : String -> String -> LoadingBuilder { a | style : Available } slotCaps msg kind -> LoadingBuilder { a | style : Used } slotCaps msg kind
loadingWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
loadingWithVariant : Value Component.LoadingVariant -> LoadingBuilder { a | variant : Available } slotCaps msg kind -> LoadingBuilder { a | variant : Used } slotCaps msg kind
loadingWithVariant value_ =
    B.withAttribute (Component.loadingVariant value_)
