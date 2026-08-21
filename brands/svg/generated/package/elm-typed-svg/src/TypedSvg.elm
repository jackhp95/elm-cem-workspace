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
import TypedSvg.Element.Clip
import TypedSvg.Element.Descriptive
import TypedSvg.Element.Image
import TypedSvg.Element.Paint
import TypedSvg.Element.Shape
import TypedSvg.Element.Structure
import TypedSvg.Element.Text


{-| See `TypedSvg.Element.Structure.a`.
-}
a :
    List (Attr TypedSvg.Element.Structure.AAttrs msg)
    -> List (Element childAccepts (TypedSvg.Element.Structure.AChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
a =
    TypedSvg.Element.Structure.a


{-| See `TypedSvg.Element.Shape.circle`.
-}
circle :
    List (Attr TypedSvg.Element.Shape.CircleAttrs msg)
    -> List (Element TypedSvg.Element.Shape.CircleContent (TypedSvg.Element.Shape.CircleChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Element.Shape.CircleIs s) admittedBy msg
circle =
    TypedSvg.Element.Shape.circle


{-| See `TypedSvg.Element.Clip.clipPath`.
-}
clipPath :
    List (Attr TypedSvg.Element.Clip.ClipPathAttrs msg)
    -> List (Element childAccepts (TypedSvg.Element.Clip.ClipPathChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Element.Clip.ClipPathIs s) admittedBy msg
clipPath =
    TypedSvg.Element.Clip.clipPath


{-| See `TypedSvg.Element.Structure.defs`.
-}
defs :
    List (Attr TypedSvg.Element.Structure.DefsAttrs msg)
    -> List (Element childAccepts (TypedSvg.Element.Structure.DefsChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Element.Structure.DefsIs s) admittedBy msg
defs =
    TypedSvg.Element.Structure.defs


{-| See `TypedSvg.Element.Descriptive.desc`.
-}
desc :
    List (Attr TypedSvg.Element.Descriptive.DescAttrs msg)
    -> List (Element TypedSvg.Element.Descriptive.DescContent (TypedSvg.Element.Descriptive.DescChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Element.Descriptive.DescIs s) admittedBy msg
desc =
    TypedSvg.Element.Descriptive.desc


{-| See `TypedSvg.Element.Shape.ellipse`.
-}
ellipse :
    List (Attr TypedSvg.Element.Shape.EllipseAttrs msg)
    -> List (Element TypedSvg.Element.Shape.EllipseContent (TypedSvg.Element.Shape.EllipseChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Element.Shape.EllipseIs s) admittedBy msg
ellipse =
    TypedSvg.Element.Shape.ellipse


{-| See `TypedSvg.Element.Structure.g`.
-}
g :
    List (Attr TypedSvg.Element.Structure.GAttrs msg)
    -> List (Element childAccepts (TypedSvg.Element.Structure.GChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Element.Structure.GIs s) admittedBy msg
g =
    TypedSvg.Element.Structure.g


{-| See `TypedSvg.Element.Image.image`.
-}
image :
    List (Attr TypedSvg.Element.Image.Attrs msg)
    -> List (Element TypedSvg.Element.Image.Content (TypedSvg.Element.Image.ChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Element.Image.Is s) admittedBy msg
image =
    TypedSvg.Element.Image.image


{-| See `TypedSvg.Element.Shape.line`.
-}
line :
    List (Attr TypedSvg.Element.Shape.LineAttrs msg)
    -> List (Element TypedSvg.Element.Shape.LineContent (TypedSvg.Element.Shape.LineChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Element.Shape.LineIs s) admittedBy msg
line =
    TypedSvg.Element.Shape.line


{-| See `TypedSvg.Element.Paint.linearGradient`.
-}
linearGradient :
    List (Attr TypedSvg.Element.Paint.LinearGradientAttrs msg)
    -> List (Element TypedSvg.Element.Paint.LinearGradientContent (TypedSvg.Element.Paint.LinearGradientChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Element.Paint.LinearGradientIs s) admittedBy msg
linearGradient =
    TypedSvg.Element.Paint.linearGradient


{-| See `TypedSvg.Element.Clip.marker`.
-}
marker :
    List (Attr TypedSvg.Element.Clip.MarkerAttrs msg)
    -> List (Element childAccepts (TypedSvg.Element.Clip.MarkerChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Element.Clip.MarkerIs s) admittedBy msg
marker =
    TypedSvg.Element.Clip.marker


{-| See `TypedSvg.Element.Clip.mask`.
-}
mask :
    List (Attr TypedSvg.Element.Clip.MaskAttrs msg)
    -> List (Element childAccepts (TypedSvg.Element.Clip.MaskChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Element.Clip.MaskIs s) admittedBy msg
mask =
    TypedSvg.Element.Clip.mask


{-| See `TypedSvg.Element.Shape.path`.
-}
path :
    List (Attr TypedSvg.Element.Shape.PathAttrs msg)
    -> List (Element TypedSvg.Element.Shape.PathContent (TypedSvg.Element.Shape.PathChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Element.Shape.PathIs s) admittedBy msg
path =
    TypedSvg.Element.Shape.path


{-| See `TypedSvg.Element.Paint.pattern`.
-}
pattern :
    List (Attr TypedSvg.Element.Paint.PatternAttrs msg)
    -> List (Element childAccepts (TypedSvg.Element.Paint.PatternChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Element.Paint.PatternIs s) admittedBy msg
pattern =
    TypedSvg.Element.Paint.pattern


{-| See `TypedSvg.Element.Shape.polygon`.
-}
polygon :
    List (Attr TypedSvg.Element.Shape.PolygonAttrs msg)
    -> List (Element TypedSvg.Element.Shape.PolygonContent (TypedSvg.Element.Shape.PolygonChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Element.Shape.PolygonIs s) admittedBy msg
polygon =
    TypedSvg.Element.Shape.polygon


{-| See `TypedSvg.Element.Shape.polyline`.
-}
polyline :
    List (Attr TypedSvg.Element.Shape.PolylineAttrs msg)
    -> List (Element TypedSvg.Element.Shape.PolylineContent (TypedSvg.Element.Shape.PolylineChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Element.Shape.PolylineIs s) admittedBy msg
polyline =
    TypedSvg.Element.Shape.polyline


{-| See `TypedSvg.Element.Paint.radialGradient`.
-}
radialGradient :
    List (Attr TypedSvg.Element.Paint.RadialGradientAttrs msg)
    -> List (Element TypedSvg.Element.Paint.RadialGradientContent (TypedSvg.Element.Paint.RadialGradientChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Element.Paint.RadialGradientIs s) admittedBy msg
radialGradient =
    TypedSvg.Element.Paint.radialGradient


{-| See `TypedSvg.Element.Shape.rect`.
-}
rect :
    List (Attr TypedSvg.Element.Shape.RectAttrs msg)
    -> List (Element TypedSvg.Element.Shape.RectContent (TypedSvg.Element.Shape.RectChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Element.Shape.RectIs s) admittedBy msg
rect =
    TypedSvg.Element.Shape.rect


{-| See `TypedSvg.Element.Paint.stop`.
-}
stop :
    List (Attr TypedSvg.Element.Paint.StopAttrs msg)
    -> List (Element childAccepts (TypedSvg.Element.Paint.StopChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Element.Paint.StopIs s) admittedBy msg
stop =
    TypedSvg.Element.Paint.stop


{-| See `TypedSvg.Element.Structure.svg`.
-}
svg :
    List (Attr TypedSvg.Element.Structure.SvgAttrs msg)
    -> List (Element childAccepts (TypedSvg.Element.Structure.SvgChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Element.Structure.SvgIs s) admittedBy msg
svg =
    TypedSvg.Element.Structure.svg


{-| See `TypedSvg.Element.Structure.switch`.
-}
switch :
    List (Attr TypedSvg.Element.Structure.SwitchAttrs msg)
    -> List (Element childAccepts (TypedSvg.Element.Structure.SwitchChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Element.Structure.SwitchIs s) admittedBy msg
switch =
    TypedSvg.Element.Structure.switch


{-| See `TypedSvg.Element.Structure.symbol`.
-}
symbol :
    List (Attr TypedSvg.Element.Structure.SymbolAttrs msg)
    -> List (Element childAccepts (TypedSvg.Element.Structure.SymbolChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Element.Structure.SymbolIs s) admittedBy msg
symbol =
    TypedSvg.Element.Structure.symbol


{-| See `TypedSvg.Element.Text.text`.
-}
text_ :
    List (Attr TypedSvg.Element.Text.TextAttrs msg)
    -> List (Element TypedSvg.Element.Text.TextContent (TypedSvg.Element.Text.TextChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Element.Text.TextIs s) admittedBy msg
text_ =
    TypedSvg.Element.Text.text


{-| See `TypedSvg.Element.Text.textPath`.
-}
textPath :
    List (Attr TypedSvg.Element.Text.TextPathAttrs msg)
    -> List (Element TypedSvg.Element.Text.TextPathContent (TypedSvg.Element.Text.TextPathChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Element.Text.TextPathIs s) admittedBy msg
textPath =
    TypedSvg.Element.Text.textPath


{-| See `TypedSvg.Element.Descriptive.title`.
-}
title :
    List (Attr TypedSvg.Element.Descriptive.TitleAttrs msg)
    -> List (Element TypedSvg.Element.Descriptive.TitleContent (TypedSvg.Element.Descriptive.TitleChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Element.Descriptive.TitleIs s) admittedBy msg
title =
    TypedSvg.Element.Descriptive.title


{-| See `TypedSvg.Element.Text.tspan`.
-}
tspan :
    List (Attr TypedSvg.Element.Text.TspanAttrs msg)
    -> List (Element TypedSvg.Element.Text.TspanContent (TypedSvg.Element.Text.TspanChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Element.Text.TspanIs s) admittedBy msg
tspan =
    TypedSvg.Element.Text.tspan


{-| See `TypedSvg.Element.Structure.use`.
-}
use :
    List (Attr TypedSvg.Element.Structure.UseAttrs msg)
    -> List (Element TypedSvg.Element.Structure.UseContent (TypedSvg.Element.Structure.UseChildAdmittedBy childAdm) msg)
    -> Element (TypedSvg.Element.Structure.UseIs s) admittedBy msg
use =
    TypedSvg.Element.Structure.use


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
