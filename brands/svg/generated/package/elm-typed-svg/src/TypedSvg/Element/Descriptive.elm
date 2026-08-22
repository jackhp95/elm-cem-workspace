module TypedSvg.Element.Descriptive exposing
    ( desc, metadata, title
    , DescIs, DescAttrs, DescContent, DescChildAdmittedBy, MetadataIs, MetadataAttrs, MetadataChildAdmittedBy, TitleIs, TitleAttrs, TitleContent, TitleChildAdmittedBy
    )

{-| The `Descriptive` element home: constructors, per-element rows, and
co-located re-exports of the shared attributes its elements admit.

@docs desc, metadata, title
@docs DescIs, DescAttrs, DescContent, DescChildAdmittedBy, MetadataIs, MetadataAttrs, MetadataChildAdmittedBy, TitleIs, TitleAttrs, TitleContent, TitleChildAdmittedBy

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import TypedSvg.Kind exposing (Brand, Ctx)


{-| The kind row `desc` produces.
-}
type alias DescIs s =
    { s | desc : Brand }


{-| `desc`'s closed attribute-capability row.
-}
type alias DescAttrs =
    { class : Supported
    , id : Supported
    , style : Supported
    }


{-| The kinds `desc` admits.
-}
type alias DescContent =
    { sharedText : Shared }


{-| The context demand `desc` injects into its children.
-}
type alias DescChildAdmittedBy childAdm =
    { childAdm | desc : Ctx }


{-| The `desc` element.
-}
desc :
    List (Attr DescAttrs msg)
    -> List (Element DescContent (DescChildAdmittedBy childAdm) msg)
    -> Element (DescIs s) admittedBy msg
desc attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "desc" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `metadata` produces.
-}
type alias MetadataIs s =
    { s | metadata : Brand }


{-| `metadata`'s closed attribute-capability row.
-}
type alias MetadataAttrs =
    { class : Supported
    , id : Supported
    , style : Supported
    }


{-| The context demand `metadata` injects into its children.
-}
type alias MetadataChildAdmittedBy childAdm =
    { childAdm | metadata : Ctx }


{-| The `metadata` element.
-}
metadata :
    List (Attr MetadataAttrs msg)
    -> List (Element childAccepts (MetadataChildAdmittedBy childAdm) msg)
    -> Element (MetadataIs s) admittedBy msg
metadata attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "metadata" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `title` produces.
-}
type alias TitleIs s =
    { s | title : Brand }


{-| `title`'s closed attribute-capability row.
-}
type alias TitleAttrs =
    { class : Supported
    , id : Supported
    , style : Supported
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
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "title" attrs (List.map HtmlIr.Element.toNode children))
