module TypedHtml.Details exposing
    ( details, summary
    , DetailsIs, DetailsAttrs, DetailsChildAdmittedBy, SummaryIs, SummaryAttrs, SummaryContent, SummaryChildAdmittedBy, SummaryAdmittedBy
    , name, open
    )

{-| The `Details` element home: constructors, per-element rows, and
co-located re-exports of the shared attributes its elements admit.

@docs details, summary
@docs DetailsIs, DetailsAttrs, DetailsChildAdmittedBy, SummaryIs, SummaryAttrs, SummaryContent, SummaryChildAdmittedBy, SummaryAdmittedBy
@docs name, open

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import TypedHtml.Attributes
import TypedHtml.Kind exposing (Brand, Ctx)


{-| The kind row `details` produces.
-}
type alias DetailsIs s =
    { s | sharedFlow : Shared }


{-| `details`'s closed attribute-capability row.
-}
type alias DetailsAttrs =
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
    , name : Supported
    , nonce : Supported
    , onClick : Supported
    , open : Supported
    , popover : Supported
    , role : Supported
    , slot : Supported
    , spellcheck : Supported
    , style : Supported
    , translate : Supported
    , writingsuggestions : Supported
    }


{-| The context demand `details` injects into its children.
-}
type alias DetailsChildAdmittedBy childAdm =
    { childAdm | details : Ctx }


{-| The `details` element.
-}
details :
    List (Attr DetailsAttrs msg)
    -> List (Element childAccepts (DetailsChildAdmittedBy childAdm) msg)
    -> Element (DetailsIs s) admittedBy msg
details attrs children =
    Ir.fromNode (Ir.node "details" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `summary` produces.
-}
type alias SummaryIs s =
    { s | summary : Brand }


{-| `summary`'s closed attribute-capability row.
-}
type alias SummaryAttrs =
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


{-| The kinds `summary` admits.
-}
type alias SummaryContent =
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


{-| The context demand `summary` injects into its children.
-}
type alias SummaryChildAdmittedBy childAdm =
    { childAdm | summary : Ctx }


{-| The CLOSED parent contexts `summary` is valid inside.
-}
type alias SummaryAdmittedBy =
    { details : Ctx }


{-| The `summary` element.
-}
summary :
    List (Attr SummaryAttrs msg)
    -> List (Element SummaryContent (SummaryChildAdmittedBy childAdm) msg)
    -> Element (SummaryIs s) SummaryAdmittedBy msg
summary attrs children =
    Ir.fromNode (Ir.node "summary" attrs (List.map HtmlIr.Element.toNode children))


{-| See `TypedHtml.Attributes.name`.
-}
name : String -> Attr { c | name : Supported } msg
name =
    TypedHtml.Attributes.name


{-| See `TypedHtml.Attributes.open`.
-}
open : Bool -> Attr { c | open : Supported } msg
open =
    TypedHtml.Attributes.open
