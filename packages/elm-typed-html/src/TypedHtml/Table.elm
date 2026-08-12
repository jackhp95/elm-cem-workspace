module TypedHtml.Table exposing
    ( caption, col, colgroup, table, tbody, td, tfoot, th, thead, tr
    , CaptionIs, CaptionAttrs, CaptionContent, CaptionChildAdmittedBy, CaptionAdmittedBy, ColIs, ColAttrs, ColChildAdmittedBy, ColAdmittedBy, ColgroupIs, ColgroupAttrs, ColgroupContent, ColgroupChildAdmittedBy, ColgroupAdmittedBy, TableIs, TableAttrs, TableContent, TableChildAdmittedBy, TbodyIs, TbodyAttrs, TbodyContent, TbodyChildAdmittedBy, TbodyAdmittedBy, TdIs, TdAttrs, TdContent, TdChildAdmittedBy, TdAdmittedBy, TfootIs, TfootAttrs, TfootContent, TfootChildAdmittedBy, TfootAdmittedBy, ThIs, ThAttrs, ThContent, ThChildAdmittedBy, ThAdmittedBy, TheadIs, TheadAttrs, TheadContent, TheadChildAdmittedBy, TheadAdmittedBy, TrIs, TrAttrs, TrContent, TrChildAdmittedBy, TrAdmittedBy
    , abbr, colspan, headers, rowspan, scope, span
    )

{-| The `Table` element home: constructors, per-element rows, and
co-located re-exports of the shared attributes its elements admit.

@docs caption, col, colgroup, table, tbody, td, tfoot, th, thead, tr
@docs CaptionIs, CaptionAttrs, CaptionContent, CaptionChildAdmittedBy, CaptionAdmittedBy, ColIs, ColAttrs, ColChildAdmittedBy, ColAdmittedBy, ColgroupIs, ColgroupAttrs, ColgroupContent, ColgroupChildAdmittedBy, ColgroupAdmittedBy, TableIs, TableAttrs, TableContent, TableChildAdmittedBy, TbodyIs, TbodyAttrs, TbodyContent, TbodyChildAdmittedBy, TbodyAdmittedBy, TdIs, TdAttrs, TdContent, TdChildAdmittedBy, TdAdmittedBy, TfootIs, TfootAttrs, TfootContent, TfootChildAdmittedBy, TfootAdmittedBy, ThIs, ThAttrs, ThContent, ThChildAdmittedBy, ThAdmittedBy, TheadIs, TheadAttrs, TheadContent, TheadChildAdmittedBy, TheadAdmittedBy, TrIs, TrAttrs, TrContent, TrChildAdmittedBy, TrAdmittedBy
@docs abbr, colspan, headers, rowspan, scope, span

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import TypedHtml.Attributes
import TypedHtml.Kind exposing (Brand, Ctx)


{-| The kind row `caption` produces.
-}
type alias CaptionIs s =
    { s | caption : Brand }


{-| `caption`'s closed attribute-capability row.
-}
type alias CaptionAttrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , class : Supported
    , contenteditable : Supported
    , draggable : Supported
    , enterkeyhint : Supported
    , id : Supported
    , inert : Supported
    , inputmode : Supported
    , itemid : Supported
    , itemprop : Supported
    , itemref : Supported
    , itemscope : Supported
    , itemtype : Supported
    , nonce : Supported
    , popover : Supported
    , role : Supported
    , slot : Supported
    , spellcheck : Supported
    , style : Supported
    , translate : Supported
    , writingsuggestions : Supported
    }


{-| The kinds `caption` admits.
-}
type alias CaptionContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedFlow : Shared
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `caption` injects into its children.
-}
type alias CaptionChildAdmittedBy childAdm =
    { childAdm | caption : Ctx }


{-| The CLOSED parent contexts `caption` is valid inside.
-}
type alias CaptionAdmittedBy =
    { table : Ctx }


{-| The `caption` element.
-}
caption :
    List (Attr CaptionAttrs msg)
    -> List (Element CaptionContent (CaptionChildAdmittedBy childAdm) msg)
    -> Element (CaptionIs s) CaptionAdmittedBy msg
caption attrs children =
    Ir.fromNode (Ir.node "caption" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `col` produces.
-}
type alias ColIs s =
    { s | col : Brand }


{-| `col`'s closed attribute-capability row.
-}
type alias ColAttrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , class : Supported
    , contenteditable : Supported
    , draggable : Supported
    , enterkeyhint : Supported
    , id : Supported
    , inert : Supported
    , inputmode : Supported
    , itemid : Supported
    , itemprop : Supported
    , itemref : Supported
    , itemscope : Supported
    , itemtype : Supported
    , nonce : Supported
    , popover : Supported
    , role : Supported
    , slot : Supported
    , span : Supported
    , spellcheck : Supported
    , style : Supported
    , translate : Supported
    , writingsuggestions : Supported
    }


{-| The context demand `col` injects into its children.
-}
type alias ColChildAdmittedBy childAdm =
    { childAdm | col : Ctx }


{-| The CLOSED parent contexts `col` is valid inside.
-}
type alias ColAdmittedBy =
    { colgroup : Ctx }


{-| The `col` element.
-}
col :
    List (Attr ColAttrs msg)
    -> List (Element childAccepts (ColChildAdmittedBy childAdm) msg)
    -> Element (ColIs s) ColAdmittedBy msg
col attrs children =
    Ir.fromNode (Ir.node "col" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `colgroup` produces.
-}
type alias ColgroupIs s =
    { s | colgroup : Brand }


{-| `colgroup`'s closed attribute-capability row.
-}
type alias ColgroupAttrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , class : Supported
    , contenteditable : Supported
    , draggable : Supported
    , enterkeyhint : Supported
    , id : Supported
    , inert : Supported
    , inputmode : Supported
    , itemid : Supported
    , itemprop : Supported
    , itemref : Supported
    , itemscope : Supported
    , itemtype : Supported
    , nonce : Supported
    , popover : Supported
    , role : Supported
    , slot : Supported
    , span : Supported
    , spellcheck : Supported
    , style : Supported
    , translate : Supported
    , writingsuggestions : Supported
    }


{-| The kinds `colgroup` admits.
-}
type alias ColgroupContent =
    { col : Brand }


{-| The context demand `colgroup` injects into its children.
-}
type alias ColgroupChildAdmittedBy childAdm =
    { childAdm | colgroup : Ctx }


{-| The CLOSED parent contexts `colgroup` is valid inside.
-}
type alias ColgroupAdmittedBy =
    { table : Ctx }


{-| The `colgroup` element.
-}
colgroup :
    List (Attr ColgroupAttrs msg)
    -> List (Element ColgroupContent (ColgroupChildAdmittedBy childAdm) msg)
    -> Element (ColgroupIs s) ColgroupAdmittedBy msg
colgroup attrs children =
    Ir.fromNode (Ir.node "colgroup" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `table` produces.
-}
type alias TableIs s =
    { s | sharedFlow : Shared }


{-| `table`'s closed attribute-capability row.
-}
type alias TableAttrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , class : Supported
    , contenteditable : Supported
    , draggable : Supported
    , enterkeyhint : Supported
    , id : Supported
    , inert : Supported
    , inputmode : Supported
    , itemid : Supported
    , itemprop : Supported
    , itemref : Supported
    , itemscope : Supported
    , itemtype : Supported
    , nonce : Supported
    , popover : Supported
    , role : Supported
    , slot : Supported
    , spellcheck : Supported
    , style : Supported
    , translate : Supported
    , writingsuggestions : Supported
    }


{-| The kinds `table` admits.
-}
type alias TableContent =
    { caption : Brand
    , colgroup : Brand
    , tbody : Brand
    , tfoot : Brand
    , thead : Brand
    }


{-| The context demand `table` injects into its children.
-}
type alias TableChildAdmittedBy childAdm =
    { childAdm | table : Ctx }


{-| The `table` element.
-}
table :
    List (Attr TableAttrs msg)
    -> List (Element TableContent (TableChildAdmittedBy childAdm) msg)
    -> Element (TableIs s) admittedBy msg
table attrs children =
    Ir.fromNode (Ir.node "table" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `tbody` produces.
-}
type alias TbodyIs s =
    { s | tbody : Brand }


{-| `tbody`'s closed attribute-capability row.
-}
type alias TbodyAttrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , class : Supported
    , contenteditable : Supported
    , draggable : Supported
    , enterkeyhint : Supported
    , id : Supported
    , inert : Supported
    , inputmode : Supported
    , itemid : Supported
    , itemprop : Supported
    , itemref : Supported
    , itemscope : Supported
    , itemtype : Supported
    , nonce : Supported
    , popover : Supported
    , role : Supported
    , slot : Supported
    , spellcheck : Supported
    , style : Supported
    , translate : Supported
    , writingsuggestions : Supported
    }


{-| The kinds `tbody` admits.
-}
type alias TbodyContent =
    { tr : Brand }


{-| The context demand `tbody` injects into its children.
-}
type alias TbodyChildAdmittedBy childAdm =
    { childAdm | tbody : Ctx }


{-| The CLOSED parent contexts `tbody` is valid inside.
-}
type alias TbodyAdmittedBy =
    { table : Ctx }


{-| The `tbody` element.
-}
tbody :
    List (Attr TbodyAttrs msg)
    -> List (Element TbodyContent (TbodyChildAdmittedBy childAdm) msg)
    -> Element (TbodyIs s) TbodyAdmittedBy msg
tbody attrs children =
    Ir.fromNode (Ir.node "tbody" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `td` produces.
-}
type alias TdIs s =
    { s | td : Brand }


{-| `td`'s closed attribute-capability row.
-}
type alias TdAttrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , class : Supported
    , colspan : Supported
    , contenteditable : Supported
    , draggable : Supported
    , enterkeyhint : Supported
    , headers : Supported
    , id : Supported
    , inert : Supported
    , inputmode : Supported
    , itemid : Supported
    , itemprop : Supported
    , itemref : Supported
    , itemscope : Supported
    , itemtype : Supported
    , nonce : Supported
    , popover : Supported
    , role : Supported
    , rowspan : Supported
    , slot : Supported
    , spellcheck : Supported
    , style : Supported
    , translate : Supported
    , writingsuggestions : Supported
    }


{-| The kinds `td` admits.
-}
type alias TdContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedFlow : Shared
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `td` injects into its children.
-}
type alias TdChildAdmittedBy childAdm =
    { childAdm | td : Ctx }


{-| The CLOSED parent contexts `td` is valid inside.
-}
type alias TdAdmittedBy =
    { tr : Ctx }


{-| The `td` element.
-}
td :
    List (Attr TdAttrs msg)
    -> List (Element TdContent (TdChildAdmittedBy childAdm) msg)
    -> Element (TdIs s) TdAdmittedBy msg
td attrs children =
    Ir.fromNode (Ir.node "td" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `tfoot` produces.
-}
type alias TfootIs s =
    { s | tfoot : Brand }


{-| `tfoot`'s closed attribute-capability row.
-}
type alias TfootAttrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , class : Supported
    , contenteditable : Supported
    , draggable : Supported
    , enterkeyhint : Supported
    , id : Supported
    , inert : Supported
    , inputmode : Supported
    , itemid : Supported
    , itemprop : Supported
    , itemref : Supported
    , itemscope : Supported
    , itemtype : Supported
    , nonce : Supported
    , popover : Supported
    , role : Supported
    , slot : Supported
    , spellcheck : Supported
    , style : Supported
    , translate : Supported
    , writingsuggestions : Supported
    }


{-| The kinds `tfoot` admits.
-}
type alias TfootContent =
    { tr : Brand }


{-| The context demand `tfoot` injects into its children.
-}
type alias TfootChildAdmittedBy childAdm =
    { childAdm | tfoot : Ctx }


{-| The CLOSED parent contexts `tfoot` is valid inside.
-}
type alias TfootAdmittedBy =
    { table : Ctx }


{-| The `tfoot` element.
-}
tfoot :
    List (Attr TfootAttrs msg)
    -> List (Element TfootContent (TfootChildAdmittedBy childAdm) msg)
    -> Element (TfootIs s) TfootAdmittedBy msg
tfoot attrs children =
    Ir.fromNode (Ir.node "tfoot" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `th` produces.
-}
type alias ThIs s =
    { s | th : Brand }


{-| `th`'s closed attribute-capability row.
-}
type alias ThAttrs =
    { abbr : Supported
    , accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , class : Supported
    , colspan : Supported
    , contenteditable : Supported
    , draggable : Supported
    , enterkeyhint : Supported
    , headers : Supported
    , id : Supported
    , inert : Supported
    , inputmode : Supported
    , itemid : Supported
    , itemprop : Supported
    , itemref : Supported
    , itemscope : Supported
    , itemtype : Supported
    , nonce : Supported
    , popover : Supported
    , role : Supported
    , rowspan : Supported
    , scope : Supported
    , slot : Supported
    , spellcheck : Supported
    , style : Supported
    , translate : Supported
    , writingsuggestions : Supported
    }


{-| The kinds `th` admits.
-}
type alias ThContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedFlow : Shared
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `th` injects into its children.
-}
type alias ThChildAdmittedBy childAdm =
    { childAdm | th : Ctx }


{-| The CLOSED parent contexts `th` is valid inside.
-}
type alias ThAdmittedBy =
    { tr : Ctx }


{-| The `th` element.
-}
th :
    List (Attr ThAttrs msg)
    -> List (Element ThContent (ThChildAdmittedBy childAdm) msg)
    -> Element (ThIs s) ThAdmittedBy msg
th attrs children =
    Ir.fromNode (Ir.node "th" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `thead` produces.
-}
type alias TheadIs s =
    { s | thead : Brand }


{-| `thead`'s closed attribute-capability row.
-}
type alias TheadAttrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , class : Supported
    , contenteditable : Supported
    , draggable : Supported
    , enterkeyhint : Supported
    , id : Supported
    , inert : Supported
    , inputmode : Supported
    , itemid : Supported
    , itemprop : Supported
    , itemref : Supported
    , itemscope : Supported
    , itemtype : Supported
    , nonce : Supported
    , popover : Supported
    , role : Supported
    , slot : Supported
    , spellcheck : Supported
    , style : Supported
    , translate : Supported
    , writingsuggestions : Supported
    }


{-| The kinds `thead` admits.
-}
type alias TheadContent =
    { tr : Brand }


{-| The context demand `thead` injects into its children.
-}
type alias TheadChildAdmittedBy childAdm =
    { childAdm | thead : Ctx }


{-| The CLOSED parent contexts `thead` is valid inside.
-}
type alias TheadAdmittedBy =
    { table : Ctx }


{-| The `thead` element.
-}
thead :
    List (Attr TheadAttrs msg)
    -> List (Element TheadContent (TheadChildAdmittedBy childAdm) msg)
    -> Element (TheadIs s) TheadAdmittedBy msg
thead attrs children =
    Ir.fromNode (Ir.node "thead" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `tr` produces.
-}
type alias TrIs s =
    { s | tr : Brand }


{-| `tr`'s closed attribute-capability row.
-}
type alias TrAttrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , class : Supported
    , contenteditable : Supported
    , draggable : Supported
    , enterkeyhint : Supported
    , id : Supported
    , inert : Supported
    , inputmode : Supported
    , itemid : Supported
    , itemprop : Supported
    , itemref : Supported
    , itemscope : Supported
    , itemtype : Supported
    , nonce : Supported
    , popover : Supported
    , role : Supported
    , slot : Supported
    , spellcheck : Supported
    , style : Supported
    , translate : Supported
    , writingsuggestions : Supported
    }


{-| The kinds `tr` admits.
-}
type alias TrContent =
    { td : Brand
    , th : Brand
    }


{-| The context demand `tr` injects into its children.
-}
type alias TrChildAdmittedBy childAdm =
    { childAdm | tr : Ctx }


{-| The CLOSED parent contexts `tr` is valid inside.
-}
type alias TrAdmittedBy =
    { tbody : Ctx, tfoot : Ctx, thead : Ctx }


{-| The `tr` element.
-}
tr :
    List (Attr TrAttrs msg)
    -> List (Element TrContent (TrChildAdmittedBy childAdm) msg)
    -> Element (TrIs s) TrAdmittedBy msg
tr attrs children =
    Ir.fromNode (Ir.node "tr" attrs (List.map HtmlIr.Element.toNode children))


{-| See `TypedHtml.Attributes.abbr`.
-}
abbr : String -> Attr { c | abbr : Supported } msg
abbr =
    TypedHtml.Attributes.abbr


{-| See `TypedHtml.Attributes.colspan`.
-}
colspan : Int -> Attr { c | colspan : Supported } msg
colspan =
    TypedHtml.Attributes.colspan


{-| See `TypedHtml.Attributes.headers`.
-}
headers : String -> Attr { c | headers : Supported } msg
headers =
    TypedHtml.Attributes.headers


{-| See `TypedHtml.Attributes.rowspan`.
-}
rowspan : Int -> Attr { c | rowspan : Supported } msg
rowspan =
    TypedHtml.Attributes.rowspan


{-| Specifies which cells the header cell applies to
-}
scope : String -> Attr { c | scope : Supported } msg
scope value_ =
    Ir.attribute "scope" value_


{-| See `TypedHtml.Attributes.span`.
-}
span : Int -> Attr { c | span : Supported } msg
span =
    TypedHtml.Attributes.span
