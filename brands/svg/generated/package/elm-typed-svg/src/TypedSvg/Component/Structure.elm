module TypedSvg.Component.Structure exposing
    ( a, defs, g, svg, switch, symbol, use
    , AAttrs, AChildAdmittedBy, DefsIs, DefsAttrs, DefsChildAdmittedBy, GIs, GAttrs, GChildAdmittedBy, SvgIs, SvgAttrs, SvgChildAdmittedBy, SwitchIs, SwitchAttrs, SwitchChildAdmittedBy, SymbolIs, SymbolAttrs, SymbolChildAdmittedBy, UseIs, UseAttrs, UseContent, UseChildAdmittedBy
    , height, href, preserveAspectRatio, target, viewBox, width, x, xmlns, y
    )

{-| The `Structure` element home: constructors, per-element rows, and
co-located re-exports of the shared attributes its elements admit.

@docs a, defs, g, svg, switch, symbol, use
@docs AAttrs, AChildAdmittedBy, DefsIs, DefsAttrs, DefsChildAdmittedBy, GIs, GAttrs, GChildAdmittedBy, SvgIs, SvgAttrs, SvgChildAdmittedBy, SwitchIs, SwitchAttrs, SwitchChildAdmittedBy, SymbolIs, SymbolAttrs, SymbolChildAdmittedBy, UseIs, UseAttrs, UseContent, UseChildAdmittedBy
@docs height, href, preserveAspectRatio, target, viewBox, width, x, xmlns, y

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import TypedSvg.Attributes
import TypedSvg.Kind exposing (Brand, Ctx)


{-| `a`'s closed attribute-capability row.
-}
type alias AAttrs =
    { class : Supported
    , href : Supported
    , id : Supported
    , style : Supported
    , target : Supported
    }


{-| The context demand `a` injects into its children.
-}
type alias AChildAdmittedBy childAdm =
    { childAdm | a : Ctx }


{-| The `a` element. Transparent content model: its produced kind row IS its
children's accepts row — it inherits its context's content model.
-}
a :
    List (Attr AAttrs msg)
    -> List (Element childAccepts (AChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
a attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "a" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `defs` produces.
-}
type alias DefsIs s =
    { s | defs : Brand }


{-| `defs`'s closed attribute-capability row.
-}
type alias DefsAttrs =
    { class : Supported
    , id : Supported
    , style : Supported
    }


{-| The context demand `defs` injects into its children.
-}
type alias DefsChildAdmittedBy childAdm =
    { childAdm | defs : Ctx }


{-| The `defs` element.
-}
defs :
    List (Attr DefsAttrs msg)
    -> List (Element childAccepts (DefsChildAdmittedBy childAdm) msg)
    -> Element (DefsIs s) admittedBy msg
defs attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "defs" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `g` produces.
-}
type alias GIs s =
    { s | g : Brand }


{-| `g`'s closed attribute-capability row.
-}
type alias GAttrs =
    { class : Supported
    , id : Supported
    , style : Supported
    }


{-| The context demand `g` injects into its children.
-}
type alias GChildAdmittedBy childAdm =
    { childAdm | g : Ctx }


{-| The `g` element.
-}
g :
    List (Attr GAttrs msg)
    -> List (Element childAccepts (GChildAdmittedBy childAdm) msg)
    -> Element (GIs s) admittedBy msg
g attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "g" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `svg` produces.
-}
type alias SvgIs s =
    { s | svg : Brand }


{-| `svg`'s closed attribute-capability row.
-}
type alias SvgAttrs =
    { class : Supported
    , height : Supported
    , id : Supported
    , preserveAspectRatio : Supported
    , style : Supported
    , viewBox : Supported
    , width : Supported
    , x : Supported
    , xmlns : Supported
    , y : Supported
    }


{-| The context demand `svg` injects into its children.
-}
type alias SvgChildAdmittedBy childAdm =
    { childAdm | svg : Ctx }


{-| The `svg` element.
-}
svg :
    List (Attr SvgAttrs msg)
    -> List (Element childAccepts (SvgChildAdmittedBy childAdm) msg)
    -> Element (SvgIs s) admittedBy msg
svg attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "svg" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `switch` produces.
-}
type alias SwitchIs s =
    { s | switch : Brand }


{-| `switch`'s closed attribute-capability row.
-}
type alias SwitchAttrs =
    { class : Supported
    , id : Supported
    , style : Supported
    }


{-| The context demand `switch` injects into its children.
-}
type alias SwitchChildAdmittedBy childAdm =
    { childAdm | switch : Ctx }


{-| The `switch` element.
-}
switch :
    List (Attr SwitchAttrs msg)
    -> List (Element childAccepts (SwitchChildAdmittedBy childAdm) msg)
    -> Element (SwitchIs s) admittedBy msg
switch attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "switch" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `symbol` produces.
-}
type alias SymbolIs s =
    { s | symbol : Brand }


{-| `symbol`'s closed attribute-capability row.
-}
type alias SymbolAttrs =
    { class : Supported
    , height : Supported
    , id : Supported
    , preserveAspectRatio : Supported
    , style : Supported
    , viewBox : Supported
    , width : Supported
    , x : Supported
    , y : Supported
    }


{-| The context demand `symbol` injects into its children.
-}
type alias SymbolChildAdmittedBy childAdm =
    { childAdm | symbol : Ctx }


{-| The `symbol` element.
-}
symbol :
    List (Attr SymbolAttrs msg)
    -> List (Element childAccepts (SymbolChildAdmittedBy childAdm) msg)
    -> Element (SymbolIs s) admittedBy msg
symbol attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "symbol" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `use` produces.
-}
type alias UseIs s =
    { s | use : Brand }


{-| `use`'s closed attribute-capability row.
-}
type alias UseAttrs =
    { class : Supported
    , height : Supported
    , href : Supported
    , id : Supported
    , style : Supported
    , width : Supported
    , x : Supported
    , y : Supported
    }


{-| The kinds `use` admits.
-}
type alias UseContent =
    { desc : Brand
    , title : Brand
    }


{-| The context demand `use` injects into its children.
-}
type alias UseChildAdmittedBy childAdm =
    { childAdm | use : Ctx }


{-| The `use` element.
-}
use :
    List (Attr UseAttrs msg)
    -> List (Element UseContent (UseChildAdmittedBy childAdm) msg)
    -> Element (UseIs s) admittedBy msg
use attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "use" attrs (List.map HtmlIr.Element.toNode children))


{-| See `TypedSvg.Attributes.height`.
-}
height : String -> Attr { c | height : Supported } msg
height =
    TypedSvg.Attributes.height


{-| See `TypedSvg.Attributes.href`.
-}
href : String -> Attr { c | href : Supported } msg
href =
    TypedSvg.Attributes.href


{-| See `TypedSvg.Attributes.preserveAspectRatio`.
-}
preserveAspectRatio : String -> Attr { c | preserveAspectRatio : Supported } msg
preserveAspectRatio =
    TypedSvg.Attributes.preserveAspectRatio


{-| See `TypedSvg.Attributes.target`.
-}
target : String -> Attr { c | target : Supported } msg
target =
    TypedSvg.Attributes.target


{-| See `TypedSvg.Attributes.viewBox`.
-}
viewBox : String -> Attr { c | viewBox : Supported } msg
viewBox =
    TypedSvg.Attributes.viewBox


{-| See `TypedSvg.Attributes.width`.
-}
width : String -> Attr { c | width : Supported } msg
width =
    TypedSvg.Attributes.width


{-| See `TypedSvg.Attributes.x`.
-}
x : String -> Attr { c | x : Supported } msg
x =
    TypedSvg.Attributes.x


{-| See `TypedSvg.Attributes.xmlns`.
-}
xmlns : String -> Attr { c | xmlns : Supported } msg
xmlns =
    TypedSvg.Attributes.xmlns


{-| See `TypedSvg.Attributes.y`.
-}
y : String -> Attr { c | y : Supported } msg
y =
    TypedSvg.Attributes.y
