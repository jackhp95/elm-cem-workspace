module TypedHtml.Button exposing
    ( button
    , Is, Attrs, Content, ChildAdmittedBy, Roles
    , commandfor, disabled, form, formenctype, formmethod, formnovalidate, formtarget, name, popovertarget, popovertargetaction, readonly, type_, value, valueAsNumber
    )

{-| The `Button` element home: constructors, per-element rows, and
co-located re-exports of the shared attributes its elements admit.

@docs button
@docs Is, Attrs, Content, ChildAdmittedBy, Roles
@docs commandfor, disabled, form, formenctype, formmethod, formnovalidate, formtarget, name, popovertarget, popovertargetaction, readonly, type_, value, valueAsNumber

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import TypedHtml.Attributes
import TypedHtml.Kind exposing (Brand, Ctx, Role)


{-| The kind row `button` produces.
-}
type alias Is s =
    { s | sharedPhrasing : Shared }


{-| `button`'s closed attribute-capability row.
-}
type alias Attrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , class : Supported
    , commandfor : Supported
    , contenteditable : Supported
    , disabled : Supported
    , draggable : Supported
    , enterkeyhint : Supported
    , form : Supported
    , formenctype : Supported
    , formmethod : Supported
    , formnovalidate : Supported
    , formtarget : Supported
    , id : Supported
    , inert : Supported
    , inputmode : Supported
    , itemid : Supported
    , itemprop : Supported
    , itemref : Supported
    , itemscope : Supported
    , itemtype : Supported
    , name : Supported
    , nonce : Supported
    , onClick : Supported
    , popover : Supported
    , popovertarget : Supported
    , popovertargetaction : Supported
    , readonly : Supported
    , role : Roles
    , slot : Supported
    , spellcheck : Supported
    , style : Supported
    , translate : Supported
    , type_ : Supported
    , value : Supported
    , writingsuggestions : Supported
    }


{-| The kinds `button` admits.
-}
type alias Content =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `button` injects into its children.
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | button : Ctx }


{-| The ARIA roles `button` admits (see `TypedHtml.Aria`).
-}
type alias Roles =
    { checkbox : Role
    , combobox : Role
    , link : Role
    , menuitem : Role
    , menuitemcheckbox : Role
    , menuitemradio : Role
    , none : Role
    , option : Role
    , presentation : Role
    , radio : Role
    , switch : Role
    , tab : Role
    }


{-| The `button` element.
-}
button :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
button attrs children =
    Ir.fromNode (Ir.node "button" attrs (List.map HtmlIr.Element.toNode children))


{-| See `TypedHtml.Attributes.commandfor`.
-}
commandfor : String -> Attr { c | commandfor : Supported } msg
commandfor =
    TypedHtml.Attributes.commandfor


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


{-| See `TypedHtml.Attributes.name`.
-}
name : String -> Attr { c | name : Supported } msg
name =
    TypedHtml.Attributes.name


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


{-| See `TypedHtml.Attributes.type_`.
-}
type_ : String -> Attr { c | type_ : Supported } msg
type_ =
    TypedHtml.Attributes.type_


{-| Value to be used for form submission

Writes the `value` CONTENT attribute — correct for every element whose `value` REFLECTS, and the only form that serializes to server-rendered markup. It is NOT the live state on <input>, where the content attribute sets only the element's DEFAULT/initial `value` and stops taking effect once the user has changed it; use `TypedHtml.Input.value` for that.

-}
value : String -> Attr { c | value : Supported } msg
value value_ =
    Ir.attribute "value" value_


{-| Set the `value` attribute from a number. An ergonomic alternative to `value`, which keeps the spec-correct `String` type; this one cannot express every legal value, so reach for `value` when you need one it cannot. Both claim the same capability, mirroring HTML's own `value` / `valueAsNumber` split.
-}
valueAsNumber : Float -> Attr { c | value : Supported } msg
valueAsNumber value_ =
    Ir.attribute "value" (String.fromFloat value_)
