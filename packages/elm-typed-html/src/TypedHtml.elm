module TypedHtml exposing
    ( a, abbr, address, area, article, aside, audio, b, base, bdi, bdo, blockquote, body, br, button, canvas, caption, cite, code, col, colgroup, data, datalist, dd, del, details, dfn, dialog, div, dl, dt, em, embed, fieldset, figcaption, figure, footer, form, h1, h2, h3, h4, h5, h6, head, header, hgroup, hr, i, iframe, img, input, ins, kbd, label, legend, li, link, main_, map, mark, menu, meta, meter, nav, noscript, object, ol, optgroup, option, output, p, picture, pictureSource, pre, progress, q, rp, rt, ruby, s, samp, script, search, section, select, slot, small, source, span, strong, style, sub, summary, sup, table, tbody, td, template, textarea, tfoot, th, thead, time, title, tr, track, u, ul, var, video, wbr
    , text
    , Element, Attr, Node, toHtml, toNode, mapMsg, mapNode
    )

{-| The general surface: every component constructor in the elm/html call
shape, one import. Signatures reference each component's aliases — reach for
`TypedHtml.<Component>` when you want the strict per-component surface (required
content, builder, narrowed values), and `TypedHtml.Attributes` / `TypedHtml.Events` /
`TypedHtml.Values` for the shared vocabulary.

`toHtml` is the render bridge to `elm/html`.

@docs a, abbr, address, area, article, aside, audio, b, base, bdi, bdo, blockquote, body, br, button, canvas, caption, cite, code, col, colgroup, data, datalist, dd, del, details, dfn, dialog, div, dl, dt, em, embed, fieldset, figcaption, figure, footer, form, h1, h2, h3, h4, h5, h6, head, header, hgroup, hr, i, iframe, img, input, ins, kbd, label, legend, li, link, main_, map, mark, menu, meta, meter, nav, noscript, object, ol, optgroup, option, output, p, picture, pictureSource, pre, progress, q, rp, rt, ruby, s, samp, script, search, section, select, slot, small, source, span, strong, style, sub, summary, sup, table, tbody, td, template, textarea, tfoot, th, thead, time, title, tr, track, u, ul, var, video, wbr
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
import TypedHtml.Button
import TypedHtml.Details
import TypedHtml.Embedded
import TypedHtml.Form
import TypedHtml.Grouping
import TypedHtml.Img
import TypedHtml.Input
import TypedHtml.Kind
import TypedHtml.Media
import TypedHtml.Metadata
import TypedHtml.Scripting
import TypedHtml.Sectioning
import TypedHtml.Select
import TypedHtml.Table
import TypedHtml.Text
import TypedHtml.Textarea


{-| See `TypedHtml.A.a`.
-}
a :
    List (Attr TypedHtml.A.Attrs msg)
    -> List (Element childAccepts (TypedHtml.A.ChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
a =
    TypedHtml.A.a


{-| See `TypedHtml.Text.abbr`.
-}
abbr :
    List (Attr TypedHtml.Text.AbbrAttrs msg)
    -> List (Element TypedHtml.Text.AbbrContent (TypedHtml.Text.AbbrChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.AbbrIs s) admittedBy msg
abbr =
    TypedHtml.Text.abbr


{-| See `TypedHtml.Sectioning.address`.
-}
address :
    List (Attr TypedHtml.Sectioning.AddressAttrs msg)
    -> List (Element childAccepts (TypedHtml.Sectioning.AddressChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Sectioning.AddressIs s) admittedBy msg
address =
    TypedHtml.Sectioning.address


{-| See `TypedHtml.Embedded.area`.
-}
area :
    List (Attr TypedHtml.Embedded.AreaAttrs msg)
    -> List (Element childAccepts (TypedHtml.Embedded.AreaChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Embedded.AreaIs s) admittedBy msg
area =
    TypedHtml.Embedded.area


{-| See `TypedHtml.Sectioning.article`.
-}
article :
    List (Attr TypedHtml.Sectioning.ArticleAttrs msg)
    -> List (Element childAccepts (TypedHtml.Sectioning.ArticleChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Sectioning.ArticleIs s) admittedBy msg
article =
    TypedHtml.Sectioning.article


{-| See `TypedHtml.Sectioning.aside`.
-}
aside :
    List (Attr TypedHtml.Sectioning.AsideAttrs msg)
    -> List (Element childAccepts (TypedHtml.Sectioning.AsideChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Sectioning.AsideIs s) admittedBy msg
aside =
    TypedHtml.Sectioning.aside


{-| See `TypedHtml.Media.audio`.
-}
audio :
    List (Attr TypedHtml.Media.AudioAttrs msg)
    -> List (Element TypedHtml.Media.AudioContent (TypedHtml.Media.AudioChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Media.AudioIs s) admittedBy msg
audio =
    TypedHtml.Media.audio


{-| See `TypedHtml.Text.b`.
-}
b :
    List (Attr TypedHtml.Text.BAttrs msg)
    -> List (Element TypedHtml.Text.BContent (TypedHtml.Text.BChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.BIs s) admittedBy msg
b =
    TypedHtml.Text.b


{-| See `TypedHtml.Metadata.base`.
-}
base :
    List (Attr TypedHtml.Metadata.BaseAttrs msg)
    -> List (Element childAccepts (TypedHtml.Metadata.BaseChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Metadata.BaseIs s) admittedBy msg
base =
    TypedHtml.Metadata.base


{-| See `TypedHtml.Text.bdi`.
-}
bdi :
    List (Attr TypedHtml.Text.BdiAttrs msg)
    -> List (Element TypedHtml.Text.BdiContent (TypedHtml.Text.BdiChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.BdiIs s) admittedBy msg
bdi =
    TypedHtml.Text.bdi


{-| See `TypedHtml.Text.bdo`.
-}
bdo :
    List (Attr TypedHtml.Text.BdoAttrs msg)
    -> List (Element TypedHtml.Text.BdoContent (TypedHtml.Text.BdoChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.BdoIs s) admittedBy msg
bdo =
    TypedHtml.Text.bdo


{-| See `TypedHtml.Grouping.blockquote`.
-}
blockquote :
    List (Attr TypedHtml.Grouping.BlockquoteAttrs msg)
    -> List (Element childAccepts (TypedHtml.Grouping.BlockquoteChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Grouping.BlockquoteIs s) admittedBy msg
blockquote =
    TypedHtml.Grouping.blockquote


{-| See `TypedHtml.Sectioning.body`.
-}
body :
    List (Attr TypedHtml.Sectioning.BodyAttrs msg)
    -> List (Element childAccepts (TypedHtml.Sectioning.BodyChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Sectioning.BodyIs s) admittedBy msg
body =
    TypedHtml.Sectioning.body


{-| See `TypedHtml.Text.br`.
-}
br :
    List (Attr TypedHtml.Text.BrAttrs msg)
    -> List (Element childAccepts (TypedHtml.Text.BrChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.BrIs s) admittedBy msg
br =
    TypedHtml.Text.br


{-| See `TypedHtml.Button.button`.
-}
button :
    List (Attr TypedHtml.Button.Attrs msg)
    -> List (Element TypedHtml.Button.Content (TypedHtml.Button.ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Button.Is s) admittedBy msg
button =
    TypedHtml.Button.button


{-| See `TypedHtml.Embedded.canvas`.
-}
canvas :
    List (Attr TypedHtml.Embedded.CanvasAttrs msg)
    -> List (Element childAccepts (TypedHtml.Embedded.CanvasChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
canvas =
    TypedHtml.Embedded.canvas


{-| See `TypedHtml.Table.caption`.
-}
caption :
    List (Attr TypedHtml.Table.CaptionAttrs msg)
    -> List (Element TypedHtml.Table.CaptionContent (TypedHtml.Table.CaptionChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Table.CaptionIs s) TypedHtml.Table.CaptionAdmittedBy msg
caption =
    TypedHtml.Table.caption


{-| See `TypedHtml.Text.cite`.
-}
cite :
    List (Attr TypedHtml.Text.CiteAttrs msg)
    -> List (Element TypedHtml.Text.CiteContent (TypedHtml.Text.CiteChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.CiteIs s) admittedBy msg
cite =
    TypedHtml.Text.cite


{-| See `TypedHtml.Text.code`.
-}
code :
    List (Attr TypedHtml.Text.CodeAttrs msg)
    -> List (Element TypedHtml.Text.CodeContent (TypedHtml.Text.CodeChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.CodeIs s) admittedBy msg
code =
    TypedHtml.Text.code


{-| See `TypedHtml.Table.col`.
-}
col :
    List (Attr TypedHtml.Table.ColAttrs msg)
    -> List (Element childAccepts (TypedHtml.Table.ColChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Table.ColIs s) TypedHtml.Table.ColAdmittedBy msg
col =
    TypedHtml.Table.col


{-| See `TypedHtml.Table.colgroup`.
-}
colgroup :
    List (Attr TypedHtml.Table.ColgroupAttrs msg)
    -> List (Element TypedHtml.Table.ColgroupContent (TypedHtml.Table.ColgroupChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Table.ColgroupIs s) TypedHtml.Table.ColgroupAdmittedBy msg
colgroup =
    TypedHtml.Table.colgroup


{-| See `TypedHtml.Text.data`.
-}
data :
    List (Attr TypedHtml.Text.DataAttrs msg)
    -> List (Element TypedHtml.Text.DataContent (TypedHtml.Text.DataChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.DataIs s) admittedBy msg
data =
    TypedHtml.Text.data


{-| See `TypedHtml.Select.datalist`.
-}
datalist :
    List (Attr TypedHtml.Select.DatalistAttrs msg)
    -> List (Element TypedHtml.Select.DatalistContent (TypedHtml.Select.DatalistChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Select.DatalistIs s) admittedBy msg
datalist =
    TypedHtml.Select.datalist


{-| See `TypedHtml.Grouping.dd`.
-}
dd :
    List (Attr TypedHtml.Grouping.DdAttrs msg)
    -> List (Element TypedHtml.Grouping.DdContent (TypedHtml.Grouping.DdChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Grouping.DdIs s) TypedHtml.Grouping.DdAdmittedBy msg
dd =
    TypedHtml.Grouping.dd


{-| See `TypedHtml.Text.del`.
-}
del :
    List (Attr TypedHtml.Text.DelAttrs msg)
    -> List (Element childAccepts (TypedHtml.Text.DelChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
del =
    TypedHtml.Text.del


{-| See `TypedHtml.Details.details`.
-}
details :
    List (Attr TypedHtml.Details.DetailsAttrs msg)
    -> List (Element childAccepts (TypedHtml.Details.DetailsChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Details.DetailsIs s) admittedBy msg
details =
    TypedHtml.Details.details


{-| See `TypedHtml.Text.dfn`.
-}
dfn :
    List (Attr TypedHtml.Text.DfnAttrs msg)
    -> List (Element TypedHtml.Text.DfnContent (TypedHtml.Text.DfnChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.DfnIs s) admittedBy msg
dfn =
    TypedHtml.Text.dfn


{-| See `TypedHtml.Grouping.dialog`.
-}
dialog :
    List (Attr TypedHtml.Grouping.DialogAttrs msg)
    -> List (Element childAccepts (TypedHtml.Grouping.DialogChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Grouping.DialogIs s) admittedBy msg
dialog =
    TypedHtml.Grouping.dialog


{-| See `TypedHtml.Grouping.div`.
-}
div :
    List (Attr TypedHtml.Grouping.DivAttrs msg)
    -> List (Element childAccepts (TypedHtml.Grouping.DivChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Grouping.DivIs s) admittedBy msg
div =
    TypedHtml.Grouping.div


{-| See `TypedHtml.Grouping.dl`.
-}
dl :
    List (Attr TypedHtml.Grouping.DlAttrs msg)
    -> List (Element TypedHtml.Grouping.DlContent (TypedHtml.Grouping.DlChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Grouping.DlIs s) admittedBy msg
dl =
    TypedHtml.Grouping.dl


{-| See `TypedHtml.Grouping.dt`.
-}
dt :
    List (Attr TypedHtml.Grouping.DtAttrs msg)
    -> List (Element TypedHtml.Grouping.DtContent (TypedHtml.Grouping.DtChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Grouping.DtIs s) TypedHtml.Grouping.DtAdmittedBy msg
dt =
    TypedHtml.Grouping.dt


{-| See `TypedHtml.Text.em`.
-}
em :
    List (Attr TypedHtml.Text.EmAttrs msg)
    -> List (Element TypedHtml.Text.EmContent (TypedHtml.Text.EmChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.EmIs s) admittedBy msg
em =
    TypedHtml.Text.em


{-| See `TypedHtml.Embedded.embed`.
-}
embed :
    List (Attr TypedHtml.Embedded.EmbedAttrs msg)
    -> List (Element childAccepts (TypedHtml.Embedded.EmbedChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Embedded.EmbedIs s) admittedBy msg
embed =
    TypedHtml.Embedded.embed


{-| See `TypedHtml.Form.fieldset`.
-}
fieldset :
    List (Attr TypedHtml.Form.FieldsetAttrs msg)
    -> List (Element childAccepts (TypedHtml.Form.FieldsetChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Form.FieldsetIs s) admittedBy msg
fieldset =
    TypedHtml.Form.fieldset


{-| See `TypedHtml.Grouping.figcaption`.
-}
figcaption :
    List (Attr TypedHtml.Grouping.FigcaptionAttrs msg)
    -> List (Element TypedHtml.Grouping.FigcaptionContent (TypedHtml.Grouping.FigcaptionChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Grouping.FigcaptionIs s) TypedHtml.Grouping.FigcaptionAdmittedBy msg
figcaption =
    TypedHtml.Grouping.figcaption


{-| See `TypedHtml.Grouping.figure`.
-}
figure :
    List (Attr TypedHtml.Grouping.FigureAttrs msg)
    -> List (Element childAccepts (TypedHtml.Grouping.FigureChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Grouping.FigureIs s) admittedBy msg
figure =
    TypedHtml.Grouping.figure


{-| See `TypedHtml.Sectioning.footer`.
-}
footer :
    List (Attr TypedHtml.Sectioning.FooterAttrs msg)
    -> List (Element childAccepts (TypedHtml.Sectioning.FooterChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Sectioning.FooterIs s) admittedBy msg
footer =
    TypedHtml.Sectioning.footer


{-| See `TypedHtml.Form.form`.
-}
form :
    List (Attr TypedHtml.Form.FormAttrs msg)
    -> List (Element childAccepts (TypedHtml.Form.FormChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Form.FormIs s) admittedBy msg
form =
    TypedHtml.Form.form


{-| See `TypedHtml.Sectioning.h1`.
-}
h1 :
    List (Attr TypedHtml.Sectioning.H1Attrs msg)
    -> List (Element TypedHtml.Sectioning.H1Content (TypedHtml.Sectioning.H1ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Sectioning.H1Is s) admittedBy msg
h1 =
    TypedHtml.Sectioning.h1


{-| See `TypedHtml.Sectioning.h2`.
-}
h2 :
    List (Attr TypedHtml.Sectioning.H2Attrs msg)
    -> List (Element TypedHtml.Sectioning.H2Content (TypedHtml.Sectioning.H2ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Sectioning.H2Is s) admittedBy msg
h2 =
    TypedHtml.Sectioning.h2


{-| See `TypedHtml.Sectioning.h3`.
-}
h3 :
    List (Attr TypedHtml.Sectioning.H3Attrs msg)
    -> List (Element TypedHtml.Sectioning.H3Content (TypedHtml.Sectioning.H3ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Sectioning.H3Is s) admittedBy msg
h3 =
    TypedHtml.Sectioning.h3


{-| See `TypedHtml.Sectioning.h4`.
-}
h4 :
    List (Attr TypedHtml.Sectioning.H4Attrs msg)
    -> List (Element TypedHtml.Sectioning.H4Content (TypedHtml.Sectioning.H4ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Sectioning.H4Is s) admittedBy msg
h4 =
    TypedHtml.Sectioning.h4


{-| See `TypedHtml.Sectioning.h5`.
-}
h5 :
    List (Attr TypedHtml.Sectioning.H5Attrs msg)
    -> List (Element TypedHtml.Sectioning.H5Content (TypedHtml.Sectioning.H5ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Sectioning.H5Is s) admittedBy msg
h5 =
    TypedHtml.Sectioning.h5


{-| See `TypedHtml.Sectioning.h6`.
-}
h6 :
    List (Attr TypedHtml.Sectioning.H6Attrs msg)
    -> List (Element TypedHtml.Sectioning.H6Content (TypedHtml.Sectioning.H6ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Sectioning.H6Is s) admittedBy msg
h6 =
    TypedHtml.Sectioning.h6


{-| See `TypedHtml.Metadata.head`.
-}
head :
    List (Attr TypedHtml.Metadata.HeadAttrs msg)
    -> List (Element TypedHtml.Kind.Metadata (TypedHtml.Metadata.HeadChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Metadata.HeadIs s) admittedBy msg
head =
    TypedHtml.Metadata.head


{-| See `TypedHtml.Sectioning.header`.
-}
header :
    List (Attr TypedHtml.Sectioning.HeaderAttrs msg)
    -> List (Element childAccepts (TypedHtml.Sectioning.HeaderChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Sectioning.HeaderIs s) admittedBy msg
header =
    TypedHtml.Sectioning.header


{-| See `TypedHtml.Sectioning.hgroup`.
-}
hgroup :
    List (Attr TypedHtml.Sectioning.HgroupAttrs msg)
    -> List (Element childAccepts (TypedHtml.Sectioning.HgroupChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Sectioning.HgroupIs s) admittedBy msg
hgroup =
    TypedHtml.Sectioning.hgroup


{-| See `TypedHtml.Grouping.hr`.
-}
hr :
    List (Attr TypedHtml.Grouping.HrAttrs msg)
    -> List (Element childAccepts (TypedHtml.Grouping.HrChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Grouping.HrIs s) admittedBy msg
hr =
    TypedHtml.Grouping.hr


{-| See `TypedHtml.Text.i`.
-}
i :
    List (Attr TypedHtml.Text.IAttrs msg)
    -> List (Element TypedHtml.Text.IContent (TypedHtml.Text.IChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.IIs s) admittedBy msg
i =
    TypedHtml.Text.i


{-| See `TypedHtml.Embedded.iframe`.
-}
iframe :
    List (Attr TypedHtml.Embedded.IframeAttrs msg)
    -> List (Element childAccepts (TypedHtml.Embedded.IframeChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Embedded.IframeIs s) admittedBy msg
iframe =
    TypedHtml.Embedded.iframe


{-| See `TypedHtml.Img.img`.
-}
img :
    List (Attr TypedHtml.Img.Attrs msg)
    -> List (Element childAccepts (TypedHtml.Img.ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Img.Is s) admittedBy msg
img =
    TypedHtml.Img.img


{-| See `TypedHtml.Input.input`.
-}
input :
    List (Attr TypedHtml.Input.Attrs msg)
    -> List (Element childAccepts (TypedHtml.Input.ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Input.Is s) admittedBy msg
input =
    TypedHtml.Input.input


{-| See `TypedHtml.Text.ins`.
-}
ins :
    List (Attr TypedHtml.Text.InsAttrs msg)
    -> List (Element childAccepts (TypedHtml.Text.InsChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
ins =
    TypedHtml.Text.ins


{-| See `TypedHtml.Text.kbd`.
-}
kbd :
    List (Attr TypedHtml.Text.KbdAttrs msg)
    -> List (Element TypedHtml.Text.KbdContent (TypedHtml.Text.KbdChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.KbdIs s) admittedBy msg
kbd =
    TypedHtml.Text.kbd


{-| See `TypedHtml.Form.label`.
-}
label :
    List (Attr TypedHtml.Form.LabelAttrs msg)
    -> List (Element TypedHtml.Form.LabelContent (TypedHtml.Form.LabelChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Form.LabelIs s) admittedBy msg
label =
    TypedHtml.Form.label


{-| See `TypedHtml.Form.legend`.
-}
legend :
    List (Attr TypedHtml.Form.LegendAttrs msg)
    -> List (Element TypedHtml.Form.LegendContent (TypedHtml.Form.LegendChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Form.LegendIs s) TypedHtml.Form.LegendAdmittedBy msg
legend =
    TypedHtml.Form.legend


{-| See `TypedHtml.Grouping.li`.
-}
li :
    List (Attr TypedHtml.Grouping.LiAttrs msg)
    -> List (Element TypedHtml.Grouping.LiContent (TypedHtml.Grouping.LiChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Grouping.LiIs s) TypedHtml.Grouping.LiAdmittedBy msg
li =
    TypedHtml.Grouping.li


{-| See `TypedHtml.Metadata.link`.
-}
link :
    List (Attr TypedHtml.Metadata.LinkAttrs msg)
    -> List (Element childAccepts (TypedHtml.Metadata.LinkChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Metadata.LinkIs s) admittedBy msg
link =
    TypedHtml.Metadata.link


{-| See `TypedHtml.Sectioning.main_`.
-}
main_ :
    List (Attr TypedHtml.Sectioning.MainAttrs msg)
    -> List (Element childAccepts (TypedHtml.Sectioning.MainChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Sectioning.MainIs s) admittedBy msg
main_ =
    TypedHtml.Sectioning.main_


{-| See `TypedHtml.Embedded.map`.
-}
map :
    List (Attr TypedHtml.Embedded.MapAttrs msg)
    -> List (Element childAccepts (TypedHtml.Embedded.MapChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
map =
    TypedHtml.Embedded.map


{-| See `TypedHtml.Text.mark`.
-}
mark :
    List (Attr TypedHtml.Text.MarkAttrs msg)
    -> List (Element TypedHtml.Text.MarkContent (TypedHtml.Text.MarkChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.MarkIs s) admittedBy msg
mark =
    TypedHtml.Text.mark


{-| See `TypedHtml.Grouping.menu`.
-}
menu :
    List (Attr TypedHtml.Grouping.MenuAttrs msg)
    -> List (Element TypedHtml.Grouping.MenuContent (TypedHtml.Grouping.MenuChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Grouping.MenuIs s) admittedBy msg
menu =
    TypedHtml.Grouping.menu


{-| See `TypedHtml.Metadata.meta`.
-}
meta :
    List (Attr TypedHtml.Metadata.MetaAttrs msg)
    -> List (Element childAccepts (TypedHtml.Metadata.MetaChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Metadata.MetaIs s) admittedBy msg
meta =
    TypedHtml.Metadata.meta


{-| See `TypedHtml.Text.meter`.
-}
meter :
    List (Attr TypedHtml.Text.MeterAttrs msg)
    -> List (Element TypedHtml.Text.MeterContent (TypedHtml.Text.MeterChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.MeterIs s) admittedBy msg
meter =
    TypedHtml.Text.meter


{-| See `TypedHtml.Sectioning.nav`.
-}
nav :
    List (Attr TypedHtml.Sectioning.NavAttrs msg)
    -> List (Element childAccepts (TypedHtml.Sectioning.NavChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Sectioning.NavIs s) admittedBy msg
nav =
    TypedHtml.Sectioning.nav


{-| See `TypedHtml.Scripting.noscript`.
-}
noscript :
    List (Attr TypedHtml.Scripting.NoscriptAttrs msg)
    -> List (Element TypedHtml.Scripting.NoscriptContent (TypedHtml.Scripting.NoscriptChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Scripting.NoscriptIs s) admittedBy msg
noscript =
    TypedHtml.Scripting.noscript


{-| See `TypedHtml.Embedded.object`.
-}
object :
    List (Attr TypedHtml.Embedded.ObjectAttrs msg)
    -> List (Element childAccepts (TypedHtml.Embedded.ObjectChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
object =
    TypedHtml.Embedded.object


{-| See `TypedHtml.Grouping.ol`.
-}
ol :
    List (Attr TypedHtml.Grouping.OlAttrs msg)
    -> List (Element TypedHtml.Grouping.OlContent (TypedHtml.Grouping.OlChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Grouping.OlIs s) admittedBy msg
ol =
    TypedHtml.Grouping.ol


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


{-| See `TypedHtml.Form.output`.
-}
output :
    List (Attr TypedHtml.Form.OutputAttrs msg)
    -> List (Element TypedHtml.Form.OutputContent (TypedHtml.Form.OutputChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Form.OutputIs s) admittedBy msg
output =
    TypedHtml.Form.output


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


{-| See `TypedHtml.Grouping.pre`.
-}
pre :
    List (Attr TypedHtml.Grouping.PreAttrs msg)
    -> List (Element TypedHtml.Grouping.PreContent (TypedHtml.Grouping.PreChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Grouping.PreIs s) admittedBy msg
pre =
    TypedHtml.Grouping.pre


{-| See `TypedHtml.Text.progress`.
-}
progress :
    List (Attr TypedHtml.Text.ProgressAttrs msg)
    -> List (Element TypedHtml.Text.ProgressContent (TypedHtml.Text.ProgressChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.ProgressIs s) admittedBy msg
progress =
    TypedHtml.Text.progress


{-| See `TypedHtml.Text.q`.
-}
q :
    List (Attr TypedHtml.Text.QAttrs msg)
    -> List (Element TypedHtml.Text.QContent (TypedHtml.Text.QChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.QIs s) admittedBy msg
q =
    TypedHtml.Text.q


{-| See `TypedHtml.Text.rp`.
-}
rp :
    List (Attr TypedHtml.Text.RpAttrs msg)
    -> List (Element TypedHtml.Text.RpContent (TypedHtml.Text.RpChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.RpIs s) TypedHtml.Text.RpAdmittedBy msg
rp =
    TypedHtml.Text.rp


{-| See `TypedHtml.Text.rt`.
-}
rt :
    List (Attr TypedHtml.Text.RtAttrs msg)
    -> List (Element TypedHtml.Text.RtContent (TypedHtml.Text.RtChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.RtIs s) TypedHtml.Text.RtAdmittedBy msg
rt =
    TypedHtml.Text.rt


{-| See `TypedHtml.Text.ruby`.
-}
ruby :
    List (Attr TypedHtml.Text.RubyAttrs msg)
    -> List (Element TypedHtml.Text.RubyContent (TypedHtml.Text.RubyChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.RubyIs s) admittedBy msg
ruby =
    TypedHtml.Text.ruby


{-| See `TypedHtml.Text.s`.
-}
s :
    List (Attr TypedHtml.Text.SAttrs msg)
    -> List (Element TypedHtml.Text.SContent (TypedHtml.Text.SChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.SIs s) admittedBy msg
s =
    TypedHtml.Text.s


{-| See `TypedHtml.Text.samp`.
-}
samp :
    List (Attr TypedHtml.Text.SampAttrs msg)
    -> List (Element TypedHtml.Text.SampContent (TypedHtml.Text.SampChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.SampIs s) admittedBy msg
samp =
    TypedHtml.Text.samp


{-| See `TypedHtml.Scripting.script`.
-}
script :
    List (Attr TypedHtml.Scripting.ScriptAttrs msg)
    -> List (Element TypedHtml.Scripting.ScriptContent (TypedHtml.Scripting.ScriptChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Scripting.ScriptIs s) admittedBy msg
script =
    TypedHtml.Scripting.script


{-| See `TypedHtml.Sectioning.search`.
-}
search :
    List (Attr TypedHtml.Sectioning.SearchAttrs msg)
    -> List (Element childAccepts (TypedHtml.Sectioning.SearchChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Sectioning.SearchIs s) admittedBy msg
search =
    TypedHtml.Sectioning.search


{-| See `TypedHtml.Sectioning.section`.
-}
section :
    List (Attr TypedHtml.Sectioning.SectionAttrs msg)
    -> List (Element childAccepts (TypedHtml.Sectioning.SectionChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Sectioning.SectionIs s) admittedBy msg
section =
    TypedHtml.Sectioning.section


{-| See `TypedHtml.Select.select`.
-}
select :
    List (Attr TypedHtml.Select.SelectAttrs msg)
    -> List (Element TypedHtml.Select.SelectContent (TypedHtml.Select.SelectChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Select.SelectIs s) admittedBy msg
select =
    TypedHtml.Select.select


{-| See `TypedHtml.Scripting.slot`.
-}
slot :
    List (Attr TypedHtml.Scripting.SlotAttrs msg)
    -> List (Element childAccepts (TypedHtml.Scripting.SlotChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
slot =
    TypedHtml.Scripting.slot


{-| See `TypedHtml.Text.small`.
-}
small :
    List (Attr TypedHtml.Text.SmallAttrs msg)
    -> List (Element TypedHtml.Text.SmallContent (TypedHtml.Text.SmallChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.SmallIs s) admittedBy msg
small =
    TypedHtml.Text.small


{-| See `TypedHtml.Media.source`.
-}
source :
    List (Attr TypedHtml.Media.SourceAttrs msg)
    -> List (Element childAccepts (TypedHtml.Media.SourceChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Media.SourceIs s) TypedHtml.Media.SourceAdmittedBy msg
source =
    TypedHtml.Media.source


{-| See `TypedHtml.Text.span`.
-}
span :
    List (Attr TypedHtml.Text.SpanAttrs msg)
    -> List (Element TypedHtml.Text.SpanContent (TypedHtml.Text.SpanChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.SpanIs s) admittedBy msg
span =
    TypedHtml.Text.span


{-| See `TypedHtml.Text.strong`.
-}
strong :
    List (Attr TypedHtml.Text.StrongAttrs msg)
    -> List (Element TypedHtml.Text.StrongContent (TypedHtml.Text.StrongChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.StrongIs s) admittedBy msg
strong =
    TypedHtml.Text.strong


{-| See `TypedHtml.Metadata.style`.
-}
style :
    List (Attr TypedHtml.Metadata.StyleAttrs msg)
    -> List (Element TypedHtml.Metadata.StyleContent (TypedHtml.Metadata.StyleChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Metadata.StyleIs s) admittedBy msg
style =
    TypedHtml.Metadata.style


{-| See `TypedHtml.Text.sub`.
-}
sub :
    List (Attr TypedHtml.Text.SubAttrs msg)
    -> List (Element TypedHtml.Text.SubContent (TypedHtml.Text.SubChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.SubIs s) admittedBy msg
sub =
    TypedHtml.Text.sub


{-| See `TypedHtml.Details.summary`.
-}
summary :
    List (Attr TypedHtml.Details.SummaryAttrs msg)
    -> List (Element TypedHtml.Details.SummaryContent (TypedHtml.Details.SummaryChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Details.SummaryIs s) TypedHtml.Details.SummaryAdmittedBy msg
summary =
    TypedHtml.Details.summary


{-| See `TypedHtml.Text.sup`.
-}
sup :
    List (Attr TypedHtml.Text.SupAttrs msg)
    -> List (Element TypedHtml.Text.SupContent (TypedHtml.Text.SupChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.SupIs s) admittedBy msg
sup =
    TypedHtml.Text.sup


{-| See `TypedHtml.Table.table`.
-}
table :
    List (Attr TypedHtml.Table.TableAttrs msg)
    -> List (Element TypedHtml.Table.TableContent (TypedHtml.Table.TableChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Table.TableIs s) admittedBy msg
table =
    TypedHtml.Table.table


{-| See `TypedHtml.Table.tbody`.
-}
tbody :
    List (Attr TypedHtml.Table.TbodyAttrs msg)
    -> List (Element TypedHtml.Table.TbodyContent (TypedHtml.Table.TbodyChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Table.TbodyIs s) TypedHtml.Table.TbodyAdmittedBy msg
tbody =
    TypedHtml.Table.tbody


{-| See `TypedHtml.Table.td`.
-}
td :
    List (Attr TypedHtml.Table.TdAttrs msg)
    -> List (Element TypedHtml.Table.TdContent (TypedHtml.Table.TdChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Table.TdIs s) TypedHtml.Table.TdAdmittedBy msg
td =
    TypedHtml.Table.td


{-| See `TypedHtml.Scripting.template`.
-}
template :
    List (Attr TypedHtml.Scripting.TemplateAttrs msg)
    -> List (Element childAccepts (TypedHtml.Scripting.TemplateChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Scripting.TemplateIs s) admittedBy msg
template =
    TypedHtml.Scripting.template


{-| See `TypedHtml.Textarea.textarea`.
-}
textarea :
    List (Attr TypedHtml.Textarea.Attrs msg)
    -> List (Element TypedHtml.Textarea.Content (TypedHtml.Textarea.ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Textarea.Is s) admittedBy msg
textarea =
    TypedHtml.Textarea.textarea


{-| See `TypedHtml.Table.tfoot`.
-}
tfoot :
    List (Attr TypedHtml.Table.TfootAttrs msg)
    -> List (Element TypedHtml.Table.TfootContent (TypedHtml.Table.TfootChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Table.TfootIs s) TypedHtml.Table.TfootAdmittedBy msg
tfoot =
    TypedHtml.Table.tfoot


{-| See `TypedHtml.Table.th`.
-}
th :
    List (Attr TypedHtml.Table.ThAttrs msg)
    -> List (Element TypedHtml.Table.ThContent (TypedHtml.Table.ThChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Table.ThIs s) TypedHtml.Table.ThAdmittedBy msg
th =
    TypedHtml.Table.th


{-| See `TypedHtml.Table.thead`.
-}
thead :
    List (Attr TypedHtml.Table.TheadAttrs msg)
    -> List (Element TypedHtml.Table.TheadContent (TypedHtml.Table.TheadChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Table.TheadIs s) TypedHtml.Table.TheadAdmittedBy msg
thead =
    TypedHtml.Table.thead


{-| See `TypedHtml.Text.time`.
-}
time :
    List (Attr TypedHtml.Text.TimeAttrs msg)
    -> List (Element TypedHtml.Text.TimeContent (TypedHtml.Text.TimeChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.TimeIs s) admittedBy msg
time =
    TypedHtml.Text.time


{-| See `TypedHtml.Metadata.title`.
-}
title :
    List (Attr TypedHtml.Metadata.TitleAttrs msg)
    -> List (Element TypedHtml.Metadata.TitleContent (TypedHtml.Metadata.TitleChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Metadata.TitleIs s) admittedBy msg
title =
    TypedHtml.Metadata.title


{-| See `TypedHtml.Table.tr`.
-}
tr :
    List (Attr TypedHtml.Table.TrAttrs msg)
    -> List (Element TypedHtml.Table.TrContent (TypedHtml.Table.TrChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Table.TrIs s) TypedHtml.Table.TrAdmittedBy msg
tr =
    TypedHtml.Table.tr


{-| See `TypedHtml.Media.track`.
-}
track :
    List (Attr TypedHtml.Media.TrackAttrs msg)
    -> List (Element childAccepts (TypedHtml.Media.TrackChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Media.TrackIs s) TypedHtml.Media.TrackAdmittedBy msg
track =
    TypedHtml.Media.track


{-| See `TypedHtml.Text.u`.
-}
u :
    List (Attr TypedHtml.Text.UAttrs msg)
    -> List (Element TypedHtml.Text.UContent (TypedHtml.Text.UChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.UIs s) admittedBy msg
u =
    TypedHtml.Text.u


{-| See `TypedHtml.Grouping.ul`.
-}
ul :
    List (Attr TypedHtml.Grouping.UlAttrs msg)
    -> List (Element TypedHtml.Grouping.UlContent (TypedHtml.Grouping.UlChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Grouping.UlIs s) admittedBy msg
ul =
    TypedHtml.Grouping.ul


{-| See `TypedHtml.Text.var`.
-}
var :
    List (Attr TypedHtml.Text.VarAttrs msg)
    -> List (Element TypedHtml.Text.VarContent (TypedHtml.Text.VarChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.VarIs s) admittedBy msg
var =
    TypedHtml.Text.var


{-| See `TypedHtml.Media.video`.
-}
video :
    List (Attr TypedHtml.Media.VideoAttrs msg)
    -> List (Element TypedHtml.Media.VideoContent (TypedHtml.Media.VideoChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Media.VideoIs s) admittedBy msg
video =
    TypedHtml.Media.video


{-| See `TypedHtml.Text.wbr`.
-}
wbr :
    List (Attr TypedHtml.Text.WbrAttrs msg)
    -> List (Element childAccepts (TypedHtml.Text.WbrChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Text.WbrIs s) admittedBy msg
wbr =
    TypedHtml.Text.wbr


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
