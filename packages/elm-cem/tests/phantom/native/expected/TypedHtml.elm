module TypedHtml exposing
    ( a, div, fieldset, legend, optgroup, option, p, picture, pictureSource, select, source, span, track, video
    , text
    , Element, Attr, Node, toHtml, toNode, mapMsg, mapNode
    )

{-| The general surface: every component constructor in the elm/html call
shape, one import. Signatures reference each component's aliases — reach for
`TypedHtml.<Component>` when you want the strict per-component surface (required
content, builder, narrowed values), and `TypedHtml.Attributes` / `TypedHtml.Events` /
`TypedHtml.Values` for the shared vocabulary.

`toHtml` is the render bridge to `elm/html`.

@docs a, div, fieldset, legend, optgroup, option, p, picture, pictureSource, select, source, span, track, video
@docs text
@docs Element, Attr, Node, toHtml, toNode, mapMsg, mapNode

-}

import Html
import HtmlIr.Attribute
import HtmlIr.Element
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared)
import HtmlIr.Node
import TypedHtml.A
import TypedHtml.Form
import TypedHtml.Grouping
import TypedHtml.Media
import TypedHtml.Select


{-| See `TypedHtml.A.a`.
-}
a :
    List (Attr TypedHtml.A.Attrs msg)
    -> List (Element childAccepts (TypedHtml.A.ChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
a =
    TypedHtml.A.a


{-| See `TypedHtml.Grouping.div`.
-}
div :
    List (Attr TypedHtml.Grouping.DivAttrs msg)
    -> List (Element childAccepts (TypedHtml.Grouping.DivChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Grouping.DivIs s) admittedBy msg
div =
    TypedHtml.Grouping.div


{-| See `TypedHtml.Form.fieldset`.
-}
fieldset :
    List (Attr TypedHtml.Form.FieldsetAttrs msg)
    -> List (Element TypedHtml.Form.FieldsetContent (TypedHtml.Form.FieldsetChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Form.FieldsetIs s) admittedBy msg
fieldset =
    TypedHtml.Form.fieldset


{-| See `TypedHtml.Form.legend`.
-}
legend :
    List (Attr TypedHtml.Form.LegendAttrs msg)
    -> List (Element TypedHtml.Form.LegendContent (TypedHtml.Form.LegendChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Form.LegendIs s) TypedHtml.Form.LegendAdmittedBy msg
legend =
    TypedHtml.Form.legend


{-| See `TypedHtml.Select.optgroup`.
-}
optgroup :
    List (Attr TypedHtml.Select.OptgroupAttrs msg)
    -> List (Element TypedHtml.Select.OptgroupContent (TypedHtml.Select.OptgroupChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Select.OptgroupIs s) TypedHtml.Select.OptgroupAdmittedBy msg
optgroup =
    TypedHtml.Select.optgroup


{-| See `TypedHtml.Select.option`.
-}
option :
    List (Attr TypedHtml.Select.OptionAttrs msg)
    -> List (Element TypedHtml.Select.OptionContent (TypedHtml.Select.OptionChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Select.OptionIs s) TypedHtml.Select.OptionAdmittedBy msg
option =
    TypedHtml.Select.option


{-| See `TypedHtml.Grouping.p`.
-}
p :
    List (Attr TypedHtml.Grouping.PAttrs msg)
    -> List (Element TypedHtml.Grouping.PContent (TypedHtml.Grouping.PChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Grouping.PIs s) admittedBy msg
p =
    TypedHtml.Grouping.p


{-| See `TypedHtml.Media.picture`.
-}
picture :
    List (Attr TypedHtml.Media.PictureAttrs msg)
    -> List (Element TypedHtml.Media.PictureContent (TypedHtml.Media.PictureChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Media.PictureIs s) admittedBy msg
picture =
    TypedHtml.Media.picture


{-| See `TypedHtml.Media.pictureSource`.
-}
pictureSource :
    List (Attr TypedHtml.Media.PictureSourceAttrs msg)
    -> List (Element childAccepts (TypedHtml.Media.PictureSourceChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Media.PictureSourceIs s) TypedHtml.Media.PictureSourceAdmittedBy msg
pictureSource =
    TypedHtml.Media.pictureSource


{-| See `TypedHtml.Select.select`.
-}
select :
    List (Attr TypedHtml.Select.SelectAttrs msg)
    -> List (Element TypedHtml.Select.SelectContent (TypedHtml.Select.SelectChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Select.SelectIs s) admittedBy msg
select =
    TypedHtml.Select.select


{-| See `TypedHtml.Media.source`.
-}
source :
    List (Attr TypedHtml.Media.SourceAttrs msg)
    -> List (Element childAccepts (TypedHtml.Media.SourceChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Media.SourceIs s) TypedHtml.Media.SourceAdmittedBy msg
source =
    TypedHtml.Media.source


{-| See `TypedHtml.Grouping.span`.
-}
span :
    List (Attr TypedHtml.Grouping.SpanAttrs msg)
    -> List (Element TypedHtml.Grouping.SpanContent (TypedHtml.Grouping.SpanChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Grouping.SpanIs s) admittedBy msg
span =
    TypedHtml.Grouping.span


{-| See `TypedHtml.Media.track`.
-}
track :
    List (Attr TypedHtml.Media.TrackAttrs msg)
    -> List (Element childAccepts (TypedHtml.Media.TrackChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Media.TrackIs s) TypedHtml.Media.TrackAdmittedBy msg
track =
    TypedHtml.Media.track


{-| See `TypedHtml.Media.video`.
-}
video :
    List (Attr TypedHtml.Media.VideoAttrs msg)
    -> List (Element TypedHtml.Media.VideoContent (TypedHtml.Media.VideoChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Media.VideoIs s) admittedBy msg
video =
    TypedHtml.Media.video


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
