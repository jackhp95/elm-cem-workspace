module Mini.Attributes exposing
    ( class, dir, id, inert, slot, style, tabindex, classList, styleList
    , disabled, grid, weight
    , gridAsInts, weightAsNumber
    , size, variant
    )

{-| The canonical shared attribute vocabulary. Every setter is an open
producer (`{ c | attr : Supported }`); each element's closed `Attrs` row
decides admittance. Enum setters here close over the library-wide UNION of
values — cross-component misuse is caught by elm-review; reach for the
per-component setters (`Mini.<Component>.<attr>`) for compile-tight narrowing.

@docs class, dir, id, inert, slot, style, tabindex, classList, styleList
@docs disabled, grid, weight
@docs gridAsInts, weightAsNumber
@docs size, variant

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value exposing (Value)
import Mini.Values


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
dir : Value Mini.Values.Dir -> Attr { c | dir : Supported } msg
dir value_ =
    Ir.attribute "dir" (HtmlIr.Value.toString value_)


{-| The global `id` attribute.
-}
id : String -> Attr { c | id : Supported } msg
id =
    Ir.attribute "id"


{-| The global `inert` attribute.
-}
inert : Bool -> Attr { c | inert : Supported } msg
inert value_ =
    if value_ then
        Ir.attribute "inert" ""

    else
        Ir.none


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


{-| Disables interaction.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled value_ =
    if value_ then
        Ir.attribute "disabled" ""

    else
        Ir.none


{-| Grid span as `<cols>x<rows>`: a delimited LIST (the `coords` shape), so no single number is valid. `_variants` adds the `List Int` form with an `x` separator.
-}
grid : String -> Attr { c | grid : Supported } msg
grid =
    Ir.attribute "grid"


{-| Stroke weight: a number, or the keyword `auto`. String-typed because no Float expresses the keyword (the `step="any"` shape); `_variants` adds the numeric form.
-}
weight : String -> Attr { c | weight : Supported } msg
weight =
    Ir.attribute "weight"


{-| Set the `grid` attribute from a list of integers, joined with `x`. An ergonomic alternative to `grid`, which keeps the spec-correct `String` type; this one cannot express every legal value, so reach for `grid` when you need one it cannot. Both claim the same capability, mirroring HTML's own `value` / `valueAsNumber` split.
-}
gridAsInts : List Int -> Attr { c | grid : Supported } msg
gridAsInts value_ =
    Ir.attribute "grid" (String.join "x" (List.map String.fromInt value_))


{-| Set the `weight` attribute from a number. An ergonomic alternative to `weight`, which keeps the spec-correct `String` type; this one cannot express every legal value, so reach for `weight` when you need one it cannot. Both claim the same capability, mirroring HTML's own `value` / `valueAsNumber` split.
-}
weightAsNumber : Float -> Attr { c | weight : Supported } msg
weightAsNumber value_ =
    Ir.attribute "weight" (String.fromFloat value_)


{-| Chip size.
-}
size : Value Mini.Values.Size -> Attr { c | size : Supported } msg
size value_ =
    Ir.attribute "size" (HtmlIr.Value.toString value_)


{-| Visual variant.
-}
variant : Value Mini.Values.Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (HtmlIr.Value.toString value_)
