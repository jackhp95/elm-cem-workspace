module Or.Build.Plain exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy
    , withCdir, withCflag, withClass
    , withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy
@docs withCdir, withCflag, withClass
@docs withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Or.Attributes as A
import Or.Element.Plain as Component
import Or.Forge.Internal as B
import Or.Kind exposing (Available, Brand, Ctx, Used)
import Or.Values


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
type alias Content =
    Component.Content


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "or-plain" [] []


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
withCdir : Value Or.Values.Cdir -> Builder { a | cdir : Available } slotCaps msg kind -> Builder { a | cdir : Used } slotCaps msg kind
withCdir value_ =
    B.withAttribute (A.cdir value_)


{-| -}
withCflag : Bool -> Builder { a | cflag : Available } slotCaps msg kind -> Builder { a | cflag : Used } slotCaps msg kind
withCflag value_ =
    B.withAttribute (A.cflag value_)


{-| -}
withClass : String -> Builder { a | class : Available } slotCaps msg kind -> Builder { a | class : Used } slotCaps msg kind
withClass value_ =
    B.withAttribute (A.class value_)
