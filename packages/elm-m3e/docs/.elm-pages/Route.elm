module Route exposing
    ( Route(..), segmentsToRoute, urlToRoute, baseUrl, routeToPath, baseUrlAsPath
    , toPath, toString, redirectTo, toLink, link, withoutBaseUrl
    )

{-|
@docs Route, segmentsToRoute, urlToRoute, baseUrl, routeToPath, baseUrlAsPath
@docs toPath, toString, redirectTo, toLink, link, withoutBaseUrl
-}


import Html
import Html.Attributes
import Server.Response
import UrlPath


{-| . -}
type Route
    = Components__All
    | Examples__Dashboard
    | Examples__Feed
    | Examples__ListDetail
    | Examples__Mail
    | Examples__Settings
    | Examples__Shop
    | Examples__SupportingPane
    | Examples__Travel
    | GettingStarted__BrowserSupport
    | GettingStarted__Installation
    | GettingStarted__Welcome
    | Guide__Accessibility
    | Guide__AccessibleByConstruction
    | Guide__CheatSheet
    | Guide__CompositionTextField
    | Guide__FirstComponent
    | Guide__GeneratedAndInspectable
    | Guide__Glossary
    | Guide__HowWeProveIt
    | Guide__InvalidStates
    | Guide__Motion
    | Guide__Reference
    | Guide__Roundtrip
    | Guide__Seams
    | Guide__Strictness
    | Guide__TheLayers
    | Guide__Theming
    | Guide__ToolingRefactors
    | Guide__Troubleshooting
    | Styles__Color
    | Styles__Density
    | Styles__Elevation
    | Styles__Motion
    | Styles__Shape
    | Styles__StateLayers
    | Styles__Typography
    | Components__Name_ { name : String }
    | Examples
    | Guide
    | Index


{-| . -}
segmentsToRoute : List String -> Maybe Route
segmentsToRoute segments =
    case segments of
    [ "components", "all" ] ->
        Just Components__All

    [ "examples", "dashboard" ] ->
        Just Examples__Dashboard

    [ "examples", "feed" ] ->
        Just Examples__Feed

    [ "examples", "list-detail" ] ->
        Just Examples__ListDetail

    [ "examples", "mail" ] ->
        Just Examples__Mail

    [ "examples", "settings" ] ->
        Just Examples__Settings

    [ "examples", "shop" ] ->
        Just Examples__Shop

    [ "examples", "supporting-pane" ] ->
        Just Examples__SupportingPane

    [ "examples", "travel" ] ->
        Just Examples__Travel

    [ "getting-started", "browser-support" ] ->
        Just GettingStarted__BrowserSupport

    [ "getting-started", "installation" ] ->
        Just GettingStarted__Installation

    [ "getting-started", "welcome" ] ->
        Just GettingStarted__Welcome

    [ "guide", "accessibility" ] ->
        Just Guide__Accessibility

    [ "guide", "accessible-by-construction" ] ->
        Just Guide__AccessibleByConstruction

    [ "guide", "cheat-sheet" ] ->
        Just Guide__CheatSheet

    [ "guide", "composition-text-field" ] ->
        Just Guide__CompositionTextField

    [ "guide", "first-component" ] ->
        Just Guide__FirstComponent

    [ "guide", "generated-and-inspectable" ] ->
        Just Guide__GeneratedAndInspectable

    [ "guide", "glossary" ] ->
        Just Guide__Glossary

    [ "guide", "how-we-prove-it" ] ->
        Just Guide__HowWeProveIt

    [ "guide", "invalid-states" ] ->
        Just Guide__InvalidStates

    [ "guide", "motion" ] ->
        Just Guide__Motion

    [ "guide", "reference" ] ->
        Just Guide__Reference

    [ "guide", "roundtrip" ] ->
        Just Guide__Roundtrip

    [ "guide", "seams" ] ->
        Just Guide__Seams

    [ "guide", "strictness" ] ->
        Just Guide__Strictness

    [ "guide", "the-layers" ] ->
        Just Guide__TheLayers

    [ "guide", "theming" ] ->
        Just Guide__Theming

    [ "guide", "tooling-refactors" ] ->
        Just Guide__ToolingRefactors

    [ "guide", "troubleshooting" ] ->
        Just Guide__Troubleshooting

    [ "styles", "color" ] ->
        Just Styles__Color

    [ "styles", "density" ] ->
        Just Styles__Density

    [ "styles", "elevation" ] ->
        Just Styles__Elevation

    [ "styles", "motion" ] ->
        Just Styles__Motion

    [ "styles", "shape" ] ->
        Just Styles__Shape

    [ "styles", "state-layers" ] ->
        Just Styles__StateLayers

    [ "styles", "typography" ] ->
        Just Styles__Typography

    [ "components", name ] ->
        Just (Components__Name_ { name = name })

    [ "examples" ] ->
        Just Examples

    [ "guide" ] ->
        Just Guide

    [] ->
        Just Index

    _ ->
        Nothing


{-| . -}
urlToRoute : { url | path : String } -> Maybe Route
urlToRoute url =
    segmentsToRoute (splitPath url.path)


{-| . -}
baseUrl : String
baseUrl =
    "/"


{-| . -}
routeToPath : Route -> List String
routeToPath route =
    List.concat
        (case route of
             Components__All ->
                 [ [ "components", "all" ] ]
         
             Examples__Dashboard ->
                 [ [ "examples", "dashboard" ] ]
         
             Examples__Feed ->
                 [ [ "examples", "feed" ] ]
         
             Examples__ListDetail ->
                 [ [ "examples", "list-detail" ] ]
         
             Examples__Mail ->
                 [ [ "examples", "mail" ] ]
         
             Examples__Settings ->
                 [ [ "examples", "settings" ] ]
         
             Examples__Shop ->
                 [ [ "examples", "shop" ] ]
         
             Examples__SupportingPane ->
                 [ [ "examples", "supporting-pane" ] ]
         
             Examples__Travel ->
                 [ [ "examples", "travel" ] ]
         
             GettingStarted__BrowserSupport ->
                 [ [ "getting-started", "browser-support" ] ]
         
             GettingStarted__Installation ->
                 [ [ "getting-started", "installation" ] ]
         
             GettingStarted__Welcome ->
                 [ [ "getting-started", "welcome" ] ]
         
             Guide__Accessibility ->
                 [ [ "guide", "accessibility" ] ]
         
             Guide__AccessibleByConstruction ->
                 [ [ "guide", "accessible-by-construction" ] ]
         
             Guide__CheatSheet ->
                 [ [ "guide", "cheat-sheet" ] ]
         
             Guide__CompositionTextField ->
                 [ [ "guide", "composition-text-field" ] ]
         
             Guide__FirstComponent ->
                 [ [ "guide", "first-component" ] ]
         
             Guide__GeneratedAndInspectable ->
                 [ [ "guide", "generated-and-inspectable" ] ]
         
             Guide__Glossary ->
                 [ [ "guide", "glossary" ] ]
         
             Guide__HowWeProveIt ->
                 [ [ "guide", "how-we-prove-it" ] ]
         
             Guide__InvalidStates ->
                 [ [ "guide", "invalid-states" ] ]
         
             Guide__Motion ->
                 [ [ "guide", "motion" ] ]
         
             Guide__Reference ->
                 [ [ "guide", "reference" ] ]
         
             Guide__Roundtrip ->
                 [ [ "guide", "roundtrip" ] ]
         
             Guide__Seams ->
                 [ [ "guide", "seams" ] ]
         
             Guide__Strictness ->
                 [ [ "guide", "strictness" ] ]
         
             Guide__TheLayers ->
                 [ [ "guide", "the-layers" ] ]
         
             Guide__Theming ->
                 [ [ "guide", "theming" ] ]
         
             Guide__ToolingRefactors ->
                 [ [ "guide", "tooling-refactors" ] ]
         
             Guide__Troubleshooting ->
                 [ [ "guide", "troubleshooting" ] ]
         
             Styles__Color ->
                 [ [ "styles", "color" ] ]
         
             Styles__Density ->
                 [ [ "styles", "density" ] ]
         
             Styles__Elevation ->
                 [ [ "styles", "elevation" ] ]
         
             Styles__Motion ->
                 [ [ "styles", "motion" ] ]
         
             Styles__Shape ->
                 [ [ "styles", "shape" ] ]
         
             Styles__StateLayers ->
                 [ [ "styles", "state-layers" ] ]
         
             Styles__Typography ->
                 [ [ "styles", "typography" ] ]
         
             Components__Name_ params ->
                 [ [ "components" ], [ params.name ] ]
         
             Examples ->
                 [ [ "examples" ] ]
         
             Guide ->
                 [ [ "guide" ] ]
         
             Index ->
                 [ [] ]
        )


{-| . -}
baseUrlAsPath : List String
baseUrlAsPath =
    List.filter
        (\item -> Basics.not (String.isEmpty item))
        (String.split "/" baseUrl)


{-| . -}
toPath : Route -> UrlPath.UrlPath
toPath route =
    UrlPath.fromString (String.join "/" (baseUrlAsPath ++ routeToPath route))


{-| . -}
toString : Route -> String
toString route =
    UrlPath.toAbsolute (toPath route)


{-| . -}
redirectTo : Route -> Server.Response.Response data error
redirectTo route =
    Server.Response.temporaryRedirect (toString route)


{-| . -}
toLink : (List (Html.Attribute msg) -> abc) -> Route -> abc
toLink toAnchorTag route =
    toAnchorTag
        [ Html.Attributes.href (toString route)
        , Html.Attributes.attribute "elm-pages:prefetch" ""
        ]


{-| . -}
link :
    List (Html.Attribute msg) -> List (Html.Html msg) -> Route -> Html.Html msg
link attributes children route =
    toLink (\anchorAttrs -> Html.a (anchorAttrs ++ attributes) children) route


{-| . -}
withoutBaseUrl : String -> String
withoutBaseUrl path =
    if String.startsWith baseUrl path then
        String.dropLeft (String.length baseUrl) path
    
    else
        path


splitPath path =
    List.filter (\item -> item /= "") (String.split "/" path)


maybeToList : Maybe String -> List String
maybeToList maybeString =
    case maybeString of
        Nothing ->
            []
    
        Just string ->
            [ string ]