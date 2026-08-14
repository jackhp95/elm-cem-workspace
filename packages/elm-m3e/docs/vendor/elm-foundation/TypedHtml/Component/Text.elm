module TypedHtml.Component.Text exposing
    ( abbr, b, bdi, bdo, br, cite, code, data, del, dfn, em, i, ins, kbd, mark, meter, progress, q, rp, rt, ruby, s, samp, small, span, strong, sub, sup, time, u, var, wbr
    , AbbrIs, AbbrAttrs, AbbrContent, AbbrChildAdmittedBy, BIs, BAttrs, BContent, BChildAdmittedBy, BdiIs, BdiAttrs, BdiContent, BdiChildAdmittedBy, BdoIs, BdoAttrs, BdoContent, BdoChildAdmittedBy, BrIs, BrAttrs, BrChildAdmittedBy, CiteIs, CiteAttrs, CiteContent, CiteChildAdmittedBy, CodeIs, CodeAttrs, CodeContent, CodeChildAdmittedBy, DataIs, DataAttrs, DataContent, DataChildAdmittedBy, DelAttrs, DelChildAdmittedBy, DfnIs, DfnAttrs, DfnContent, DfnChildAdmittedBy, EmIs, EmAttrs, EmContent, EmChildAdmittedBy, IIs, IAttrs, IContent, IChildAdmittedBy, InsAttrs, InsChildAdmittedBy, KbdIs, KbdAttrs, KbdContent, KbdChildAdmittedBy, MarkIs, MarkAttrs, MarkContent, MarkChildAdmittedBy, MeterIs, MeterAttrs, MeterContent, MeterChildAdmittedBy, ProgressIs, ProgressAttrs, ProgressContent, ProgressChildAdmittedBy, QIs, QAttrs, QContent, QChildAdmittedBy, RpIs, RpAttrs, RpContent, RpChildAdmittedBy, RpAdmittedBy, RtIs, RtAttrs, RtContent, RtChildAdmittedBy, RtAdmittedBy, RubyIs, RubyAttrs, RubyContent, RubyChildAdmittedBy, SIs, SAttrs, SContent, SChildAdmittedBy, SampIs, SampAttrs, SampContent, SampChildAdmittedBy, SmallIs, SmallAttrs, SmallContent, SmallChildAdmittedBy, SpanIs, SpanAttrs, SpanContent, SpanChildAdmittedBy, SpanRoles, StrongIs, StrongAttrs, StrongContent, StrongChildAdmittedBy, SubIs, SubAttrs, SubContent, SubChildAdmittedBy, SupIs, SupAttrs, SupContent, SupChildAdmittedBy, TimeIs, TimeAttrs, TimeContent, TimeChildAdmittedBy, UIs, UAttrs, UContent, UChildAdmittedBy, VarIs, VarAttrs, VarContent, VarChildAdmittedBy, WbrIs, WbrAttrs, WbrChildAdmittedBy
    , datetime, high, low, max, min, optimum, value, valueNumeric, valueAsNumber
    )

{-| The `Text` element home: constructors, per-element rows, and
co-located re-exports of the shared attributes its elements admit.

@docs abbr, b, bdi, bdo, br, cite, code, data, del, dfn, em, i, ins, kbd, mark, meter, progress, q, rp, rt, ruby, s, samp, small, span, strong, sub, sup, time, u, var, wbr
@docs AbbrIs, AbbrAttrs, AbbrContent, AbbrChildAdmittedBy, BIs, BAttrs, BContent, BChildAdmittedBy, BdiIs, BdiAttrs, BdiContent, BdiChildAdmittedBy, BdoIs, BdoAttrs, BdoContent, BdoChildAdmittedBy, BrIs, BrAttrs, BrChildAdmittedBy, CiteIs, CiteAttrs, CiteContent, CiteChildAdmittedBy, CodeIs, CodeAttrs, CodeContent, CodeChildAdmittedBy, DataIs, DataAttrs, DataContent, DataChildAdmittedBy, DelAttrs, DelChildAdmittedBy, DfnIs, DfnAttrs, DfnContent, DfnChildAdmittedBy, EmIs, EmAttrs, EmContent, EmChildAdmittedBy, IIs, IAttrs, IContent, IChildAdmittedBy, InsAttrs, InsChildAdmittedBy, KbdIs, KbdAttrs, KbdContent, KbdChildAdmittedBy, MarkIs, MarkAttrs, MarkContent, MarkChildAdmittedBy, MeterIs, MeterAttrs, MeterContent, MeterChildAdmittedBy, ProgressIs, ProgressAttrs, ProgressContent, ProgressChildAdmittedBy, QIs, QAttrs, QContent, QChildAdmittedBy, RpIs, RpAttrs, RpContent, RpChildAdmittedBy, RpAdmittedBy, RtIs, RtAttrs, RtContent, RtChildAdmittedBy, RtAdmittedBy, RubyIs, RubyAttrs, RubyContent, RubyChildAdmittedBy, SIs, SAttrs, SContent, SChildAdmittedBy, SampIs, SampAttrs, SampContent, SampChildAdmittedBy, SmallIs, SmallAttrs, SmallContent, SmallChildAdmittedBy, SpanIs, SpanAttrs, SpanContent, SpanChildAdmittedBy, SpanRoles, StrongIs, StrongAttrs, StrongContent, StrongChildAdmittedBy, SubIs, SubAttrs, SubContent, SubChildAdmittedBy, SupIs, SupAttrs, SupContent, SupChildAdmittedBy, TimeIs, TimeAttrs, TimeContent, TimeChildAdmittedBy, UIs, UAttrs, UContent, UChildAdmittedBy, VarIs, VarAttrs, VarContent, VarChildAdmittedBy, WbrIs, WbrAttrs, WbrChildAdmittedBy
@docs datetime, high, low, max, min, optimum, value, valueNumeric, valueAsNumber

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import TypedHtml.Attributes
import TypedHtml.Kind exposing (Brand, Ctx, Role)


{-| The kind row `abbr` produces.
-}
type alias AbbrIs s =
    { s | sharedPhrasing : Shared }


{-| `abbr`'s closed attribute-capability row.
-}
type alias AbbrAttrs =
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


{-| The kinds `abbr` admits.
-}
type alias AbbrContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `abbr` injects into its children.
-}
type alias AbbrChildAdmittedBy childAdm =
    { childAdm | abbr : Ctx }


{-| The `abbr` element.
-}
abbr :
    List (Attr AbbrAttrs msg)
    -> List (Element AbbrContent (AbbrChildAdmittedBy childAdm) msg)
    -> Element (AbbrIs s) admittedBy msg
abbr attrs children =
    Ir.fromNode (Ir.node "abbr" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `b` produces.
-}
type alias BIs s =
    { s | sharedPhrasing : Shared }


{-| `b`'s closed attribute-capability row.
-}
type alias BAttrs =
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


{-| The kinds `b` admits.
-}
type alias BContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `b` injects into its children.
-}
type alias BChildAdmittedBy childAdm =
    { childAdm | b : Ctx }


{-| The `b` element.
-}
b :
    List (Attr BAttrs msg)
    -> List (Element BContent (BChildAdmittedBy childAdm) msg)
    -> Element (BIs s) admittedBy msg
b attrs children =
    Ir.fromNode (Ir.node "b" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `bdi` produces.
-}
type alias BdiIs s =
    { s | sharedPhrasing : Shared }


{-| `bdi`'s closed attribute-capability row.
-}
type alias BdiAttrs =
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


{-| The kinds `bdi` admits.
-}
type alias BdiContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `bdi` injects into its children.
-}
type alias BdiChildAdmittedBy childAdm =
    { childAdm | bdi : Ctx }


{-| The `bdi` element.
-}
bdi :
    List (Attr BdiAttrs msg)
    -> List (Element BdiContent (BdiChildAdmittedBy childAdm) msg)
    -> Element (BdiIs s) admittedBy msg
bdi attrs children =
    Ir.fromNode (Ir.node "bdi" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `bdo` produces.
-}
type alias BdoIs s =
    { s | sharedPhrasing : Shared }


{-| `bdo`'s closed attribute-capability row.
-}
type alias BdoAttrs =
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


{-| The kinds `bdo` admits.
-}
type alias BdoContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `bdo` injects into its children.
-}
type alias BdoChildAdmittedBy childAdm =
    { childAdm | bdo : Ctx }


{-| The `bdo` element.
-}
bdo :
    List (Attr BdoAttrs msg)
    -> List (Element BdoContent (BdoChildAdmittedBy childAdm) msg)
    -> Element (BdoIs s) admittedBy msg
bdo attrs children =
    Ir.fromNode (Ir.node "bdo" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `br` produces.
-}
type alias BrIs s =
    { s | sharedPhrasing : Shared }


{-| `br`'s closed attribute-capability row.
-}
type alias BrAttrs =
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


{-| The context demand `br` injects into its children.
-}
type alias BrChildAdmittedBy childAdm =
    { childAdm | br : Ctx }


{-| The `br` element.
-}
br :
    List (Attr BrAttrs msg)
    -> List (Element childAccepts (BrChildAdmittedBy childAdm) msg)
    -> Element (BrIs s) admittedBy msg
br attrs children =
    Ir.fromNode (Ir.node "br" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `cite` produces.
-}
type alias CiteIs s =
    { s | sharedPhrasing : Shared }


{-| `cite`'s closed attribute-capability row.
-}
type alias CiteAttrs =
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


{-| The kinds `cite` admits.
-}
type alias CiteContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `cite` injects into its children.
-}
type alias CiteChildAdmittedBy childAdm =
    { childAdm | cite : Ctx }


{-| The `cite` element.
-}
cite :
    List (Attr CiteAttrs msg)
    -> List (Element CiteContent (CiteChildAdmittedBy childAdm) msg)
    -> Element (CiteIs s) admittedBy msg
cite attrs children =
    Ir.fromNode (Ir.node "cite" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `code` produces.
-}
type alias CodeIs s =
    { s | sharedPhrasing : Shared }


{-| `code`'s closed attribute-capability row.
-}
type alias CodeAttrs =
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


{-| The kinds `code` admits.
-}
type alias CodeContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `code` injects into its children.
-}
type alias CodeChildAdmittedBy childAdm =
    { childAdm | code : Ctx }


{-| The `code` element.
-}
code :
    List (Attr CodeAttrs msg)
    -> List (Element CodeContent (CodeChildAdmittedBy childAdm) msg)
    -> Element (CodeIs s) admittedBy msg
code attrs children =
    Ir.fromNode (Ir.node "code" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `data` produces.
-}
type alias DataIs s =
    { s | sharedPhrasing : Shared }


{-| `data`'s closed attribute-capability row.
-}
type alias DataAttrs =
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
    , value : Supported
    , writingsuggestions : Supported
    }


{-| The kinds `data` admits.
-}
type alias DataContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `data` injects into its children.
-}
type alias DataChildAdmittedBy childAdm =
    { childAdm | data : Ctx }


{-| The `data` element.
-}
data :
    List (Attr DataAttrs msg)
    -> List (Element DataContent (DataChildAdmittedBy childAdm) msg)
    -> Element (DataIs s) admittedBy msg
data attrs children =
    Ir.fromNode (Ir.node "data" attrs (List.map HtmlIr.Element.toNode children))


{-| `del`'s closed attribute-capability row.
-}
type alias DelAttrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , cite : Supported
    , class : Supported
    , contenteditable : Supported
    , datetime : Supported
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


{-| The context demand `del` injects into its children.
-}
type alias DelChildAdmittedBy childAdm =
    { childAdm | del : Ctx }


{-| The `del` element. Transparent content model: its produced kind row IS its
children's accepts row — it inherits its context's content model.
-}
del :
    List (Attr DelAttrs msg)
    -> List (Element childAccepts (DelChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
del attrs children =
    Ir.fromNode (Ir.node "del" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `dfn` produces.
-}
type alias DfnIs s =
    { s | sharedPhrasing : Shared }


{-| `dfn`'s closed attribute-capability row.
-}
type alias DfnAttrs =
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


{-| The kinds `dfn` admits.
-}
type alias DfnContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `dfn` injects into its children.
-}
type alias DfnChildAdmittedBy childAdm =
    { childAdm | dfn : Ctx }


{-| The `dfn` element.
-}
dfn :
    List (Attr DfnAttrs msg)
    -> List (Element DfnContent (DfnChildAdmittedBy childAdm) msg)
    -> Element (DfnIs s) admittedBy msg
dfn attrs children =
    Ir.fromNode (Ir.node "dfn" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `em` produces.
-}
type alias EmIs s =
    { s | sharedPhrasing : Shared }


{-| `em`'s closed attribute-capability row.
-}
type alias EmAttrs =
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


{-| The kinds `em` admits.
-}
type alias EmContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `em` injects into its children.
-}
type alias EmChildAdmittedBy childAdm =
    { childAdm | em : Ctx }


{-| The `em` element.
-}
em :
    List (Attr EmAttrs msg)
    -> List (Element EmContent (EmChildAdmittedBy childAdm) msg)
    -> Element (EmIs s) admittedBy msg
em attrs children =
    Ir.fromNode (Ir.node "em" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `i` produces.
-}
type alias IIs s =
    { s | sharedPhrasing : Shared }


{-| `i`'s closed attribute-capability row.
-}
type alias IAttrs =
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


{-| The kinds `i` admits.
-}
type alias IContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `i` injects into its children.
-}
type alias IChildAdmittedBy childAdm =
    { childAdm | i : Ctx }


{-| The `i` element.
-}
i :
    List (Attr IAttrs msg)
    -> List (Element IContent (IChildAdmittedBy childAdm) msg)
    -> Element (IIs s) admittedBy msg
i attrs children =
    Ir.fromNode (Ir.node "i" attrs (List.map HtmlIr.Element.toNode children))


{-| `ins`'s closed attribute-capability row.
-}
type alias InsAttrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , cite : Supported
    , class : Supported
    , contenteditable : Supported
    , datetime : Supported
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


{-| The context demand `ins` injects into its children.
-}
type alias InsChildAdmittedBy childAdm =
    { childAdm | ins : Ctx }


{-| The `ins` element. Transparent content model: its produced kind row IS its
children's accepts row — it inherits its context's content model.
-}
ins :
    List (Attr InsAttrs msg)
    -> List (Element childAccepts (InsChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
ins attrs children =
    Ir.fromNode (Ir.node "ins" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `kbd` produces.
-}
type alias KbdIs s =
    { s | sharedPhrasing : Shared }


{-| `kbd`'s closed attribute-capability row.
-}
type alias KbdAttrs =
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


{-| The kinds `kbd` admits.
-}
type alias KbdContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `kbd` injects into its children.
-}
type alias KbdChildAdmittedBy childAdm =
    { childAdm | kbd : Ctx }


{-| The `kbd` element.
-}
kbd :
    List (Attr KbdAttrs msg)
    -> List (Element KbdContent (KbdChildAdmittedBy childAdm) msg)
    -> Element (KbdIs s) admittedBy msg
kbd attrs children =
    Ir.fromNode (Ir.node "kbd" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `mark` produces.
-}
type alias MarkIs s =
    { s | sharedPhrasing : Shared }


{-| `mark`'s closed attribute-capability row.
-}
type alias MarkAttrs =
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


{-| The kinds `mark` admits.
-}
type alias MarkContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `mark` injects into its children.
-}
type alias MarkChildAdmittedBy childAdm =
    { childAdm | mark : Ctx }


{-| The `mark` element.
-}
mark :
    List (Attr MarkAttrs msg)
    -> List (Element MarkContent (MarkChildAdmittedBy childAdm) msg)
    -> Element (MarkIs s) admittedBy msg
mark attrs children =
    Ir.fromNode (Ir.node "mark" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `meter` produces.
-}
type alias MeterIs s =
    { s | sharedPhrasing : Shared }


{-| `meter`'s closed attribute-capability row.
-}
type alias MeterAttrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , class : Supported
    , contenteditable : Supported
    , draggable : Supported
    , enterkeyhint : Supported
    , high : Supported
    , id : Supported
    , inert : Supported
    , inputmode : Supported
    , itemid : Supported
    , itemprop : Supported
    , itemref : Supported
    , itemscope : Supported
    , itemtype : Supported
    , low : Supported
    , max : Supported
    , min : Supported
    , nonce : Supported
    , optimum : Supported
    , popover : Supported
    , role : Supported
    , slot : Supported
    , spellcheck : Supported
    , style : Supported
    , translate : Supported
    , valueNumeric : Supported
    , writingsuggestions : Supported
    }


{-| The kinds `meter` admits.
-}
type alias MeterContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `meter` injects into its children.
-}
type alias MeterChildAdmittedBy childAdm =
    { childAdm | meter : Ctx }


{-| The `meter` element.
-}
meter :
    List (Attr MeterAttrs msg)
    -> List (Element MeterContent (MeterChildAdmittedBy childAdm) msg)
    -> Element (MeterIs s) admittedBy msg
meter attrs children =
    Ir.fromNode (Ir.node "meter" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `progress` produces.
-}
type alias ProgressIs s =
    { s | sharedPhrasing : Shared }


{-| `progress`'s closed attribute-capability row.
-}
type alias ProgressAttrs =
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
    , max : Supported
    , nonce : Supported
    , popover : Supported
    , role : Supported
    , slot : Supported
    , spellcheck : Supported
    , style : Supported
    , translate : Supported
    , valueNumeric : Supported
    , writingsuggestions : Supported
    }


{-| The kinds `progress` admits.
-}
type alias ProgressContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `progress` injects into its children.
-}
type alias ProgressChildAdmittedBy childAdm =
    { childAdm | progress : Ctx }


{-| The `progress` element.
-}
progress :
    List (Attr ProgressAttrs msg)
    -> List (Element ProgressContent (ProgressChildAdmittedBy childAdm) msg)
    -> Element (ProgressIs s) admittedBy msg
progress attrs children =
    Ir.fromNode (Ir.node "progress" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `q` produces.
-}
type alias QIs s =
    { s | sharedPhrasing : Shared }


{-| `q`'s closed attribute-capability row.
-}
type alias QAttrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , cite : Supported
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


{-| The kinds `q` admits.
-}
type alias QContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `q` injects into its children.
-}
type alias QChildAdmittedBy childAdm =
    { childAdm | q : Ctx }


{-| The `q` element.
-}
q :
    List (Attr QAttrs msg)
    -> List (Element QContent (QChildAdmittedBy childAdm) msg)
    -> Element (QIs s) admittedBy msg
q attrs children =
    Ir.fromNode (Ir.node "q" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `rp` produces.
-}
type alias RpIs s =
    { s | rp : Brand }


{-| `rp`'s closed attribute-capability row.
-}
type alias RpAttrs =
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


{-| The kinds `rp` admits.
-}
type alias RpContent =
    { sharedText : Shared }


{-| The context demand `rp` injects into its children.
-}
type alias RpChildAdmittedBy childAdm =
    { childAdm | rp : Ctx }


{-| The CLOSED parent contexts `rp` is valid inside.
-}
type alias RpAdmittedBy =
    { ruby : Ctx }


{-| The `rp` element.
-}
rp :
    List (Attr RpAttrs msg)
    -> List (Element RpContent (RpChildAdmittedBy childAdm) msg)
    -> Element (RpIs s) RpAdmittedBy msg
rp attrs children =
    Ir.fromNode (Ir.node "rp" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `rt` produces.
-}
type alias RtIs s =
    { s | rt : Brand }


{-| `rt`'s closed attribute-capability row.
-}
type alias RtAttrs =
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


{-| The kinds `rt` admits.
-}
type alias RtContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `rt` injects into its children.
-}
type alias RtChildAdmittedBy childAdm =
    { childAdm | rt : Ctx }


{-| The CLOSED parent contexts `rt` is valid inside.
-}
type alias RtAdmittedBy =
    { ruby : Ctx }


{-| The `rt` element.
-}
rt :
    List (Attr RtAttrs msg)
    -> List (Element RtContent (RtChildAdmittedBy childAdm) msg)
    -> Element (RtIs s) RtAdmittedBy msg
rt attrs children =
    Ir.fromNode (Ir.node "rt" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `ruby` produces.
-}
type alias RubyIs s =
    { s | sharedPhrasing : Shared }


{-| `ruby`'s closed attribute-capability row.
-}
type alias RubyAttrs =
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


{-| The kinds `ruby` admits.
-}
type alias RubyContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , rp : Brand
    , rt : Brand
    , script : Brand
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `ruby` injects into its children.
-}
type alias RubyChildAdmittedBy childAdm =
    { childAdm | ruby : Ctx }


{-| The `ruby` element.
-}
ruby :
    List (Attr RubyAttrs msg)
    -> List (Element RubyContent (RubyChildAdmittedBy childAdm) msg)
    -> Element (RubyIs s) admittedBy msg
ruby attrs children =
    Ir.fromNode (Ir.node "ruby" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `s` produces.
-}
type alias SIs s =
    { s | sharedPhrasing : Shared }


{-| `s`'s closed attribute-capability row.
-}
type alias SAttrs =
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


{-| The kinds `s` admits.
-}
type alias SContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `s` injects into its children.
-}
type alias SChildAdmittedBy childAdm =
    { childAdm | s : Ctx }


{-| The `s` element.
-}
s :
    List (Attr SAttrs msg)
    -> List (Element SContent (SChildAdmittedBy childAdm) msg)
    -> Element (SIs s) admittedBy msg
s attrs children =
    Ir.fromNode (Ir.node "s" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `samp` produces.
-}
type alias SampIs s =
    { s | sharedPhrasing : Shared }


{-| `samp`'s closed attribute-capability row.
-}
type alias SampAttrs =
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


{-| The kinds `samp` admits.
-}
type alias SampContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `samp` injects into its children.
-}
type alias SampChildAdmittedBy childAdm =
    { childAdm | samp : Ctx }


{-| The `samp` element.
-}
samp :
    List (Attr SampAttrs msg)
    -> List (Element SampContent (SampChildAdmittedBy childAdm) msg)
    -> Element (SampIs s) admittedBy msg
samp attrs children =
    Ir.fromNode (Ir.node "samp" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `small` produces.
-}
type alias SmallIs s =
    { s | sharedPhrasing : Shared }


{-| `small`'s closed attribute-capability row.
-}
type alias SmallAttrs =
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


{-| The kinds `small` admits.
-}
type alias SmallContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `small` injects into its children.
-}
type alias SmallChildAdmittedBy childAdm =
    { childAdm | small : Ctx }


{-| The `small` element.
-}
small :
    List (Attr SmallAttrs msg)
    -> List (Element SmallContent (SmallChildAdmittedBy childAdm) msg)
    -> Element (SmallIs s) admittedBy msg
small attrs children =
    Ir.fromNode (Ir.node "small" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `span` produces.
-}
type alias SpanIs s =
    { s | sharedPhrasing : Shared }


{-| `span`'s closed attribute-capability row.
-}
type alias SpanAttrs =
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
    , role : SpanRoles
    , slot : Supported
    , spellcheck : Supported
    , style : Supported
    , translate : Supported
    , writingsuggestions : Supported
    }


{-| The kinds `span` admits.
-}
type alias SpanContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `span` injects into its children.
-}
type alias SpanChildAdmittedBy childAdm =
    { childAdm | span : Ctx }


{-| The ARIA roles `span` admits (see `TypedHtml.Aria`).
-}
type alias SpanRoles =
    { generic : Role
    , group : Role
    , listitem : Role
    , none : Role
    , note : Role
    , presentation : Role
    , tooltip : Role
    }


{-| The `span` element.
-}
span :
    List (Attr SpanAttrs msg)
    -> List (Element SpanContent (SpanChildAdmittedBy childAdm) msg)
    -> Element (SpanIs s) admittedBy msg
span attrs children =
    Ir.fromNode (Ir.node "span" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `strong` produces.
-}
type alias StrongIs s =
    { s | sharedPhrasing : Shared }


{-| `strong`'s closed attribute-capability row.
-}
type alias StrongAttrs =
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


{-| The kinds `strong` admits.
-}
type alias StrongContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `strong` injects into its children.
-}
type alias StrongChildAdmittedBy childAdm =
    { childAdm | strong : Ctx }


{-| The `strong` element.
-}
strong :
    List (Attr StrongAttrs msg)
    -> List (Element StrongContent (StrongChildAdmittedBy childAdm) msg)
    -> Element (StrongIs s) admittedBy msg
strong attrs children =
    Ir.fromNode (Ir.node "strong" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `sub` produces.
-}
type alias SubIs s =
    { s | sharedPhrasing : Shared }


{-| `sub`'s closed attribute-capability row.
-}
type alias SubAttrs =
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


{-| The kinds `sub` admits.
-}
type alias SubContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `sub` injects into its children.
-}
type alias SubChildAdmittedBy childAdm =
    { childAdm | sub : Ctx }


{-| The `sub` element.
-}
sub :
    List (Attr SubAttrs msg)
    -> List (Element SubContent (SubChildAdmittedBy childAdm) msg)
    -> Element (SubIs s) admittedBy msg
sub attrs children =
    Ir.fromNode (Ir.node "sub" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `sup` produces.
-}
type alias SupIs s =
    { s | sharedPhrasing : Shared }


{-| `sup`'s closed attribute-capability row.
-}
type alias SupAttrs =
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


{-| The kinds `sup` admits.
-}
type alias SupContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `sup` injects into its children.
-}
type alias SupChildAdmittedBy childAdm =
    { childAdm | sup : Ctx }


{-| The `sup` element.
-}
sup :
    List (Attr SupAttrs msg)
    -> List (Element SupContent (SupChildAdmittedBy childAdm) msg)
    -> Element (SupIs s) admittedBy msg
sup attrs children =
    Ir.fromNode (Ir.node "sup" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `time` produces.
-}
type alias TimeIs s =
    { s | sharedPhrasing : Shared }


{-| `time`'s closed attribute-capability row.
-}
type alias TimeAttrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , class : Supported
    , contenteditable : Supported
    , datetime : Supported
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


{-| The kinds `time` admits.
-}
type alias TimeContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `time` injects into its children.
-}
type alias TimeChildAdmittedBy childAdm =
    { childAdm | time : Ctx }


{-| The `time` element.
-}
time :
    List (Attr TimeAttrs msg)
    -> List (Element TimeContent (TimeChildAdmittedBy childAdm) msg)
    -> Element (TimeIs s) admittedBy msg
time attrs children =
    Ir.fromNode (Ir.node "time" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `u` produces.
-}
type alias UIs s =
    { s | sharedPhrasing : Shared }


{-| `u`'s closed attribute-capability row.
-}
type alias UAttrs =
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


{-| The kinds `u` admits.
-}
type alias UContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `u` injects into its children.
-}
type alias UChildAdmittedBy childAdm =
    { childAdm | u : Ctx }


{-| The `u` element.
-}
u :
    List (Attr UAttrs msg)
    -> List (Element UContent (UChildAdmittedBy childAdm) msg)
    -> Element (UIs s) admittedBy msg
u attrs children =
    Ir.fromNode (Ir.node "u" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `var` produces.
-}
type alias VarIs s =
    { s | sharedPhrasing : Shared }


{-| `var`'s closed attribute-capability row.
-}
type alias VarAttrs =
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


{-| The kinds `var` admits.
-}
type alias VarContent =
    { area : Brand
    , img : Brand
    , link : Brand
    , meta : Brand
    , noscript : Brand
    , script : Brand
    , sharedIcon : Shared
    , sharedPhrasing : Shared
    , sharedText : Shared
    , template : Brand
    }


{-| The context demand `var` injects into its children.
-}
type alias VarChildAdmittedBy childAdm =
    { childAdm | var : Ctx }


{-| The `var` element.
-}
var :
    List (Attr VarAttrs msg)
    -> List (Element VarContent (VarChildAdmittedBy childAdm) msg)
    -> Element (VarIs s) admittedBy msg
var attrs children =
    Ir.fromNode (Ir.node "var" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `wbr` produces.
-}
type alias WbrIs s =
    { s | sharedPhrasing : Shared }


{-| `wbr`'s closed attribute-capability row.
-}
type alias WbrAttrs =
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


{-| The context demand `wbr` injects into its children.
-}
type alias WbrChildAdmittedBy childAdm =
    { childAdm | wbr : Ctx }


{-| The `wbr` element.
-}
wbr :
    List (Attr WbrAttrs msg)
    -> List (Element childAccepts (WbrChildAdmittedBy childAdm) msg)
    -> Element (WbrIs s) admittedBy msg
wbr attrs children =
    Ir.fromNode (Ir.node "wbr" attrs (List.map HtmlIr.Element.toNode children))


{-| See `TypedHtml.Attributes.datetime`.
-}
datetime : String -> Attr { c | datetime : Supported } msg
datetime =
    TypedHtml.Attributes.datetime


{-| See `TypedHtml.Attributes.high`.
-}
high : Float -> Attr { c | high : Supported } msg
high =
    TypedHtml.Attributes.high


{-| See `TypedHtml.Attributes.low`.
-}
low : Float -> Attr { c | low : Supported } msg
low =
    TypedHtml.Attributes.low


{-| See `TypedHtml.Attributes.max`.
-}
max : String -> Attr { c | max : Supported } msg
max =
    TypedHtml.Attributes.max


{-| See `TypedHtml.Attributes.min`.
-}
min : String -> Attr { c | min : Supported } msg
min =
    TypedHtml.Attributes.min


{-| See `TypedHtml.Attributes.optimum`.
-}
optimum : Float -> Attr { c | optimum : Supported } msg
optimum =
    TypedHtml.Attributes.optimum


{-| Machine-readable value

Writes the `value` CONTENT attribute — correct for every element whose `value` REFLECTS, and the only form that serializes to server-rendered markup. It is NOT the live state on <input>, where the content attribute sets only the element's DEFAULT/initial `value` and stops taking effect once the user has changed it; use `TypedHtml.Input.value` for that.

-}
value : String -> Attr { c | value : Supported } msg
value value_ =
    Ir.attribute "value" value_


{-| See `TypedHtml.Attributes.valueNumeric`.
-}
valueNumeric : Float -> Attr { c | valueNumeric : Supported } msg
valueNumeric =
    TypedHtml.Attributes.valueNumeric


{-| Set the `value` attribute from a number. An ergonomic alternative to `value`, which keeps the spec-correct `String` type; this one cannot express every legal value, so reach for `value` when you need one it cannot. Both claim the same capability, mirroring HTML's own `value` / `valueAsNumber` split.
-}
valueAsNumber : Float -> Attr { c | value : Supported } msg
valueAsNumber value_ =
    Ir.attribute "value" (String.fromFloat value_)
