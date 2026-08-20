module Hz.Attributes exposing
    ( class, id, slot, style, classList, styleList
    , label, value, withHint, withLabel
    , defaultValue
    , position
    , positionBlank_, positionParent_, positionSelf_, positionTop_, positionTop
    )

{-| The canonical shared attribute vocabulary. Every setter is an open
producer (`{ c | attr : Supported }`); each element's closed `Attrs` row
decides admittance. Enum setters here close over the library-wide UNION of
values — cross-component misuse is caught by elm-review; reach for the
per-component setters (`Hz.<Component>.<attr>`) for compile-tight narrowing.

Portmanteau setters (`variantRainbow`, `shapeRounded`, …) are nullary
aliases that pre-apply one enum token. They exist for IDE discovery:
type `variant` and autocomplete lists every value inline. Each claims
the same capability row as its base enum setter, so admittance is identical.

**Deliberately absent.** These attributes are declared by the manifest and
are real HTML, but `elm/virtual-dom` cannot write them, so this library does
not pretend to: a setter would compile, render, and silently do something
else. None of them is reachable from Elm at all — reach for a port or a
custom element instead of restoring a setter here.

  - `formaction` — `_VirtualDom_noOnOrFormAction` rewrites every `VirtualDom.attribute` key matching `/^(on|formAction$)/i` to `data-` ++ key, so this would render as `data-formaction` and never as `formaction`. The property form is closed too — `_VirtualDom_noInnerHtmlOrFormAction` rewrites the exact key `formAction`, and the lowercase key is an inert expando no element observes — so there is no working path from Elm.
  - `innerhtml` — `_VirtualDom_noInnerHtmlOrFormAction` rewrites the `VirtualDom.property` keys `innerHTML` / `outerHTML` / `formAction` to `data-` ++ key; a differently-cased spelling escapes that test only to become an inert JS expando, since the element's own property name is the exact one. Either way `innerHTML` never reaches the DOM.
  - `is` — `is` is inert: a customized built-in element must be opted in at creation time via `document.createElement(tag, { is })`, and `_VirtualDom_render` calls `_VirtualDom_doc.createElement(vNode.__tag)` with no options argument, so the element already exists as its plain built-in self before any fact is applied. There is no `is` IDL attribute either, so the property form is an inert expando.
  - `onbeforetoggle` — `_VirtualDom_noOnOrFormAction` rewrites every `VirtualDom.attribute` key matching `/^(on|formAction$)/i` to `data-` ++ key, so this would render as `data-onbeforetoggle` and never as `onbeforetoggle`.
  - `once` — `_VirtualDom_noOnOrFormAction` rewrites every `VirtualDom.attribute` key matching `/^(on|formAction$)/i` to `data-` ++ key, so this would render as `data-once` and never as `once`.

@docs class, id, slot, style, classList, styleList
@docs label, value, withHint, withLabel
@docs defaultValue
@docs position
@docs positionBlank_, positionParent_, positionSelf_, positionTop_, positionTop

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value exposing (Value)
import Hz.Values
import Json.Encode


{-| The global `class` attribute. Repeats ACCUMULATE: `[ class "a", class "b" ]` renders `class="a b"`.
-}
class : String -> Attr { c | class : Supported } msg
class =
    Ir.attribute "class"


{-| The classes whose flag is `True`, space-joined. Accumulates with every other `class` / `classList` on the element.
-}
classList : List ( String, Bool ) -> Attr { c | class : Supported } msg
classList pairs =
    Ir.attribute "class" (String.join " " (List.map Tuple.first (List.filter Tuple.second pairs)))


{-| The global `id` attribute.
-}
id : String -> Attr { c | id : Supported } msg
id =
    Ir.attribute "id"


{-| The global `slot` attribute (named-slot placement by hand).
-}
slot : String -> Attr { c | slot : Supported } msg
slot =
    Ir.attribute "slot"


{-| One inline-style declaration (the `elm/html` 0.19 shape). Declarations MERGE across every `style` / `styleList` on the element, last-wins per property.
-}
style : String -> String -> Attr { c | style : Supported } msg
style property value_ =
    Ir.styles [ ( property, value_ ) ]


{-| Inline-style declarations as a `( property, value )` list (the `elm/html` 0.18 shape). Merges exactly as `style` does.
-}
styleList : List ( String, String ) -> Attr { c | style : Supported } msg
styleList =
    Ir.styles


{-| NOT blocked — the control. Proves the guard is selective rather than emptying the element's surface, and that a blocked sibling does not take the whole `Attrs` row with it.
-}
label : String -> Attr { c | label : Supported } msg
label =
    Ir.attribute "label"


{-| First value.

Sets the LIVE DOM property `value`, not the content attribute. The content attribute — the element's INITIAL state, and the only form that serializes to server-rendered markup — is `defaultValue`.

-}
value : String -> Attr { c | value : Supported } msg
value value_ =
    Ir.property "value" (Json.Encode.string value_)


{-| Enable hint section.
-}
withHint : Bool -> Attr { c | withHint : Supported } msg
withHint value_ =
    if value_ then
        Ir.attribute "with-hint" ""

    else
        Ir.none


{-| Enable label section.
-}
withLabel : Bool -> Attr { c | withLabel : Supported } msg
withLabel value_ =
    if value_ then
        Ir.attribute "with-label" ""

    else
        Ir.none


{-| Set the `value` CONTENT attribute — the element's DEFAULT/initial `value`, mirroring HTML's own `defaultValue` IDL attribute. Unlike `value` (which writes the live DOM property) this one SERIALIZES: it is what server-rendered markup and `outerHTML` show, and it is what a form reset restores to.
-}
defaultValue : String -> Attr { c | value : Supported } msg
defaultValue =
    Ir.attribute "value"


{-| Position enum with leading-underscore and plain tokens.
-}
position : Value Hz.Values.Position -> Attr { c | position : Supported } msg
position value_ =
    Ir.attribute "position" (HtmlIr.Value.toString value_)


{-| Set the `position` attribute to `"_blank"`. Portmanteau of `position` + `_blank` — for IDE discovery and single-import ergonomics.
-}
positionBlank_ : Attr { c | position : Supported } msg
positionBlank_ =
    Ir.attribute "position" "_blank"


{-| Set the `position` attribute to `"_parent"`. Portmanteau of `position` + `_parent` — for IDE discovery and single-import ergonomics.
-}
positionParent_ : Attr { c | position : Supported } msg
positionParent_ =
    Ir.attribute "position" "_parent"


{-| Set the `position` attribute to `"_self"`. Portmanteau of `position` + `_self` — for IDE discovery and single-import ergonomics.
-}
positionSelf_ : Attr { c | position : Supported } msg
positionSelf_ =
    Ir.attribute "position" "_self"


{-| Set the `position` attribute to `"_top"`. Portmanteau of `position` + `_top` — for IDE discovery and single-import ergonomics.
-}
positionTop_ : Attr { c | position : Supported } msg
positionTop_ =
    Ir.attribute "position" "_top"


{-| Set the `position` attribute to `"top"`. Portmanteau of `position` + `top` — for IDE discovery and single-import ergonomics.
-}
positionTop : Attr { c | position : Supported } msg
positionTop =
    Ir.attribute "position" "top"
