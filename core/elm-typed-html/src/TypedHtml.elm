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
import TypedHtml.Component.A
import TypedHtml.Component.Button
import TypedHtml.Component.Details
import TypedHtml.Component.Embedded
import TypedHtml.Component.Form
import TypedHtml.Component.Grouping
import TypedHtml.Component.Img
import TypedHtml.Component.Input
import TypedHtml.Component.Media
import TypedHtml.Component.Metadata
import TypedHtml.Component.Scripting
import TypedHtml.Component.Sectioning
import TypedHtml.Component.Select
import TypedHtml.Component.Table
import TypedHtml.Component.Text
import TypedHtml.Component.Textarea
import TypedHtml.Kind


{-| See `TypedHtml.Component.A.a`.
-}
a :
    List (Attr TypedHtml.Component.A.Attrs msg)
    -> List (Element childAccepts (TypedHtml.Component.A.ChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
a =
    TypedHtml.Component.A.a


{-| See `TypedHtml.Component.Text.abbr`.
-}
abbr :
    List (Attr TypedHtml.Component.Text.AbbrAttrs msg)
    -> List (Element TypedHtml.Component.Text.AbbrContent (TypedHtml.Component.Text.AbbrChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.AbbrIs s) admittedBy msg
abbr =
    TypedHtml.Component.Text.abbr


{-| See `TypedHtml.Component.Sectioning.address`.
-}
address :
    List (Attr TypedHtml.Component.Sectioning.AddressAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Sectioning.AddressChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Sectioning.AddressIs s) admittedBy msg
address =
    TypedHtml.Component.Sectioning.address


{-| See `TypedHtml.Component.Embedded.area`.
-}
area :
    List (Attr TypedHtml.Component.Embedded.AreaAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Embedded.AreaChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Embedded.AreaIs s) admittedBy msg
area =
    TypedHtml.Component.Embedded.area


{-| See `TypedHtml.Component.Sectioning.article`.
-}
article :
    List (Attr TypedHtml.Component.Sectioning.ArticleAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Sectioning.ArticleChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Sectioning.ArticleIs s) admittedBy msg
article =
    TypedHtml.Component.Sectioning.article


{-| See `TypedHtml.Component.Sectioning.aside`.
-}
aside :
    List (Attr TypedHtml.Component.Sectioning.AsideAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Sectioning.AsideChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Sectioning.AsideIs s) admittedBy msg
aside =
    TypedHtml.Component.Sectioning.aside


{-| See `TypedHtml.Component.Media.audio`.
-}
audio :
    List (Attr TypedHtml.Component.Media.AudioAttrs msg)
    -> List (Element TypedHtml.Component.Media.AudioContent (TypedHtml.Component.Media.AudioChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Media.AudioIs s) admittedBy msg
audio =
    TypedHtml.Component.Media.audio


{-| See `TypedHtml.Component.Text.b`.
-}
b :
    List (Attr TypedHtml.Component.Text.BAttrs msg)
    -> List (Element TypedHtml.Component.Text.BContent (TypedHtml.Component.Text.BChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.BIs s) admittedBy msg
b =
    TypedHtml.Component.Text.b


{-| See `TypedHtml.Component.Metadata.base`.
-}
base :
    List (Attr TypedHtml.Component.Metadata.BaseAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Metadata.BaseChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Metadata.BaseIs s) admittedBy msg
base =
    TypedHtml.Component.Metadata.base


{-| See `TypedHtml.Component.Text.bdi`.
-}
bdi :
    List (Attr TypedHtml.Component.Text.BdiAttrs msg)
    -> List (Element TypedHtml.Component.Text.BdiContent (TypedHtml.Component.Text.BdiChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.BdiIs s) admittedBy msg
bdi =
    TypedHtml.Component.Text.bdi


{-| See `TypedHtml.Component.Text.bdo`.
-}
bdo :
    List (Attr TypedHtml.Component.Text.BdoAttrs msg)
    -> List (Element TypedHtml.Component.Text.BdoContent (TypedHtml.Component.Text.BdoChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.BdoIs s) admittedBy msg
bdo =
    TypedHtml.Component.Text.bdo


{-| See `TypedHtml.Component.Grouping.blockquote`.
-}
blockquote :
    List (Attr TypedHtml.Component.Grouping.BlockquoteAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Grouping.BlockquoteChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Grouping.BlockquoteIs s) admittedBy msg
blockquote =
    TypedHtml.Component.Grouping.blockquote


{-| See `TypedHtml.Component.Sectioning.body`.
-}
body :
    List (Attr TypedHtml.Component.Sectioning.BodyAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Sectioning.BodyChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Sectioning.BodyIs s) admittedBy msg
body =
    TypedHtml.Component.Sectioning.body


{-| See `TypedHtml.Component.Text.br`.
-}
br :
    List (Attr TypedHtml.Component.Text.BrAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Text.BrChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.BrIs s) admittedBy msg
br =
    TypedHtml.Component.Text.br


{-| See `TypedHtml.Component.Button.button`.
-}
button :
    List (Attr TypedHtml.Component.Button.Attrs msg)
    -> List (Element TypedHtml.Component.Button.Content (TypedHtml.Component.Button.ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Button.Is s) admittedBy msg
button =
    TypedHtml.Component.Button.button


{-| See `TypedHtml.Component.Embedded.canvas`.
-}
canvas :
    List (Attr TypedHtml.Component.Embedded.CanvasAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Embedded.CanvasChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
canvas =
    TypedHtml.Component.Embedded.canvas


{-| See `TypedHtml.Component.Table.caption`.
-}
caption :
    List (Attr TypedHtml.Component.Table.CaptionAttrs msg)
    -> List (Element TypedHtml.Component.Table.CaptionContent (TypedHtml.Component.Table.CaptionChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Table.CaptionIs s) TypedHtml.Component.Table.CaptionAdmittedBy msg
caption =
    TypedHtml.Component.Table.caption


{-| See `TypedHtml.Component.Text.cite`.
-}
cite :
    List (Attr TypedHtml.Component.Text.CiteAttrs msg)
    -> List (Element TypedHtml.Component.Text.CiteContent (TypedHtml.Component.Text.CiteChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.CiteIs s) admittedBy msg
cite =
    TypedHtml.Component.Text.cite


{-| See `TypedHtml.Component.Text.code`.
-}
code :
    List (Attr TypedHtml.Component.Text.CodeAttrs msg)
    -> List (Element TypedHtml.Component.Text.CodeContent (TypedHtml.Component.Text.CodeChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.CodeIs s) admittedBy msg
code =
    TypedHtml.Component.Text.code


{-| See `TypedHtml.Component.Table.col`.
-}
col :
    List (Attr TypedHtml.Component.Table.ColAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Table.ColChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Table.ColIs s) TypedHtml.Component.Table.ColAdmittedBy msg
col =
    TypedHtml.Component.Table.col


{-| See `TypedHtml.Component.Table.colgroup`.
-}
colgroup :
    List (Attr TypedHtml.Component.Table.ColgroupAttrs msg)
    -> List (Element TypedHtml.Component.Table.ColgroupContent (TypedHtml.Component.Table.ColgroupChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Table.ColgroupIs s) TypedHtml.Component.Table.ColgroupAdmittedBy msg
colgroup =
    TypedHtml.Component.Table.colgroup


{-| See `TypedHtml.Component.Text.data`.
-}
data :
    List (Attr TypedHtml.Component.Text.DataAttrs msg)
    -> List (Element TypedHtml.Component.Text.DataContent (TypedHtml.Component.Text.DataChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.DataIs s) admittedBy msg
data =
    TypedHtml.Component.Text.data


{-| See `TypedHtml.Component.Select.datalist`.
-}
datalist :
    List (Attr TypedHtml.Component.Select.DatalistAttrs msg)
    -> List (Element TypedHtml.Component.Select.DatalistContent (TypedHtml.Component.Select.DatalistChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Select.DatalistIs s) admittedBy msg
datalist =
    TypedHtml.Component.Select.datalist


{-| See `TypedHtml.Component.Grouping.dd`.
-}
dd :
    List (Attr TypedHtml.Component.Grouping.DdAttrs msg)
    -> List (Element TypedHtml.Component.Grouping.DdContent (TypedHtml.Component.Grouping.DdChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Grouping.DdIs s) TypedHtml.Component.Grouping.DdAdmittedBy msg
dd =
    TypedHtml.Component.Grouping.dd


{-| See `TypedHtml.Component.Text.del`.
-}
del :
    List (Attr TypedHtml.Component.Text.DelAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Text.DelChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
del =
    TypedHtml.Component.Text.del


{-| See `TypedHtml.Component.Details.details`.
-}
details :
    List (Attr TypedHtml.Component.Details.DetailsAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Details.DetailsChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Details.DetailsIs s) admittedBy msg
details =
    TypedHtml.Component.Details.details


{-| See `TypedHtml.Component.Text.dfn`.
-}
dfn :
    List (Attr TypedHtml.Component.Text.DfnAttrs msg)
    -> List (Element TypedHtml.Component.Text.DfnContent (TypedHtml.Component.Text.DfnChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.DfnIs s) admittedBy msg
dfn =
    TypedHtml.Component.Text.dfn


{-| See `TypedHtml.Component.Grouping.dialog`.
-}
dialog :
    List (Attr TypedHtml.Component.Grouping.DialogAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Grouping.DialogChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Grouping.DialogIs s) admittedBy msg
dialog =
    TypedHtml.Component.Grouping.dialog


{-| See `TypedHtml.Component.Grouping.div`.
-}
div :
    List (Attr TypedHtml.Component.Grouping.DivAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Grouping.DivChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Grouping.DivIs s) admittedBy msg
div =
    TypedHtml.Component.Grouping.div


{-| See `TypedHtml.Component.Grouping.dl`.
-}
dl :
    List (Attr TypedHtml.Component.Grouping.DlAttrs msg)
    -> List (Element TypedHtml.Component.Grouping.DlContent (TypedHtml.Component.Grouping.DlChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Grouping.DlIs s) admittedBy msg
dl =
    TypedHtml.Component.Grouping.dl


{-| See `TypedHtml.Component.Grouping.dt`.
-}
dt :
    List (Attr TypedHtml.Component.Grouping.DtAttrs msg)
    -> List (Element TypedHtml.Component.Grouping.DtContent (TypedHtml.Component.Grouping.DtChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Grouping.DtIs s) TypedHtml.Component.Grouping.DtAdmittedBy msg
dt =
    TypedHtml.Component.Grouping.dt


{-| See `TypedHtml.Component.Text.em`.
-}
em :
    List (Attr TypedHtml.Component.Text.EmAttrs msg)
    -> List (Element TypedHtml.Component.Text.EmContent (TypedHtml.Component.Text.EmChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.EmIs s) admittedBy msg
em =
    TypedHtml.Component.Text.em


{-| See `TypedHtml.Component.Embedded.embed`.
-}
embed :
    List (Attr TypedHtml.Component.Embedded.EmbedAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Embedded.EmbedChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Embedded.EmbedIs s) admittedBy msg
embed =
    TypedHtml.Component.Embedded.embed


{-| See `TypedHtml.Component.Form.fieldset`.
-}
fieldset :
    List (Attr TypedHtml.Component.Form.FieldsetAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Form.FieldsetChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Form.FieldsetIs s) admittedBy msg
fieldset =
    TypedHtml.Component.Form.fieldset


{-| See `TypedHtml.Component.Grouping.figcaption`.
-}
figcaption :
    List (Attr TypedHtml.Component.Grouping.FigcaptionAttrs msg)
    -> List (Element TypedHtml.Component.Grouping.FigcaptionContent (TypedHtml.Component.Grouping.FigcaptionChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Grouping.FigcaptionIs s) TypedHtml.Component.Grouping.FigcaptionAdmittedBy msg
figcaption =
    TypedHtml.Component.Grouping.figcaption


{-| See `TypedHtml.Component.Grouping.figure`.
-}
figure :
    List (Attr TypedHtml.Component.Grouping.FigureAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Grouping.FigureChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Grouping.FigureIs s) admittedBy msg
figure =
    TypedHtml.Component.Grouping.figure


{-| See `TypedHtml.Component.Sectioning.footer`.
-}
footer :
    List (Attr TypedHtml.Component.Sectioning.FooterAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Sectioning.FooterChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Sectioning.FooterIs s) admittedBy msg
footer =
    TypedHtml.Component.Sectioning.footer


{-| See `TypedHtml.Component.Form.form`.
-}
form :
    List (Attr TypedHtml.Component.Form.FormAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Form.FormChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Form.FormIs s) admittedBy msg
form =
    TypedHtml.Component.Form.form


{-| See `TypedHtml.Component.Sectioning.h1`.
-}
h1 :
    List (Attr TypedHtml.Component.Sectioning.H1Attrs msg)
    -> List (Element TypedHtml.Component.Sectioning.H1Content (TypedHtml.Component.Sectioning.H1ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Sectioning.H1Is s) admittedBy msg
h1 =
    TypedHtml.Component.Sectioning.h1


{-| See `TypedHtml.Component.Sectioning.h2`.
-}
h2 :
    List (Attr TypedHtml.Component.Sectioning.H2Attrs msg)
    -> List (Element TypedHtml.Component.Sectioning.H2Content (TypedHtml.Component.Sectioning.H2ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Sectioning.H2Is s) admittedBy msg
h2 =
    TypedHtml.Component.Sectioning.h2


{-| See `TypedHtml.Component.Sectioning.h3`.
-}
h3 :
    List (Attr TypedHtml.Component.Sectioning.H3Attrs msg)
    -> List (Element TypedHtml.Component.Sectioning.H3Content (TypedHtml.Component.Sectioning.H3ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Sectioning.H3Is s) admittedBy msg
h3 =
    TypedHtml.Component.Sectioning.h3


{-| See `TypedHtml.Component.Sectioning.h4`.
-}
h4 :
    List (Attr TypedHtml.Component.Sectioning.H4Attrs msg)
    -> List (Element TypedHtml.Component.Sectioning.H4Content (TypedHtml.Component.Sectioning.H4ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Sectioning.H4Is s) admittedBy msg
h4 =
    TypedHtml.Component.Sectioning.h4


{-| See `TypedHtml.Component.Sectioning.h5`.
-}
h5 :
    List (Attr TypedHtml.Component.Sectioning.H5Attrs msg)
    -> List (Element TypedHtml.Component.Sectioning.H5Content (TypedHtml.Component.Sectioning.H5ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Sectioning.H5Is s) admittedBy msg
h5 =
    TypedHtml.Component.Sectioning.h5


{-| See `TypedHtml.Component.Sectioning.h6`.
-}
h6 :
    List (Attr TypedHtml.Component.Sectioning.H6Attrs msg)
    -> List (Element TypedHtml.Component.Sectioning.H6Content (TypedHtml.Component.Sectioning.H6ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Sectioning.H6Is s) admittedBy msg
h6 =
    TypedHtml.Component.Sectioning.h6


{-| See `TypedHtml.Component.Metadata.head`.
-}
head :
    List (Attr TypedHtml.Component.Metadata.HeadAttrs msg)
    -> List (Element TypedHtml.Kind.Metadata (TypedHtml.Component.Metadata.HeadChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Metadata.HeadIs s) admittedBy msg
head =
    TypedHtml.Component.Metadata.head


{-| See `TypedHtml.Component.Sectioning.header`.
-}
header :
    List (Attr TypedHtml.Component.Sectioning.HeaderAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Sectioning.HeaderChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Sectioning.HeaderIs s) admittedBy msg
header =
    TypedHtml.Component.Sectioning.header


{-| See `TypedHtml.Component.Sectioning.hgroup`.
-}
hgroup :
    List (Attr TypedHtml.Component.Sectioning.HgroupAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Sectioning.HgroupChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Sectioning.HgroupIs s) admittedBy msg
hgroup =
    TypedHtml.Component.Sectioning.hgroup


{-| See `TypedHtml.Component.Grouping.hr`.
-}
hr :
    List (Attr TypedHtml.Component.Grouping.HrAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Grouping.HrChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Grouping.HrIs s) admittedBy msg
hr =
    TypedHtml.Component.Grouping.hr


{-| See `TypedHtml.Component.Text.i`.
-}
i :
    List (Attr TypedHtml.Component.Text.IAttrs msg)
    -> List (Element TypedHtml.Component.Text.IContent (TypedHtml.Component.Text.IChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.IIs s) admittedBy msg
i =
    TypedHtml.Component.Text.i


{-| See `TypedHtml.Component.Embedded.iframe`.
-}
iframe :
    List (Attr TypedHtml.Component.Embedded.IframeAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Embedded.IframeChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Embedded.IframeIs s) admittedBy msg
iframe =
    TypedHtml.Component.Embedded.iframe


{-| See `TypedHtml.Component.Img.img`.
-}
img :
    List (Attr TypedHtml.Component.Img.Attrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Img.ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Img.Is s) admittedBy msg
img =
    TypedHtml.Component.Img.img


{-| See `TypedHtml.Component.Input.input`.
-}
input :
    List (Attr TypedHtml.Component.Input.Attrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Input.ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Input.Is s) admittedBy msg
input =
    TypedHtml.Component.Input.input


{-| See `TypedHtml.Component.Text.ins`.
-}
ins :
    List (Attr TypedHtml.Component.Text.InsAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Text.InsChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
ins =
    TypedHtml.Component.Text.ins


{-| See `TypedHtml.Component.Text.kbd`.
-}
kbd :
    List (Attr TypedHtml.Component.Text.KbdAttrs msg)
    -> List (Element TypedHtml.Component.Text.KbdContent (TypedHtml.Component.Text.KbdChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.KbdIs s) admittedBy msg
kbd =
    TypedHtml.Component.Text.kbd


{-| See `TypedHtml.Component.Form.label`.
-}
label :
    List (Attr TypedHtml.Component.Form.LabelAttrs msg)
    -> List (Element TypedHtml.Component.Form.LabelContent (TypedHtml.Component.Form.LabelChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Form.LabelIs s) admittedBy msg
label =
    TypedHtml.Component.Form.label


{-| See `TypedHtml.Component.Form.legend`.
-}
legend :
    List (Attr TypedHtml.Component.Form.LegendAttrs msg)
    -> List (Element TypedHtml.Component.Form.LegendContent (TypedHtml.Component.Form.LegendChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Form.LegendIs s) TypedHtml.Component.Form.LegendAdmittedBy msg
legend =
    TypedHtml.Component.Form.legend


{-| See `TypedHtml.Component.Grouping.li`.
-}
li :
    List (Attr TypedHtml.Component.Grouping.LiAttrs msg)
    -> List (Element TypedHtml.Component.Grouping.LiContent (TypedHtml.Component.Grouping.LiChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Grouping.LiIs s) TypedHtml.Component.Grouping.LiAdmittedBy msg
li =
    TypedHtml.Component.Grouping.li


{-| See `TypedHtml.Component.Metadata.link`.
-}
link :
    List (Attr TypedHtml.Component.Metadata.LinkAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Metadata.LinkChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Metadata.LinkIs s) admittedBy msg
link =
    TypedHtml.Component.Metadata.link


{-| See `TypedHtml.Component.Sectioning.main_`.
-}
main_ :
    List (Attr TypedHtml.Component.Sectioning.MainAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Sectioning.MainChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Sectioning.MainIs s) admittedBy msg
main_ =
    TypedHtml.Component.Sectioning.main_


{-| See `TypedHtml.Component.Embedded.map`.
-}
map :
    List (Attr TypedHtml.Component.Embedded.MapAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Embedded.MapChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
map =
    TypedHtml.Component.Embedded.map


{-| See `TypedHtml.Component.Text.mark`.
-}
mark :
    List (Attr TypedHtml.Component.Text.MarkAttrs msg)
    -> List (Element TypedHtml.Component.Text.MarkContent (TypedHtml.Component.Text.MarkChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.MarkIs s) admittedBy msg
mark =
    TypedHtml.Component.Text.mark


{-| See `TypedHtml.Component.Grouping.menu`.
-}
menu :
    List (Attr TypedHtml.Component.Grouping.MenuAttrs msg)
    -> List (Element TypedHtml.Component.Grouping.MenuContent (TypedHtml.Component.Grouping.MenuChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Grouping.MenuIs s) admittedBy msg
menu =
    TypedHtml.Component.Grouping.menu


{-| See `TypedHtml.Component.Metadata.meta`.
-}
meta :
    List (Attr TypedHtml.Component.Metadata.MetaAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Metadata.MetaChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Metadata.MetaIs s) admittedBy msg
meta =
    TypedHtml.Component.Metadata.meta


{-| See `TypedHtml.Component.Text.meter`.
-}
meter :
    List (Attr TypedHtml.Component.Text.MeterAttrs msg)
    -> List (Element TypedHtml.Component.Text.MeterContent (TypedHtml.Component.Text.MeterChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.MeterIs s) admittedBy msg
meter =
    TypedHtml.Component.Text.meter


{-| See `TypedHtml.Component.Sectioning.nav`.
-}
nav :
    List (Attr TypedHtml.Component.Sectioning.NavAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Sectioning.NavChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Sectioning.NavIs s) admittedBy msg
nav =
    TypedHtml.Component.Sectioning.nav


{-| See `TypedHtml.Component.Scripting.noscript`.
-}
noscript :
    List (Attr TypedHtml.Component.Scripting.NoscriptAttrs msg)
    -> List (Element TypedHtml.Component.Scripting.NoscriptContent (TypedHtml.Component.Scripting.NoscriptChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Scripting.NoscriptIs s) admittedBy msg
noscript =
    TypedHtml.Component.Scripting.noscript


{-| See `TypedHtml.Component.Embedded.object`.
-}
object :
    List (Attr TypedHtml.Component.Embedded.ObjectAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Embedded.ObjectChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
object =
    TypedHtml.Component.Embedded.object


{-| See `TypedHtml.Component.Grouping.ol`.
-}
ol :
    List (Attr TypedHtml.Component.Grouping.OlAttrs msg)
    -> List (Element TypedHtml.Component.Grouping.OlContent (TypedHtml.Component.Grouping.OlChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Grouping.OlIs s) admittedBy msg
ol =
    TypedHtml.Component.Grouping.ol


{-| See `TypedHtml.Component.Select.optgroup`.
-}
optgroup :
    List (Attr TypedHtml.Component.Select.OptgroupAttrs msg)
    -> List (Element TypedHtml.Component.Select.OptgroupContent (TypedHtml.Component.Select.OptgroupChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Select.OptgroupIs s) TypedHtml.Component.Select.OptgroupAdmittedBy msg
optgroup =
    TypedHtml.Component.Select.optgroup


{-| See `TypedHtml.Component.Select.option`.
-}
option :
    List (Attr TypedHtml.Component.Select.OptionAttrs msg)
    -> List (Element TypedHtml.Component.Select.OptionContent (TypedHtml.Component.Select.OptionChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Select.OptionIs s) TypedHtml.Component.Select.OptionAdmittedBy msg
option =
    TypedHtml.Component.Select.option


{-| See `TypedHtml.Component.Form.output`.
-}
output :
    List (Attr TypedHtml.Component.Form.OutputAttrs msg)
    -> List (Element TypedHtml.Component.Form.OutputContent (TypedHtml.Component.Form.OutputChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Form.OutputIs s) admittedBy msg
output =
    TypedHtml.Component.Form.output


{-| See `TypedHtml.Component.Grouping.p`.
-}
p :
    List (Attr TypedHtml.Component.Grouping.PAttrs msg)
    -> List (Element TypedHtml.Component.Grouping.PContent (TypedHtml.Component.Grouping.PChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Grouping.PIs s) admittedBy msg
p =
    TypedHtml.Component.Grouping.p


{-| See `TypedHtml.Component.Media.picture`.
-}
picture :
    List (Attr TypedHtml.Component.Media.PictureAttrs msg)
    -> List (Element TypedHtml.Component.Media.PictureContent (TypedHtml.Component.Media.PictureChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Media.PictureIs s) admittedBy msg
picture =
    TypedHtml.Component.Media.picture


{-| See `TypedHtml.Component.Media.pictureSource`.
-}
pictureSource :
    List (Attr TypedHtml.Component.Media.PictureSourceAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Media.PictureSourceChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Media.PictureSourceIs s) TypedHtml.Component.Media.PictureSourceAdmittedBy msg
pictureSource =
    TypedHtml.Component.Media.pictureSource


{-| See `TypedHtml.Component.Grouping.pre`.
-}
pre :
    List (Attr TypedHtml.Component.Grouping.PreAttrs msg)
    -> List (Element TypedHtml.Component.Grouping.PreContent (TypedHtml.Component.Grouping.PreChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Grouping.PreIs s) admittedBy msg
pre =
    TypedHtml.Component.Grouping.pre


{-| See `TypedHtml.Component.Text.progress`.
-}
progress :
    List (Attr TypedHtml.Component.Text.ProgressAttrs msg)
    -> List (Element TypedHtml.Component.Text.ProgressContent (TypedHtml.Component.Text.ProgressChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.ProgressIs s) admittedBy msg
progress =
    TypedHtml.Component.Text.progress


{-| See `TypedHtml.Component.Text.q`.
-}
q :
    List (Attr TypedHtml.Component.Text.QAttrs msg)
    -> List (Element TypedHtml.Component.Text.QContent (TypedHtml.Component.Text.QChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.QIs s) admittedBy msg
q =
    TypedHtml.Component.Text.q


{-| See `TypedHtml.Component.Text.rp`.
-}
rp :
    List (Attr TypedHtml.Component.Text.RpAttrs msg)
    -> List (Element TypedHtml.Component.Text.RpContent (TypedHtml.Component.Text.RpChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.RpIs s) TypedHtml.Component.Text.RpAdmittedBy msg
rp =
    TypedHtml.Component.Text.rp


{-| See `TypedHtml.Component.Text.rt`.
-}
rt :
    List (Attr TypedHtml.Component.Text.RtAttrs msg)
    -> List (Element TypedHtml.Component.Text.RtContent (TypedHtml.Component.Text.RtChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.RtIs s) TypedHtml.Component.Text.RtAdmittedBy msg
rt =
    TypedHtml.Component.Text.rt


{-| See `TypedHtml.Component.Text.ruby`.
-}
ruby :
    List (Attr TypedHtml.Component.Text.RubyAttrs msg)
    -> List (Element TypedHtml.Component.Text.RubyContent (TypedHtml.Component.Text.RubyChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.RubyIs s) admittedBy msg
ruby =
    TypedHtml.Component.Text.ruby


{-| See `TypedHtml.Component.Text.s`.
-}
s :
    List (Attr TypedHtml.Component.Text.SAttrs msg)
    -> List (Element TypedHtml.Component.Text.SContent (TypedHtml.Component.Text.SChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.SIs s) admittedBy msg
s =
    TypedHtml.Component.Text.s


{-| See `TypedHtml.Component.Text.samp`.
-}
samp :
    List (Attr TypedHtml.Component.Text.SampAttrs msg)
    -> List (Element TypedHtml.Component.Text.SampContent (TypedHtml.Component.Text.SampChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.SampIs s) admittedBy msg
samp =
    TypedHtml.Component.Text.samp


{-| See `TypedHtml.Component.Scripting.script`.
-}
script :
    List (Attr TypedHtml.Component.Scripting.ScriptAttrs msg)
    -> List (Element TypedHtml.Component.Scripting.ScriptContent (TypedHtml.Component.Scripting.ScriptChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Scripting.ScriptIs s) admittedBy msg
script =
    TypedHtml.Component.Scripting.script


{-| See `TypedHtml.Component.Sectioning.search`.
-}
search :
    List (Attr TypedHtml.Component.Sectioning.SearchAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Sectioning.SearchChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Sectioning.SearchIs s) admittedBy msg
search =
    TypedHtml.Component.Sectioning.search


{-| See `TypedHtml.Component.Sectioning.section`.
-}
section :
    List (Attr TypedHtml.Component.Sectioning.SectionAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Sectioning.SectionChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Sectioning.SectionIs s) admittedBy msg
section =
    TypedHtml.Component.Sectioning.section


{-| See `TypedHtml.Component.Select.select`.
-}
select :
    List (Attr TypedHtml.Component.Select.SelectAttrs msg)
    -> List (Element TypedHtml.Component.Select.SelectContent (TypedHtml.Component.Select.SelectChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Select.SelectIs s) admittedBy msg
select =
    TypedHtml.Component.Select.select


{-| See `TypedHtml.Component.Scripting.slot`.
-}
slot :
    List (Attr TypedHtml.Component.Scripting.SlotAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Scripting.SlotChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
slot =
    TypedHtml.Component.Scripting.slot


{-| See `TypedHtml.Component.Text.small`.
-}
small :
    List (Attr TypedHtml.Component.Text.SmallAttrs msg)
    -> List (Element TypedHtml.Component.Text.SmallContent (TypedHtml.Component.Text.SmallChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.SmallIs s) admittedBy msg
small =
    TypedHtml.Component.Text.small


{-| See `TypedHtml.Component.Media.source`.
-}
source :
    List (Attr TypedHtml.Component.Media.SourceAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Media.SourceChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Media.SourceIs s) TypedHtml.Component.Media.SourceAdmittedBy msg
source =
    TypedHtml.Component.Media.source


{-| See `TypedHtml.Component.Text.span`.
-}
span :
    List (Attr TypedHtml.Component.Text.SpanAttrs msg)
    -> List (Element TypedHtml.Component.Text.SpanContent (TypedHtml.Component.Text.SpanChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.SpanIs s) admittedBy msg
span =
    TypedHtml.Component.Text.span


{-| See `TypedHtml.Component.Text.strong`.
-}
strong :
    List (Attr TypedHtml.Component.Text.StrongAttrs msg)
    -> List (Element TypedHtml.Component.Text.StrongContent (TypedHtml.Component.Text.StrongChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.StrongIs s) admittedBy msg
strong =
    TypedHtml.Component.Text.strong


{-| See `TypedHtml.Component.Metadata.style`.
-}
style :
    List (Attr TypedHtml.Component.Metadata.StyleAttrs msg)
    -> List (Element TypedHtml.Component.Metadata.StyleContent (TypedHtml.Component.Metadata.StyleChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Metadata.StyleIs s) admittedBy msg
style =
    TypedHtml.Component.Metadata.style


{-| See `TypedHtml.Component.Text.sub`.
-}
sub :
    List (Attr TypedHtml.Component.Text.SubAttrs msg)
    -> List (Element TypedHtml.Component.Text.SubContent (TypedHtml.Component.Text.SubChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.SubIs s) admittedBy msg
sub =
    TypedHtml.Component.Text.sub


{-| See `TypedHtml.Component.Details.summary`.
-}
summary :
    List (Attr TypedHtml.Component.Details.SummaryAttrs msg)
    -> List (Element TypedHtml.Component.Details.SummaryContent (TypedHtml.Component.Details.SummaryChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Details.SummaryIs s) TypedHtml.Component.Details.SummaryAdmittedBy msg
summary =
    TypedHtml.Component.Details.summary


{-| See `TypedHtml.Component.Text.sup`.
-}
sup :
    List (Attr TypedHtml.Component.Text.SupAttrs msg)
    -> List (Element TypedHtml.Component.Text.SupContent (TypedHtml.Component.Text.SupChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.SupIs s) admittedBy msg
sup =
    TypedHtml.Component.Text.sup


{-| See `TypedHtml.Component.Table.table`.
-}
table :
    List (Attr TypedHtml.Component.Table.TableAttrs msg)
    -> List (Element TypedHtml.Component.Table.TableContent (TypedHtml.Component.Table.TableChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Table.TableIs s) admittedBy msg
table =
    TypedHtml.Component.Table.table


{-| See `TypedHtml.Component.Table.tbody`.
-}
tbody :
    List (Attr TypedHtml.Component.Table.TbodyAttrs msg)
    -> List (Element TypedHtml.Component.Table.TbodyContent (TypedHtml.Component.Table.TbodyChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Table.TbodyIs s) TypedHtml.Component.Table.TbodyAdmittedBy msg
tbody =
    TypedHtml.Component.Table.tbody


{-| See `TypedHtml.Component.Table.td`.
-}
td :
    List (Attr TypedHtml.Component.Table.TdAttrs msg)
    -> List (Element TypedHtml.Component.Table.TdContent (TypedHtml.Component.Table.TdChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Table.TdIs s) TypedHtml.Component.Table.TdAdmittedBy msg
td =
    TypedHtml.Component.Table.td


{-| See `TypedHtml.Component.Scripting.template`.
-}
template :
    List (Attr TypedHtml.Component.Scripting.TemplateAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Scripting.TemplateChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Scripting.TemplateIs s) admittedBy msg
template =
    TypedHtml.Component.Scripting.template


{-| See `TypedHtml.Component.Textarea.textarea`.
-}
textarea :
    List (Attr TypedHtml.Component.Textarea.Attrs msg)
    -> List (Element TypedHtml.Component.Textarea.Content (TypedHtml.Component.Textarea.ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Textarea.Is s) admittedBy msg
textarea =
    TypedHtml.Component.Textarea.textarea


{-| See `TypedHtml.Component.Table.tfoot`.
-}
tfoot :
    List (Attr TypedHtml.Component.Table.TfootAttrs msg)
    -> List (Element TypedHtml.Component.Table.TfootContent (TypedHtml.Component.Table.TfootChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Table.TfootIs s) TypedHtml.Component.Table.TfootAdmittedBy msg
tfoot =
    TypedHtml.Component.Table.tfoot


{-| See `TypedHtml.Component.Table.th`.
-}
th :
    List (Attr TypedHtml.Component.Table.ThAttrs msg)
    -> List (Element TypedHtml.Component.Table.ThContent (TypedHtml.Component.Table.ThChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Table.ThIs s) TypedHtml.Component.Table.ThAdmittedBy msg
th =
    TypedHtml.Component.Table.th


{-| See `TypedHtml.Component.Table.thead`.
-}
thead :
    List (Attr TypedHtml.Component.Table.TheadAttrs msg)
    -> List (Element TypedHtml.Component.Table.TheadContent (TypedHtml.Component.Table.TheadChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Table.TheadIs s) TypedHtml.Component.Table.TheadAdmittedBy msg
thead =
    TypedHtml.Component.Table.thead


{-| See `TypedHtml.Component.Text.time`.
-}
time :
    List (Attr TypedHtml.Component.Text.TimeAttrs msg)
    -> List (Element TypedHtml.Component.Text.TimeContent (TypedHtml.Component.Text.TimeChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.TimeIs s) admittedBy msg
time =
    TypedHtml.Component.Text.time


{-| See `TypedHtml.Component.Metadata.title`.
-}
title :
    List (Attr TypedHtml.Component.Metadata.TitleAttrs msg)
    -> List (Element TypedHtml.Component.Metadata.TitleContent (TypedHtml.Component.Metadata.TitleChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Metadata.TitleIs s) admittedBy msg
title =
    TypedHtml.Component.Metadata.title


{-| See `TypedHtml.Component.Table.tr`.
-}
tr :
    List (Attr TypedHtml.Component.Table.TrAttrs msg)
    -> List (Element TypedHtml.Component.Table.TrContent (TypedHtml.Component.Table.TrChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Table.TrIs s) TypedHtml.Component.Table.TrAdmittedBy msg
tr =
    TypedHtml.Component.Table.tr


{-| See `TypedHtml.Component.Media.track`.
-}
track :
    List (Attr TypedHtml.Component.Media.TrackAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Media.TrackChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Media.TrackIs s) TypedHtml.Component.Media.TrackAdmittedBy msg
track =
    TypedHtml.Component.Media.track


{-| See `TypedHtml.Component.Text.u`.
-}
u :
    List (Attr TypedHtml.Component.Text.UAttrs msg)
    -> List (Element TypedHtml.Component.Text.UContent (TypedHtml.Component.Text.UChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.UIs s) admittedBy msg
u =
    TypedHtml.Component.Text.u


{-| See `TypedHtml.Component.Grouping.ul`.
-}
ul :
    List (Attr TypedHtml.Component.Grouping.UlAttrs msg)
    -> List (Element TypedHtml.Component.Grouping.UlContent (TypedHtml.Component.Grouping.UlChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Grouping.UlIs s) admittedBy msg
ul =
    TypedHtml.Component.Grouping.ul


{-| See `TypedHtml.Component.Text.var`.
-}
var :
    List (Attr TypedHtml.Component.Text.VarAttrs msg)
    -> List (Element TypedHtml.Component.Text.VarContent (TypedHtml.Component.Text.VarChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.VarIs s) admittedBy msg
var =
    TypedHtml.Component.Text.var


{-| See `TypedHtml.Component.Media.video`.
-}
video :
    List (Attr TypedHtml.Component.Media.VideoAttrs msg)
    -> List (Element TypedHtml.Component.Media.VideoContent (TypedHtml.Component.Media.VideoChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Media.VideoIs s) admittedBy msg
video =
    TypedHtml.Component.Media.video


{-| See `TypedHtml.Component.Text.wbr`.
-}
wbr :
    List (Attr TypedHtml.Component.Text.WbrAttrs msg)
    -> List (Element childAccepts (TypedHtml.Component.Text.WbrChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Text.WbrIs s) admittedBy msg
wbr =
    TypedHtml.Component.Text.wbr


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
