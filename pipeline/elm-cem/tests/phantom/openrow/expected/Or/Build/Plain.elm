module Or.Build.Plain exposing (Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy, build, toElement, withCdir, withCflag, withClass, withChild)

{-| The **Plain** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `Or.Component.Plain`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `Or.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy, build, toElement, withCdir, withCflag, withClass, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Or.Attributes as A
import Or.Component.Plain as Component
import Or.Forge.Internal as B
import Or.Kind exposing (Available, Brand, Ctx, Used)
import Or.Values


{-| -}
type alias Is s =
    Component.PlainIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.PlainBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.PlainAttrCaps


{-| -}
type alias SlotCaps =
    Component.PlainSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.PlainChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.PlainContent


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "or-plain" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.PlainIs kind) admittedBy msg
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
