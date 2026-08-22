module Mini.Build.Button exposing (Builder, AttrCaps, SlotCaps, Is, Content, IconSlot, ChildAdmittedBy, build, toElement, withClass, withDir, withDisabled, withId, withInert, withOnClick, withSlot, withStyle, withTabindex, withVariant, withWeight, icon, withIcon, withChild)

{-| The **Button** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `Mini.Component.Button`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `Mini.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, Content, IconSlot, ChildAdmittedBy, build, toElement, withClass, withDir, withDisabled, withId, withInert, withOnClick, withSlot, withStyle, withTabindex, withVariant, withWeight, icon, withIcon, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Mini.Attributes as A
import Mini.Component.Button as Component
import Mini.Events as Ev
import Mini.Forge.Internal as B
import Mini.Kind exposing (Available, Brand, Ctx, Used)
import Mini.Values


{-| -}
type alias Is s =
    Component.ButtonIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.ButtonBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.ButtonAttrCaps


{-| -}
type alias SlotCaps =
    Component.ButtonSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.ButtonChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.ButtonContent


{-| -}
type alias IconSlot =
    Component.ButtonIconSlot


{-| -}
build :
    { content : Element Component.ButtonContent (Component.ButtonChildAdmittedBy childAdm) msg }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "mini-button" [] [ El.toNode required_.content ]


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.ButtonIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
icon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ButtonIconSlot msg
    -> Element free freeAdmittedBy msg
icon builder =
    Component.buttonIcon (B.toElement builder)


{-| -}
withIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ButtonIconSlot msg
    -> Builder attrCaps { s | icon : Available } msg kind
    -> Builder attrCaps { s | icon : Used } msg kind
withIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.buttonIcon (B.toElement slotBuilder))) builder_


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


{-| -}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withVariant : Value Component.ButtonVariant -> Builder { a | variant : Available } slotCaps msg kind -> Builder { a | variant : Used } slotCaps msg kind
withVariant value_ =
    B.withAttribute (Component.buttonVariant value_)


{-| -}
withWeight : String -> Builder { a | weight : Available } slotCaps msg kind -> Builder { a | weight : Used } slotCaps msg kind
withWeight value_ =
    B.withAttribute (A.weight value_)


{-| -}
withOnClick : msg -> Builder { a | onClick : Available } slotCaps msg kind -> Builder { a | onClick : Used } slotCaps msg kind
withOnClick value_ =
    B.withAttribute (Ev.onClick value_)
