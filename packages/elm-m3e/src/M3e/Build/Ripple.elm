module M3e.Build.Ripple exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withCentered, withClass, withDisabled, withFor, withId, withRadius, withSlot, withStyle, withUnbounded
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withCentered, withClass, withDisabled, withFor, withId, withRadius, withSlot, withStyle, withUnbounded

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.Ripple as Component
import M3e.Internal.Types.Ripple
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| -}
type alias Is s =
    M3e.Internal.Types.Ripple.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Ripple.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    M3e.Internal.Types.Ripple.AttrCaps


{-| -}
type alias SlotCaps =
    {}


{-| -}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Ripple.ChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-ripple" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


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
withCentered : Bool -> Builder { a | centered : Available } slotCaps msg kind -> Builder { a | centered : Used } slotCaps msg kind
withCentered value_ =
    B.withAttribute (A.centered value_)


{-| -}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withFor : String -> Builder { a | for : Available } slotCaps msg kind -> Builder { a | for : Used } slotCaps msg kind
withFor value_ =
    B.withAttribute (A.for value_)


{-| -}
withRadius : Float -> Builder { a | radius : Available } slotCaps msg kind -> Builder { a | radius : Used } slotCaps msg kind
withRadius value_ =
    B.withAttribute (A.radius value_)


{-| -}
withUnbounded : Bool -> Builder { a | unbounded : Available } slotCaps msg kind -> Builder { a | unbounded : Used } slotCaps msg kind
withUnbounded value_ =
    B.withAttribute (A.unbounded value_)
