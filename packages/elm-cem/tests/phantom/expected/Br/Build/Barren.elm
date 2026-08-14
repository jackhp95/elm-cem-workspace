module Br.Build.Barren exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy
    , withClass, withCount, withId, withLabel, withSlot, withStyle
    , withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy
@docs withClass, withCount, withId, withLabel, withSlot, withStyle
@docs withChild

-}

import Br.Attributes as A
import Br.Component.Barren as Component
import Br.Forge.Internal as B
import Br.Internal.Types.Barren
import Br.Kind exposing (Available, Brand, Ctx, Used)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)


{-| -}
type alias Is s =
    Br.Internal.Types.Barren.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Br.Internal.Types.Barren.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Br.Internal.Types.Barren.AttrCaps


{-| -}
type alias SlotCaps =
    {}


{-| -}
type alias ChildAdmittedBy childAdm =
    Br.Internal.Types.Barren.ChildAdmittedBy childAdm


{-| -}
type alias Content =
    Br.Internal.Types.Barren.Content


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "br-barren" [] []


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
withCount : Float -> Builder { a | count : Available } slotCaps msg kind -> Builder { a | count : Used } slotCaps msg kind
withCount value_ =
    B.withAttribute (A.count value_)


{-| -}
withLabel : String -> Builder { a | label : Available } slotCaps msg kind -> Builder { a | label : Used } slotCaps msg kind
withLabel value_ =
    B.withAttribute (A.label value_)
