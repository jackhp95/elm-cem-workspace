module TypedHtml.Element.Form exposing
    ( fieldset, legend
    , FieldsetIs, FieldsetAttrs, FieldsetContent, FieldsetChildAdmittedBy, LegendIs, LegendAttrs, LegendContent, LegendChildAdmittedBy, LegendAdmittedBy
    )

{-| The `Form` element home: constructors, per-element rows, and
co-located re-exports of the shared attributes its elements admit.

@docs fieldset, legend
@docs FieldsetIs, FieldsetAttrs, FieldsetContent, FieldsetChildAdmittedBy, LegendIs, LegendAttrs, LegendContent, LegendChildAdmittedBy, LegendAdmittedBy

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import TypedHtml.Kind exposing (Brand, Ctx)


{-| The kind row `fieldset` produces.
-}
type alias FieldsetIs s =
    { s | fieldset : Brand }


{-| `fieldset`'s closed attribute-capability row.
-}
type alias FieldsetAttrs =
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


{-| The kinds `fieldset` admits.
-}
type alias FieldsetContent =
    { div : Brand
    , legend : Brand
    , p : Brand
    }


{-| The context demand `fieldset` injects into its children.
-}
type alias FieldsetChildAdmittedBy childAdm =
    { childAdm | fieldset : Ctx }


{-| The `fieldset` element.
-}
fieldset :
    List (Attr FieldsetAttrs msg)
    -> List (Element FieldsetContent (FieldsetChildAdmittedBy childAdm) msg)
    -> Element (FieldsetIs s) admittedBy msg
fieldset attrs children =
    Ir.fromNode (Ir.node "fieldset" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `legend` produces.
-}
type alias LegendIs s =
    { s | legend : Brand }


{-| `legend`'s closed attribute-capability row.
-}
type alias LegendAttrs =
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


{-| The kinds `legend` admits.
-}
type alias LegendContent =
    { sharedText : Shared }


{-| The context demand `legend` injects into its children.
-}
type alias LegendChildAdmittedBy childAdm =
    { childAdm | legend : Ctx }


{-| The CLOSED parent contexts `legend` is valid inside.
-}
type alias LegendAdmittedBy =
    { fieldset : Ctx }


{-| The `legend` element.
-}
legend :
    List (Attr LegendAttrs msg)
    -> List (Element LegendContent (LegendChildAdmittedBy childAdm) msg)
    -> Element (LegendIs s) LegendAdmittedBy msg
legend attrs children =
    Ir.fromNode (Ir.node "legend" attrs (List.map HtmlIr.Element.toNode children))
