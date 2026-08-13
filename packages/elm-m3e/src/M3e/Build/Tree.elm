module M3e.Build.Tree exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy
    , withCascade, withClass, withId, withMulti, withOnChange, withSlot, withStyle
    , withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy
@docs withCascade, withClass, withId, withMulti, withOnChange, withSlot, withStyle
@docs withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.Tree as Component
import M3e.Events as Ev
import M3e.Internal.Types.Tree
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| -}
type alias Is s =
    M3e.Internal.Types.Tree.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Tree.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    M3e.Internal.Types.Tree.AttrCaps


{-| -}
type alias SlotCaps =
    {}


{-| -}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Tree.ChildAdmittedBy childAdm


{-| -}
type alias Content =
    M3e.Internal.Types.Tree.Content


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-tree" [] []


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
withCascade : Bool -> Builder { a | cascade : Available } slotCaps msg kind -> Builder { a | cascade : Used } slotCaps msg kind
withCascade value_ =
    B.withAttribute (A.cascade value_)


{-| -}
withMulti : Bool -> Builder { a | multi : Available } slotCaps msg kind -> Builder { a | multi : Used } slotCaps msg kind
withMulti value_ =
    B.withAttribute (A.multi value_)


{-| -}
withOnChange : msg -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Ev.onChange value_)
