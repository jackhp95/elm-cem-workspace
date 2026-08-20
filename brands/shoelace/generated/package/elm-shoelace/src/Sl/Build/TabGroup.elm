module Sl.Build.TabGroup exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withActivation, withClass, withFixedScrollControls, withId, withNoScrollControls, withOnTabHide, withOnTabShow, withPlacement, withSlot, withStyle
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withActivation, withClass, withFixedScrollControls, withId, withNoScrollControls, withOnTabHide, withOnTabShow, withPlacement, withSlot, withStyle

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Attributes as A
import Sl.Component.TabGroup as Component
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
    B.init "sl-tab-group" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
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
withActivation : Value Component.Activation -> Builder { a | activation : Available } slotCaps msg kind -> Builder { a | activation : Used } slotCaps msg kind
withActivation value_ =
    B.withAttribute (Component.activation value_)


{-| -}
withFixedScrollControls : Bool -> Builder { a | fixedScrollControls : Available } slotCaps msg kind -> Builder { a | fixedScrollControls : Used } slotCaps msg kind
withFixedScrollControls value_ =
    B.withAttribute (A.fixedScrollControls value_)


{-| -}
withNoScrollControls : Bool -> Builder { a | noScrollControls : Available } slotCaps msg kind -> Builder { a | noScrollControls : Used } slotCaps msg kind
withNoScrollControls value_ =
    B.withAttribute (A.noScrollControls value_)


{-| -}
withPlacement : Value Component.Placement -> Builder { a | placement : Available } slotCaps msg kind -> Builder { a | placement : Used } slotCaps msg kind
withPlacement value_ =
    B.withAttribute (Component.placement value_)


{-| -}
withOnTabShow : msg -> Builder { a | onTabShow : Available } slotCaps msg kind -> Builder { a | onTabShow : Used } slotCaps msg kind
withOnTabShow value_ =
    B.withAttribute (Ev.onTabShow value_)


{-| -}
withOnTabHide : msg -> Builder { a | onTabHide : Available } slotCaps msg kind -> Builder { a | onTabHide : Used } slotCaps msg kind
withOnTabHide value_ =
    B.withAttribute (Ev.onTabHide value_)
