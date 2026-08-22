module Sl.Build.CopyButton exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withCopyLabel, withDisabled, withErrorLabel, withFeedbackDuration, withFrom, withHoist, withId, withOnCopy, withOnError, withSlot, withStyle, withSuccessLabel, withTooltipPlacement, withValue)

{-| The **CopyButton** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `Sl.Component.CopyButton`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `Sl.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withCopyLabel, withDisabled, withErrorLabel, withFeedbackDuration, withFrom, withHoist, withId, withOnCopy, withOnError, withSlot, withStyle, withSuccessLabel, withTooltipPlacement, withValue

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Attributes as A
import Sl.Component.CopyButton as Component
import Sl.Events as Ev
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)
import Sl.Values


{-| -}
type alias Is s =
    Component.CopyButtonIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.CopyButtonBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.CopyButtonAttrCaps


{-| -}
type alias SlotCaps =
    Component.CopyButtonSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.CopyButtonChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-copy-button" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.CopyButtonIs kind) admittedBy msg
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
withCopyLabel : String -> Builder { a | copyLabel : Available } slotCaps msg kind -> Builder { a | copyLabel : Used } slotCaps msg kind
withCopyLabel value_ =
    B.withAttribute (A.copyLabel value_)


{-| -}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withErrorLabel : String -> Builder { a | errorLabel : Available } slotCaps msg kind -> Builder { a | errorLabel : Used } slotCaps msg kind
withErrorLabel value_ =
    B.withAttribute (A.errorLabel value_)


{-| -}
withFeedbackDuration : Float -> Builder { a | feedbackDuration : Available } slotCaps msg kind -> Builder { a | feedbackDuration : Used } slotCaps msg kind
withFeedbackDuration value_ =
    B.withAttribute (A.feedbackDuration value_)


{-| -}
withFrom : String -> Builder { a | from : Available } slotCaps msg kind -> Builder { a | from : Used } slotCaps msg kind
withFrom value_ =
    B.withAttribute (A.from value_)


{-| -}
withHoist : Bool -> Builder { a | hoist : Available } slotCaps msg kind -> Builder { a | hoist : Used } slotCaps msg kind
withHoist value_ =
    B.withAttribute (A.hoist value_)


{-| -}
withSuccessLabel : String -> Builder { a | successLabel : Available } slotCaps msg kind -> Builder { a | successLabel : Used } slotCaps msg kind
withSuccessLabel value_ =
    B.withAttribute (A.successLabel value_)


{-| -}
withTooltipPlacement : Value Component.CopyButtonTooltipPlacement -> Builder { a | tooltipPlacement : Available } slotCaps msg kind -> Builder { a | tooltipPlacement : Used } slotCaps msg kind
withTooltipPlacement value_ =
    B.withAttribute (Component.copyButtonTooltipPlacement value_)


{-| -}
withValue : String -> Builder { a | value : Available } slotCaps msg kind -> Builder { a | value : Used } slotCaps msg kind
withValue value_ =
    B.withAttribute (A.value value_)


{-| -}
withOnCopy : msg -> Builder { a | onCopy : Available } slotCaps msg kind -> Builder { a | onCopy : Used } slotCaps msg kind
withOnCopy value_ =
    B.withAttribute (Ev.onCopy value_)


{-| -}
withOnError : msg -> Builder { a | onError : Available } slotCaps msg kind -> Builder { a | onError : Used } slotCaps msg kind
withOnError value_ =
    B.withAttribute (Ev.onError value_)
