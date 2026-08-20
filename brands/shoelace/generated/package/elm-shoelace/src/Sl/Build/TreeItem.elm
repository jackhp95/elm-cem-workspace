module Sl.Build.TreeItem exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withClass, withDisabled, withExpanded, withId, withLazy, withOnAfterCollapse, withOnAfterExpand, withOnCollapse, withOnExpand, withOnLazyChange, withOnLazyLoad, withSelected, withSlot, withStyle
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withClass, withDisabled, withExpanded, withId, withLazy, withOnAfterCollapse, withOnAfterExpand, withOnCollapse, withOnExpand, withOnLazyChange, withOnLazyLoad, withSelected, withSlot, withStyle

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Sl.Attributes as A
import Sl.Component.TreeItem as Component
import Sl.Events as Ev
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


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
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-tree-item" [] []


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
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withExpanded : Bool -> Builder { a | expanded : Available } slotCaps msg kind -> Builder { a | expanded : Used } slotCaps msg kind
withExpanded value_ =
    B.withAttribute (A.expanded value_)


{-| -}
withLazy : Bool -> Builder { a | lazy : Available } slotCaps msg kind -> Builder { a | lazy : Used } slotCaps msg kind
withLazy value_ =
    B.withAttribute (A.lazy value_)


{-| -}
withSelected : Bool -> Builder { a | selected : Available } slotCaps msg kind -> Builder { a | selected : Used } slotCaps msg kind
withSelected value_ =
    B.withAttribute (A.selected value_)


{-| -}
withOnExpand : msg -> Builder { a | onExpand : Available } slotCaps msg kind -> Builder { a | onExpand : Used } slotCaps msg kind
withOnExpand value_ =
    B.withAttribute (Ev.onExpand value_)


{-| -}
withOnAfterExpand : msg -> Builder { a | onAfterExpand : Available } slotCaps msg kind -> Builder { a | onAfterExpand : Used } slotCaps msg kind
withOnAfterExpand value_ =
    B.withAttribute (Ev.onAfterExpand value_)


{-| -}
withOnCollapse : msg -> Builder { a | onCollapse : Available } slotCaps msg kind -> Builder { a | onCollapse : Used } slotCaps msg kind
withOnCollapse value_ =
    B.withAttribute (Ev.onCollapse value_)


{-| -}
withOnAfterCollapse : msg -> Builder { a | onAfterCollapse : Available } slotCaps msg kind -> Builder { a | onAfterCollapse : Used } slotCaps msg kind
withOnAfterCollapse value_ =
    B.withAttribute (Ev.onAfterCollapse value_)


{-| -}
withOnLazyChange : msg -> Builder { a | onLazyChange : Available } slotCaps msg kind -> Builder { a | onLazyChange : Used } slotCaps msg kind
withOnLazyChange value_ =
    B.withAttribute (Ev.onLazyChange value_)


{-| -}
withOnLazyLoad : msg -> Builder { a | onLazyLoad : Available } slotCaps msg kind -> Builder { a | onLazyLoad : Used } slotCaps msg kind
withOnLazyLoad value_ =
    B.withAttribute (Ev.onLazyLoad value_)
