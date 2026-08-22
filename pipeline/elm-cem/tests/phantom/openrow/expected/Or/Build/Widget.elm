module Or.Build.Widget exposing (Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy, build, toElement, withCdir, withCflag, withClass, withLabel, withChild)

{-| The **Widget** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `Or.Component.Widget`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `Or.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy, build, toElement, withCdir, withCflag, withClass, withLabel, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Or.Attributes as A
import Or.Component.Widget as Component
import Or.Forge.Internal as B
import Or.Kind exposing (Available, Brand, Ctx, Used)
import Or.Values


{-| -}
type alias Is s =
    Component.WidgetIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.WidgetBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.WidgetAttrCaps


{-| -}
type alias SlotCaps =
    Component.WidgetSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.WidgetChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.WidgetContent


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "or-widget" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.WidgetIs kind) admittedBy msg
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


{-| -}
withLabel : String -> Builder { a | label : Available } slotCaps msg kind -> Builder { a | label : Used } slotCaps msg kind
withLabel value_ =
    B.withAttribute (A.label value_)
