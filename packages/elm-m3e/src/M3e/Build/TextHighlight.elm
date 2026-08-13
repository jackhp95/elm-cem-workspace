module M3e.Build.TextHighlight exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withCaseSensitive, withClass, withDisabled, withId, withMode, withOnHighlight, withSlot, withStyle, withTerm
    , withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withCaseSensitive, withClass, withDisabled, withId, withMode, withOnHighlight, withSlot, withStyle, withTerm
@docs withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.TextHighlight as Component
import M3e.Events as Ev
import M3e.Internal.Types.TextHighlight
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    M3e.Internal.Types.TextHighlight.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.TextHighlight.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    M3e.Internal.Types.TextHighlight.AttrCaps


{-| -}
type alias SlotCaps =
    {}


{-| -}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.TextHighlight.ChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-text-highlight" [] []


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
withCaseSensitive : Bool -> Builder { a | caseSensitive : Available } slotCaps msg kind -> Builder { a | caseSensitive : Used } slotCaps msg kind
withCaseSensitive value_ =
    B.withAttribute (A.caseSensitive value_)


{-| -}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withMode : Value Component.Mode -> Builder { a | mode : Available } slotCaps msg kind -> Builder { a | mode : Used } slotCaps msg kind
withMode value_ =
    B.withAttribute (Component.mode value_)


{-| -}
withTerm : String -> Builder { a | term : Available } slotCaps msg kind -> Builder { a | term : Used } slotCaps msg kind
withTerm value_ =
    B.withAttribute (A.term value_)


{-| -}
withOnHighlight : msg -> Builder { a | onHighlight : Available } slotCaps msg kind -> Builder { a | onHighlight : Used } slotCaps msg kind
withOnHighlight value_ =
    B.withAttribute (Ev.onHighlight value_)
