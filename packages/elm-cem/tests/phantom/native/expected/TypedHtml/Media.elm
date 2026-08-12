module TypedHtml.Media exposing
    ( picture, pictureSource, source, track, video
    , PictureIs, PictureAttrs, PictureContent, PictureChildAdmittedBy, PictureSourceIs, PictureSourceAttrs, PictureSourceChildAdmittedBy, PictureSourceAdmittedBy, SourceIs, SourceAttrs, SourceChildAdmittedBy, SourceAdmittedBy, TrackIs, TrackAttrs, TrackChildAdmittedBy, TrackAdmittedBy, VideoIs, VideoAttrs, VideoContent, VideoChildAdmittedBy
    , src, srcset
    )

{-| The `Media` element home: constructors, per-element rows, and
co-located re-exports of the shared attributes its elements admit.

@docs picture, pictureSource, source, track, video
@docs PictureIs, PictureAttrs, PictureContent, PictureChildAdmittedBy, PictureSourceIs, PictureSourceAttrs, PictureSourceChildAdmittedBy, PictureSourceAdmittedBy, SourceIs, SourceAttrs, SourceChildAdmittedBy, SourceAdmittedBy, TrackIs, TrackAttrs, TrackChildAdmittedBy, TrackAdmittedBy, VideoIs, VideoAttrs, VideoContent, VideoChildAdmittedBy
@docs src, srcset

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import TypedHtml.Attributes
import TypedHtml.Kind exposing (Brand, Ctx)


{-| The kind row `picture` produces.
-}
type alias PictureIs s =
    { s | picture : Brand }


{-| `picture`'s closed attribute-capability row.
-}
type alias PictureAttrs =
    { autofocus : Supported
    , class : Supported
    , dir : Supported
    , hidden : Supported
    , id : Supported
    , role : Supported
    , slot : Supported
    , style : Supported
    , tabindex : Supported
    }


{-| The kinds `picture` admits.
-}
type alias PictureContent =
    { pictureSource : Brand }


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
    { autofocus : Supported
    , class : Supported
    , dir : Supported
    , hidden : Supported
    , id : Supported
    , role : Supported
    , slot : Supported
    , srcset : Supported
    , style : Supported
    , tabindex : Supported
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
    { autofocus : Supported
    , class : Supported
    , dir : Supported
    , hidden : Supported
    , id : Supported
    , role : Supported
    , slot : Supported
    , src : Supported
    , style : Supported
    , tabindex : Supported
    }


{-| The context demand `source` injects into its children.
-}
type alias SourceChildAdmittedBy childAdm =
    { childAdm | source : Ctx }


{-| The CLOSED parent contexts `source` is valid inside.
-}
type alias SourceAdmittedBy =
    { video : Ctx }


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
    { autofocus : Supported
    , class : Supported
    , dir : Supported
    , hidden : Supported
    , id : Supported
    , role : Supported
    , slot : Supported
    , src : Supported
    , style : Supported
    , tabindex : Supported
    }


{-| The context demand `track` injects into its children.
-}
type alias TrackChildAdmittedBy childAdm =
    { childAdm | track : Ctx }


{-| The CLOSED parent contexts `track` is valid inside.
-}
type alias TrackAdmittedBy =
    { video : Ctx }


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
    { s | video : Brand }


{-| `video`'s closed attribute-capability row.
-}
type alias VideoAttrs =
    { autofocus : Supported
    , class : Supported
    , dir : Supported
    , hidden : Supported
    , id : Supported
    , role : Supported
    , slot : Supported
    , style : Supported
    , tabindex : Supported
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


{-| See `TypedHtml.Attributes.src`.
-}
src : String -> Attr { c | src : Supported } msg
src =
    TypedHtml.Attributes.src


{-| See `TypedHtml.Attributes.srcset`.
-}
srcset : String -> Attr { c | srcset : Supported } msg
srcset =
    TypedHtml.Attributes.srcset
