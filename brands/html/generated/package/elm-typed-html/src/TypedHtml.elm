module TypedHtml exposing
    ( a, abbr, address, area, article, aside, audio, b, base, bdi, bdo, blockquote, body, br, button, canvas, caption, cite, code, col, colgroup, data, datalist, dd, del, details, dfn, dialog, div, dl, dt, em, embed, fieldset, figcaption, figure, footer, form, h1, h2, h3, h4, h5, h6, head, header, hgroup, hr, i, iframe, img, input, ins, kbd, label, legend, li, link, main_, map, mark, menu, meta, meter, nav, noscript, object, ol, optgroup, option, output, p, picture, pictureSource, pre, progress, q, rp, rt, ruby, s, samp, script, search, section, select, slot, small, source, span, strong, style, sub, summary, sup, table, tbody, td, template, textarea, tfoot, th, thead, time, title, tr, track, u, ul, var, video, wbr
    , text
    , Element, Attr, Node, toHtml, toNode, mapMsg, mapNode, key, lazy, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7, lazy8, addClass, attrIf, when, testId
    )

{-| The general surface: every component constructor in the elm/html call
shape, one import. Signatures reference each component's aliases — reach for
`TypedHtml.<Component>` when you want the strict per-component surface (required
content, builder, narrowed values), and `TypedHtml.Attributes` / `TypedHtml.Events` /
`TypedHtml.Values` for the shared vocabulary.

`toHtml` is the render bridge to `elm/html`.

The `slot<Name>` placers assign a child element to a named slot in any
component that accepts it. Admittance is open (broad row) — wrong-kind
placements are caught by `Cem.ValidSlotKind` (elm-review).

@docs a, abbr, address, area, article, aside, audio, b, base, bdi, bdo, blockquote, body, br, button, canvas, caption, cite, code, col, colgroup, data, datalist, dd, del, details, dfn, dialog, div, dl, dt, em, embed, fieldset, figcaption, figure, footer, form, h1, h2, h3, h4, h5, h6, head, header, hgroup, hr, i, iframe, img, input, ins, kbd, label, legend, li, link, main_, map, mark, menu, meta, meter, nav, noscript, object, ol, optgroup, option, output, p, picture, pictureSource, pre, progress, q, rp, rt, ruby, s, samp, script, search, section, select, slot, small, source, span, strong, style, sub, summary, sup, table, tbody, td, template, textarea, tfoot, th, thead, time, title, tr, track, u, ul, var, video, wbr
@docs text
@docs Element, Attr, Node, toHtml, toNode, mapMsg, mapNode, key, lazy, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7, lazy8, addClass, attrIf, when, testId

-}

import Html
import HtmlIr.Attribute
import HtmlIr.Element
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared)
import HtmlIr.Node
import TypedHtml.Element.A
import TypedHtml.Element.Button
import TypedHtml.Element.Details
import TypedHtml.Element.Embedded
import TypedHtml.Element.Form
import TypedHtml.Element.Grouping
import TypedHtml.Element.Img
import TypedHtml.Element.Input
import TypedHtml.Element.Media
import TypedHtml.Element.Metadata
import TypedHtml.Element.Scripting
import TypedHtml.Element.Sectioning
import TypedHtml.Element.Select
import TypedHtml.Element.Table
import TypedHtml.Element.Text
import TypedHtml.Element.Textarea
import TypedHtml.Kind


{-| See `TypedHtml.Element.A.a`.
-}
a :
    List (Attr TypedHtml.Element.A.Attrs msg)
    -> List (Element childAccepts (TypedHtml.Element.A.ChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
a =
    TypedHtml.Element.A.a


{-| See `TypedHtml.Element.Text.abbr`.
-}
abbr :
    List (Attr TypedHtml.Element.Text.AbbrAttrs msg)
    -> List (Element TypedHtml.Element.Text.AbbrContent (TypedHtml.Element.Text.AbbrChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.AbbrIs s) admittedBy msg
abbr =
    TypedHtml.Element.Text.abbr


{-| See `TypedHtml.Element.Sectioning.address`.
-}
address :
    List (Attr TypedHtml.Element.Sectioning.AddressAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Sectioning.AddressChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Sectioning.AddressIs s) admittedBy msg
address =
    TypedHtml.Element.Sectioning.address


{-| See `TypedHtml.Element.Embedded.area`.
-}
area :
    List (Attr TypedHtml.Element.Embedded.AreaAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Embedded.AreaChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Embedded.AreaIs s) admittedBy msg
area =
    TypedHtml.Element.Embedded.area


{-| See `TypedHtml.Element.Sectioning.article`.
-}
article :
    List (Attr TypedHtml.Element.Sectioning.ArticleAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Sectioning.ArticleChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Sectioning.ArticleIs s) admittedBy msg
article =
    TypedHtml.Element.Sectioning.article


{-| See `TypedHtml.Element.Sectioning.aside`.
-}
aside :
    List (Attr TypedHtml.Element.Sectioning.AsideAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Sectioning.AsideChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Sectioning.AsideIs s) admittedBy msg
aside =
    TypedHtml.Element.Sectioning.aside


{-| See `TypedHtml.Element.Media.audio`.
-}
audio :
    List (Attr TypedHtml.Element.Media.AudioAttrs msg)
    -> List (Element TypedHtml.Element.Media.AudioContent (TypedHtml.Element.Media.AudioChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Media.AudioIs s) admittedBy msg
audio =
    TypedHtml.Element.Media.audio


{-| See `TypedHtml.Element.Text.b`.
-}
b :
    List (Attr TypedHtml.Element.Text.BAttrs msg)
    -> List (Element TypedHtml.Element.Text.BContent (TypedHtml.Element.Text.BChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.BIs s) admittedBy msg
b =
    TypedHtml.Element.Text.b


{-| See `TypedHtml.Element.Metadata.base`.
-}
base :
    List (Attr TypedHtml.Element.Metadata.BaseAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Metadata.BaseChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Metadata.BaseIs s) admittedBy msg
base =
    TypedHtml.Element.Metadata.base


{-| See `TypedHtml.Element.Text.bdi`.
-}
bdi :
    List (Attr TypedHtml.Element.Text.BdiAttrs msg)
    -> List (Element TypedHtml.Element.Text.BdiContent (TypedHtml.Element.Text.BdiChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.BdiIs s) admittedBy msg
bdi =
    TypedHtml.Element.Text.bdi


{-| See `TypedHtml.Element.Text.bdo`.
-}
bdo :
    List (Attr TypedHtml.Element.Text.BdoAttrs msg)
    -> List (Element TypedHtml.Element.Text.BdoContent (TypedHtml.Element.Text.BdoChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.BdoIs s) admittedBy msg
bdo =
    TypedHtml.Element.Text.bdo


{-| See `TypedHtml.Element.Grouping.blockquote`.
-}
blockquote :
    List (Attr TypedHtml.Element.Grouping.BlockquoteAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Grouping.BlockquoteChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Grouping.BlockquoteIs s) admittedBy msg
blockquote =
    TypedHtml.Element.Grouping.blockquote


{-| See `TypedHtml.Element.Sectioning.body`.
-}
body :
    List (Attr TypedHtml.Element.Sectioning.BodyAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Sectioning.BodyChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Sectioning.BodyIs s) admittedBy msg
body =
    TypedHtml.Element.Sectioning.body


{-| See `TypedHtml.Element.Text.br`.
-}
br :
    List (Attr TypedHtml.Element.Text.BrAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Text.BrChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.BrIs s) admittedBy msg
br =
    TypedHtml.Element.Text.br


{-| See `TypedHtml.Element.Button.button`.
-}
button :
    List (Attr TypedHtml.Element.Button.Attrs msg)
    -> List (Element TypedHtml.Element.Button.Content (TypedHtml.Element.Button.ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Button.Is s) admittedBy msg
button =
    TypedHtml.Element.Button.button


{-| See `TypedHtml.Element.Embedded.canvas`.
-}
canvas :
    List (Attr TypedHtml.Element.Embedded.CanvasAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Embedded.CanvasChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
canvas =
    TypedHtml.Element.Embedded.canvas


{-| See `TypedHtml.Element.Table.caption`.
-}
caption :
    List (Attr TypedHtml.Element.Table.CaptionAttrs msg)
    -> List (Element TypedHtml.Element.Table.CaptionContent (TypedHtml.Element.Table.CaptionChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Table.CaptionIs s) TypedHtml.Element.Table.CaptionAdmittedBy msg
caption =
    TypedHtml.Element.Table.caption


{-| See `TypedHtml.Element.Text.cite`.
-}
cite :
    List (Attr TypedHtml.Element.Text.CiteAttrs msg)
    -> List (Element TypedHtml.Element.Text.CiteContent (TypedHtml.Element.Text.CiteChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.CiteIs s) admittedBy msg
cite =
    TypedHtml.Element.Text.cite


{-| See `TypedHtml.Element.Text.code`.
-}
code :
    List (Attr TypedHtml.Element.Text.CodeAttrs msg)
    -> List (Element TypedHtml.Element.Text.CodeContent (TypedHtml.Element.Text.CodeChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.CodeIs s) admittedBy msg
code =
    TypedHtml.Element.Text.code


{-| See `TypedHtml.Element.Table.col`.
-}
col :
    List (Attr TypedHtml.Element.Table.ColAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Table.ColChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Table.ColIs s) TypedHtml.Element.Table.ColAdmittedBy msg
col =
    TypedHtml.Element.Table.col


{-| See `TypedHtml.Element.Table.colgroup`.
-}
colgroup :
    List (Attr TypedHtml.Element.Table.ColgroupAttrs msg)
    -> List (Element TypedHtml.Element.Table.ColgroupContent (TypedHtml.Element.Table.ColgroupChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Table.ColgroupIs s) TypedHtml.Element.Table.ColgroupAdmittedBy msg
colgroup =
    TypedHtml.Element.Table.colgroup


{-| See `TypedHtml.Element.Text.data`.
-}
data :
    List (Attr TypedHtml.Element.Text.DataAttrs msg)
    -> List (Element TypedHtml.Element.Text.DataContent (TypedHtml.Element.Text.DataChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.DataIs s) admittedBy msg
data =
    TypedHtml.Element.Text.data


{-| See `TypedHtml.Element.Select.datalist`.
-}
datalist :
    List (Attr TypedHtml.Element.Select.DatalistAttrs msg)
    -> List (Element TypedHtml.Element.Select.DatalistContent (TypedHtml.Element.Select.DatalistChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Select.DatalistIs s) admittedBy msg
datalist =
    TypedHtml.Element.Select.datalist


{-| See `TypedHtml.Element.Grouping.dd`.
-}
dd :
    List (Attr TypedHtml.Element.Grouping.DdAttrs msg)
    -> List (Element TypedHtml.Element.Grouping.DdContent (TypedHtml.Element.Grouping.DdChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Grouping.DdIs s) TypedHtml.Element.Grouping.DdAdmittedBy msg
dd =
    TypedHtml.Element.Grouping.dd


{-| See `TypedHtml.Element.Text.del`.
-}
del :
    List (Attr TypedHtml.Element.Text.DelAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Text.DelChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
del =
    TypedHtml.Element.Text.del


{-| See `TypedHtml.Element.Details.details`.
-}
details :
    List (Attr TypedHtml.Element.Details.DetailsAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Details.DetailsChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Details.DetailsIs s) admittedBy msg
details =
    TypedHtml.Element.Details.details


{-| See `TypedHtml.Element.Text.dfn`.
-}
dfn :
    List (Attr TypedHtml.Element.Text.DfnAttrs msg)
    -> List (Element TypedHtml.Element.Text.DfnContent (TypedHtml.Element.Text.DfnChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.DfnIs s) admittedBy msg
dfn =
    TypedHtml.Element.Text.dfn


{-| See `TypedHtml.Element.Grouping.dialog`.
-}
dialog :
    List (Attr TypedHtml.Element.Grouping.DialogAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Grouping.DialogChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Grouping.DialogIs s) admittedBy msg
dialog =
    TypedHtml.Element.Grouping.dialog


{-| See `TypedHtml.Element.Grouping.div`.
-}
div :
    List (Attr TypedHtml.Element.Grouping.DivAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Grouping.DivChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Grouping.DivIs s) admittedBy msg
div =
    TypedHtml.Element.Grouping.div


{-| See `TypedHtml.Element.Grouping.dl`.
-}
dl :
    List (Attr TypedHtml.Element.Grouping.DlAttrs msg)
    -> List (Element TypedHtml.Element.Grouping.DlContent (TypedHtml.Element.Grouping.DlChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Grouping.DlIs s) admittedBy msg
dl =
    TypedHtml.Element.Grouping.dl


{-| See `TypedHtml.Element.Grouping.dt`.
-}
dt :
    List (Attr TypedHtml.Element.Grouping.DtAttrs msg)
    -> List (Element TypedHtml.Element.Grouping.DtContent (TypedHtml.Element.Grouping.DtChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Grouping.DtIs s) TypedHtml.Element.Grouping.DtAdmittedBy msg
dt =
    TypedHtml.Element.Grouping.dt


{-| See `TypedHtml.Element.Text.em`.
-}
em :
    List (Attr TypedHtml.Element.Text.EmAttrs msg)
    -> List (Element TypedHtml.Element.Text.EmContent (TypedHtml.Element.Text.EmChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.EmIs s) admittedBy msg
em =
    TypedHtml.Element.Text.em


{-| See `TypedHtml.Element.Embedded.embed`.
-}
embed :
    List (Attr TypedHtml.Element.Embedded.EmbedAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Embedded.EmbedChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Embedded.EmbedIs s) admittedBy msg
embed =
    TypedHtml.Element.Embedded.embed


{-| See `TypedHtml.Element.Form.fieldset`.
-}
fieldset :
    List (Attr TypedHtml.Element.Form.FieldsetAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Form.FieldsetChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Form.FieldsetIs s) admittedBy msg
fieldset =
    TypedHtml.Element.Form.fieldset


{-| See `TypedHtml.Element.Grouping.figcaption`.
-}
figcaption :
    List (Attr TypedHtml.Element.Grouping.FigcaptionAttrs msg)
    -> List (Element TypedHtml.Element.Grouping.FigcaptionContent (TypedHtml.Element.Grouping.FigcaptionChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Grouping.FigcaptionIs s) TypedHtml.Element.Grouping.FigcaptionAdmittedBy msg
figcaption =
    TypedHtml.Element.Grouping.figcaption


{-| See `TypedHtml.Element.Grouping.figure`.
-}
figure :
    List (Attr TypedHtml.Element.Grouping.FigureAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Grouping.FigureChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Grouping.FigureIs s) admittedBy msg
figure =
    TypedHtml.Element.Grouping.figure


{-| See `TypedHtml.Element.Sectioning.footer`.
-}
footer :
    List (Attr TypedHtml.Element.Sectioning.FooterAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Sectioning.FooterChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Sectioning.FooterIs s) admittedBy msg
footer =
    TypedHtml.Element.Sectioning.footer


{-| See `TypedHtml.Element.Form.form`.
-}
form :
    List (Attr TypedHtml.Element.Form.FormAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Form.FormChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Form.FormIs s) admittedBy msg
form =
    TypedHtml.Element.Form.form


{-| See `TypedHtml.Element.Sectioning.h1`.
-}
h1 :
    List (Attr TypedHtml.Element.Sectioning.H1Attrs msg)
    -> List (Element TypedHtml.Element.Sectioning.H1Content (TypedHtml.Element.Sectioning.H1ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Sectioning.H1Is s) admittedBy msg
h1 =
    TypedHtml.Element.Sectioning.h1


{-| See `TypedHtml.Element.Sectioning.h2`.
-}
h2 :
    List (Attr TypedHtml.Element.Sectioning.H2Attrs msg)
    -> List (Element TypedHtml.Element.Sectioning.H2Content (TypedHtml.Element.Sectioning.H2ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Sectioning.H2Is s) admittedBy msg
h2 =
    TypedHtml.Element.Sectioning.h2


{-| See `TypedHtml.Element.Sectioning.h3`.
-}
h3 :
    List (Attr TypedHtml.Element.Sectioning.H3Attrs msg)
    -> List (Element TypedHtml.Element.Sectioning.H3Content (TypedHtml.Element.Sectioning.H3ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Sectioning.H3Is s) admittedBy msg
h3 =
    TypedHtml.Element.Sectioning.h3


{-| See `TypedHtml.Element.Sectioning.h4`.
-}
h4 :
    List (Attr TypedHtml.Element.Sectioning.H4Attrs msg)
    -> List (Element TypedHtml.Element.Sectioning.H4Content (TypedHtml.Element.Sectioning.H4ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Sectioning.H4Is s) admittedBy msg
h4 =
    TypedHtml.Element.Sectioning.h4


{-| See `TypedHtml.Element.Sectioning.h5`.
-}
h5 :
    List (Attr TypedHtml.Element.Sectioning.H5Attrs msg)
    -> List (Element TypedHtml.Element.Sectioning.H5Content (TypedHtml.Element.Sectioning.H5ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Sectioning.H5Is s) admittedBy msg
h5 =
    TypedHtml.Element.Sectioning.h5


{-| See `TypedHtml.Element.Sectioning.h6`.
-}
h6 :
    List (Attr TypedHtml.Element.Sectioning.H6Attrs msg)
    -> List (Element TypedHtml.Element.Sectioning.H6Content (TypedHtml.Element.Sectioning.H6ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Sectioning.H6Is s) admittedBy msg
h6 =
    TypedHtml.Element.Sectioning.h6


{-| See `TypedHtml.Element.Metadata.head`.
-}
head :
    List (Attr TypedHtml.Element.Metadata.HeadAttrs msg)
    -> List (Element TypedHtml.Kind.Metadata (TypedHtml.Element.Metadata.HeadChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Metadata.HeadIs s) admittedBy msg
head =
    TypedHtml.Element.Metadata.head


{-| See `TypedHtml.Element.Sectioning.header`.
-}
header :
    List (Attr TypedHtml.Element.Sectioning.HeaderAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Sectioning.HeaderChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Sectioning.HeaderIs s) admittedBy msg
header =
    TypedHtml.Element.Sectioning.header


{-| See `TypedHtml.Element.Sectioning.hgroup`.
-}
hgroup :
    List (Attr TypedHtml.Element.Sectioning.HgroupAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Sectioning.HgroupChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Sectioning.HgroupIs s) admittedBy msg
hgroup =
    TypedHtml.Element.Sectioning.hgroup


{-| See `TypedHtml.Element.Grouping.hr`.
-}
hr :
    List (Attr TypedHtml.Element.Grouping.HrAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Grouping.HrChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Grouping.HrIs s) admittedBy msg
hr =
    TypedHtml.Element.Grouping.hr


{-| See `TypedHtml.Element.Text.i`.
-}
i :
    List (Attr TypedHtml.Element.Text.IAttrs msg)
    -> List (Element TypedHtml.Element.Text.IContent (TypedHtml.Element.Text.IChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.IIs s) admittedBy msg
i =
    TypedHtml.Element.Text.i


{-| See `TypedHtml.Element.Embedded.iframe`.
-}
iframe :
    List (Attr TypedHtml.Element.Embedded.IframeAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Embedded.IframeChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Embedded.IframeIs s) admittedBy msg
iframe =
    TypedHtml.Element.Embedded.iframe


{-| See `TypedHtml.Element.Img.img`.
-}
img :
    List (Attr TypedHtml.Element.Img.Attrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Img.ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Img.Is s) admittedBy msg
img =
    TypedHtml.Element.Img.img


{-| See `TypedHtml.Element.Input.input`.
-}
input :
    List (Attr TypedHtml.Element.Input.Attrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Input.ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Input.Is s) admittedBy msg
input =
    TypedHtml.Element.Input.input


{-| See `TypedHtml.Element.Text.ins`.
-}
ins :
    List (Attr TypedHtml.Element.Text.InsAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Text.InsChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
ins =
    TypedHtml.Element.Text.ins


{-| See `TypedHtml.Element.Text.kbd`.
-}
kbd :
    List (Attr TypedHtml.Element.Text.KbdAttrs msg)
    -> List (Element TypedHtml.Element.Text.KbdContent (TypedHtml.Element.Text.KbdChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.KbdIs s) admittedBy msg
kbd =
    TypedHtml.Element.Text.kbd


{-| See `TypedHtml.Element.Form.label`.
-}
label :
    List (Attr TypedHtml.Element.Form.LabelAttrs msg)
    -> List (Element TypedHtml.Element.Form.LabelContent (TypedHtml.Element.Form.LabelChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Form.LabelIs s) admittedBy msg
label =
    TypedHtml.Element.Form.label


{-| See `TypedHtml.Element.Form.legend`.
-}
legend :
    List (Attr TypedHtml.Element.Form.LegendAttrs msg)
    -> List (Element TypedHtml.Element.Form.LegendContent (TypedHtml.Element.Form.LegendChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Form.LegendIs s) TypedHtml.Element.Form.LegendAdmittedBy msg
legend =
    TypedHtml.Element.Form.legend


{-| See `TypedHtml.Element.Grouping.li`.
-}
li :
    List (Attr TypedHtml.Element.Grouping.LiAttrs msg)
    -> List (Element TypedHtml.Element.Grouping.LiContent (TypedHtml.Element.Grouping.LiChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Grouping.LiIs s) TypedHtml.Element.Grouping.LiAdmittedBy msg
li =
    TypedHtml.Element.Grouping.li


{-| See `TypedHtml.Element.Metadata.link`.
-}
link :
    List (Attr TypedHtml.Element.Metadata.LinkAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Metadata.LinkChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Metadata.LinkIs s) admittedBy msg
link =
    TypedHtml.Element.Metadata.link


{-| See `TypedHtml.Element.Sectioning.main_`.
-}
main_ :
    List (Attr TypedHtml.Element.Sectioning.MainAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Sectioning.MainChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Sectioning.MainIs s) admittedBy msg
main_ =
    TypedHtml.Element.Sectioning.main_


{-| See `TypedHtml.Element.Embedded.map`.
-}
map :
    List (Attr TypedHtml.Element.Embedded.MapAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Embedded.MapChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
map =
    TypedHtml.Element.Embedded.map


{-| See `TypedHtml.Element.Text.mark`.
-}
mark :
    List (Attr TypedHtml.Element.Text.MarkAttrs msg)
    -> List (Element TypedHtml.Element.Text.MarkContent (TypedHtml.Element.Text.MarkChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.MarkIs s) admittedBy msg
mark =
    TypedHtml.Element.Text.mark


{-| See `TypedHtml.Element.Grouping.menu`.
-}
menu :
    List (Attr TypedHtml.Element.Grouping.MenuAttrs msg)
    -> List (Element TypedHtml.Element.Grouping.MenuContent (TypedHtml.Element.Grouping.MenuChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Grouping.MenuIs s) admittedBy msg
menu =
    TypedHtml.Element.Grouping.menu


{-| See `TypedHtml.Element.Metadata.meta`.
-}
meta :
    List (Attr TypedHtml.Element.Metadata.MetaAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Metadata.MetaChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Metadata.MetaIs s) admittedBy msg
meta =
    TypedHtml.Element.Metadata.meta


{-| See `TypedHtml.Element.Text.meter`.
-}
meter :
    List (Attr TypedHtml.Element.Text.MeterAttrs msg)
    -> List (Element TypedHtml.Element.Text.MeterContent (TypedHtml.Element.Text.MeterChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.MeterIs s) admittedBy msg
meter =
    TypedHtml.Element.Text.meter


{-| See `TypedHtml.Element.Sectioning.nav`.
-}
nav :
    List (Attr TypedHtml.Element.Sectioning.NavAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Sectioning.NavChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Sectioning.NavIs s) admittedBy msg
nav =
    TypedHtml.Element.Sectioning.nav


{-| See `TypedHtml.Element.Scripting.noscript`.
-}
noscript :
    List (Attr TypedHtml.Element.Scripting.NoscriptAttrs msg)
    -> List (Element TypedHtml.Element.Scripting.NoscriptContent (TypedHtml.Element.Scripting.NoscriptChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Scripting.NoscriptIs s) admittedBy msg
noscript =
    TypedHtml.Element.Scripting.noscript


{-| See `TypedHtml.Element.Embedded.object`.
-}
object :
    List (Attr TypedHtml.Element.Embedded.ObjectAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Embedded.ObjectChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
object =
    TypedHtml.Element.Embedded.object


{-| See `TypedHtml.Element.Grouping.ol`.
-}
ol :
    List (Attr TypedHtml.Element.Grouping.OlAttrs msg)
    -> List (Element TypedHtml.Element.Grouping.OlContent (TypedHtml.Element.Grouping.OlChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Grouping.OlIs s) admittedBy msg
ol =
    TypedHtml.Element.Grouping.ol


{-| See `TypedHtml.Element.Select.optgroup`.
-}
optgroup :
    List (Attr TypedHtml.Element.Select.OptgroupAttrs msg)
    -> List (Element TypedHtml.Element.Select.OptgroupContent (TypedHtml.Element.Select.OptgroupChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Select.OptgroupIs s) TypedHtml.Element.Select.OptgroupAdmittedBy msg
optgroup =
    TypedHtml.Element.Select.optgroup


{-| See `TypedHtml.Element.Select.option`.
-}
option :
    List (Attr TypedHtml.Element.Select.OptionAttrs msg)
    -> List (Element TypedHtml.Element.Select.OptionContent (TypedHtml.Element.Select.OptionChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Select.OptionIs s) TypedHtml.Element.Select.OptionAdmittedBy msg
option =
    TypedHtml.Element.Select.option


{-| See `TypedHtml.Element.Form.output`.
-}
output :
    List (Attr TypedHtml.Element.Form.OutputAttrs msg)
    -> List (Element TypedHtml.Element.Form.OutputContent (TypedHtml.Element.Form.OutputChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Form.OutputIs s) admittedBy msg
output =
    TypedHtml.Element.Form.output


{-| See `TypedHtml.Element.Grouping.p`.
-}
p :
    List (Attr TypedHtml.Element.Grouping.PAttrs msg)
    -> List (Element TypedHtml.Element.Grouping.PContent (TypedHtml.Element.Grouping.PChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Grouping.PIs s) admittedBy msg
p =
    TypedHtml.Element.Grouping.p


{-| See `TypedHtml.Element.Media.picture`.
-}
picture :
    List (Attr TypedHtml.Element.Media.PictureAttrs msg)
    -> List (Element TypedHtml.Element.Media.PictureContent (TypedHtml.Element.Media.PictureChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Media.PictureIs s) admittedBy msg
picture =
    TypedHtml.Element.Media.picture


{-| See `TypedHtml.Element.Media.pictureSource`.
-}
pictureSource :
    List (Attr TypedHtml.Element.Media.PictureSourceAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Media.PictureSourceChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Media.PictureSourceIs s) TypedHtml.Element.Media.PictureSourceAdmittedBy msg
pictureSource =
    TypedHtml.Element.Media.pictureSource


{-| See `TypedHtml.Element.Grouping.pre`.
-}
pre :
    List (Attr TypedHtml.Element.Grouping.PreAttrs msg)
    -> List (Element TypedHtml.Element.Grouping.PreContent (TypedHtml.Element.Grouping.PreChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Grouping.PreIs s) admittedBy msg
pre =
    TypedHtml.Element.Grouping.pre


{-| See `TypedHtml.Element.Text.progress`.
-}
progress :
    List (Attr TypedHtml.Element.Text.ProgressAttrs msg)
    -> List (Element TypedHtml.Element.Text.ProgressContent (TypedHtml.Element.Text.ProgressChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.ProgressIs s) admittedBy msg
progress =
    TypedHtml.Element.Text.progress


{-| See `TypedHtml.Element.Text.q`.
-}
q :
    List (Attr TypedHtml.Element.Text.QAttrs msg)
    -> List (Element TypedHtml.Element.Text.QContent (TypedHtml.Element.Text.QChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.QIs s) admittedBy msg
q =
    TypedHtml.Element.Text.q


{-| See `TypedHtml.Element.Text.rp`.
-}
rp :
    List (Attr TypedHtml.Element.Text.RpAttrs msg)
    -> List (Element TypedHtml.Element.Text.RpContent (TypedHtml.Element.Text.RpChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.RpIs s) TypedHtml.Element.Text.RpAdmittedBy msg
rp =
    TypedHtml.Element.Text.rp


{-| See `TypedHtml.Element.Text.rt`.
-}
rt :
    List (Attr TypedHtml.Element.Text.RtAttrs msg)
    -> List (Element TypedHtml.Element.Text.RtContent (TypedHtml.Element.Text.RtChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.RtIs s) TypedHtml.Element.Text.RtAdmittedBy msg
rt =
    TypedHtml.Element.Text.rt


{-| See `TypedHtml.Element.Text.ruby`.
-}
ruby :
    List (Attr TypedHtml.Element.Text.RubyAttrs msg)
    -> List (Element TypedHtml.Element.Text.RubyContent (TypedHtml.Element.Text.RubyChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.RubyIs s) admittedBy msg
ruby =
    TypedHtml.Element.Text.ruby


{-| See `TypedHtml.Element.Text.s`.
-}
s :
    List (Attr TypedHtml.Element.Text.SAttrs msg)
    -> List (Element TypedHtml.Element.Text.SContent (TypedHtml.Element.Text.SChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.SIs s) admittedBy msg
s =
    TypedHtml.Element.Text.s


{-| See `TypedHtml.Element.Text.samp`.
-}
samp :
    List (Attr TypedHtml.Element.Text.SampAttrs msg)
    -> List (Element TypedHtml.Element.Text.SampContent (TypedHtml.Element.Text.SampChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.SampIs s) admittedBy msg
samp =
    TypedHtml.Element.Text.samp


{-| See `TypedHtml.Element.Scripting.script`.
-}
script :
    List (Attr TypedHtml.Element.Scripting.ScriptAttrs msg)
    -> List (Element TypedHtml.Element.Scripting.ScriptContent (TypedHtml.Element.Scripting.ScriptChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Scripting.ScriptIs s) admittedBy msg
script =
    TypedHtml.Element.Scripting.script


{-| See `TypedHtml.Element.Sectioning.search`.
-}
search :
    List (Attr TypedHtml.Element.Sectioning.SearchAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Sectioning.SearchChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Sectioning.SearchIs s) admittedBy msg
search =
    TypedHtml.Element.Sectioning.search


{-| See `TypedHtml.Element.Sectioning.section`.
-}
section :
    List (Attr TypedHtml.Element.Sectioning.SectionAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Sectioning.SectionChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Sectioning.SectionIs s) admittedBy msg
section =
    TypedHtml.Element.Sectioning.section


{-| See `TypedHtml.Element.Select.select`.
-}
select :
    List (Attr TypedHtml.Element.Select.SelectAttrs msg)
    -> List (Element TypedHtml.Element.Select.SelectContent (TypedHtml.Element.Select.SelectChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Select.SelectIs s) admittedBy msg
select =
    TypedHtml.Element.Select.select


{-| See `TypedHtml.Element.Scripting.slot`.
-}
slot :
    List (Attr TypedHtml.Element.Scripting.SlotAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Scripting.SlotChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
slot =
    TypedHtml.Element.Scripting.slot


{-| See `TypedHtml.Element.Text.small`.
-}
small :
    List (Attr TypedHtml.Element.Text.SmallAttrs msg)
    -> List (Element TypedHtml.Element.Text.SmallContent (TypedHtml.Element.Text.SmallChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.SmallIs s) admittedBy msg
small =
    TypedHtml.Element.Text.small


{-| See `TypedHtml.Element.Media.source`.
-}
source :
    List (Attr TypedHtml.Element.Media.SourceAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Media.SourceChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Media.SourceIs s) TypedHtml.Element.Media.SourceAdmittedBy msg
source =
    TypedHtml.Element.Media.source


{-| See `TypedHtml.Element.Text.span`.
-}
span :
    List (Attr TypedHtml.Element.Text.SpanAttrs msg)
    -> List (Element TypedHtml.Element.Text.SpanContent (TypedHtml.Element.Text.SpanChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.SpanIs s) admittedBy msg
span =
    TypedHtml.Element.Text.span


{-| See `TypedHtml.Element.Text.strong`.
-}
strong :
    List (Attr TypedHtml.Element.Text.StrongAttrs msg)
    -> List (Element TypedHtml.Element.Text.StrongContent (TypedHtml.Element.Text.StrongChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.StrongIs s) admittedBy msg
strong =
    TypedHtml.Element.Text.strong


{-| See `TypedHtml.Element.Metadata.style`.
-}
style :
    List (Attr TypedHtml.Element.Metadata.StyleAttrs msg)
    -> List (Element TypedHtml.Element.Metadata.StyleContent (TypedHtml.Element.Metadata.StyleChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Metadata.StyleIs s) admittedBy msg
style =
    TypedHtml.Element.Metadata.style


{-| See `TypedHtml.Element.Text.sub`.
-}
sub :
    List (Attr TypedHtml.Element.Text.SubAttrs msg)
    -> List (Element TypedHtml.Element.Text.SubContent (TypedHtml.Element.Text.SubChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.SubIs s) admittedBy msg
sub =
    TypedHtml.Element.Text.sub


{-| See `TypedHtml.Element.Details.summary`.
-}
summary :
    List (Attr TypedHtml.Element.Details.SummaryAttrs msg)
    -> List (Element TypedHtml.Element.Details.SummaryContent (TypedHtml.Element.Details.SummaryChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Details.SummaryIs s) TypedHtml.Element.Details.SummaryAdmittedBy msg
summary =
    TypedHtml.Element.Details.summary


{-| See `TypedHtml.Element.Text.sup`.
-}
sup :
    List (Attr TypedHtml.Element.Text.SupAttrs msg)
    -> List (Element TypedHtml.Element.Text.SupContent (TypedHtml.Element.Text.SupChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.SupIs s) admittedBy msg
sup =
    TypedHtml.Element.Text.sup


{-| See `TypedHtml.Element.Table.table`.
-}
table :
    List (Attr TypedHtml.Element.Table.TableAttrs msg)
    -> List (Element TypedHtml.Element.Table.TableContent (TypedHtml.Element.Table.TableChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Table.TableIs s) admittedBy msg
table =
    TypedHtml.Element.Table.table


{-| See `TypedHtml.Element.Table.tbody`.
-}
tbody :
    List (Attr TypedHtml.Element.Table.TbodyAttrs msg)
    -> List (Element TypedHtml.Element.Table.TbodyContent (TypedHtml.Element.Table.TbodyChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Table.TbodyIs s) TypedHtml.Element.Table.TbodyAdmittedBy msg
tbody =
    TypedHtml.Element.Table.tbody


{-| See `TypedHtml.Element.Table.td`.
-}
td :
    List (Attr TypedHtml.Element.Table.TdAttrs msg)
    -> List (Element TypedHtml.Element.Table.TdContent (TypedHtml.Element.Table.TdChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Table.TdIs s) TypedHtml.Element.Table.TdAdmittedBy msg
td =
    TypedHtml.Element.Table.td


{-| See `TypedHtml.Element.Scripting.template`.
-}
template :
    List (Attr TypedHtml.Element.Scripting.TemplateAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Scripting.TemplateChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Scripting.TemplateIs s) admittedBy msg
template =
    TypedHtml.Element.Scripting.template


{-| See `TypedHtml.Element.Textarea.textarea`.
-}
textarea :
    List (Attr TypedHtml.Element.Textarea.Attrs msg)
    -> List (Element TypedHtml.Element.Textarea.Content (TypedHtml.Element.Textarea.ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Textarea.Is s) admittedBy msg
textarea =
    TypedHtml.Element.Textarea.textarea


{-| See `TypedHtml.Element.Table.tfoot`.
-}
tfoot :
    List (Attr TypedHtml.Element.Table.TfootAttrs msg)
    -> List (Element TypedHtml.Element.Table.TfootContent (TypedHtml.Element.Table.TfootChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Table.TfootIs s) TypedHtml.Element.Table.TfootAdmittedBy msg
tfoot =
    TypedHtml.Element.Table.tfoot


{-| See `TypedHtml.Element.Table.th`.
-}
th :
    List (Attr TypedHtml.Element.Table.ThAttrs msg)
    -> List (Element TypedHtml.Element.Table.ThContent (TypedHtml.Element.Table.ThChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Table.ThIs s) TypedHtml.Element.Table.ThAdmittedBy msg
th =
    TypedHtml.Element.Table.th


{-| See `TypedHtml.Element.Table.thead`.
-}
thead :
    List (Attr TypedHtml.Element.Table.TheadAttrs msg)
    -> List (Element TypedHtml.Element.Table.TheadContent (TypedHtml.Element.Table.TheadChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Table.TheadIs s) TypedHtml.Element.Table.TheadAdmittedBy msg
thead =
    TypedHtml.Element.Table.thead


{-| See `TypedHtml.Element.Text.time`.
-}
time :
    List (Attr TypedHtml.Element.Text.TimeAttrs msg)
    -> List (Element TypedHtml.Element.Text.TimeContent (TypedHtml.Element.Text.TimeChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.TimeIs s) admittedBy msg
time =
    TypedHtml.Element.Text.time


{-| See `TypedHtml.Element.Metadata.title`.
-}
title :
    List (Attr TypedHtml.Element.Metadata.TitleAttrs msg)
    -> List (Element TypedHtml.Element.Metadata.TitleContent (TypedHtml.Element.Metadata.TitleChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Metadata.TitleIs s) admittedBy msg
title =
    TypedHtml.Element.Metadata.title


{-| See `TypedHtml.Element.Table.tr`.
-}
tr :
    List (Attr TypedHtml.Element.Table.TrAttrs msg)
    -> List (Element TypedHtml.Element.Table.TrContent (TypedHtml.Element.Table.TrChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Table.TrIs s) TypedHtml.Element.Table.TrAdmittedBy msg
tr =
    TypedHtml.Element.Table.tr


{-| See `TypedHtml.Element.Media.track`.
-}
track :
    List (Attr TypedHtml.Element.Media.TrackAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Media.TrackChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Media.TrackIs s) TypedHtml.Element.Media.TrackAdmittedBy msg
track =
    TypedHtml.Element.Media.track


{-| See `TypedHtml.Element.Text.u`.
-}
u :
    List (Attr TypedHtml.Element.Text.UAttrs msg)
    -> List (Element TypedHtml.Element.Text.UContent (TypedHtml.Element.Text.UChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.UIs s) admittedBy msg
u =
    TypedHtml.Element.Text.u


{-| See `TypedHtml.Element.Grouping.ul`.
-}
ul :
    List (Attr TypedHtml.Element.Grouping.UlAttrs msg)
    -> List (Element TypedHtml.Element.Grouping.UlContent (TypedHtml.Element.Grouping.UlChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Grouping.UlIs s) admittedBy msg
ul =
    TypedHtml.Element.Grouping.ul


{-| See `TypedHtml.Element.Text.var`.
-}
var :
    List (Attr TypedHtml.Element.Text.VarAttrs msg)
    -> List (Element TypedHtml.Element.Text.VarContent (TypedHtml.Element.Text.VarChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.VarIs s) admittedBy msg
var =
    TypedHtml.Element.Text.var


{-| See `TypedHtml.Element.Media.video`.
-}
video :
    List (Attr TypedHtml.Element.Media.VideoAttrs msg)
    -> List (Element TypedHtml.Element.Media.VideoContent (TypedHtml.Element.Media.VideoChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Media.VideoIs s) admittedBy msg
video =
    TypedHtml.Element.Media.video


{-| See `TypedHtml.Element.Text.wbr`.
-}
wbr :
    List (Attr TypedHtml.Element.Text.WbrAttrs msg)
    -> List (Element childAccepts (TypedHtml.Element.Text.WbrChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Element.Text.WbrIs s) admittedBy msg
wbr =
    TypedHtml.Element.Text.wbr


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
