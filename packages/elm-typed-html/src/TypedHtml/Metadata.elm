module TypedHtml.Metadata exposing
    ( base, head, link, meta, style, title
    , BaseIs, BaseAttrs, BaseChildAdmittedBy, HeadIs, HeadAttrs, HeadChildAdmittedBy, LinkIs, LinkAttrs, LinkChildAdmittedBy, MetaIs, MetaAttrs, MetaChildAdmittedBy, StyleIs, StyleAttrs, StyleContent, StyleChildAdmittedBy, TitleIs, TitleAttrs, TitleContent, TitleChildAdmittedBy
    , blocking, charset, color, content, crossorigin, disabled, fetchpriority, href, hreflang, httpEquiv, imagesizes, imagesrcset, integrity, media, name, referrerpolicy, rel, sizes, target
    )

{-| The `Metadata` element home: constructors, per-element rows, and
co-located re-exports of the shared attributes its elements admit.

@docs base, head, link, meta, style, title
@docs BaseIs, BaseAttrs, BaseChildAdmittedBy, HeadIs, HeadAttrs, HeadChildAdmittedBy, LinkIs, LinkAttrs, LinkChildAdmittedBy, MetaIs, MetaAttrs, MetaChildAdmittedBy, StyleIs, StyleAttrs, StyleContent, StyleChildAdmittedBy, TitleIs, TitleAttrs, TitleContent, TitleChildAdmittedBy
@docs blocking, charset, color, content, crossorigin, disabled, fetchpriority, href, hreflang, httpEquiv, imagesizes, imagesrcset, integrity, media, name, referrerpolicy, rel, sizes, target

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import TypedHtml.Attributes
import TypedHtml.Kind exposing (Brand, Ctx)


{-| The kind row `base` produces.
-}
type alias BaseIs s =
    { s | base : Brand }


{-| `base`'s closed attribute-capability row.
-}
type alias BaseAttrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , class : Supported
    , contenteditable : Supported
    , draggable : Supported
    , enterkeyhint : Supported
    , href : Supported
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
    , target : Supported
    , translate : Supported
    , writingsuggestions : Supported
    }


{-| The context demand `base` injects into its children.
-}
type alias BaseChildAdmittedBy childAdm =
    { childAdm | base : Ctx }


{-| The `base` element.
-}
base :
    List (Attr BaseAttrs msg)
    -> List (Element childAccepts (BaseChildAdmittedBy childAdm) msg)
    -> Element (BaseIs s) admittedBy msg
base attrs children =
    Ir.fromNode (Ir.node "base" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `head` produces.
-}
type alias HeadIs s =
    { s | head : Brand }


{-| `head`'s closed attribute-capability row.
-}
type alias HeadAttrs =
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


{-| The context demand `head` injects into its children.
-}
type alias HeadChildAdmittedBy childAdm =
    { childAdm | head : Ctx }


{-| The `head` element.
-}
head :
    List (Attr HeadAttrs msg)
    -> List (Element TypedHtml.Kind.Metadata (HeadChildAdmittedBy childAdm) msg)
    -> Element (HeadIs s) admittedBy msg
head attrs children =
    Ir.fromNode (Ir.node "head" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `link` produces.
-}
type alias LinkIs s =
    { s | link : Brand }


{-| `link`'s closed attribute-capability row.
-}
type alias LinkAttrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , blocking : Supported
    , class : Supported
    , color : Supported
    , contenteditable : Supported
    , crossorigin : Supported
    , disabled : Supported
    , draggable : Supported
    , enterkeyhint : Supported
    , fetchpriority : Supported
    , href : Supported
    , hreflang : Supported
    , id : Supported
    , imagesizes : Supported
    , imagesrcset : Supported
    , inert : Supported
    , inputmode : Supported
    , integrity : Supported
    , itemid : Supported
    , itemprop : Supported
    , itemref : Supported
    , itemscope : Supported
    , itemtype : Supported
    , media : Supported
    , nonce : Supported
    , popover : Supported
    , referrerpolicy : Supported
    , rel : Supported
    , role : Supported
    , sizes : Supported
    , slot : Supported
    , spellcheck : Supported
    , style : Supported
    , translate : Supported
    , writingsuggestions : Supported
    }


{-| The context demand `link` injects into its children.
-}
type alias LinkChildAdmittedBy childAdm =
    { childAdm | link : Ctx }


{-| The `link` element.
-}
link :
    List (Attr LinkAttrs msg)
    -> List (Element childAccepts (LinkChildAdmittedBy childAdm) msg)
    -> Element (LinkIs s) admittedBy msg
link attrs children =
    Ir.fromNode (Ir.node "link" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `meta` produces.
-}
type alias MetaIs s =
    { s | meta : Brand }


{-| `meta`'s closed attribute-capability row.
-}
type alias MetaAttrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , charset : Supported
    , class : Supported
    , content : Supported
    , contenteditable : Supported
    , draggable : Supported
    , enterkeyhint : Supported
    , httpEquiv : Supported
    , id : Supported
    , inert : Supported
    , inputmode : Supported
    , itemid : Supported
    , itemprop : Supported
    , itemref : Supported
    , itemscope : Supported
    , itemtype : Supported
    , media : Supported
    , name : Supported
    , nonce : Supported
    , popover : Supported
    , role : Supported
    , slot : Supported
    , spellcheck : Supported
    , style : Supported
    , translate : Supported
    , writingsuggestions : Supported
    }


{-| The context demand `meta` injects into its children.
-}
type alias MetaChildAdmittedBy childAdm =
    { childAdm | meta : Ctx }


{-| The `meta` element.
-}
meta :
    List (Attr MetaAttrs msg)
    -> List (Element childAccepts (MetaChildAdmittedBy childAdm) msg)
    -> Element (MetaIs s) admittedBy msg
meta attrs children =
    Ir.fromNode (Ir.node "meta" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `style` produces.
-}
type alias StyleIs s =
    { s | style : Brand }


{-| `style`'s closed attribute-capability row.
-}
type alias StyleAttrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , blocking : Supported
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
    , media : Supported
    , nonce : Supported
    , popover : Supported
    , role : Supported
    , slot : Supported
    , spellcheck : Supported
    , style : Supported
    , translate : Supported
    , writingsuggestions : Supported
    }


{-| The kinds `style` admits.
-}
type alias StyleContent =
    { sharedText : Shared }


{-| The context demand `style` injects into its children.
-}
type alias StyleChildAdmittedBy childAdm =
    { childAdm | style : Ctx }


{-| The `style` element.
-}
style :
    List (Attr StyleAttrs msg)
    -> List (Element StyleContent (StyleChildAdmittedBy childAdm) msg)
    -> Element (StyleIs s) admittedBy msg
style attrs children =
    Ir.fromNode (Ir.node "style" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `title` produces.
-}
type alias TitleIs s =
    { s | title : Brand }


{-| `title`'s closed attribute-capability row.
-}
type alias TitleAttrs =
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


{-| The kinds `title` admits.
-}
type alias TitleContent =
    { sharedText : Shared }


{-| The context demand `title` injects into its children.
-}
type alias TitleChildAdmittedBy childAdm =
    { childAdm | title : Ctx }


{-| The `title` element.
-}
title :
    List (Attr TitleAttrs msg)
    -> List (Element TitleContent (TitleChildAdmittedBy childAdm) msg)
    -> Element (TitleIs s) admittedBy msg
title attrs children =
    Ir.fromNode (Ir.node "title" attrs (List.map HtmlIr.Element.toNode children))


{-| Whether the element is potentially render-blocking
-}
blocking : String -> Attr { c | blocking : Supported } msg
blocking value_ =
    Ir.attribute "blocking" value_


{-| Character encoding declaration
-}
charset : String -> Attr { c | charset : Supported } msg
charset value_ =
    Ir.attribute "charset" value_


{-| See `TypedHtml.Attributes.color`.
-}
color : String -> Attr { c | color : Supported } msg
color =
    TypedHtml.Attributes.color


{-| See `TypedHtml.Attributes.content`.
-}
content : String -> Attr { c | content : Supported } msg
content =
    TypedHtml.Attributes.content


{-| How the element handles crossorigin requests
-}
crossorigin : String -> Attr { c | crossorigin : Supported } msg
crossorigin value_ =
    Ir.attribute "crossorigin" value_


{-| See `TypedHtml.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    TypedHtml.Attributes.disabled


{-| Sets the priority for fetches initiated by the element
-}
fetchpriority : String -> Attr { c | fetchpriority : Supported } msg
fetchpriority value_ =
    Ir.attribute "fetchpriority" value_


{-| See `TypedHtml.Attributes.href`.
-}
href : String -> Attr { c | href : Supported } msg
href =
    TypedHtml.Attributes.href


{-| See `TypedHtml.Attributes.hreflang`.
-}
hreflang : String -> Attr { c | hreflang : Supported } msg
hreflang =
    TypedHtml.Attributes.hreflang


{-| Pragma directive
-}
httpEquiv : String -> Attr { c | httpEquiv : Supported } msg
httpEquiv value_ =
    Ir.attribute "http-equiv" value_


{-| See `TypedHtml.Attributes.imagesizes`.
-}
imagesizes : String -> Attr { c | imagesizes : Supported } msg
imagesizes =
    TypedHtml.Attributes.imagesizes


{-| See `TypedHtml.Attributes.imagesrcset`.
-}
imagesrcset : String -> Attr { c | imagesrcset : Supported } msg
imagesrcset =
    TypedHtml.Attributes.imagesrcset


{-| See `TypedHtml.Attributes.integrity`.
-}
integrity : String -> Attr { c | integrity : Supported } msg
integrity =
    TypedHtml.Attributes.integrity


{-| See `TypedHtml.Attributes.media`.
-}
media : String -> Attr { c | media : Supported } msg
media =
    TypedHtml.Attributes.media


{-| See `TypedHtml.Attributes.name`.
-}
name : String -> Attr { c | name : Supported } msg
name =
    TypedHtml.Attributes.name


{-| Referrer policy for fetches initiated by the element
-}
referrerpolicy : String -> Attr { c | referrerpolicy : Supported } msg
referrerpolicy value_ =
    Ir.attribute "referrerpolicy" value_


{-| See `TypedHtml.Attributes.rel`.
-}
rel : String -> Attr { c | rel : Supported } msg
rel =
    TypedHtml.Attributes.rel


{-| See `TypedHtml.Attributes.sizes`.
-}
sizes : String -> Attr { c | sizes : Supported } msg
sizes =
    TypedHtml.Attributes.sizes


{-| See `TypedHtml.Attributes.target`.
-}
target : String -> Attr { c | target : Supported } msg
target =
    TypedHtml.Attributes.target
