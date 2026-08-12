module TypedHtml.Grouping exposing
    ( div, p, span
    , DivIs, DivAttrs, DivChildAdmittedBy, DivRoles, PIs, PAttrs, PContent, PChildAdmittedBy, SpanIs, SpanAttrs, SpanContent, SpanChildAdmittedBy
    )

{-| The `Grouping` element home: constructors, per-element rows, and
co-located re-exports of the shared attributes its elements admit.

@docs div, p, span
@docs DivIs, DivAttrs, DivChildAdmittedBy, DivRoles, PIs, PAttrs, PContent, PChildAdmittedBy, SpanIs, SpanAttrs, SpanContent, SpanChildAdmittedBy

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import TypedHtml.Kind exposing (Brand, Ctx, Role)


{-| The kind row `div` produces.
-}
type alias DivIs s =
    { s | div : Brand }


{-| `div`'s closed attribute-capability row.
-}
type alias DivAttrs =
    { autofocus : Supported
    , class : Supported
    , dir : Supported
    , hidden : Supported
    , id : Supported
    , role : DivRoles
    , slot : Supported
    , style : Supported
    , tabindex : Supported
    }


{-| The context demand `div` injects into its children.
-}
type alias DivChildAdmittedBy childAdm =
    { childAdm | div : Ctx }


{-| The ARIA roles `div` admits (see `TypedHtml.Aria`).
-}
type alias DivRoles =
    { navigation : Role
    , presentation : Role
    }


{-| The `div` element.
-}
div :
    List (Attr DivAttrs msg)
    -> List (Element childAccepts (DivChildAdmittedBy childAdm) msg)
    -> Element (DivIs s) admittedBy msg
div attrs children =
    Ir.fromNode (Ir.node "div" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `p` produces.
-}
type alias PIs s =
    { s | p : Brand }


{-| `p`'s closed attribute-capability row.
-}
type alias PAttrs =
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


{-| The kinds `p` admits.
-}
type alias PContent =
    { a : Brand
    , sharedText : Shared
    , span : Brand
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


{-| The kind row `span` produces.
-}
type alias SpanIs s =
    { s | span : Brand }


{-| `span`'s closed attribute-capability row.
-}
type alias SpanAttrs =
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


{-| The kinds `span` admits.
-}
type alias SpanContent =
    { sharedText : Shared }


{-| The context demand `span` injects into its children.
-}
type alias SpanChildAdmittedBy childAdm =
    { childAdm | span : Ctx }


{-| The `span` element.
-}
span :
    List (Attr SpanAttrs msg)
    -> List (Element SpanContent (SpanChildAdmittedBy childAdm) msg)
    -> Element (SpanIs s) admittedBy msg
span attrs children =
    Ir.fromNode (Ir.node "span" attrs (List.map HtmlIr.Element.toNode children))
