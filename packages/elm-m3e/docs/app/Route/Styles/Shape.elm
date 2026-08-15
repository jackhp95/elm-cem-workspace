module Route.Styles.Shape exposing (ActionData, Data, Model, Msg, route)

{-| **Shape** — the M3 Expressive shape system, re-authored on the M3e API
(opus). Two token families: the **corner-radius scale** (`--md-sys-shape-corner-*`,
the rounded rectangles every layer/form clips to) and the **named shapes**
(`M3e.Shape` clip paths). Shape **morphing** — one shape animating into another on
interaction — is the signature of M3 Expressive. Rendered live in the content-pane

  - card pattern.

-}

import BackendTask
import Doc
import Head
import Head.Seo as Seo
import M3e exposing (Element)
import M3e.Attributes
import M3e.Component.Shape as Shape
import M3e.Kind
import M3e.Values as Value
import MimeType
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import TypedHtml
import TypedHtml.Attributes as TA
import TypedHtml.Component.Grouping
import UrlPath
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    {}


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single { head = head, data = BackendTask.succeed {} }
        |> RouteBuilder.buildNoState { view = view }


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-m3e"
        , image =
            { url = [ "og-card.png" ] |> UrlPath.join |> Pages.Url.fromPath
            , alt = "elm-m3e"
            , dimensions = Just { width = 1200, height = 630 }
            , mimeType = Just (MimeType.Image MimeType.Png)
            }
        , description = "The M3 Expressive shape system: the corner-radius scale, named shapes, and shape morphing."
        , locale = Nothing
        , title = "Shape · elm-m3e"
        }
        |> Seo.website


{-| The canonical M3 corner-radius scale: `(rounded utility, label, rem value)`.
The rounded-md-corner-\* utilities resolve `--radius-md-corner-*` → the
`--md-sys-shape-corner-value-*` tokens (see `sys/shape.css`). Values are the token
literals — do not edit here without editing the token.
-}
cornerScale : List ( String, String, String )
cornerScale =
    [ ( "rounded-md-corner-none", "None", "0" )
    , ( "rounded-md-corner-extra-small", "Extra small", "0.25rem" )
    , ( "rounded-md-corner-small", "Small", "0.5rem" )
    , ( "rounded-md-corner-medium", "Medium", "0.75rem" )
    , ( "rounded-md-corner-large", "Large", "1rem" )
    , ( "rounded-md-corner-large-increased", "Large increased", "1.25rem" )
    , ( "rounded-md-corner-extra-large", "Extra large", "1.75rem" )
    , ( "rounded-md-corner-extra-large-increased", "Extra large increased", "2rem" )
    , ( "rounded-md-corner-extra-extra-large", "Extra extra large", "3rem" )
    , ( "rounded-md-corner-full", "Full", "624.9375rem" )
    ]


cornerSwatch : ( String, String, String ) -> Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
cornerSwatch ( rounded, label, value ) =
    TypedHtml.div [ TA.class "flex flex-col gap-2" ]
        [ TypedHtml.div
            [ TA.class ("bg-primary-container text-on-primary-container " ++ rounded ++ " h-20 w-full") ]
            []
        , TypedHtml.div [ TA.class "flex flex-col" ]
            [ M3e.heading [ M3e.Attributes.variant Value.label, M3e.Attributes.size Value.large, TA.class "text-on-surface" ] [ M3e.text label ]
            , TypedHtml.code [ TA.class "text-body-sm text-on-surface-variant" ] [ M3e.text value ]
            ]
        ]


{-| Named-shape swatches. Kept as a `(token, label)` list mapped through
`namedSwatch` so each token stays a variable at the `Shape.name` call site — the
tokens' open phantom rows unify into one wide record in the list literal, and
passing the token through (rather than a literal enum) keeps the barrel-flatten
rule from firing on a per-shape enum value.
-}
namedShapes : List (Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg)
namedShapes =
    -- The lambda is inlined (no top-level `namedSwatch` signature) on purpose:
    -- `Shape.name` wants a wide closed record, and the tokens' open phantom rows
    -- only unify into it under inference here inside `List.map`. Keeping the token
    -- a variable (not a literal enum) also keeps the barrel-flatten rule quiet.
    List.map
        (\( token, label ) ->
            TypedHtml.div [ TA.class "flex flex-col items-center gap-2" ]
                [ TypedHtml.div [ TA.class "contents" ] [ M3e.shape [ Shape.name token ] [] ]
                , M3e.heading [ M3e.Attributes.variant Value.label, M3e.Attributes.size Value.large, TA.class "text-on-surface-variant" ] [ M3e.text label ]
                ]
        )
        [ ( Value.circle, "Circle" )
        , ( Value.flower, "Flower" )
        , ( Value.heart, "Heart" )
        , ( Value.pill, "Pill" )
        , ( Value.diamond, "Diamond" )
        , ( Value.gem, "Gem" )
        , ( Value.sunny, "Sunny" )
        , ( Value.burst, "Burst" )
        , ( Value.hexagon, "Hexagon" )
        , ( Value.triangle, "Triangle" )
        , ( Value.oval, "Oval" )
        , ( Value.arch, "Arch" )
        ]


pageHeading : Element { s | heading : M3e.Kind.Brand } adm_ msg
pageHeading =
    M3e.heading
        [ M3e.Attributes.variant Value.display, M3e.Attributes.size Value.small, M3e.Attributes.level 1 ]
        [ M3e.text "Shape" ]


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    View.fromElement "Shape"
        (Doc.pane
            [ TypedHtml.section [ TA.class "space-y-3" ]
                [ pageHeading
                , TypedHtml.div [ TA.class "max-w-2xl" ]
                    [ TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                        [ M3e.text "Material 3 has two shape families. The corner-radius scale rounds every rectangular surface (cards, buttons, sheets) via --md-sys-shape-corner-* tokens. The named shapes are M3 Expressive clip paths — circles, flowers, stars — for hero surfaces and emphasis. Shape morphing, one shape springing into another on press or selection, is the signature move of M3 Expressive." ]
                    ]
                ]
            , TypedHtml.section [ TA.class "space-y-3" ]
                [ Doc.sectionHeadingWithId (Doc.slugify "Corner-radius scale") "Corner-radius scale"
                , TypedHtml.div [ TA.class "max-w-2xl" ]
                    [ TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                        [ M3e.text "Nine canonical sizes from none through extra-extra-large, plus full (a pill). Each swatch is a primary-container surface clipped with the matching rounded-md-corner-* utility; the caption is the token's rem value." ]
                    ]
                , Doc.showcase
                    (TypedHtml.div [ TA.class "grid grid-cols-2 gap-6 sm:grid-cols-3 lg:grid-cols-5" ]
                        (List.map cornerSwatch cornerScale)
                    )
                ]
            , TypedHtml.section [ TA.class "space-y-3" ]
                [ Doc.sectionHeadingWithId (Doc.slugify "Named shapes") "Named shapes"
                , TypedHtml.div [ TA.class "max-w-2xl" ]
                    [ TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                        [ M3e.text "M3e.shape clips a filled tile to a named shape via Shape.name Value tokens — the same clip-path set Material uses for expressive surfaces." ]
                    ]
                , Doc.showcase
                    (TypedHtml.div [ TA.class "grid grid-cols-3 gap-6 sm:grid-cols-4 lg:grid-cols-6" ] namedShapes)
                ]
            , TypedHtml.section [ TA.class "space-y-3" ]
                [ Doc.sectionHeadingWithId (Doc.slugify "Shape morphing") "Shape morphing"
                , TypedHtml.div [ TA.class "max-w-2xl" ]
                    [ TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                        [ M3e.text "The defining M3 Expressive interaction: a shape animates between two states rather than snapping. Buttons carry a full set of morph tokens for exactly this — a round or square resting shape and a distinct pressed shape it springs to and back from." ]
                    ]
                , TypedHtml.ul [ TA.class "list-disc space-y-1.5 pl-5" ]
                    [ TypedHtml.li []
                        [ TypedHtml.span [ TA.class "text-body-lg text-on-surface-variant" ]
                            [ TypedHtml.code [ TA.class "text-body-lg text-on-surface" ] [ M3e.text "--md-sys-shape-corner-*" ]
                            , M3e.text " — the resting corner scale above."
                            ]
                        ]
                    , TypedHtml.li []
                        [ TypedHtml.span [ TA.class "text-body-lg text-on-surface-variant" ]
                            [ TypedHtml.code [ TA.class "text-body-lg text-on-surface" ] [ M3e.text "--m3e-button-*-shape-round / -shape-square" ]
                            , M3e.text " — a button's resting shape per size variant."
                            ]
                        ]
                    , TypedHtml.li []
                        [ TypedHtml.span [ TA.class "text-body-lg text-on-surface-variant" ]
                            [ TypedHtml.code [ TA.class "text-body-lg text-on-surface" ] [ M3e.text "--m3e-button-*-shape-pressed-morph" ]
                            , M3e.text " — the pressed shape it morphs to, then springs back on release."
                            ]
                        ]
                    ]
                ]
            ]
        )
