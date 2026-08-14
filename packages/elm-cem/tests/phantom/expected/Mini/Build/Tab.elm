module Mini.Build.Tab exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy, AdmittedBy
    , withClass, withDir, withId, withInert, withSlot, withStyle, withTabindex
    , withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy, AdmittedBy
@docs withClass, withDir, withId, withInert, withSlot, withStyle, withTabindex
@docs withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import Mini.Attributes as A
import Mini.Component.Tab as Component
import Mini.Forge.Internal as B
import Mini.Internal.Types.Tab
import Mini.Kind exposing (Available, Brand, Ctx, Used)
import Mini.Values


{-| -}
type alias Is s =
    Mini.Internal.Types.Tab.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Mini.Internal.Types.Tab.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Mini.Internal.Types.Tab.AttrCaps


{-| -}
type alias SlotCaps =
    {}


{-| -}
type alias ChildAdmittedBy childAdm =
    Mini.Internal.Types.Tab.ChildAdmittedBy childAdm


{-| -}
type alias AdmittedBy =
    Mini.Internal.Types.Tab.AdmittedBy


{-| -}
type alias Content =
    Mini.Internal.Types.Tab.Content


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "mini-tab" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) Component.AdmittedBy msg
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
withDir : Value Mini.Values.Dir -> Builder { a | dir : Available } slotCaps msg kind -> Builder { a | dir : Used } slotCaps msg kind
withDir value_ =
    B.withAttribute (A.dir value_)


{-| -}
withId : String -> Builder { a | id : Available } slotCaps msg kind -> Builder { a | id : Used } slotCaps msg kind
withId value_ =
    B.withAttribute (A.id value_)


{-| -}
withInert : Bool -> Builder { a | inert : Available } slotCaps msg kind -> Builder { a | inert : Used } slotCaps msg kind
withInert value_ =
    B.withAttribute (A.inert value_)


{-| -}
withSlot : String -> Builder { a | slot : Available } slotCaps msg kind -> Builder { a | slot : Used } slotCaps msg kind
withSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
withStyle : String -> String -> Builder { a | style : Available } slotCaps msg kind -> Builder { a | style : Used } slotCaps msg kind
withStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
withTabindex : Int -> Builder { a | tabindex : Available } slotCaps msg kind -> Builder { a | tabindex : Used } slotCaps msg kind
withTabindex value_ =
    B.withAttribute (A.tabindex value_)
