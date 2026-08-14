module TypedHtml.Component.Input exposing
    ( input
    , Is, Attrs, ChildAdmittedBy
    , accept, alpha, alt, autocomplete, checked, colorspace, dirname, disabled, form, formenctype, formmethod, formnovalidate, formtarget, height, list, max, maxlength, min, minlength, multiple, name, pattern, placeholder, popovertarget, popovertargetaction, readonly, required, size, src, step, type_, value, width, defaultChecked, defaultValue, stepAsNumber, valueAsNumber
    )

{-| The `Input` element home: constructors, per-element rows, and
co-located re-exports of the shared attributes its elements admit.

@docs input
@docs Is, Attrs, ChildAdmittedBy
@docs accept, alpha, alt, autocomplete, checked, colorspace, dirname, disabled, form, formenctype, formmethod, formnovalidate, formtarget, height, list, max, maxlength, min, minlength, multiple, name, pattern, placeholder, popovertarget, popovertargetaction, readonly, required, size, src, step, type_, value, width, defaultChecked, defaultValue, stepAsNumber, valueAsNumber

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import TypedHtml.Attributes
import TypedHtml.Kind exposing (Ctx)


{-| The kind row `input` produces.
-}
type alias Is s =
    { s | sharedPhrasing : Shared }


{-| `input`'s closed attribute-capability row.
-}
type alias Attrs =
    { accept : Supported
    , accesskey : Supported
    , alpha : Supported
    , alt : Supported
    , autocapitalize : Supported
    , autocomplete : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , checked : Supported
    , class : Supported
    , colorspace : Supported
    , contenteditable : Supported
    , dirname : Supported
    , disabled : Supported
    , draggable : Supported
    , enterkeyhint : Supported
    , form : Supported
    , formenctype : Supported
    , formmethod : Supported
    , formnovalidate : Supported
    , formtarget : Supported
    , height : Supported
    , id : Supported
    , inert : Supported
    , inputmode : Supported
    , itemid : Supported
    , itemprop : Supported
    , itemref : Supported
    , itemscope : Supported
    , itemtype : Supported
    , list : Supported
    , max : Supported
    , maxlength : Supported
    , min : Supported
    , minlength : Supported
    , multiple : Supported
    , name : Supported
    , nonce : Supported
    , onCheck : Supported
    , onClick : Supported
    , onInput : Supported
    , pattern : Supported
    , placeholder : Supported
    , popover : Supported
    , popovertarget : Supported
    , popovertargetaction : Supported
    , readonly : Supported
    , required : Supported
    , role : Supported
    , size : Supported
    , slot : Supported
    , spellcheck : Supported
    , src : Supported
    , step : Supported
    , style : Supported
    , translate : Supported
    , type_ : Supported
    , value : Supported
    , width : Supported
    , writingsuggestions : Supported
    }


{-| The context demand `input` injects into its children.
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | input : Ctx }


{-| The `input` element.
-}
input :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
input attrs children =
    Ir.fromNode (Ir.node "input" attrs (List.map HtmlIr.Element.toNode children))


{-| See `TypedHtml.Attributes.accept`.
-}
accept : String -> Attr { c | accept : Supported } msg
accept =
    TypedHtml.Attributes.accept


{-| See `TypedHtml.Attributes.alpha`.
-}
alpha : Bool -> Attr { c | alpha : Supported } msg
alpha =
    TypedHtml.Attributes.alpha


{-| See `TypedHtml.Attributes.alt`.
-}
alt : String -> Attr { c | alt : Supported } msg
alt =
    TypedHtml.Attributes.alt


{-| See `TypedHtml.Attributes.autocomplete`.
-}
autocomplete : String -> Attr { c | autocomplete : Supported } msg
autocomplete =
    TypedHtml.Attributes.autocomplete


{-| See `TypedHtml.Attributes.checked`.
-}
checked : Bool -> Attr { c | checked : Supported } msg
checked =
    TypedHtml.Attributes.checked


{-| The color space of the serialized color
-}
colorspace : String -> Attr { c | colorspace : Supported } msg
colorspace value_ =
    Ir.attribute "colorspace" value_


{-| See `TypedHtml.Attributes.dirname`.
-}
dirname : String -> Attr { c | dirname : Supported } msg
dirname =
    TypedHtml.Attributes.dirname


{-| See `TypedHtml.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    TypedHtml.Attributes.disabled


{-| See `TypedHtml.Attributes.form`.
-}
form : String -> Attr { c | form : Supported } msg
form =
    TypedHtml.Attributes.form


{-| Entry list encoding type to use for form submission
-}
formenctype : String -> Attr { c | formenctype : Supported } msg
formenctype value_ =
    Ir.attribute "formenctype" value_


{-| Variant to use for form submission
-}
formmethod : String -> Attr { c | formmethod : Supported } msg
formmethod value_ =
    Ir.attribute "formmethod" value_


{-| See `TypedHtml.Attributes.formnovalidate`.
-}
formnovalidate : Bool -> Attr { c | formnovalidate : Supported } msg
formnovalidate =
    TypedHtml.Attributes.formnovalidate


{-| See `TypedHtml.Attributes.formtarget`.
-}
formtarget : String -> Attr { c | formtarget : Supported } msg
formtarget =
    TypedHtml.Attributes.formtarget


{-| See `TypedHtml.Attributes.height`.
-}
height : Int -> Attr { c | height : Supported } msg
height =
    TypedHtml.Attributes.height


{-| See `TypedHtml.Attributes.list`.
-}
list : String -> Attr { c | list : Supported } msg
list =
    TypedHtml.Attributes.list


{-| See `TypedHtml.Attributes.max`.
-}
max : String -> Attr { c | max : Supported } msg
max =
    TypedHtml.Attributes.max


{-| See `TypedHtml.Attributes.maxlength`.
-}
maxlength : Int -> Attr { c | maxlength : Supported } msg
maxlength =
    TypedHtml.Attributes.maxlength


{-| See `TypedHtml.Attributes.min`.
-}
min : String -> Attr { c | min : Supported } msg
min =
    TypedHtml.Attributes.min


{-| See `TypedHtml.Attributes.minlength`.
-}
minlength : Int -> Attr { c | minlength : Supported } msg
minlength =
    TypedHtml.Attributes.minlength


{-| See `TypedHtml.Attributes.multiple`.
-}
multiple : Bool -> Attr { c | multiple : Supported } msg
multiple =
    TypedHtml.Attributes.multiple


{-| See `TypedHtml.Attributes.name`.
-}
name : String -> Attr { c | name : Supported } msg
name =
    TypedHtml.Attributes.name


{-| See `TypedHtml.Attributes.pattern`.
-}
pattern : String -> Attr { c | pattern : Supported } msg
pattern =
    TypedHtml.Attributes.pattern


{-| See `TypedHtml.Attributes.placeholder`.
-}
placeholder : String -> Attr { c | placeholder : Supported } msg
placeholder =
    TypedHtml.Attributes.placeholder


{-| See `TypedHtml.Attributes.popovertarget`.
-}
popovertarget : String -> Attr { c | popovertarget : Supported } msg
popovertarget =
    TypedHtml.Attributes.popovertarget


{-| Indicates whether a targeted popover element is to be toggled, shown, or hidden
-}
popovertargetaction : String -> Attr { c | popovertargetaction : Supported } msg
popovertargetaction value_ =
    Ir.attribute "popovertargetaction" value_


{-| See `TypedHtml.Attributes.readonly`.
-}
readonly : Bool -> Attr { c | readonly : Supported } msg
readonly =
    TypedHtml.Attributes.readonly


{-| See `TypedHtml.Attributes.required`.
-}
required : Bool -> Attr { c | required : Supported } msg
required =
    TypedHtml.Attributes.required


{-| See `TypedHtml.Attributes.size`.
-}
size : Int -> Attr { c | size : Supported } msg
size =
    TypedHtml.Attributes.size


{-| See `TypedHtml.Attributes.src`.
-}
src : String -> Attr { c | src : Supported } msg
src =
    TypedHtml.Attributes.src


{-| See `TypedHtml.Attributes.step`.
-}
step : String -> Attr { c | step : Supported } msg
step =
    TypedHtml.Attributes.step


{-| See `TypedHtml.Attributes.type_`.
-}
type_ : String -> Attr { c | type_ : Supported } msg
type_ =
    TypedHtml.Attributes.type_


{-| See `TypedHtml.Attributes.value`.
-}
value : String -> Attr { c | value : Supported } msg
value =
    TypedHtml.Attributes.value


{-| See `TypedHtml.Attributes.width`.
-}
width : Int -> Attr { c | width : Supported } msg
width =
    TypedHtml.Attributes.width


{-| See `TypedHtml.Attributes.defaultChecked`.
-}
defaultChecked : Bool -> Attr { c | checked : Supported } msg
defaultChecked =
    TypedHtml.Attributes.defaultChecked


{-| See `TypedHtml.Attributes.defaultValue`.
-}
defaultValue : String -> Attr { c | value : Supported } msg
defaultValue =
    TypedHtml.Attributes.defaultValue


{-| See `TypedHtml.Attributes.stepAsNumber`.
-}
stepAsNumber : Float -> Attr { c | step : Supported } msg
stepAsNumber =
    TypedHtml.Attributes.stepAsNumber


{-| See `TypedHtml.Attributes.valueAsNumber`.
-}
valueAsNumber : Float -> Attr { c | value : Supported } msg
valueAsNumber =
    TypedHtml.Attributes.valueAsNumber
