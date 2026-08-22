module Sl.Build.Details exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withClass, withDisabled, withId, withOnAfterHide, withOnAfterShow, withOnHide, withOnShow, withOpen, withSlot, withStyle, withSummary
    , withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withClass, withDisabled, withId, withOnAfterHide, withOnAfterShow, withOnHide, withOnShow, withOpen, withSlot, withStyle, withSummary
@docs withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Sl.Attributes as A
import Sl.Element.Details as Component
import Sl.Events as Ev
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


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
    B.init "sl-details" [] []


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
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withOpen : Bool -> Builder { a | open : Available } slotCaps msg kind -> Builder { a | open : Used } slotCaps msg kind
withOpen value_ =
    B.withAttribute (A.open value_)


{-| -}
withSummary : String -> Builder { a | summary : Available } slotCaps msg kind -> Builder { a | summary : Used } slotCaps msg kind
withSummary value_ =
    B.withAttribute (A.summary value_)


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
