module TypedHtml.Select exposing
    ( datalist, optgroup, option, select
    , DatalistIs, DatalistAttrs, DatalistContent, DatalistChildAdmittedBy, OptgroupIs, OptgroupAttrs, OptgroupContent, OptgroupChildAdmittedBy, OptgroupAdmittedBy, OptionIs, OptionAttrs, OptionContent, OptionChildAdmittedBy, OptionAdmittedBy, SelectIs, SelectAttrs, SelectContent, SelectChildAdmittedBy
    , autocomplete, disabled, form, label, multiple, name, readonly, required, selected, size, value, defaultSelected, valueAsNumber
    )

{-| The `Select` element home: constructors, per-element rows, and
co-located re-exports of the shared attributes its elements admit.

@docs datalist, optgroup, option, select
@docs DatalistIs, DatalistAttrs, DatalistContent, DatalistChildAdmittedBy, OptgroupIs, OptgroupAttrs, OptgroupContent, OptgroupChildAdmittedBy, OptgroupAdmittedBy, OptionIs, OptionAttrs, OptionContent, OptionChildAdmittedBy, OptionAdmittedBy, SelectIs, SelectAttrs, SelectContent, SelectChildAdmittedBy
@docs autocomplete, disabled, form, label, multiple, name, readonly, required, selected, size, value, defaultSelected, valueAsNumber

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import TypedHtml.Attributes
import TypedHtml.Kind exposing (Brand, Ctx)


{-| The kind row `datalist` produces.
-}
type alias DatalistIs s =
    { s | sharedPhrasing : Shared }


{-| `datalist`'s closed attribute-capability row.
-}
type alias DatalistAttrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , class : Supported
    , contenteditable : Supported
    , draggable : Supported
    , enterkeyhint : Supported
    , id : Supported
    , inert : Supported
    , inputmode : Supported
    , itemid : Supported
    , itemprop : Supported
    , itemref : Supported
    , itemscope : Supported
    , itemtype : Supported
    , nonce : Supported
    , popover : Supported
    , role : Supported
    , slot : Supported
    , spellcheck : Supported
    , style : Supported
    , translate : Supported
    , writingsuggestions : Supported
    }


{-| The kinds `datalist` admits.
-}
type alias DatalistContent =
    { option : Brand
    , sharedText : Shared
    }


{-| The context demand `datalist` injects into its children.
-}
type alias DatalistChildAdmittedBy childAdm =
    { childAdm | datalist : Ctx }


{-| The `datalist` element.
-}
datalist :
    List (Attr DatalistAttrs msg)
    -> List (Element DatalistContent (DatalistChildAdmittedBy childAdm) msg)
    -> Element (DatalistIs s) admittedBy msg
datalist attrs children =
    Ir.fromNode (Ir.node "datalist" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `optgroup` produces.
-}
type alias OptgroupIs s =
    { s | optgroup : Brand }


{-| `optgroup`'s closed attribute-capability row.
-}
type alias OptgroupAttrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , class : Supported
    , contenteditable : Supported
    , disabled : Supported
    , draggable : Supported
    , enterkeyhint : Supported
    , id : Supported
    , inert : Supported
    , inputmode : Supported
    , itemid : Supported
    , itemprop : Supported
    , itemref : Supported
    , itemscope : Supported
    , itemtype : Supported
    , label : Supported
    , nonce : Supported
    , popover : Supported
    , role : Supported
    , slot : Supported
    , spellcheck : Supported
    , style : Supported
    , translate : Supported
    , writingsuggestions : Supported
    }


{-| The kinds `optgroup` admits.
-}
type alias OptgroupContent =
    { option : Brand }


{-| The context demand `optgroup` injects into its children.
-}
type alias OptgroupChildAdmittedBy childAdm =
    { childAdm | optgroup : Ctx }


{-| The CLOSED parent contexts `optgroup` is valid inside.
-}
type alias OptgroupAdmittedBy =
    { optgroup : Ctx, select : Ctx }


{-| The `optgroup` element.
-}
optgroup :
    List (Attr OptgroupAttrs msg)
    -> List (Element OptgroupContent (OptgroupChildAdmittedBy childAdm) msg)
    -> Element (OptgroupIs s) OptgroupAdmittedBy msg
optgroup attrs children =
    Ir.fromNode (Ir.node "optgroup" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `option` produces.
-}
type alias OptionIs s =
    { s | option : Brand }


{-| `option`'s closed attribute-capability row.
-}
type alias OptionAttrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , class : Supported
    , contenteditable : Supported
    , disabled : Supported
    , draggable : Supported
    , enterkeyhint : Supported
    , id : Supported
    , inert : Supported
    , inputmode : Supported
    , itemid : Supported
    , itemprop : Supported
    , itemref : Supported
    , itemscope : Supported
    , itemtype : Supported
    , label : Supported
    , nonce : Supported
    , popover : Supported
    , role : Supported
    , selected : Supported
    , slot : Supported
    , spellcheck : Supported
    , style : Supported
    , translate : Supported
    , value : Supported
    , writingsuggestions : Supported
    }


{-| The kinds `option` admits.
-}
type alias OptionContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedFlow : Shared
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `option` injects into its children.
-}
type alias OptionChildAdmittedBy childAdm =
    { childAdm | option : Ctx }


{-| The CLOSED parent contexts `option` is valid inside.
-}
type alias OptionAdmittedBy =
    { optgroup : Ctx, select : Ctx }


{-| The `option` element.
-}
option :
    List (Attr OptionAttrs msg)
    -> List (Element OptionContent (OptionChildAdmittedBy childAdm) msg)
    -> Element (OptionIs s) OptionAdmittedBy msg
option attrs children =
    Ir.fromNode (Ir.node "option" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `select` produces.
-}
type alias SelectIs s =
    { s | sharedPhrasing : Shared }


{-| `select`'s closed attribute-capability row.
-}
type alias SelectAttrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocomplete : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , class : Supported
    , contenteditable : Supported
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
    , multiple : Supported
    , name : Supported
    , nonce : Supported
    , onChange : Supported
    , onClick : Supported
    , onInput : Supported
    , popover : Supported
    , readonly : Supported
    , required : Supported
    , role : Supported
    , size : Supported
    , slot : Supported
    , spellcheck : Supported
    , style : Supported
    , translate : Supported
    , writingsuggestions : Supported
    }


{-| The kinds `select` admits.
-}
type alias SelectContent =
    { optgroup : Brand
    , option : Brand
    }


{-| The context demand `select` injects into its children.
-}
type alias SelectChildAdmittedBy childAdm =
    { childAdm | select : Ctx }


{-| The `select` element.
-}
select :
    List (Attr SelectAttrs msg)
    -> List (Element SelectContent (SelectChildAdmittedBy childAdm) msg)
    -> Element (SelectIs s) admittedBy msg
select attrs children =
    Ir.fromNode (Ir.node "select" attrs (List.map HtmlIr.Element.toNode children))


{-| See `TypedHtml.Attributes.autocomplete`.
-}
autocomplete : String -> Attr { c | autocomplete : Supported } msg
autocomplete =
    TypedHtml.Attributes.autocomplete


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


{-| See `TypedHtml.Attributes.label`.
-}
label : String -> Attr { c | label : Supported } msg
label =
    TypedHtml.Attributes.label


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


{-| See `TypedHtml.Attributes.selected`.
-}
selected : Bool -> Attr { c | selected : Supported } msg
selected =
    TypedHtml.Attributes.selected


{-| See `TypedHtml.Attributes.size`.
-}
size : Int -> Attr { c | size : Supported } msg
size =
    TypedHtml.Attributes.size


{-| Value to be used for form submission

Writes the `value` CONTENT attribute — correct for every element whose `value` REFLECTS, and the only form that serializes to server-rendered markup. It is NOT the live state on <input>, where the content attribute sets only the element's DEFAULT/initial `value` and stops taking effect once the user has changed it; use `TypedHtml.Input.value` for that.

-}
value : String -> Attr { c | value : Supported } msg
value value_ =
    Ir.attribute "value" value_


{-| See `TypedHtml.Attributes.defaultSelected`.
-}
defaultSelected : Bool -> Attr { c | selected : Supported } msg
defaultSelected =
    TypedHtml.Attributes.defaultSelected


{-| Set the `value` attribute from a number. An ergonomic alternative to `value`, which keeps the spec-correct `String` type; this one cannot express every legal value, so reach for `value` when you need one it cannot. Both claim the same capability, mirroring HTML's own `value` / `valueAsNumber` split.
-}
valueAsNumber : Float -> Attr { c | value : Supported } msg
valueAsNumber value_ =
    Ir.attribute "value" (String.fromFloat value_)
