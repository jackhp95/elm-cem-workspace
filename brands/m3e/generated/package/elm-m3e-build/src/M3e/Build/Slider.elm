module M3e.Build.Slider exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withDisabled, withDiscrete, withId, withLabelled, withMax, withMin, withOnBeforeinput, withOnChange, withOnInput, withSize, withSlot, withStep, withStyle, withChild)

{-| The **Slider** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `M3e.Component.Slider`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withDisabled, withDiscrete, withId, withLabelled, withMax, withMin, withOnBeforeinput, withOnChange, withOnInput, withSize, withSlot, withStep, withStyle, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.Slider as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.SliderIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.SliderBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.SliderAttrCaps


{-| -}
type alias SlotCaps =
    Component.SliderSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.SliderChildAdmittedBy childAdm


{-| -}
build :
    { content : Element childAccepts (Component.SliderChildAdmittedBy childAdm) msg }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-slider" [] [ El.toNode required_.content ]


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.SliderIs kind) admittedBy msg
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
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withDiscrete : Bool -> Builder { a | discrete : Available } slotCaps msg kind -> Builder { a | discrete : Used } slotCaps msg kind
withDiscrete value_ =
    B.withAttribute (A.discrete value_)


{-| -}
withLabelled : Bool -> Builder { a | labelled : Available } slotCaps msg kind -> Builder { a | labelled : Used } slotCaps msg kind
withLabelled value_ =
    B.withAttribute (A.labelled value_)


{-| -}
withMax : Float -> Builder { a | max : Available } slotCaps msg kind -> Builder { a | max : Used } slotCaps msg kind
withMax value_ =
    B.withAttribute (A.max value_)


{-| -}
withMin : Float -> Builder { a | min : Available } slotCaps msg kind -> Builder { a | min : Used } slotCaps msg kind
withMin value_ =
    B.withAttribute (A.min value_)


{-| -}
withSize : Value Component.SliderSize -> Builder { a | size : Available } slotCaps msg kind -> Builder { a | size : Used } slotCaps msg kind
withSize value_ =
    B.withAttribute (Component.sliderSize value_)


{-| -}
withStep : Float -> Builder { a | step : Available } slotCaps msg kind -> Builder { a | step : Used } slotCaps msg kind
withStep value_ =
    B.withAttribute (A.step value_)


{-| -}
withOnBeforeinput : msg -> Builder { a | onBeforeinput : Available } slotCaps msg kind -> Builder { a | onBeforeinput : Used } slotCaps msg kind
withOnBeforeinput value_ =
    B.withAttribute (Ev.onBeforeinput value_)


{-| -}
withOnInput : msg -> Builder { a | onInput : Available } slotCaps msg kind -> Builder { a | onInput : Used } slotCaps msg kind
withOnInput value_ =
    B.withAttribute (Ev.onInput value_)


{-| -}
withOnChange : msg -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Ev.onChange value_)
