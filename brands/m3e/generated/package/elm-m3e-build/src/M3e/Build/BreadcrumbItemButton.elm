module M3e.Build.BreadcrumbItemButton exposing (Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy, build, toElement, withClass, withCurrent, withDisabled, withDownload, withHref, withId, withOnClick, withRel, withSlot, withStyle, withTarget, withChild)

{-| The **BreadcrumbItemButton** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `M3e.Component.BreadcrumbItemButton`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy, build, toElement, withClass, withCurrent, withDisabled, withDownload, withHref, withId, withOnClick, withRel, withSlot, withStyle, withTarget, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.BreadcrumbItemButton as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.BreadcrumbItemButtonIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.BreadcrumbItemButtonBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.BreadcrumbItemButtonAttrCaps


{-| -}
type alias SlotCaps =
    Component.BreadcrumbItemButtonSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.BreadcrumbItemButtonChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.BreadcrumbItemButtonContent


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-breadcrumb-item-button" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.BreadcrumbItemButtonIs kind) admittedBy msg
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
withCurrent : Value Component.BreadcrumbItemButtonCurrent -> Builder { a | current : Available } slotCaps msg kind -> Builder { a | current : Used } slotCaps msg kind
withCurrent value_ =
    B.withAttribute (Component.breadcrumbItemButtonCurrent value_)


{-| -}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withDownload : String -> Builder { a | download : Available } slotCaps msg kind -> Builder { a | download : Used } slotCaps msg kind
withDownload value_ =
    B.withAttribute (A.download value_)


{-| -}
withHref : String -> Builder { a | href : Available } slotCaps msg kind -> Builder { a | href : Used } slotCaps msg kind
withHref value_ =
    B.withAttribute (A.href value_)


{-| -}
withRel : String -> Builder { a | rel : Available } slotCaps msg kind -> Builder { a | rel : Used } slotCaps msg kind
withRel value_ =
    B.withAttribute (A.rel value_)


{-| -}
withTarget : String -> Builder { a | target : Available } slotCaps msg kind -> Builder { a | target : Used } slotCaps msg kind
withTarget value_ =
    B.withAttribute (A.target value_)


{-| -}
withOnClick : msg -> Builder { a | onClick : Available } slotCaps msg kind -> Builder { a | onClick : Used } slotCaps msg kind
withOnClick value_ =
    B.withAttribute (Ev.onClick value_)
