module TypedHtml.Component.Grouping exposing
    ( blockquote, dd, dialog, div, dl, dt, figcaption, figure, hr, li, menu, ol, p, pre, ul
    , BlockquoteIs, BlockquoteAttrs, BlockquoteChildAdmittedBy, DdIs, DdAttrs, DdContent, DdChildAdmittedBy, DdAdmittedBy, DialogIs, DialogAttrs, DialogChildAdmittedBy, DivIs, DivAttrs, DivChildAdmittedBy, DivRoles, DlIs, DlAttrs, DlContent, DlChildAdmittedBy, DtIs, DtAttrs, DtContent, DtChildAdmittedBy, DtAdmittedBy, FigcaptionIs, FigcaptionAttrs, FigcaptionContent, FigcaptionChildAdmittedBy, FigcaptionAdmittedBy, FigureIs, FigureAttrs, FigureChildAdmittedBy, HrIs, HrAttrs, HrChildAdmittedBy, LiIs, LiAttrs, LiContent, LiChildAdmittedBy, LiAdmittedBy, MenuIs, MenuAttrs, MenuContent, MenuChildAdmittedBy, OlIs, OlAttrs, OlContent, OlChildAdmittedBy, PIs, PAttrs, PContent, PChildAdmittedBy, PreIs, PreAttrs, PreContent, PreChildAdmittedBy, UlIs, UlAttrs, UlContent, UlChildAdmittedBy
    , cite, closedby, open, reversed, start, valueOrdinal
    )

{-| The `Grouping` element home: constructors, per-element rows, and
co-located re-exports of the shared attributes its elements admit.

@docs blockquote, dd, dialog, div, dl, dt, figcaption, figure, hr, li, menu, ol, p, pre, ul
@docs BlockquoteIs, BlockquoteAttrs, BlockquoteChildAdmittedBy, DdIs, DdAttrs, DdContent, DdChildAdmittedBy, DdAdmittedBy, DialogIs, DialogAttrs, DialogChildAdmittedBy, DivIs, DivAttrs, DivChildAdmittedBy, DivRoles, DlIs, DlAttrs, DlContent, DlChildAdmittedBy, DtIs, DtAttrs, DtContent, DtChildAdmittedBy, DtAdmittedBy, FigcaptionIs, FigcaptionAttrs, FigcaptionContent, FigcaptionChildAdmittedBy, FigcaptionAdmittedBy, FigureIs, FigureAttrs, FigureChildAdmittedBy, HrIs, HrAttrs, HrChildAdmittedBy, LiIs, LiAttrs, LiContent, LiChildAdmittedBy, LiAdmittedBy, MenuIs, MenuAttrs, MenuContent, MenuChildAdmittedBy, OlIs, OlAttrs, OlContent, OlChildAdmittedBy, PIs, PAttrs, PContent, PChildAdmittedBy, PreIs, PreAttrs, PreContent, PreChildAdmittedBy, UlIs, UlAttrs, UlContent, UlChildAdmittedBy
@docs cite, closedby, open, reversed, start, valueOrdinal

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import TypedHtml.Attributes
import TypedHtml.Kind exposing (Brand, Ctx, Role)


{-| The kind row `blockquote` produces.
-}
type alias BlockquoteIs s =
    { s | sharedFlow : Shared }


{-| `blockquote`'s closed attribute-capability row.
-}
type alias BlockquoteAttrs =
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


{-| The context demand `blockquote` injects into its children.
-}
type alias BlockquoteChildAdmittedBy childAdm =
    { childAdm | blockquote : Ctx }


{-| The `blockquote` element.
-}
blockquote :
    List (Attr BlockquoteAttrs msg)
    -> List (Element childAccepts (BlockquoteChildAdmittedBy childAdm) msg)
    -> Element (BlockquoteIs s) admittedBy msg
blockquote attrs children =
    Ir.fromNode (Ir.node "blockquote" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `dd` produces.
-}
type alias DdIs s =
    { s | dd : Brand }


{-| `dd`'s closed attribute-capability row.
-}
type alias DdAttrs =
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


{-| The kinds `dd` admits.
-}
type alias DdContent =
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


{-| The context demand `dd` injects into its children.
-}
type alias DdChildAdmittedBy childAdm =
    { childAdm | dd : Ctx }


{-| The CLOSED parent contexts `dd` is valid inside.
-}
type alias DdAdmittedBy =
    { dl : Ctx }


{-| The `dd` element.
-}
dd :
    List (Attr DdAttrs msg)
    -> List (Element DdContent (DdChildAdmittedBy childAdm) msg)
    -> Element (DdIs s) DdAdmittedBy msg
dd attrs children =
    Ir.fromNode (Ir.node "dd" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `dialog` produces.
-}
type alias DialogIs s =
    { s | sharedFlow : Shared }


{-| `dialog`'s closed attribute-capability row.
-}
type alias DialogAttrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , class : Supported
    , closedby : Supported
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
    , open : Supported
    , popover : Supported
    , role : Supported
    , slot : Supported
    , spellcheck : Supported
    , style : Supported
    , translate : Supported
    , writingsuggestions : Supported
    }


{-| The context demand `dialog` injects into its children.
-}
type alias DialogChildAdmittedBy childAdm =
    { childAdm | dialog : Ctx }


{-| The `dialog` element.
-}
dialog :
    List (Attr DialogAttrs msg)
    -> List (Element childAccepts (DialogChildAdmittedBy childAdm) msg)
    -> Element (DialogIs s) admittedBy msg
dialog attrs children =
    Ir.fromNode (Ir.node "dialog" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `div` produces.
-}
type alias DivIs s =
    { s | sharedFlow : Shared }


{-| `div`'s closed attribute-capability row.
-}
type alias DivAttrs =
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
    , role : DivRoles
    , slot : Supported
    , spellcheck : Supported
    , style : Supported
    , translate : Supported
    , writingsuggestions : Supported
    }


{-| The context demand `div` injects into its children.
-}
type alias DivChildAdmittedBy childAdm =
    { childAdm | div : Ctx }


{-| The ARIA roles `div` admits (see `TypedHtml.Aria`).
-}
type alias DivRoles =
    { banner : Role
    , complementary : Role
    , contentinfo : Role
    , form : Role
    , group : Role
    , list : Role
    , log : Role
    , main_ : Role
    , navigation : Role
    , none : Role
    , note : Role
    , presentation : Role
    , region : Role
    , search : Role
    , separator : Role
    , status : Role
    , timer : Role
    , toolbar : Role
    , tooltip : Role
    }


{-| The `div` element.
-}
div :
    List (Attr DivAttrs msg)
    -> List (Element childAccepts (DivChildAdmittedBy childAdm) msg)
    -> Element (DivIs s) admittedBy msg
div attrs children =
    Ir.fromNode (Ir.node "div" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `dl` produces.
-}
type alias DlIs s =
    { s | sharedFlow : Shared }


{-| `dl`'s closed attribute-capability row.
-}
type alias DlAttrs =
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


{-| The kinds `dl` admits.
-}
type alias DlContent =
    { dd : Brand
    , dt : Brand
    , sharedFlow : Shared
    }


{-| The context demand `dl` injects into its children.
-}
type alias DlChildAdmittedBy childAdm =
    { childAdm | dl : Ctx }


{-| The `dl` element.
-}
dl :
    List (Attr DlAttrs msg)
    -> List (Element DlContent (DlChildAdmittedBy childAdm) msg)
    -> Element (DlIs s) admittedBy msg
dl attrs children =
    Ir.fromNode (Ir.node "dl" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `dt` produces.
-}
type alias DtIs s =
    { s | dt : Brand }


{-| `dt`'s closed attribute-capability row.
-}
type alias DtAttrs =
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


{-| The kinds `dt` admits.
-}
type alias DtContent =
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


{-| The context demand `dt` injects into its children.
-}
type alias DtChildAdmittedBy childAdm =
    { childAdm | dt : Ctx }


{-| The CLOSED parent contexts `dt` is valid inside.
-}
type alias DtAdmittedBy =
    { dl : Ctx }


{-| The `dt` element.
-}
dt :
    List (Attr DtAttrs msg)
    -> List (Element DtContent (DtChildAdmittedBy childAdm) msg)
    -> Element (DtIs s) DtAdmittedBy msg
dt attrs children =
    Ir.fromNode (Ir.node "dt" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `figcaption` produces.
-}
type alias FigcaptionIs s =
    { s | figcaption : Brand }


{-| `figcaption`'s closed attribute-capability row.
-}
type alias FigcaptionAttrs =
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


{-| The kinds `figcaption` admits.
-}
type alias FigcaptionContent =
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


{-| The context demand `figcaption` injects into its children.
-}
type alias FigcaptionChildAdmittedBy childAdm =
    { childAdm | figcaption : Ctx }


{-| The CLOSED parent contexts `figcaption` is valid inside.
-}
type alias FigcaptionAdmittedBy =
    { figure : Ctx }


{-| The `figcaption` element.
-}
figcaption :
    List (Attr FigcaptionAttrs msg)
    -> List (Element FigcaptionContent (FigcaptionChildAdmittedBy childAdm) msg)
    -> Element (FigcaptionIs s) FigcaptionAdmittedBy msg
figcaption attrs children =
    Ir.fromNode (Ir.node "figcaption" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `figure` produces.
-}
type alias FigureIs s =
    { s | sharedFlow : Shared }


{-| `figure`'s closed attribute-capability row.
-}
type alias FigureAttrs =
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


{-| The context demand `figure` injects into its children.
-}
type alias FigureChildAdmittedBy childAdm =
    { childAdm | figure : Ctx }


{-| The `figure` element.
-}
figure :
    List (Attr FigureAttrs msg)
    -> List (Element childAccepts (FigureChildAdmittedBy childAdm) msg)
    -> Element (FigureIs s) admittedBy msg
figure attrs children =
    Ir.fromNode (Ir.node "figure" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `hr` produces.
-}
type alias HrIs s =
    { s | sharedFlow : Shared }


{-| `hr`'s closed attribute-capability row.
-}
type alias HrAttrs =
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


{-| The context demand `hr` injects into its children.
-}
type alias HrChildAdmittedBy childAdm =
    { childAdm | hr : Ctx }


{-| The `hr` element.
-}
hr :
    List (Attr HrAttrs msg)
    -> List (Element childAccepts (HrChildAdmittedBy childAdm) msg)
    -> Element (HrIs s) admittedBy msg
hr attrs children =
    Ir.fromNode (Ir.node "hr" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `li` produces.
-}
type alias LiIs s =
    { s | li : Brand }


{-| `li`'s closed attribute-capability row.
-}
type alias LiAttrs =
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
    , valueOrdinal : Supported
    , writingsuggestions : Supported
    }


{-| The kinds `li` admits.
-}
type alias LiContent =
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


{-| The context demand `li` injects into its children.
-}
type alias LiChildAdmittedBy childAdm =
    { childAdm | li : Ctx }


{-| The CLOSED parent contexts `li` is valid inside.
-}
type alias LiAdmittedBy =
    { menu : Ctx, ol : Ctx, ul : Ctx }


{-| The `li` element.
-}
li :
    List (Attr LiAttrs msg)
    -> List (Element LiContent (LiChildAdmittedBy childAdm) msg)
    -> Element (LiIs s) LiAdmittedBy msg
li attrs children =
    Ir.fromNode (Ir.node "li" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `menu` produces.
-}
type alias MenuIs s =
    { s | sharedFlow : Shared }


{-| `menu`'s closed attribute-capability row.
-}
type alias MenuAttrs =
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


{-| The kinds `menu` admits.
-}
type alias MenuContent =
    { li : Brand }


{-| The context demand `menu` injects into its children.
-}
type alias MenuChildAdmittedBy childAdm =
    { childAdm | menu : Ctx }


{-| The `menu` element.
-}
menu :
    List (Attr MenuAttrs msg)
    -> List (Element MenuContent (MenuChildAdmittedBy childAdm) msg)
    -> Element (MenuIs s) admittedBy msg
menu attrs children =
    Ir.fromNode (Ir.node "menu" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `ol` produces.
-}
type alias OlIs s =
    { s | sharedFlow : Shared }


{-| `ol`'s closed attribute-capability row.
-}
type alias OlAttrs =
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
    , reversed : Supported
    , role : Supported
    , slot : Supported
    , spellcheck : Supported
    , start : Supported
    , style : Supported
    , translate : Supported
    , writingsuggestions : Supported
    }


{-| The kinds `ol` admits.
-}
type alias OlContent =
    { li : Brand }


{-| The context demand `ol` injects into its children.
-}
type alias OlChildAdmittedBy childAdm =
    { childAdm | ol : Ctx }


{-| The `ol` element.
-}
ol :
    List (Attr OlAttrs msg)
    -> List (Element OlContent (OlChildAdmittedBy childAdm) msg)
    -> Element (OlIs s) admittedBy msg
ol attrs children =
    Ir.fromNode (Ir.node "ol" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `p` produces.
-}
type alias PIs s =
    { s | sharedFlow : Shared }


{-| `p`'s closed attribute-capability row.
-}
type alias PAttrs =
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


{-| The kinds `p` admits.
-}
type alias PContent =
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


{-| The context demand `p` injects into its children.
-}
type alias PChildAdmittedBy childAdm =
    { childAdm | p : Ctx }


{-| The `p` element.
-}
p :
    List (Attr PAttrs msg)
    -> List (Element PContent (PChildAdmittedBy childAdm) msg)
    -> Element (PIs s) admittedBy msg
p attrs children =
    Ir.fromNode (Ir.node "p" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `pre` produces.
-}
type alias PreIs s =
    { s | sharedFlow : Shared }


{-| `pre`'s closed attribute-capability row.
-}
type alias PreAttrs =
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


{-| The kinds `pre` admits.
-}
type alias PreContent =
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


{-| The context demand `pre` injects into its children.
-}
type alias PreChildAdmittedBy childAdm =
    { childAdm | pre : Ctx }


{-| The `pre` element.
-}
pre :
    List (Attr PreAttrs msg)
    -> List (Element PreContent (PreChildAdmittedBy childAdm) msg)
    -> Element (PreIs s) admittedBy msg
pre attrs children =
    Ir.fromNode (Ir.node "pre" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `ul` produces.
-}
type alias UlIs s =
    { s | sharedFlow : Shared }


{-| `ul`'s closed attribute-capability row.
-}
type alias UlAttrs =
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


{-| The kinds `ul` admits.
-}
type alias UlContent =
    { li : Brand }


{-| The context demand `ul` injects into its children.
-}
type alias UlChildAdmittedBy childAdm =
    { childAdm | ul : Ctx }


{-| The `ul` element.
-}
ul :
    List (Attr UlAttrs msg)
    -> List (Element UlContent (UlChildAdmittedBy childAdm) msg)
    -> Element (UlIs s) admittedBy msg
ul attrs children =
    Ir.fromNode (Ir.node "ul" attrs (List.map HtmlIr.Element.toNode children))


{-| See `TypedHtml.Attributes.cite`.
-}
cite : String -> Attr { c | cite : Supported } msg
cite =
    TypedHtml.Attributes.cite


{-| Which user actions will close the dialog
-}
closedby : String -> Attr { c | closedby : Supported } msg
closedby value_ =
    Ir.attribute "closedby" value_


{-| See `TypedHtml.Attributes.open`.
-}
open : Bool -> Attr { c | open : Supported } msg
open =
    TypedHtml.Attributes.open


{-| See `TypedHtml.Attributes.reversed`.
-}
reversed : Bool -> Attr { c | reversed : Supported } msg
reversed =
    TypedHtml.Attributes.reversed


{-| See `TypedHtml.Attributes.start`.
-}
start : Int -> Attr { c | start : Supported } msg
start =
    TypedHtml.Attributes.start


{-| See `TypedHtml.Attributes.valueOrdinal`.
-}
valueOrdinal : Int -> Attr { c | valueOrdinal : Supported } msg
valueOrdinal =
    TypedHtml.Attributes.valueOrdinal
