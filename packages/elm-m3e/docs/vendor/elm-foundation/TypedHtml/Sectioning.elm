module TypedHtml.Sectioning exposing
    ( address, article, aside, body, footer, h1, h2, h3, h4, h5, h6, header, hgroup, main_, nav, search, section
    , AddressIs, AddressAttrs, AddressChildAdmittedBy, ArticleIs, ArticleAttrs, ArticleChildAdmittedBy, AsideIs, AsideAttrs, AsideChildAdmittedBy, BodyIs, BodyAttrs, BodyChildAdmittedBy, FooterIs, FooterAttrs, FooterChildAdmittedBy, H1Is, H1Attrs, H1Content, H1ChildAdmittedBy, H2Is, H2Attrs, H2Content, H2ChildAdmittedBy, H3Is, H3Attrs, H3Content, H3ChildAdmittedBy, H4Is, H4Attrs, H4Content, H4ChildAdmittedBy, H5Is, H5Attrs, H5Content, H5ChildAdmittedBy, H6Is, H6Attrs, H6Content, H6ChildAdmittedBy, HeaderIs, HeaderAttrs, HeaderChildAdmittedBy, HgroupIs, HgroupAttrs, HgroupChildAdmittedBy, MainIs, MainAttrs, MainChildAdmittedBy, NavIs, NavAttrs, NavChildAdmittedBy, NavRoles, SearchIs, SearchAttrs, SearchChildAdmittedBy, SectionIs, SectionAttrs, SectionChildAdmittedBy, SectionRoles
    )

{-| The `Sectioning` element home: constructors, per-element rows, and
co-located re-exports of the shared attributes its elements admit.

@docs address, article, aside, body, footer, h1, h2, h3, h4, h5, h6, header, hgroup, main_, nav, search, section
@docs AddressIs, AddressAttrs, AddressChildAdmittedBy, ArticleIs, ArticleAttrs, ArticleChildAdmittedBy, AsideIs, AsideAttrs, AsideChildAdmittedBy, BodyIs, BodyAttrs, BodyChildAdmittedBy, FooterIs, FooterAttrs, FooterChildAdmittedBy, H1Is, H1Attrs, H1Content, H1ChildAdmittedBy, H2Is, H2Attrs, H2Content, H2ChildAdmittedBy, H3Is, H3Attrs, H3Content, H3ChildAdmittedBy, H4Is, H4Attrs, H4Content, H4ChildAdmittedBy, H5Is, H5Attrs, H5Content, H5ChildAdmittedBy, H6Is, H6Attrs, H6Content, H6ChildAdmittedBy, HeaderIs, HeaderAttrs, HeaderChildAdmittedBy, HgroupIs, HgroupAttrs, HgroupChildAdmittedBy, MainIs, MainAttrs, MainChildAdmittedBy, NavIs, NavAttrs, NavChildAdmittedBy, NavRoles, SearchIs, SearchAttrs, SearchChildAdmittedBy, SectionIs, SectionAttrs, SectionChildAdmittedBy, SectionRoles

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import TypedHtml.Kind exposing (Brand, Ctx, Role)


{-| The kind row `address` produces.
-}
type alias AddressIs s =
    { s | sharedFlow : Shared }


{-| `address`'s closed attribute-capability row.
-}
type alias AddressAttrs =
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


{-| The context demand `address` injects into its children.
-}
type alias AddressChildAdmittedBy childAdm =
    { childAdm | address : Ctx }


{-| The `address` element.
-}
address :
    List (Attr AddressAttrs msg)
    -> List (Element childAccepts (AddressChildAdmittedBy childAdm) msg)
    -> Element (AddressIs s) admittedBy msg
address attrs children =
    Ir.fromNode (Ir.node "address" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `article` produces.
-}
type alias ArticleIs s =
    { s | sharedFlow : Shared }


{-| `article`'s closed attribute-capability row.
-}
type alias ArticleAttrs =
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


{-| The context demand `article` injects into its children.
-}
type alias ArticleChildAdmittedBy childAdm =
    { childAdm | article : Ctx }


{-| The `article` element.
-}
article :
    List (Attr ArticleAttrs msg)
    -> List (Element childAccepts (ArticleChildAdmittedBy childAdm) msg)
    -> Element (ArticleIs s) admittedBy msg
article attrs children =
    Ir.fromNode (Ir.node "article" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `aside` produces.
-}
type alias AsideIs s =
    { s | sharedFlow : Shared }


{-| `aside`'s closed attribute-capability row.
-}
type alias AsideAttrs =
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


{-| The context demand `aside` injects into its children.
-}
type alias AsideChildAdmittedBy childAdm =
    { childAdm | aside : Ctx }


{-| The `aside` element.
-}
aside :
    List (Attr AsideAttrs msg)
    -> List (Element childAccepts (AsideChildAdmittedBy childAdm) msg)
    -> Element (AsideIs s) admittedBy msg
aside attrs children =
    Ir.fromNode (Ir.node "aside" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `body` produces.
-}
type alias BodyIs s =
    { s | body : Brand }


{-| `body`'s closed attribute-capability row.
-}
type alias BodyAttrs =
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


{-| The context demand `body` injects into its children.
-}
type alias BodyChildAdmittedBy childAdm =
    { childAdm | body : Ctx }


{-| The `body` element.
-}
body :
    List (Attr BodyAttrs msg)
    -> List (Element childAccepts (BodyChildAdmittedBy childAdm) msg)
    -> Element (BodyIs s) admittedBy msg
body attrs children =
    Ir.fromNode (Ir.node "body" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `footer` produces.
-}
type alias FooterIs s =
    { s | sharedFlow : Shared }


{-| `footer`'s closed attribute-capability row.
-}
type alias FooterAttrs =
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


{-| The context demand `footer` injects into its children.
-}
type alias FooterChildAdmittedBy childAdm =
    { childAdm | footer : Ctx }


{-| The `footer` element.
-}
footer :
    List (Attr FooterAttrs msg)
    -> List (Element childAccepts (FooterChildAdmittedBy childAdm) msg)
    -> Element (FooterIs s) admittedBy msg
footer attrs children =
    Ir.fromNode (Ir.node "footer" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `h1` produces.
-}
type alias H1Is s =
    { s | sharedFlow : Shared }


{-| `h1`'s closed attribute-capability row.
-}
type alias H1Attrs =
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


{-| The kinds `h1` admits.
-}
type alias H1Content =
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


{-| The context demand `h1` injects into its children.
-}
type alias H1ChildAdmittedBy childAdm =
    { childAdm | h1 : Ctx }


{-| The `h1` element.
-}
h1 :
    List (Attr H1Attrs msg)
    -> List (Element H1Content (H1ChildAdmittedBy childAdm) msg)
    -> Element (H1Is s) admittedBy msg
h1 attrs children =
    Ir.fromNode (Ir.node "h1" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `h2` produces.
-}
type alias H2Is s =
    { s | sharedFlow : Shared }


{-| `h2`'s closed attribute-capability row.
-}
type alias H2Attrs =
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


{-| The kinds `h2` admits.
-}
type alias H2Content =
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


{-| The context demand `h2` injects into its children.
-}
type alias H2ChildAdmittedBy childAdm =
    { childAdm | h2 : Ctx }


{-| The `h2` element.
-}
h2 :
    List (Attr H2Attrs msg)
    -> List (Element H2Content (H2ChildAdmittedBy childAdm) msg)
    -> Element (H2Is s) admittedBy msg
h2 attrs children =
    Ir.fromNode (Ir.node "h2" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `h3` produces.
-}
type alias H3Is s =
    { s | sharedFlow : Shared }


{-| `h3`'s closed attribute-capability row.
-}
type alias H3Attrs =
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


{-| The kinds `h3` admits.
-}
type alias H3Content =
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


{-| The context demand `h3` injects into its children.
-}
type alias H3ChildAdmittedBy childAdm =
    { childAdm | h3 : Ctx }


{-| The `h3` element.
-}
h3 :
    List (Attr H3Attrs msg)
    -> List (Element H3Content (H3ChildAdmittedBy childAdm) msg)
    -> Element (H3Is s) admittedBy msg
h3 attrs children =
    Ir.fromNode (Ir.node "h3" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `h4` produces.
-}
type alias H4Is s =
    { s | sharedFlow : Shared }


{-| `h4`'s closed attribute-capability row.
-}
type alias H4Attrs =
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


{-| The kinds `h4` admits.
-}
type alias H4Content =
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


{-| The context demand `h4` injects into its children.
-}
type alias H4ChildAdmittedBy childAdm =
    { childAdm | h4 : Ctx }


{-| The `h4` element.
-}
h4 :
    List (Attr H4Attrs msg)
    -> List (Element H4Content (H4ChildAdmittedBy childAdm) msg)
    -> Element (H4Is s) admittedBy msg
h4 attrs children =
    Ir.fromNode (Ir.node "h4" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `h5` produces.
-}
type alias H5Is s =
    { s | sharedFlow : Shared }


{-| `h5`'s closed attribute-capability row.
-}
type alias H5Attrs =
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


{-| The kinds `h5` admits.
-}
type alias H5Content =
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


{-| The context demand `h5` injects into its children.
-}
type alias H5ChildAdmittedBy childAdm =
    { childAdm | h5 : Ctx }


{-| The `h5` element.
-}
h5 :
    List (Attr H5Attrs msg)
    -> List (Element H5Content (H5ChildAdmittedBy childAdm) msg)
    -> Element (H5Is s) admittedBy msg
h5 attrs children =
    Ir.fromNode (Ir.node "h5" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `h6` produces.
-}
type alias H6Is s =
    { s | sharedFlow : Shared }


{-| `h6`'s closed attribute-capability row.
-}
type alias H6Attrs =
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


{-| The kinds `h6` admits.
-}
type alias H6Content =
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


{-| The context demand `h6` injects into its children.
-}
type alias H6ChildAdmittedBy childAdm =
    { childAdm | h6 : Ctx }


{-| The `h6` element.
-}
h6 :
    List (Attr H6Attrs msg)
    -> List (Element H6Content (H6ChildAdmittedBy childAdm) msg)
    -> Element (H6Is s) admittedBy msg
h6 attrs children =
    Ir.fromNode (Ir.node "h6" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `header` produces.
-}
type alias HeaderIs s =
    { s | sharedFlow : Shared }


{-| `header`'s closed attribute-capability row.
-}
type alias HeaderAttrs =
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


{-| The context demand `header` injects into its children.
-}
type alias HeaderChildAdmittedBy childAdm =
    { childAdm | header : Ctx }


{-| The `header` element.
-}
header :
    List (Attr HeaderAttrs msg)
    -> List (Element childAccepts (HeaderChildAdmittedBy childAdm) msg)
    -> Element (HeaderIs s) admittedBy msg
header attrs children =
    Ir.fromNode (Ir.node "header" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `hgroup` produces.
-}
type alias HgroupIs s =
    { s | sharedFlow : Shared }


{-| `hgroup`'s closed attribute-capability row.
-}
type alias HgroupAttrs =
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


{-| The context demand `hgroup` injects into its children.
-}
type alias HgroupChildAdmittedBy childAdm =
    { childAdm | hgroup : Ctx }


{-| The `hgroup` element.
-}
hgroup :
    List (Attr HgroupAttrs msg)
    -> List (Element childAccepts (HgroupChildAdmittedBy childAdm) msg)
    -> Element (HgroupIs s) admittedBy msg
hgroup attrs children =
    Ir.fromNode (Ir.node "hgroup" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `main` produces.
-}
type alias MainIs s =
    { s | sharedFlow : Shared }


{-| `main`'s closed attribute-capability row.
-}
type alias MainAttrs =
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


{-| The context demand `main` injects into its children.
-}
type alias MainChildAdmittedBy childAdm =
    { childAdm | main_ : Ctx }


{-| The `main` element.
-}
main_ :
    List (Attr MainAttrs msg)
    -> List (Element childAccepts (MainChildAdmittedBy childAdm) msg)
    -> Element (MainIs s) admittedBy msg
main_ attrs children =
    Ir.fromNode (Ir.node "main" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `nav` produces.
-}
type alias NavIs s =
    { s | sharedFlow : Shared }


{-| `nav`'s closed attribute-capability row.
-}
type alias NavAttrs =
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
    , role : NavRoles
    , slot : Supported
    , spellcheck : Supported
    , style : Supported
    , translate : Supported
    , writingsuggestions : Supported
    }


{-| The context demand `nav` injects into its children.
-}
type alias NavChildAdmittedBy childAdm =
    { childAdm | nav : Ctx }


{-| The ARIA roles `nav` admits (see `TypedHtml.Aria`).
-}
type alias NavRoles =
    { menu : Role
    , menubar : Role
    , navigation : Role
    , none : Role
    , presentation : Role
    , tablist : Role
    }


{-| The `nav` element.
-}
nav :
    List (Attr NavAttrs msg)
    -> List (Element childAccepts (NavChildAdmittedBy childAdm) msg)
    -> Element (NavIs s) admittedBy msg
nav attrs children =
    Ir.fromNode (Ir.node "nav" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `search` produces.
-}
type alias SearchIs s =
    { s | sharedFlow : Shared }


{-| `search`'s closed attribute-capability row.
-}
type alias SearchAttrs =
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


{-| The context demand `search` injects into its children.
-}
type alias SearchChildAdmittedBy childAdm =
    { childAdm | search : Ctx }


{-| The `search` element.
-}
search :
    List (Attr SearchAttrs msg)
    -> List (Element childAccepts (SearchChildAdmittedBy childAdm) msg)
    -> Element (SearchIs s) admittedBy msg
search attrs children =
    Ir.fromNode (Ir.node "search" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `section` produces.
-}
type alias SectionIs s =
    { s | sharedFlow : Shared }


{-| `section`'s closed attribute-capability row.
-}
type alias SectionAttrs =
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
    , role : SectionRoles
    , slot : Supported
    , spellcheck : Supported
    , style : Supported
    , translate : Supported
    , writingsuggestions : Supported
    }


{-| The context demand `section` injects into its children.
-}
type alias SectionChildAdmittedBy childAdm =
    { childAdm | section : Ctx }


{-| The ARIA roles `section` admits (see `TypedHtml.Aria`).
-}
type alias SectionRoles =
    { alert : Role
    , alertdialog : Role
    , application : Role
    , banner : Role
    , complementary : Role
    , contentinfo : Role
    , dialog : Role
    , document : Role
    , feed : Role
    , group : Role
    , log : Role
    , main_ : Role
    , marquee : Role
    , navigation : Role
    , none : Role
    , note : Role
    , presentation : Role
    , region : Role
    , search : Role
    , status : Role
    , timer : Role
    , toolbar : Role
    , tooltip : Role
    }


{-| The `section` element.
-}
section :
    List (Attr SectionAttrs msg)
    -> List (Element childAccepts (SectionChildAdmittedBy childAdm) msg)
    -> Element (SectionIs s) admittedBy msg
section attrs children =
    Ir.fromNode (Ir.node "section" attrs (List.map HtmlIr.Element.toNode children))
