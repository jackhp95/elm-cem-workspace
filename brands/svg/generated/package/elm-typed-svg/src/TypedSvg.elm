module TypedSvg exposing
    ( a, circle, clipPath, defs, desc, ellipse, g, image, line, linearGradient, marker, mask, path, pattern, polygon, polyline, radialGradient, rect, stop, svg, switch, symbol, text_, textPath, title, tspan, use
    , text
    , Element, Attr, Node, toHtml, toNode, mapMsg, mapNode, key, lazy, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7, lazy8, addClass, attrIf, when, testId
    )

{-| The general surface: every component constructor in the elm/html call
shape, one import. Signatures reference each component's aliases — reach for
`TypedSvg.<Component>` when you want the strict per-component surface (required
content, builder, narrowed values), and `TypedSvg.Attributes` / `TypedSvg.Events` /
`TypedSvg.Values` for the shared vocabulary.

`toHtml` is the render bridge to `elm/html`.

The `slot<Name>` placers assign a child element to a named slot in any
component that accepts it. Admittance is open (broad row) — wrong-kind
placements are caught by `Cem.ValidSlotKind` (elm-review).

@docs a, circle, clipPath, defs, desc, ellipse, g, image, line, linearGradient, marker, mask, path, pattern, polygon, polyline, radialGradient, rect, stop, svg, switch, symbol, text_, textPath, title, tspan, use
@docs text
@docs Element, Attr, Node, toHtml, toNode, mapMsg, mapNode, key, lazy, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7, lazy8, addClass, attrIf, when, testId

-}

import Html
import HtmlIr.Attribute
import HtmlIr.Element
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared)
import HtmlIr.Node
import TypedSvg.Component.Clip
import TypedSvg.Component.Descriptive
import TypedSvg.Component.Image
import TypedSvg.Component.Paint
import TypedSvg.Component.Shape
import TypedSvg.Component.Structure
import TypedSvg.Component.Text


{-| See `TypedSvg.Component.Structure.a`.
-}
a :
    List (Attr TypedSvg.Component.Structure.AAttrs msg)
    -> List (Element childAccepts (TypedSvg.Component.Structure.AChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
a =
    TypedSvg.Component.Structure.a


{-| See `TypedSvg.Component.Shape.circle`.
-}
circle :
    List (Attr TypedSvg.Component.Shape.CircleAttrs msg)
    -> List (Element TypedSvg.Component.Shape.CircleContent (TypedSvg.Component.Shape.CircleChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Component.Shape.CircleIs s) admittedBy msg
circle =
    TypedSvg.Component.Shape.circle


{-| See `TypedSvg.Component.Clip.clipPath`.
-}
clipPath :
    List (Attr TypedSvg.Component.Clip.ClipPathAttrs msg)
    -> List (Element childAccepts (TypedSvg.Component.Clip.ClipPathChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Component.Clip.ClipPathIs s) admittedBy msg
clipPath =
    TypedSvg.Component.Clip.clipPath


{-| See `TypedSvg.Component.Structure.defs`.
-}
defs :
    List (Attr TypedSvg.Component.Structure.DefsAttrs msg)
    -> List (Element childAccepts (TypedSvg.Component.Structure.DefsChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Component.Structure.DefsIs s) admittedBy msg
defs =
    TypedSvg.Component.Structure.defs


{-| See `TypedSvg.Component.Descriptive.desc`.
-}
desc :
    List (Attr TypedSvg.Component.Descriptive.DescAttrs msg)
    -> List (Element TypedSvg.Component.Descriptive.DescContent (TypedSvg.Component.Descriptive.DescChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Component.Descriptive.DescIs s) admittedBy msg
desc =
    TypedSvg.Component.Descriptive.desc


{-| See `TypedSvg.Component.Shape.ellipse`.
-}
ellipse :
    List (Attr TypedSvg.Component.Shape.EllipseAttrs msg)
    -> List (Element TypedSvg.Component.Shape.EllipseContent (TypedSvg.Component.Shape.EllipseChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Component.Shape.EllipseIs s) admittedBy msg
ellipse =
    TypedSvg.Component.Shape.ellipse


{-| See `TypedSvg.Component.Structure.g`.
-}
g :
    List (Attr TypedSvg.Component.Structure.GAttrs msg)
    -> List (Element childAccepts (TypedSvg.Component.Structure.GChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Component.Structure.GIs s) admittedBy msg
g =
    TypedSvg.Component.Structure.g


{-| See `TypedSvg.Component.Image.image`.
-}
image :
    List (Attr TypedSvg.Component.Image.Attrs msg)
    -> List (Element TypedSvg.Component.Image.Content (TypedSvg.Component.Image.ChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Component.Image.Is s) admittedBy msg
image =
    TypedSvg.Component.Image.image


{-| See `TypedSvg.Component.Shape.line`.
-}
line :
    List (Attr TypedSvg.Component.Shape.LineAttrs msg)
    -> List (Element TypedSvg.Component.Shape.LineContent (TypedSvg.Component.Shape.LineChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Component.Shape.LineIs s) admittedBy msg
line =
    TypedSvg.Component.Shape.line


{-| See `TypedSvg.Component.Paint.linearGradient`.
-}
linearGradient :
    List (Attr TypedSvg.Component.Paint.LinearGradientAttrs msg)
    -> List (Element TypedSvg.Component.Paint.LinearGradientContent (TypedSvg.Component.Paint.LinearGradientChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Component.Paint.LinearGradientIs s) admittedBy msg
linearGradient =
    TypedSvg.Component.Paint.linearGradient


{-| See `TypedSvg.Component.Clip.marker`.
-}
marker :
    List (Attr TypedSvg.Component.Clip.MarkerAttrs msg)
    -> List (Element childAccepts (TypedSvg.Component.Clip.MarkerChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Component.Clip.MarkerIs s) admittedBy msg
marker =
    TypedSvg.Component.Clip.marker


{-| See `TypedSvg.Component.Clip.mask`.
-}
mask :
    List (Attr TypedSvg.Component.Clip.MaskAttrs msg)
    -> List (Element childAccepts (TypedSvg.Component.Clip.MaskChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Component.Clip.MaskIs s) admittedBy msg
mask =
    TypedSvg.Component.Clip.mask


{-| See `TypedSvg.Component.Shape.path`.
-}
path :
    List (Attr TypedSvg.Component.Shape.PathAttrs msg)
    -> List (Element TypedSvg.Component.Shape.PathContent (TypedSvg.Component.Shape.PathChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Component.Shape.PathIs s) admittedBy msg
path =
    TypedSvg.Component.Shape.path


{-| See `TypedSvg.Component.Paint.pattern`.
-}
pattern :
    List (Attr TypedSvg.Component.Paint.PatternAttrs msg)
    -> List (Element childAccepts (TypedSvg.Component.Paint.PatternChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Component.Paint.PatternIs s) admittedBy msg
pattern =
    TypedSvg.Component.Paint.pattern


{-| See `TypedSvg.Component.Shape.polygon`.
-}
polygon :
    List (Attr TypedSvg.Component.Shape.PolygonAttrs msg)
    -> List (Element TypedSvg.Component.Shape.PolygonContent (TypedSvg.Component.Shape.PolygonChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Component.Shape.PolygonIs s) admittedBy msg
polygon =
    TypedSvg.Component.Shape.polygon


{-| See `TypedSvg.Component.Shape.polyline`.
-}
polyline :
    List (Attr TypedSvg.Component.Shape.PolylineAttrs msg)
    -> List (Element TypedSvg.Component.Shape.PolylineContent (TypedSvg.Component.Shape.PolylineChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Component.Shape.PolylineIs s) admittedBy msg
polyline =
    TypedSvg.Component.Shape.polyline


{-| See `TypedSvg.Component.Paint.radialGradient`.
-}
radialGradient :
    List (Attr TypedSvg.Component.Paint.RadialGradientAttrs msg)
    -> List (Element TypedSvg.Component.Paint.RadialGradientContent (TypedSvg.Component.Paint.RadialGradientChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Component.Paint.RadialGradientIs s) admittedBy msg
radialGradient =
    TypedSvg.Component.Paint.radialGradient


{-| See `TypedSvg.Component.Shape.rect`.
-}
rect :
    List (Attr TypedSvg.Component.Shape.RectAttrs msg)
    -> List (Element TypedSvg.Component.Shape.RectContent (TypedSvg.Component.Shape.RectChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Component.Shape.RectIs s) admittedBy msg
rect =
    TypedSvg.Component.Shape.rect


{-| See `TypedSvg.Component.Paint.stop`.
-}
stop :
    List (Attr TypedSvg.Component.Paint.StopAttrs msg)
    -> List (Element childAccepts (TypedSvg.Component.Paint.StopChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Component.Paint.StopIs s) admittedBy msg
stop =
    TypedSvg.Component.Paint.stop


{-| See `TypedSvg.Component.Structure.svg`.
-}
svg :
    List (Attr TypedSvg.Component.Structure.SvgAttrs msg)
    -> List (Element childAccepts (TypedSvg.Component.Structure.SvgChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Component.Structure.SvgIs s) admittedBy msg
svg =
    TypedSvg.Component.Structure.svg


{-| See `TypedSvg.Component.Structure.switch`.
-}
switch :
    List (Attr TypedSvg.Component.Structure.SwitchAttrs msg)
    -> List (Element childAccepts (TypedSvg.Component.Structure.SwitchChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Component.Structure.SwitchIs s) admittedBy msg
switch =
    TypedSvg.Component.Structure.switch


{-| See `TypedSvg.Component.Structure.symbol`.
-}
symbol :
    List (Attr TypedSvg.Component.Structure.SymbolAttrs msg)
    -> List (Element childAccepts (TypedSvg.Component.Structure.SymbolChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Component.Structure.SymbolIs s) admittedBy msg
symbol =
    TypedSvg.Component.Structure.symbol


{-| See `TypedSvg.Component.Text.text`.
-}
text_ :
    List (Attr TypedSvg.Component.Text.TextAttrs msg)
    -> List (Element TypedSvg.Component.Text.TextContent (TypedSvg.Component.Text.TextChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Component.Text.TextIs s) admittedBy msg
text_ =
    TypedSvg.Component.Text.text


{-| See `TypedSvg.Component.Text.textPath`.
-}
textPath :
    List (Attr TypedSvg.Component.Text.TextPathAttrs msg)
    -> List (Element TypedSvg.Component.Text.TextPathContent (TypedSvg.Component.Text.TextPathChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Component.Text.TextPathIs s) admittedBy msg
textPath =
    TypedSvg.Component.Text.textPath


{-| See `TypedSvg.Component.Descriptive.title`.
-}
title :
    List (Attr TypedSvg.Component.Descriptive.TitleAttrs msg)
    -> List (Element TypedSvg.Component.Descriptive.TitleContent (TypedSvg.Component.Descriptive.TitleChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Component.Descriptive.TitleIs s) admittedBy msg
title =
    TypedSvg.Component.Descriptive.title


{-| See `TypedSvg.Component.Text.tspan`.
-}
tspan :
    List (Attr TypedSvg.Component.Text.TspanAttrs msg)
    -> List (Element TypedSvg.Component.Text.TspanContent (TypedSvg.Component.Text.TspanChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Component.Text.TspanIs s) admittedBy msg
tspan =
    TypedSvg.Component.Text.tspan


{-| See `TypedSvg.Component.Structure.use`.
-}
use :
    List (Attr TypedSvg.Component.Structure.UseAttrs msg)
    -> List (Element TypedSvg.Component.Structure.UseContent (TypedSvg.Component.Structure.UseChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Component.Structure.UseIs s) admittedBy msg
use =
    TypedSvg.Component.Structure.use


{-| The shared text atom — admissible into any library's opted-in slot.
-}
text : String -> Element { s | sharedText : Shared } admittedBy msg
text value_ =
    Ir.fromNode (Ir.text value_)


{-| The typed IR element every constructor here produces. Re-exported so callers never import `HtmlIr.Element` directly.
-}
type alias Element accepts admittedBy msg =
    HtmlIr.Element.Element accepts admittedBy msg


{-| A typed attribute. Re-exported so callers never import `HtmlIr.Attribute` directly.
-}
type alias Attr capability msg =
    HtmlIr.Attribute.Attr capability msg


{-| The untyped IR node an `Element` wraps — the erased form, carrying no phantom claims. Re-exported for the boundaries that must store renderable content in a monomorphic field (a framework `View` record, a cache); lift it back with `<Lib>.Unsafe.fromNode`.
-}
type alias Node msg =
    HtmlIr.Node.Node msg


{-| Render any element from this library to `elm/html`.
-}
toHtml : Element accepts admittedBy msg -> Html.Html msg
toHtml =
    HtmlIr.Element.toNode >> HtmlIr.Node.toHtml


{-| Erase an element to its untyped [`Node`](#Node) — the safe out-bound direction; the phantom rows are discarded, never re-asserted.
-}
toNode : Element accepts admittedBy msg -> Node msg
toNode =
    HtmlIr.Element.toNode


{-| Map the `msg` type of any element from this library (the typed IR's `Html.map`). Structural: the tree is not rendered, rows are preserved.
-}
mapMsg : (a -> b) -> Element accepts admittedBy a -> Element accepts admittedBy b
mapMsg =
    HtmlIr.Element.map


{-| [`mapMsg`](#mapMsg) for an erased [`Node`](#Node).
-}
mapNode : (a -> b) -> Node a -> Node b
mapNode =
    HtmlIr.Node.map


{-| Attach a diff key to a child so its parent container renders as a keyed node. State and animations survive reorders, insertions, and removals. Phantom rows are preserved — a keyed chip is still a chip.
-}
key : String -> Element accepts admittedBy msg -> Element accepts admittedBy msg
key =
    HtmlIr.Element.key


{-| Memoise a subtree while its input is referentially unchanged. The result keeps its phantom rows and drops into any slot. **The view function must be a stable top-level binding** — an inline lambda allocates a fresh closure each render and silently never memoises.
-}
lazy : (a -> Element accepts admittedBy msg) -> a -> Element accepts admittedBy msg
lazy =
    HtmlIr.Element.lazy


{-| 2-argument variant of [`lazy`](#lazy).
-}
lazy2 : (a -> b -> Element accepts admittedBy msg) -> a -> b -> Element accepts admittedBy msg
lazy2 =
    HtmlIr.Element.lazy2


{-| 3-argument variant of [`lazy`](#lazy).
-}
lazy3 : (a -> b -> c -> Element accepts admittedBy msg) -> a -> b -> c -> Element accepts admittedBy msg
lazy3 =
    HtmlIr.Element.lazy3


{-| 4-argument variant of [`lazy`](#lazy).
-}
lazy4 : (a -> b -> c -> d -> Element accepts admittedBy msg) -> a -> b -> c -> d -> Element accepts admittedBy msg
lazy4 =
    HtmlIr.Element.lazy4


{-| 5-argument variant of [`lazy`](#lazy).
-}
lazy5 : (a -> b -> c -> d -> e -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> Element accepts admittedBy msg
lazy5 =
    HtmlIr.Element.lazy5


{-| 6-argument variant of [`lazy`](#lazy). Note type params skip `f` to match the underlying `VirtualDom.lazy6` convention.
-}
lazy6 : (a -> b -> c -> d -> e -> g -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> g -> Element accepts admittedBy msg
lazy6 =
    HtmlIr.Element.lazy6


{-| 7-argument variant of [`lazy`](#lazy).
-}
lazy7 : (a -> b -> c -> d -> e -> g -> h -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> g -> h -> Element accepts admittedBy msg
lazy7 =
    HtmlIr.Element.lazy7


{-| 8-argument variant of [`lazy`](#lazy). **This variant does not memoise** — the Element→Html bridge only has room for seven memoised data arguments, so the eighth forces a fresh closure each render and defeats the reference check. For real memoisation, fold the extra state into one of the first seven arguments and use [`lazy7`](#lazy7).
-}
lazy8 : (a -> b -> c -> d -> e -> g -> h -> i -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> g -> h -> i -> Element accepts admittedBy msg
lazy8 =
    HtmlIr.Element.lazy8


{-| Add a CSS class, participating in the `class` merge. Phantom rows preserved.
-}
addClass : String -> Element accepts admittedBy msg -> Element accepts admittedBy msg
addClass =
    HtmlIr.Element.addClass


{-| Conditionally attach an attribute — applied when the flag is `True`, a no-op when `False`. Phantom rows preserved.
-}
attrIf : Bool -> Attr capability msg -> Element accepts admittedBy msg -> Element accepts admittedBy msg
attrIf =
    HtmlIr.Element.attrIf


{-| Keep an element only when the flag is `True`; `False` collapses it to an empty node that renders nothing. Phantom rows preserved.
-}
when : Bool -> Element accepts admittedBy msg -> Element accepts admittedBy msg
when =
    HtmlIr.Element.when


{-| Stamp a `data-testid` attribute for test hooks. Phantom rows preserved.
-}
testId : String -> Element accepts admittedBy msg -> Element accepts admittedBy msg
testId =
    HtmlIr.Element.testId
