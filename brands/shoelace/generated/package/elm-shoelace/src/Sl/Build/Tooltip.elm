module Sl.Build.Tooltip exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withClass, withContent, withDisabled, withDistance, withHoist, withId, withOnAfterHide, withOnAfterShow, withOnHide, withOnShow, withOpen, withPlacement, withSkidding, withSlot, withStyle, withTrigger
    , withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withClass, withContent, withDisabled, withDistance, withHoist, withId, withOnAfterHide, withOnAfterShow, withOnHide, withOnShow, withOpen, withPlacement, withSkidding, withSlot, withStyle, withTrigger
@docs withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Attributes as A
import Sl.Element.Tooltip as Component
import Sl.Events as Ev
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)
import Sl.Values


{-| -}
type alias Is s =
    Component.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.AttrCaps


{-| -}
type alias SlotCaps =
    {}


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.ChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-tooltip" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
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
withContent : String -> Builder { a | content : Available } slotCaps msg kind -> Builder { a | content : Used } slotCaps msg kind
withContent value_ =
    B.withAttribute (A.content value_)


{-| -}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withDistance : Float -> Builder { a | distance : Available } slotCaps msg kind -> Builder { a | distance : Used } slotCaps msg kind
withDistance value_ =
    B.withAttribute (A.distance value_)


{-| -}
withHoist : Bool -> Builder { a | hoist : Available } slotCaps msg kind -> Builder { a | hoist : Used } slotCaps msg kind
withHoist value_ =
    B.withAttribute (A.hoist value_)


{-| -}
withOpen : Bool -> Builder { a | open : Available } slotCaps msg kind -> Builder { a | open : Used } slotCaps msg kind
withOpen value_ =
    B.withAttribute (A.open value_)


{-| -}
withPlacement : Value Component.Placement -> Builder { a | placement : Available } slotCaps msg kind -> Builder { a | placement : Used } slotCaps msg kind
withPlacement value_ =
    B.withAttribute (Component.placement value_)


{-| -}
withSkidding : Float -> Builder { a | skidding : Available } slotCaps msg kind -> Builder { a | skidding : Used } slotCaps msg kind
withSkidding value_ =
    B.withAttribute (A.skidding value_)


{-| -}
withTrigger : String -> Builder { a | trigger : Available } slotCaps msg kind -> Builder { a | trigger : Used } slotCaps msg kind
withTrigger value_ =
    B.withAttribute (A.trigger value_)


{-| -}
withOnShow : msg -> Builder { a | onShow : Available } slotCaps msg kind -> Builder { a | onShow : Used } slotCaps msg kind
withOnShow value_ =
    B.withAttribute (Ev.onShow value_)


{-| -}
withOnAfterShow : msg -> Builder { a | onAfterShow : Available } slotCaps msg kind -> Builder { a | onAfterShow : Used } slotCaps msg kind
withOnAfterShow value_ =
    B.withAttribute (Ev.onAfterShow value_)


{-| -}
withOnHide : msg -> Builder { a | onHide : Available } slotCaps msg kind -> Builder { a | onHide : Used } slotCaps msg kind
withOnHide value_ =
    B.withAttribute (Ev.onHide value_)


{-| -}
withOnAfterHide : msg -> Builder { a | onAfterHide : Available } slotCaps msg kind -> Builder { a | onAfterHide : Used } slotCaps msg kind
withOnAfterHide value_ =
    B.withAttribute (Ev.onAfterHide value_)
