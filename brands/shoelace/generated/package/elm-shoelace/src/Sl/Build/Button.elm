module Sl.Build.Button exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withCaret, withCircle, withClass, withDisabled, withDownload, withForm, withFormenctype, withFormmethod, withFormnovalidate, withFormtarget, withHref, withId, withLoading, withName, withOnBlur, withOnFocus, withOnInvalid, withOutline, withPill, withRel, withSize, withSlot, withStyle, withTarget, withTitle, withType, withValue, withVariant
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withCaret, withCircle, withClass, withDisabled, withDownload, withForm, withFormenctype, withFormmethod, withFormnovalidate, withFormtarget, withHref, withId, withLoading, withName, withOnBlur, withOnFocus, withOnInvalid, withOutline, withPill, withRel, withSize, withSlot, withStyle, withTarget, withTitle, withType, withValue, withVariant

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Encode
import Sl.Attributes as A
import Sl.Component.Button as Component
import Sl.Events as Ev
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)
import Sl.Values


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
    B.init "sl-button" [] []


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
withCaret : Bool -> Builder { a | caret : Available } slotCaps msg kind -> Builder { a | caret : Used } slotCaps msg kind
withCaret value_ =
    B.withAttribute (A.caret value_)


{-| -}
withCircle : Bool -> Builder { a | circle : Available } slotCaps msg kind -> Builder { a | circle : Used } slotCaps msg kind
withCircle value_ =
    B.withAttribute (A.circle value_)


{-| -}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withDownload : String -> Builder { a | download : Available } slotCaps msg kind -> Builder { a | download : Used } slotCaps msg kind
withDownload value_ =
    B.withAttribute (A.download value_)


{-| -}
withForm : String -> Builder { a | form : Available } slotCaps msg kind -> Builder { a | form : Used } slotCaps msg kind
withForm value_ =
    B.withAttribute (A.form value_)


{-| -}
withFormenctype : Value Component.Formenctype -> Builder { a | formenctype : Available } slotCaps msg kind -> Builder { a | formenctype : Used } slotCaps msg kind
withFormenctype value_ =
    B.withAttribute (Component.formenctype value_)


{-| -}
withFormmethod : Value Component.Formmethod -> Builder { a | formmethod : Available } slotCaps msg kind -> Builder { a | formmethod : Used } slotCaps msg kind
withFormmethod value_ =
    B.withAttribute (Component.formmethod value_)


{-| -}
withFormnovalidate : Bool -> Builder { a | formnovalidate : Available } slotCaps msg kind -> Builder { a | formnovalidate : Used } slotCaps msg kind
withFormnovalidate value_ =
    B.withAttribute (A.formnovalidate value_)


{-| -}
withFormtarget : Value Component.Formtarget -> Builder { a | formtarget : Available } slotCaps msg kind -> Builder { a | formtarget : Used } slotCaps msg kind
withFormtarget value_ =
    B.withAttribute (Component.formtarget value_)


{-| -}
withHref : String -> Builder { a | href : Available } slotCaps msg kind -> Builder { a | href : Used } slotCaps msg kind
withHref value_ =
    B.withAttribute (A.href value_)


{-| -}
withLoading : Bool -> Builder { a | loading : Available } slotCaps msg kind -> Builder { a | loading : Used } slotCaps msg kind
withLoading value_ =
    B.withAttribute
        (if value_ then
            Ir.attribute "loading" ""

         else
            Ir.none
        )


{-| -}
withName : String -> Builder { a | name : Available } slotCaps msg kind -> Builder { a | name : Used } slotCaps msg kind
withName value_ =
    B.withAttribute (A.name value_)


{-| -}
withOutline : Bool -> Builder { a | outline : Available } slotCaps msg kind -> Builder { a | outline : Used } slotCaps msg kind
withOutline value_ =
    B.withAttribute (A.outline value_)


{-| -}
withPill : Bool -> Builder { a | pill : Available } slotCaps msg kind -> Builder { a | pill : Used } slotCaps msg kind
withPill value_ =
    B.withAttribute (A.pill value_)


{-| -}
withRel : String -> Builder { a | rel : Available } slotCaps msg kind -> Builder { a | rel : Used } slotCaps msg kind
withRel value_ =
    B.withAttribute (A.rel value_)


{-| -}
withSize : Value Component.Size -> Builder { a | size : Available } slotCaps msg kind -> Builder { a | size : Used } slotCaps msg kind
withSize value_ =
    B.withAttribute (Component.size value_)


{-| -}
withTarget : Value Component.Target -> Builder { a | target : Available } slotCaps msg kind -> Builder { a | target : Used } slotCaps msg kind
withTarget value_ =
    B.withAttribute (Component.target value_)


{-| -}
withTitle : String -> Builder { a | title : Available } slotCaps msg kind -> Builder { a | title : Used } slotCaps msg kind
withTitle value_ =
    B.withAttribute (A.title value_)


{-| -}
withType : Value Component.Type -> Builder { a | type_ : Available } slotCaps msg kind -> Builder { a | type_ : Used } slotCaps msg kind
withType value_ =
    B.withAttribute (Component.type_ value_)


{-| -}
withValue : String -> Builder { a | value : Available } slotCaps msg kind -> Builder { a | value : Used } slotCaps msg kind
withValue value_ =
    B.withAttribute (A.value value_)


{-| -}
withVariant : Value Component.Variant -> Builder { a | variant : Available } slotCaps msg kind -> Builder { a | variant : Used } slotCaps msg kind
withVariant value_ =
    B.withAttribute (Component.variant value_)


{-| -}
withOnBlur : msg -> Builder { a | onBlur : Available } slotCaps msg kind -> Builder { a | onBlur : Used } slotCaps msg kind
withOnBlur value_ =
    B.withAttribute (Ev.onBlur value_)


{-| -}
withOnFocus : msg -> Builder { a | onFocus : Available } slotCaps msg kind -> Builder { a | onFocus : Used } slotCaps msg kind
withOnFocus value_ =
    B.withAttribute (Ev.onFocus value_)


{-| -}
withOnInvalid : msg -> Builder { a | onInvalid : Available } slotCaps msg kind -> Builder { a | onInvalid : Used } slotCaps msg kind
withOnInvalid value_ =
    B.withAttribute (Ev.onInvalid value_)
