module TypedHtml.Attributes exposing
    ( autofocus, class, dir, hidden, id, slot, style, tabindex, classList, styleList
    , disabled, href, size, src, srcset, value
    , defaultValue
    , valueAsNumber
    )

{-| The canonical shared attribute vocabulary. Every setter is an open
producer (`{ c | attr : Supported }`); each element's closed `Attrs` row
decides admittance. Enum setters here close over the library-wide UNION of
values — cross-component misuse is caught by elm-review; reach for the
per-component setters (`TypedHtml.<Component>.<attr>`) for compile-tight narrowing.

@docs autofocus, class, dir, hidden, id, slot, style, tabindex, classList, styleList
@docs disabled, href, size, src, srcset, value
@docs defaultValue
@docs valueAsNumber

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value exposing (Value)
import Json.Encode
import TypedHtml.Values


{-| The global `autofocus` attribute.
-}
autofocus : Bool -> Attr { c | autofocus : Supported } msg
autofocus value_ =
    if value_ then
        Ir.attribute "autofocus" ""

    else
        Ir.none


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


{-| The global `dir` attribute.
-}
dir : Value TypedHtml.Values.Dir -> Attr { c | dir : Supported } msg
dir value_ =
    Ir.attribute "dir" (HtmlIr.Value.toString value_)


{-| The global `hidden` attribute.
-}
hidden : Value TypedHtml.Values.Hidden -> Attr { c | hidden : Supported } msg
hidden value_ =
    Ir.attribute "hidden" (HtmlIr.Value.toString value_)


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


{-| The global `tabindex` attribute.
-}
tabindex : Int -> Attr { c | tabindex : Supported } msg
tabindex value_ =
    Ir.attribute "tabindex" (String.fromInt value_)


{-| Disables the control.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled value_ =
    if value_ then
        Ir.attribute "disabled" ""

    else
        Ir.none


{-| Link target.
-}
href : String -> Attr { c | href : Supported } msg
href =
    Ir.attribute "href"


{-| Number of options to show at once.
-}
size : Int -> Attr { c | size : Supported } msg
size value_ =
    Ir.attribute "size" (String.fromInt value_)


{-| Track URL.
-}
src : String -> Attr { c | src : Supported } msg
src =
    Ir.attribute "src"


{-| Image candidates.
-}
srcset : String -> Attr { c | srcset : Supported } msg
srcset =
    Ir.attribute "srcset"


{-| Submission value.

Sets the LIVE DOM property `value`, not the content attribute. The content attribute — the element's INITIAL state, and the only form that serializes to server-rendered markup — is `defaultValue`.

-}
value : String -> Attr { c | value : Supported } msg
value value_ =
    Ir.property "value" (Json.Encode.string value_)


{-| Set the `value` CONTENT attribute — the element's DEFAULT/initial `value`, mirroring HTML's own `defaultValue` IDL attribute. Unlike `value` (which writes the live DOM property) this one SERIALIZES: it is what server-rendered markup and `outerHTML` show, and it is what a form reset restores to.
-}
defaultValue : String -> Attr { c | value : Supported } msg
defaultValue =
    Ir.attribute "value"


{-| Set the `value` attribute from a number. An ergonomic alternative to `value`, which keeps the spec-correct `String` type; this one cannot express every legal value, so reach for `value` when you need one it cannot. Both claim the same capability, mirroring HTML's own `value` / `valueAsNumber` split.
-}
valueAsNumber : Float -> Attr { c | value : Supported } msg
valueAsNumber value_ =
    Ir.property "value" (Json.Encode.string (String.fromFloat value_))
