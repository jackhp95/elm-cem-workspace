module Mini.Build2.Tab exposing (Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy, AdmittedBy, build, toElement, withClass, withDir, withId, withInert, withSlot, withStyle, withTabindex, withChild)

{-| The **Tab** family — COMPOSED builders (DAG-rework Task 3 dual-emit).

One module carrying every member's builder surface
(degenerate single-member family — flat, un-prefixed surface),
sourced through `Mini.Component2.Tab` (the family façade) rather
than the per-element `Mini.Element.*` modules. This is the Shape A
`Build2` cutover; it emits ALONGSIDE the shipped per-element `Mini.Build.*`
surface and does not replace it (until Task 4 materialize).

@docs Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy, AdmittedBy, build, toElement, withClass, withDir, withId, withInert, withSlot, withStyle, withTabindex, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Mini.Attributes as A
import Mini.Component2.Tab as Component
import Mini.Forge.Internal as B
import Mini.Kind exposing (Available, Brand, Ctx, Used)
import Mini.Values


{-| -}
type alias Is s =
    Component.TabIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.TabBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.TabAttrCaps


{-| -}
type alias SlotCaps =
    Component.TabSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.TabChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.TabContent


{-| -}
type alias AdmittedBy =
    Component.TabAdmittedBy


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "mini-tab" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.TabIs kind) Component.TabAdmittedBy msg
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
