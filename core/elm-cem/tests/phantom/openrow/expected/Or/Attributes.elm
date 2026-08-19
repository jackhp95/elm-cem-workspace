module Or.Attributes exposing
    ( cdir, cflag, class, odir, oflag, classList
    , label
    )

{-| The canonical shared attribute vocabulary. Every setter is an open
producer (`{ c | attr : Supported }`); each element's closed `Attrs` row
decides admittance. Enum setters here close over the library-wide UNION of
values — cross-component misuse is caught by elm-review; reach for the
per-component setters (`Or.<Component>.<attr>`) for compile-tight narrowing.

Portmanteau setters (`variantRainbow`, `shapeRounded`, …) are nullary
aliases that pre-apply one enum token. They exist for IDE discovery:
type `variant` and autocomplete lists every value inline. Each claims
the same capability row as its base enum setter, so admittance is identical.

@docs cdir, cflag, class, odir, oflag, classList
@docs label

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value exposing (Value)
import Or.Values


{-| The global `cdir` attribute.
-}
cdir : Value Or.Values.Cdir -> Attr { c | cdir : Supported } msg
cdir value_ =
    Ir.attribute "cdir" (HtmlIr.Value.toString value_)


{-| The global `cflag` attribute.
-}
cflag : Bool -> Attr { c | cflag : Supported } msg
cflag value_ =
    if value_ then
        Ir.attribute "cflag" ""

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


{-| The global `odir` attribute.
-}
odir : Value Or.Values.Odir -> Attr c msg
odir value_ =
    Ir.attribute "odir" (HtmlIr.Value.toString value_)


{-| The global `oflag` attribute.
-}
oflag : Bool -> Attr c msg
oflag value_ =
    if value_ then
        Ir.attribute "oflag" ""

    else
        Ir.none


{-| A plain string attribute of the component's own.
-}
label : String -> Attr { c | label : Supported } msg
label =
    Ir.attribute "label"
