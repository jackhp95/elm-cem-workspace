module M3e.Build.Step exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, Content, DoneIconSlot, EditIconSlot, ErrorSlot, ErrorIconSlot, HintSlot, IconSlot, ChildAdmittedBy
    , withClass, withCompleted, withDisabled, withEditable, withFor, withId, withInvalid, withOnBeforeinput, withOnChange, withOnClick, withOnInput, withOptional, withSelected, withSlot, withStyle
    , doneIcon, editIcon, error, errorIcon, hint, icon
    , withDoneIcon, withEditIcon, withError, withErrorIcon, withHint, withIcon, withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, Content, DoneIconSlot, EditIconSlot, ErrorSlot, ErrorIconSlot, HintSlot, IconSlot, ChildAdmittedBy
@docs withClass, withCompleted, withDisabled, withEditable, withFor, withId, withInvalid, withOnBeforeinput, withOnChange, withOnClick, withOnInput, withOptional, withSelected, withSlot, withStyle
@docs doneIcon, editIcon, error, errorIcon, hint, icon
@docs withDoneIcon, withEditIcon, withError, withErrorIcon, withHint, withIcon, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Attributes as A
import M3e.Component.Step as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


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
    Component.SlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.ChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.Content


{-| -}
type alias DoneIconSlot =
    Component.DoneIconSlot


{-| -}
type alias EditIconSlot =
    Component.EditIconSlot


{-| -}
type alias ErrorSlot =
    Component.ErrorSlot


{-| -}
type alias ErrorIconSlot =
    Component.ErrorIconSlot


{-| -}
type alias HintSlot =
    Component.HintSlot


{-| -}
type alias IconSlot =
    Component.IconSlot


{-| -}
build :
    { content : Element Component.Content (Component.ChildAdmittedBy childAdm) msg }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-step" [] [ El.toNode required_.content ]


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| -}
doneIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.DoneIconSlot msg
    -> Element free freeAdmittedBy msg
doneIcon builder =
    Component.doneIcon (B.toElement builder)


{-| -}
editIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.EditIconSlot msg
    -> Element free freeAdmittedBy msg
editIcon builder =
    Component.editIcon (B.toElement builder)


{-| -}
error :
    B.Builder childRow childAttrCaps childSlotCaps Component.ErrorSlot msg
    -> Element free freeAdmittedBy msg
error builder =
    Component.error (B.toElement builder)


{-| -}
errorIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ErrorIconSlot msg
    -> Element free freeAdmittedBy msg
errorIcon builder =
    Component.errorIcon (B.toElement builder)


{-| -}
hint :
    B.Builder childRow childAttrCaps childSlotCaps Component.HintSlot msg
    -> Element free freeAdmittedBy msg
hint builder =
    Component.hint (B.toElement builder)


{-| -}
icon :
    B.Builder childRow childAttrCaps childSlotCaps Component.IconSlot msg
    -> Element free freeAdmittedBy msg
icon builder =
    Component.icon (B.toElement builder)


{-| -}
withDoneIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.DoneIconSlot msg
    -> Builder attrCaps { s | doneIcon : Available } msg kind
    -> Builder attrCaps { s | doneIcon : Used } msg kind
withDoneIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.doneIcon (B.toElement slotBuilder))) builder_


{-| -}
withEditIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.EditIconSlot msg
    -> Builder attrCaps { s | editIcon : Available } msg kind
    -> Builder attrCaps { s | editIcon : Used } msg kind
withEditIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.editIcon (B.toElement slotBuilder))) builder_


{-| -}
withError :
    B.Builder childRow childAttrCaps childSlotCaps Component.ErrorSlot msg
    -> Builder attrCaps { s | error : Available } msg kind
    -> Builder attrCaps { s | error : Used } msg kind
withError slotBuilder builder_ =
    B.withChild (El.toNode (Component.error (B.toElement slotBuilder))) builder_


{-| -}
withErrorIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ErrorIconSlot msg
    -> Builder attrCaps { s | errorIcon : Available } msg kind
    -> Builder attrCaps { s | errorIcon : Used } msg kind
withErrorIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.errorIcon (B.toElement slotBuilder))) builder_


{-| -}
withHint :
    B.Builder childRow childAttrCaps childSlotCaps Component.HintSlot msg
    -> Builder attrCaps { s | hint : Available } msg kind
    -> Builder attrCaps { s | hint : Used } msg kind
withHint slotBuilder builder_ =
    B.withChild (El.toNode (Component.hint (B.toElement slotBuilder))) builder_


{-| -}
withIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.IconSlot msg
    -> Builder attrCaps { s | icon : Available } msg kind
    -> Builder attrCaps { s | icon : Used } msg kind
withIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.icon (B.toElement slotBuilder))) builder_


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
withCompleted : Bool -> Builder { a | completed : Available } slotCaps msg kind -> Builder { a | completed : Used } slotCaps msg kind
withCompleted value_ =
    B.withAttribute (A.completed value_)


{-| -}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withEditable : Bool -> Builder { a | editable : Available } slotCaps msg kind -> Builder { a | editable : Used } slotCaps msg kind
withEditable value_ =
    B.withAttribute (A.editable value_)


{-| -}
withFor : String -> Builder { a | for : Available } slotCaps msg kind -> Builder { a | for : Used } slotCaps msg kind
withFor value_ =
    B.withAttribute (A.for value_)


{-| -}
withInvalid : Bool -> Builder { a | invalid : Available } slotCaps msg kind -> Builder { a | invalid : Used } slotCaps msg kind
withInvalid value_ =
    B.withAttribute (A.invalid value_)


{-| -}
withOptional : Bool -> Builder { a | optional : Available } slotCaps msg kind -> Builder { a | optional : Used } slotCaps msg kind
withOptional value_ =
    B.withAttribute (A.optional value_)


{-| -}
withSelected : Bool -> Builder { a | selected : Available } slotCaps msg kind -> Builder { a | selected : Used } slotCaps msg kind
withSelected value_ =
    B.withAttribute (A.selected value_)


{-| -}
withOnBeforeinput : msg -> Builder { a | onBeforeinput : Available } slotCaps msg kind -> Builder { a | onBeforeinput : Used } slotCaps msg kind
withOnBeforeinput value_ =
    B.withAttribute (Ev.onBeforeinput value_)


{-| -}
withOnInput : msg -> Builder { a | onInput : Available } slotCaps msg kind -> Builder { a | onInput : Used } slotCaps msg kind
withOnInput value_ =
    B.withAttribute (Ev.onInput value_)


{-| -}
withOnChange : msg -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
withOnClick : msg -> Builder { a | onClick : Available } slotCaps msg kind -> Builder { a | onClick : Used } slotCaps msg kind
withOnClick value_ =
    B.withAttribute (Ev.onClick value_)
