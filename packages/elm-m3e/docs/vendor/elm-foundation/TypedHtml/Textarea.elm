module TypedHtml.Textarea exposing
    ( textarea
    , Is, Attrs, Content, ChildAdmittedBy
    , autocomplete, cols, dirname, disabled, form, maxlength, minlength, name, placeholder, readonly, required, rows, wrap
    )

{-| The `Textarea` element home: constructors, per-element rows, and
co-located re-exports of the shared attributes its elements admit.

@docs textarea
@docs Is, Attrs, Content, ChildAdmittedBy
@docs autocomplete, cols, dirname, disabled, form, maxlength, minlength, name, placeholder, readonly, required, rows, wrap

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import TypedHtml.Attributes
import TypedHtml.Kind exposing (Ctx)


{-| The kind row `textarea` produces.
-}
type alias Is s =
    { s | sharedPhrasing : Shared }


{-| `textarea`'s closed attribute-capability row.
-}
type alias Attrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocomplete : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , class : Supported
    , cols : Supported
    , contenteditable : Supported
    , dirname : Supported
    , disabled : Supported
    , draggable : Supported
    , enterkeyhint : Supported
    , form : Supported
    , id : Supported
    , inert : Supported
    , inputmode : Supported
    , itemid : Supported
    , itemprop : Supported
    , itemref : Supported
    , itemscope : Supported
    , itemtype : Supported
    , maxlength : Supported
    , minlength : Supported
    , name : Supported
    , nonce : Supported
    , onChange : Supported
    , onClick : Supported
    , onInput : Supported
    , placeholder : Supported
    , popover : Supported
    , readonly : Supported
    , required : Supported
    , role : Supported
    , rows : Supported
    , slot : Supported
    , spellcheck : Supported
    , style : Supported
    , translate : Supported
    , wrap : Supported
    , writingsuggestions : Supported
    }


{-| The kinds `textarea` admits.
-}
type alias Content =
    { sharedText : Shared }


{-| The context demand `textarea` injects into its children.
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | textarea : Ctx }


{-| The `textarea` element.
-}
textarea :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
textarea attrs children =
    Ir.fromNode (Ir.node "textarea" attrs (List.map HtmlIr.Element.toNode children))


{-| See `TypedHtml.Attributes.autocomplete`.
-}
autocomplete : String -> Attr { c | autocomplete : Supported } msg
autocomplete =
    TypedHtml.Attributes.autocomplete


{-| See `TypedHtml.Attributes.cols`.
-}
cols : Int -> Attr { c | cols : Supported } msg
cols =
    TypedHtml.Attributes.cols


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


{-| See `TypedHtml.Attributes.maxlength`.
-}
maxlength : Int -> Attr { c | maxlength : Supported } msg
maxlength =
    TypedHtml.Attributes.maxlength


{-| See `TypedHtml.Attributes.minlength`.
-}
minlength : Int -> Attr { c | minlength : Supported } msg
minlength =
    TypedHtml.Attributes.minlength


{-| See `TypedHtml.Attributes.name`.
-}
name : String -> Attr { c | name : Supported } msg
name =
    TypedHtml.Attributes.name


{-| See `TypedHtml.Attributes.placeholder`.
-}
placeholder : String -> Attr { c | placeholder : Supported } msg
placeholder =
    TypedHtml.Attributes.placeholder


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


{-| See `TypedHtml.Attributes.rows`.
-}
rows : Int -> Attr { c | rows : Supported } msg
rows =
    TypedHtml.Attributes.rows


{-| How the value of the form control is to be wrapped for form submission
-}
wrap : String -> Attr { c | wrap : Supported } msg
wrap value_ =
    Ir.attribute "wrap" value_
