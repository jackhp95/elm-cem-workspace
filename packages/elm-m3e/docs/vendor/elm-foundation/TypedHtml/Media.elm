module TypedHtml.Media exposing
    ( audio, picture, pictureSource, source, track, video
    , AudioIs, AudioAttrs, AudioContent, AudioChildAdmittedBy, PictureIs, PictureAttrs, PictureContent, PictureChildAdmittedBy, PictureSourceIs, PictureSourceAttrs, PictureSourceChildAdmittedBy, PictureSourceAdmittedBy, SourceIs, SourceAttrs, SourceChildAdmittedBy, SourceAdmittedBy, TrackIs, TrackAttrs, TrackChildAdmittedBy, TrackAdmittedBy, VideoIs, VideoAttrs, VideoContent, VideoChildAdmittedBy
    , autoplay, controls, crossorigin, default, height, kind, label, loading, loop, media, muted, playsinline, poster, preload, sizes, src, srclang, srcset, width, defaultMuted
    )

{-| The `Media` element home: constructors, per-element rows, and
co-located re-exports of the shared attributes its elements admit.

@docs audio, picture, pictureSource, source, track, video
@docs AudioIs, AudioAttrs, AudioContent, AudioChildAdmittedBy, PictureIs, PictureAttrs, PictureContent, PictureChildAdmittedBy, PictureSourceIs, PictureSourceAttrs, PictureSourceChildAdmittedBy, PictureSourceAdmittedBy, SourceIs, SourceAttrs, SourceChildAdmittedBy, SourceAdmittedBy, TrackIs, TrackAttrs, TrackChildAdmittedBy, TrackAdmittedBy, VideoIs, VideoAttrs, VideoContent, VideoChildAdmittedBy
@docs autoplay, controls, crossorigin, default, height, kind, label, loading, loop, media, muted, playsinline, poster, preload, sizes, src, srclang, srcset, width, defaultMuted

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import TypedHtml.Attributes
import TypedHtml.Kind exposing (Brand, Ctx)


{-| The kind row `audio` produces.
-}
type alias AudioIs s =
    { s | sharedPhrasing : Shared }


{-| `audio`'s closed attribute-capability row.
-}
type alias AudioAttrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , autoplay : Supported
    , class : Supported
    , contenteditable : Supported
    , controls : Supported
    , crossorigin : Supported
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
    , loading : Supported
    , loop : Supported
    , muted : Supported
    , nonce : Supported
    , onClick : Supported
    , popover : Supported
    , preload : Supported
    , role : Supported
    , slot : Supported
    , spellcheck : Supported
    , src : Supported
    , style : Supported
    , translate : Supported
    , writingsuggestions : Supported
    }


{-| The kinds `audio` admits.
-}
type alias AudioContent =
    { sharedText : Shared
    , source : Brand
    , track : Brand
    }


{-| The context demand `audio` injects into its children.
-}
type alias AudioChildAdmittedBy childAdm =
    { childAdm | audio : Ctx }


{-| The `audio` element.
-}
audio :
    List (Attr AudioAttrs msg)
    -> List (Element AudioContent (AudioChildAdmittedBy childAdm) msg)
    -> Element (AudioIs s) admittedBy msg
audio attrs children =
    Ir.fromNode (Ir.node "audio" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `picture` produces.
-}
type alias PictureIs s =
    { s | sharedPhrasing : Shared }


{-| `picture`'s closed attribute-capability row.
-}
type alias PictureAttrs =
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


{-| The kinds `picture` admits.
-}
type alias PictureContent =
    { img : Brand
    , pictureSource : Brand
    }


{-| The context demand `picture` injects into its children.
-}
type alias PictureChildAdmittedBy childAdm =
    { childAdm | picture : Ctx }


{-| The `picture` element.
-}
picture :
    List (Attr PictureAttrs msg)
    -> List (Element PictureContent (PictureChildAdmittedBy childAdm) msg)
    -> Element (PictureIs s) admittedBy msg
picture attrs children =
    Ir.fromNode (Ir.node "picture" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `source` produces.
-}
type alias PictureSourceIs s =
    { s | pictureSource : Brand }


{-| `source`'s closed attribute-capability row.
-}
type alias PictureSourceAttrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , class : Supported
    , contenteditable : Supported
    , draggable : Supported
    , enterkeyhint : Supported
    , height : Supported
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
    , sizes : Supported
    , slot : Supported
    , spellcheck : Supported
    , srcset : Supported
    , style : Supported
    , translate : Supported
    , width : Supported
    , writingsuggestions : Supported
    }


{-| The context demand `source` injects into its children.
-}
type alias PictureSourceChildAdmittedBy childAdm =
    { childAdm | pictureSource : Ctx }


{-| The CLOSED parent contexts `source` is valid inside.
-}
type alias PictureSourceAdmittedBy =
    { picture : Ctx }


{-| The `source` element.
-}
pictureSource :
    List (Attr PictureSourceAttrs msg)
    -> List (Element childAccepts (PictureSourceChildAdmittedBy childAdm) msg)
    -> Element (PictureSourceIs s) PictureSourceAdmittedBy msg
pictureSource attrs children =
    Ir.fromNode (Ir.node "source" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `source` produces.
-}
type alias SourceIs s =
    { s | source : Brand }


{-| `source`'s closed attribute-capability row.
-}
type alias SourceAttrs =
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
    , media : Supported
    , nonce : Supported
    , popover : Supported
    , role : Supported
    , sizes : Supported
    , slot : Supported
    , spellcheck : Supported
    , src : Supported
    , srcset : Supported
    , style : Supported
    , translate : Supported
    , writingsuggestions : Supported
    }


{-| The context demand `source` injects into its children.
-}
type alias SourceChildAdmittedBy childAdm =
    { childAdm | source : Ctx }


{-| The CLOSED parent contexts `source` is valid inside.
-}
type alias SourceAdmittedBy =
    { audio : Ctx, video : Ctx }


{-| The `source` element.
-}
source :
    List (Attr SourceAttrs msg)
    -> List (Element childAccepts (SourceChildAdmittedBy childAdm) msg)
    -> Element (SourceIs s) SourceAdmittedBy msg
source attrs children =
    Ir.fromNode (Ir.node "source" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `track` produces.
-}
type alias TrackIs s =
    { s | track : Brand }


{-| `track`'s closed attribute-capability row.
-}
type alias TrackAttrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , class : Supported
    , contenteditable : Supported
    , default : Supported
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
    , kind : Supported
    , label : Supported
    , nonce : Supported
    , popover : Supported
    , role : Supported
    , slot : Supported
    , spellcheck : Supported
    , src : Supported
    , srclang : Supported
    , style : Supported
    , translate : Supported
    , writingsuggestions : Supported
    }


{-| The context demand `track` injects into its children.
-}
type alias TrackChildAdmittedBy childAdm =
    { childAdm | track : Ctx }


{-| The CLOSED parent contexts `track` is valid inside.
-}
type alias TrackAdmittedBy =
    { audio : Ctx, video : Ctx }


{-| The `track` element.
-}
track :
    List (Attr TrackAttrs msg)
    -> List (Element childAccepts (TrackChildAdmittedBy childAdm) msg)
    -> Element (TrackIs s) TrackAdmittedBy msg
track attrs children =
    Ir.fromNode (Ir.node "track" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `video` produces.
-}
type alias VideoIs s =
    { s | sharedPhrasing : Shared }


{-| `video`'s closed attribute-capability row.
-}
type alias VideoAttrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , autoplay : Supported
    , class : Supported
    , contenteditable : Supported
    , crossorigin : Supported
    , draggable : Supported
    , enterkeyhint : Supported
    , height : Supported
    , id : Supported
    , inert : Supported
    , inputmode : Supported
    , itemid : Supported
    , itemprop : Supported
    , itemref : Supported
    , itemscope : Supported
    , itemtype : Supported
    , loading : Supported
    , loop : Supported
    , muted : Supported
    , nonce : Supported
    , onClick : Supported
    , playsinline : Supported
    , popover : Supported
    , poster : Supported
    , preload : Supported
    , role : Supported
    , slot : Supported
    , spellcheck : Supported
    , src : Supported
    , style : Supported
    , translate : Supported
    , width : Supported
    , writingsuggestions : Supported
    }


{-| The kinds `video` admits.
-}
type alias VideoContent =
    { sharedText : Shared
    , source : Brand
    , track : Brand
    }


{-| The context demand `video` injects into its children.
-}
type alias VideoChildAdmittedBy childAdm =
    { childAdm | video : Ctx }


{-| The `video` element.
-}
video :
    List (Attr VideoAttrs msg)
    -> List (Element VideoContent (VideoChildAdmittedBy childAdm) msg)
    -> Element (VideoIs s) admittedBy msg
video attrs children =
    Ir.fromNode (Ir.node "video" attrs (List.map HtmlIr.Element.toNode children))


{-| See `TypedHtml.Attributes.autoplay`.
-}
autoplay : Bool -> Attr { c | autoplay : Supported } msg
autoplay =
    TypedHtml.Attributes.autoplay


{-| See `TypedHtml.Attributes.controls`.
-}
controls : Bool -> Attr { c | controls : Supported } msg
controls =
    TypedHtml.Attributes.controls


{-| How the element handles crossorigin requests
-}
crossorigin : String -> Attr { c | crossorigin : Supported } msg
crossorigin value_ =
    Ir.attribute "crossorigin" value_


{-| See `TypedHtml.Attributes.default`.
-}
default : Bool -> Attr { c | default : Supported } msg
default =
    TypedHtml.Attributes.default


{-| See `TypedHtml.Attributes.height`.
-}
height : Int -> Attr { c | height : Supported } msg
height =
    TypedHtml.Attributes.height


{-| The type of text track
-}
kind : String -> Attr { c | kind : Supported } msg
kind value_ =
    Ir.attribute "kind" value_


{-| See `TypedHtml.Attributes.label`.
-}
label : String -> Attr { c | label : Supported } msg
label =
    TypedHtml.Attributes.label


{-| Used when determining loading deferral
-}
loading : String -> Attr { c | loading : Supported } msg
loading value_ =
    Ir.attribute "loading" value_


{-| See `TypedHtml.Attributes.loop`.
-}
loop : Bool -> Attr { c | loop : Supported } msg
loop =
    TypedHtml.Attributes.loop


{-| See `TypedHtml.Attributes.media`.
-}
media : String -> Attr { c | media : Supported } msg
media =
    TypedHtml.Attributes.media


{-| See `TypedHtml.Attributes.muted`.
-}
muted : Bool -> Attr { c | muted : Supported } msg
muted =
    TypedHtml.Attributes.muted


{-| See `TypedHtml.Attributes.playsinline`.
-}
playsinline : Bool -> Attr { c | playsinline : Supported } msg
playsinline =
    TypedHtml.Attributes.playsinline


{-| See `TypedHtml.Attributes.poster`.
-}
poster : String -> Attr { c | poster : Supported } msg
poster =
    TypedHtml.Attributes.poster


{-| Hints how much buffering the media resource will likely need
-}
preload : String -> Attr { c | preload : Supported } msg
preload value_ =
    Ir.attribute "preload" value_


{-| See `TypedHtml.Attributes.sizes`.
-}
sizes : String -> Attr { c | sizes : Supported } msg
sizes =
    TypedHtml.Attributes.sizes


{-| See `TypedHtml.Attributes.src`.
-}
src : String -> Attr { c | src : Supported } msg
src =
    TypedHtml.Attributes.src


{-| See `TypedHtml.Attributes.srclang`.
-}
srclang : String -> Attr { c | srclang : Supported } msg
srclang =
    TypedHtml.Attributes.srclang


{-| See `TypedHtml.Attributes.srcset`.
-}
srcset : String -> Attr { c | srcset : Supported } msg
srcset =
    TypedHtml.Attributes.srcset


{-| See `TypedHtml.Attributes.width`.
-}
width : Int -> Attr { c | width : Supported } msg
width =
    TypedHtml.Attributes.width


{-| See `TypedHtml.Attributes.defaultMuted`.
-}
defaultMuted : Bool -> Attr { c | muted : Supported } msg
defaultMuted =
    TypedHtml.Attributes.defaultMuted
