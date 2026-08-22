module M3e.Build.Button exposing (Builder, AttrCaps, SlotCaps, Is, Content, IconSlot, SelectedSlot, SelectedIconSlot, TrailingIconSlot, ChildAdmittedBy, ActionCaps, build, toElement, withClass, withDisabled, withDisabledInteractive, withDownload, withHref, withId, withName, withOnBeforeinput, withOnChange, withOnClick, withOnInput, withRel, withSelected, withShape, withSize, withSlot, withStyle, withTarget, withToggle, withType, withValue, withVariant, icon, selected, selectedIcon, trailingIcon, withIcon, withSelectedSlot, withSelectedIcon, withTrailingIcon, withChild)

{-| The **Button** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `M3e.Component.Button`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, Content, IconSlot, SelectedSlot, SelectedIconSlot, TrailingIconSlot, ChildAdmittedBy, ActionCaps, build, toElement, withClass, withDisabled, withDisabledInteractive, withDownload, withHref, withId, withName, withOnBeforeinput, withOnChange, withOnClick, withOnInput, withRel, withSelected, withShape, withSize, withSlot, withStyle, withTarget, withToggle, withType, withValue, withVariant, icon, selected, selectedIcon, trailingIcon, withIcon, withSelectedSlot, withSelectedIcon, withTrailingIcon, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Json.Encode
import M3e.Action as Ac
import M3e.Attributes as A
import M3e.Component.Button as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


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
type alias SelectedSlot =
    Component.ButtonSelectedSlot


{-| -}
type alias SelectedIconSlot =
    Component.ButtonSelectedIconSlot


{-| -}
type alias TrailingIconSlot =
    Component.ButtonTrailingIconSlot


{-| -}
type alias ActionCaps =
    Component.ButtonActionCaps


{-| -}
build :
    { content : Element Component.ButtonContent (Component.ButtonChildAdmittedBy childAdm) msg
    , action : Ac.Action Component.ButtonActionCaps msg
    }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-button" (Ac.toAttrs required_.action) [ Ac.wrapContent required_.action (El.toNode required_.content) ]


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
selected :
    B.Builder childRow childAttrCaps childSlotCaps Component.ButtonSelectedSlot msg
    -> Element free freeAdmittedBy msg
selected builder =
    Component.buttonSelected (B.toElement builder)


{-| -}
selectedIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ButtonSelectedIconSlot msg
    -> Element free freeAdmittedBy msg
selectedIcon builder =
    Component.buttonSelectedIcon (B.toElement builder)


{-| -}
trailingIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ButtonTrailingIconSlot msg
    -> Element free freeAdmittedBy msg
trailingIcon builder =
    Component.buttonTrailingIcon (B.toElement builder)


{-| -}
withIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ButtonIconSlot msg
    -> Builder attrCaps { s | icon : Available } msg kind
    -> Builder attrCaps { s | icon : Used } msg kind
withIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.buttonIcon (B.toElement slotBuilder))) builder_


{-| -}
withSelectedSlot :
    B.Builder childRow childAttrCaps childSlotCaps Component.ButtonSelectedSlot msg
    -> Builder attrCaps { s | selected : Available } msg kind
    -> Builder attrCaps { s | selected : Used } msg kind
withSelectedSlot slotBuilder builder_ =
    B.withChild (El.toNode (Component.buttonSelected (B.toElement slotBuilder))) builder_


{-| -}
withSelectedIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ButtonSelectedIconSlot msg
    -> Builder attrCaps { s | selectedIcon : Available } msg kind
    -> Builder attrCaps { s | selectedIcon : Used } msg kind
withSelectedIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.buttonSelectedIcon (B.toElement slotBuilder))) builder_


{-| -}
withTrailingIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ButtonTrailingIconSlot msg
    -> Builder attrCaps { s | trailingIcon : Available } msg kind
    -> Builder attrCaps { s | trailingIcon : Used } msg kind
withTrailingIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.buttonTrailingIcon (B.toElement slotBuilder))) builder_


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
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withDisabledInteractive : Bool -> Builder { a | disabledInteractive : Available } slotCaps msg kind -> Builder { a | disabledInteractive : Used } slotCaps msg kind
withDisabledInteractive value_ =
    B.withAttribute (A.disabledInteractive value_)


{-| -}
withDownload : String -> Builder { a | download : Available } slotCaps msg kind -> Builder { a | download : Used } slotCaps msg kind
withDownload value_ =
    B.withAttribute (A.download value_)


{-| -}
withHref : String -> Builder { a | href : Available } slotCaps msg kind -> Builder { a | href : Used } slotCaps msg kind
withHref value_ =
    B.withAttribute (A.href value_)


{-| -}
withName : String -> Builder { a | name : Available } slotCaps msg kind -> Builder { a | name : Used } slotCaps msg kind
withName value_ =
    B.withAttribute (Ir.attribute "name" value_)


{-| -}
withRel : String -> Builder { a | rel : Available } slotCaps msg kind -> Builder { a | rel : Used } slotCaps msg kind
withRel value_ =
    B.withAttribute (A.rel value_)


{-| -}
withSelected : Bool -> Builder { a | selected : Available } slotCaps msg kind -> Builder { a | selected : Used } slotCaps msg kind
withSelected value_ =
    B.withAttribute (A.selected value_)


{-| -}
withShape : Value Component.ButtonShape -> Builder { a | shape : Available } slotCaps msg kind -> Builder { a | shape : Used } slotCaps msg kind
withShape value_ =
    B.withAttribute (Component.buttonShape value_)


{-| -}
withSize : Value Component.ButtonSize -> Builder { a | size : Available } slotCaps msg kind -> Builder { a | size : Used } slotCaps msg kind
withSize value_ =
    B.withAttribute (Component.buttonSize value_)


{-| -}
withTarget : String -> Builder { a | target : Available } slotCaps msg kind -> Builder { a | target : Used } slotCaps msg kind
withTarget value_ =
    B.withAttribute (A.target value_)


{-| -}
withToggle : Bool -> Builder { a | toggle : Available } slotCaps msg kind -> Builder { a | toggle : Used } slotCaps msg kind
withToggle value_ =
    B.withAttribute (A.toggle value_)


{-| -}
withType : Value Component.ButtonType -> Builder { a | type_ : Available } slotCaps msg kind -> Builder { a | type_ : Used } slotCaps msg kind
withType value_ =
    B.withAttribute (Component.buttonType_ value_)


{-| -}
withValue : String -> Builder { a | value : Available } slotCaps msg kind -> Builder { a | value : Used } slotCaps msg kind
withValue value_ =
    B.withAttribute (A.value value_)


{-| -}
withVariant : Value Component.ButtonVariant -> Builder { a | variant : Available } slotCaps msg kind -> Builder { a | variant : Used } slotCaps msg kind
withVariant value_ =
    B.withAttribute (Component.buttonVariant value_)


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
