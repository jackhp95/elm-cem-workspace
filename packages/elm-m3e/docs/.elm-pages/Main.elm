port module Main exposing
    ( Model, Msg, PageData, ActionData, config, main
    )

{-|
@docs Model, Msg, PageData, ActionData, config, main
-}


import Api
import ApiRoute
import BackendTask
import Browser.Navigation
import Bytes
import Bytes.Decode
import Bytes.Encode
import Dict
import Effect
import ErrorPage
import FatalError
import Form
import Head
import Html
import Http
import Json.Decode
import Json.Encode
import Lamdera.Wire3
import Pages.ConcurrentSubmission
import Pages.Fetcher
import Pages.Flags
import Pages.Internal.NotFoundReason
import Pages.Internal.Platform
import Pages.Internal.ResponseSketch
import Pages.Internal.RoutePattern
import Pages.Navigation
import Pages.PageUrl
import PagesMsg
import Route
import Route.Components.All
import Route.Components.Name_
import Route.Examples
import Route.Examples.Dashboard
import Route.Examples.Feed
import Route.Examples.ListDetail
import Route.Examples.Mail
import Route.Examples.Settings
import Route.Examples.Shop
import Route.Examples.SupportingPane
import Route.Examples.Travel
import Route.GettingStarted.BrowserSupport
import Route.GettingStarted.Installation
import Route.GettingStarted.Welcome
import Route.Guide
import Route.Guide.Accessibility
import Route.Guide.AccessibleByConstruction
import Route.Guide.CheatSheet
import Route.Guide.CompositionTextField
import Route.Guide.FirstComponent
import Route.Guide.GeneratedAndInspectable
import Route.Guide.Glossary
import Route.Guide.HowWeProveIt
import Route.Guide.InvalidStates
import Route.Guide.Motion
import Route.Guide.Reference
import Route.Guide.Roundtrip
import Route.Guide.Seams
import Route.Guide.Strictness
import Route.Guide.TheLayers
import Route.Guide.Theming
import Route.Guide.ToolingRefactors
import Route.Guide.Troubleshooting
import Route.Index
import Route.Styles.Color
import Route.Styles.Density
import Route.Styles.Elevation
import Route.Styles.Motion
import Route.Styles.Shape
import Route.Styles.StateLayers
import Route.Styles.Typography
import Server.Request
import Server.Response
import Shared
import SharedTemplate
import Site
import SiteConfig
import Url
import UrlPath
import View


type alias Model =
    { global : Shared.Model
    , page : PageModel
    , current :
        Maybe { path :
            { path : UrlPath.UrlPath
            , query : Maybe String
            , fragment : Maybe String
            }
        , metadata : Maybe Route.Route
        , pageUrl : Maybe Pages.PageUrl.PageUrl
        }
    }


type PageModel
    = ModelComponents__All Route.Components.All.Model
    | ModelExamples__Dashboard Route.Examples.Dashboard.Model
    | ModelExamples__Feed Route.Examples.Feed.Model
    | ModelExamples__ListDetail Route.Examples.ListDetail.Model
    | ModelExamples__Mail Route.Examples.Mail.Model
    | ModelExamples__Settings Route.Examples.Settings.Model
    | ModelExamples__Shop Route.Examples.Shop.Model
    | ModelExamples__SupportingPane Route.Examples.SupportingPane.Model
    | ModelExamples__Travel Route.Examples.Travel.Model
    | ModelGettingStarted__BrowserSupport
        Route.GettingStarted.BrowserSupport.Model
    | ModelGettingStarted__Installation Route.GettingStarted.Installation.Model
    | ModelGettingStarted__Welcome Route.GettingStarted.Welcome.Model
    | ModelGuide__Accessibility Route.Guide.Accessibility.Model
    | ModelGuide__AccessibleByConstruction
        Route.Guide.AccessibleByConstruction.Model
    | ModelGuide__CheatSheet Route.Guide.CheatSheet.Model
    | ModelGuide__CompositionTextField Route.Guide.CompositionTextField.Model
    | ModelGuide__FirstComponent Route.Guide.FirstComponent.Model
    | ModelGuide__GeneratedAndInspectable
        Route.Guide.GeneratedAndInspectable.Model
    | ModelGuide__Glossary Route.Guide.Glossary.Model
    | ModelGuide__HowWeProveIt Route.Guide.HowWeProveIt.Model
    | ModelGuide__InvalidStates Route.Guide.InvalidStates.Model
    | ModelGuide__Motion Route.Guide.Motion.Model
    | ModelGuide__Reference Route.Guide.Reference.Model
    | ModelGuide__Roundtrip Route.Guide.Roundtrip.Model
    | ModelGuide__Seams Route.Guide.Seams.Model
    | ModelGuide__Strictness Route.Guide.Strictness.Model
    | ModelGuide__TheLayers Route.Guide.TheLayers.Model
    | ModelGuide__Theming Route.Guide.Theming.Model
    | ModelGuide__ToolingRefactors Route.Guide.ToolingRefactors.Model
    | ModelGuide__Troubleshooting Route.Guide.Troubleshooting.Model
    | ModelStyles__Color Route.Styles.Color.Model
    | ModelStyles__Density Route.Styles.Density.Model
    | ModelStyles__Elevation Route.Styles.Elevation.Model
    | ModelStyles__Motion Route.Styles.Motion.Model
    | ModelStyles__Shape Route.Styles.Shape.Model
    | ModelStyles__StateLayers Route.Styles.StateLayers.Model
    | ModelStyles__Typography Route.Styles.Typography.Model
    | ModelComponents__Name_ Route.Components.Name_.Model
    | ModelExamples Route.Examples.Model
    | ModelGuide Route.Guide.Model
    | ModelIndex Route.Index.Model
    | ModelErrorPage____ ErrorPage.Model
    | NotFound


type Msg
    = MsgComponents__All Route.Components.All.Msg
    | MsgExamples__Dashboard Route.Examples.Dashboard.Msg
    | MsgExamples__Feed Route.Examples.Feed.Msg
    | MsgExamples__ListDetail Route.Examples.ListDetail.Msg
    | MsgExamples__Mail Route.Examples.Mail.Msg
    | MsgExamples__Settings Route.Examples.Settings.Msg
    | MsgExamples__Shop Route.Examples.Shop.Msg
    | MsgExamples__SupportingPane Route.Examples.SupportingPane.Msg
    | MsgExamples__Travel Route.Examples.Travel.Msg
    | MsgGettingStarted__BrowserSupport Route.GettingStarted.BrowserSupport.Msg
    | MsgGettingStarted__Installation Route.GettingStarted.Installation.Msg
    | MsgGettingStarted__Welcome Route.GettingStarted.Welcome.Msg
    | MsgGuide__Accessibility Route.Guide.Accessibility.Msg
    | MsgGuide__AccessibleByConstruction
        Route.Guide.AccessibleByConstruction.Msg
    | MsgGuide__CheatSheet Route.Guide.CheatSheet.Msg
    | MsgGuide__CompositionTextField Route.Guide.CompositionTextField.Msg
    | MsgGuide__FirstComponent Route.Guide.FirstComponent.Msg
    | MsgGuide__GeneratedAndInspectable Route.Guide.GeneratedAndInspectable.Msg
    | MsgGuide__Glossary Route.Guide.Glossary.Msg
    | MsgGuide__HowWeProveIt Route.Guide.HowWeProveIt.Msg
    | MsgGuide__InvalidStates Route.Guide.InvalidStates.Msg
    | MsgGuide__Motion Route.Guide.Motion.Msg
    | MsgGuide__Reference Route.Guide.Reference.Msg
    | MsgGuide__Roundtrip Route.Guide.Roundtrip.Msg
    | MsgGuide__Seams Route.Guide.Seams.Msg
    | MsgGuide__Strictness Route.Guide.Strictness.Msg
    | MsgGuide__TheLayers Route.Guide.TheLayers.Msg
    | MsgGuide__Theming Route.Guide.Theming.Msg
    | MsgGuide__ToolingRefactors Route.Guide.ToolingRefactors.Msg
    | MsgGuide__Troubleshooting Route.Guide.Troubleshooting.Msg
    | MsgStyles__Color Route.Styles.Color.Msg
    | MsgStyles__Density Route.Styles.Density.Msg
    | MsgStyles__Elevation Route.Styles.Elevation.Msg
    | MsgStyles__Motion Route.Styles.Motion.Msg
    | MsgStyles__Shape Route.Styles.Shape.Msg
    | MsgStyles__StateLayers Route.Styles.StateLayers.Msg
    | MsgStyles__Typography Route.Styles.Typography.Msg
    | MsgComponents__Name_ Route.Components.Name_.Msg
    | MsgExamples Route.Examples.Msg
    | MsgGuide Route.Guide.Msg
    | MsgIndex Route.Index.Msg
    | MsgGlobal Shared.Msg
    | OnPageChange
        { protocol : Url.Protocol
        , host : String
        , port_ : Maybe Int
        , path : UrlPath.UrlPath
        , query : Maybe String
        , fragment : Maybe String
        , metadata : Maybe Route.Route
        }
    | MsgErrorPage____ ErrorPage.Msg


type PageData
    = DataComponents__All Route.Components.All.Data
    | DataExamples__Dashboard Route.Examples.Dashboard.Data
    | DataExamples__Feed Route.Examples.Feed.Data
    | DataExamples__ListDetail Route.Examples.ListDetail.Data
    | DataExamples__Mail Route.Examples.Mail.Data
    | DataExamples__Settings Route.Examples.Settings.Data
    | DataExamples__Shop Route.Examples.Shop.Data
    | DataExamples__SupportingPane Route.Examples.SupportingPane.Data
    | DataExamples__Travel Route.Examples.Travel.Data
    | DataGettingStarted__BrowserSupport
        Route.GettingStarted.BrowserSupport.Data
    | DataGettingStarted__Installation Route.GettingStarted.Installation.Data
    | DataGettingStarted__Welcome Route.GettingStarted.Welcome.Data
    | DataGuide__Accessibility Route.Guide.Accessibility.Data
    | DataGuide__AccessibleByConstruction
        Route.Guide.AccessibleByConstruction.Data
    | DataGuide__CheatSheet Route.Guide.CheatSheet.Data
    | DataGuide__CompositionTextField Route.Guide.CompositionTextField.Data
    | DataGuide__FirstComponent Route.Guide.FirstComponent.Data
    | DataGuide__GeneratedAndInspectable
        Route.Guide.GeneratedAndInspectable.Data
    | DataGuide__Glossary Route.Guide.Glossary.Data
    | DataGuide__HowWeProveIt Route.Guide.HowWeProveIt.Data
    | DataGuide__InvalidStates Route.Guide.InvalidStates.Data
    | DataGuide__Motion Route.Guide.Motion.Data
    | DataGuide__Reference Route.Guide.Reference.Data
    | DataGuide__Roundtrip Route.Guide.Roundtrip.Data
    | DataGuide__Seams Route.Guide.Seams.Data
    | DataGuide__Strictness Route.Guide.Strictness.Data
    | DataGuide__TheLayers Route.Guide.TheLayers.Data
    | DataGuide__Theming Route.Guide.Theming.Data
    | DataGuide__ToolingRefactors Route.Guide.ToolingRefactors.Data
    | DataGuide__Troubleshooting Route.Guide.Troubleshooting.Data
    | DataStyles__Color Route.Styles.Color.Data
    | DataStyles__Density Route.Styles.Density.Data
    | DataStyles__Elevation Route.Styles.Elevation.Data
    | DataStyles__Motion Route.Styles.Motion.Data
    | DataStyles__Shape Route.Styles.Shape.Data
    | DataStyles__StateLayers Route.Styles.StateLayers.Data
    | DataStyles__Typography Route.Styles.Typography.Data
    | DataComponents__Name_ Route.Components.Name_.Data
    | DataExamples Route.Examples.Data
    | DataGuide Route.Guide.Data
    | DataIndex Route.Index.Data
    | Data404NotFoundPage____
    | DataErrorPage____ ErrorPage.ErrorPage


type ActionData
    = ActionDataComponents__All Route.Components.All.ActionData
    | ActionDataExamples__Dashboard Route.Examples.Dashboard.ActionData
    | ActionDataExamples__Feed Route.Examples.Feed.ActionData
    | ActionDataExamples__ListDetail Route.Examples.ListDetail.ActionData
    | ActionDataExamples__Mail Route.Examples.Mail.ActionData
    | ActionDataExamples__Settings Route.Examples.Settings.ActionData
    | ActionDataExamples__Shop Route.Examples.Shop.ActionData
    | ActionDataExamples__SupportingPane
        Route.Examples.SupportingPane.ActionData
    | ActionDataExamples__Travel Route.Examples.Travel.ActionData
    | ActionDataGettingStarted__BrowserSupport
        Route.GettingStarted.BrowserSupport.ActionData
    | ActionDataGettingStarted__Installation
        Route.GettingStarted.Installation.ActionData
    | ActionDataGettingStarted__Welcome Route.GettingStarted.Welcome.ActionData
    | ActionDataGuide__Accessibility Route.Guide.Accessibility.ActionData
    | ActionDataGuide__AccessibleByConstruction
        Route.Guide.AccessibleByConstruction.ActionData
    | ActionDataGuide__CheatSheet Route.Guide.CheatSheet.ActionData
    | ActionDataGuide__CompositionTextField
        Route.Guide.CompositionTextField.ActionData
    | ActionDataGuide__FirstComponent Route.Guide.FirstComponent.ActionData
    | ActionDataGuide__GeneratedAndInspectable
        Route.Guide.GeneratedAndInspectable.ActionData
    | ActionDataGuide__Glossary Route.Guide.Glossary.ActionData
    | ActionDataGuide__HowWeProveIt Route.Guide.HowWeProveIt.ActionData
    | ActionDataGuide__InvalidStates Route.Guide.InvalidStates.ActionData
    | ActionDataGuide__Motion Route.Guide.Motion.ActionData
    | ActionDataGuide__Reference Route.Guide.Reference.ActionData
    | ActionDataGuide__Roundtrip Route.Guide.Roundtrip.ActionData
    | ActionDataGuide__Seams Route.Guide.Seams.ActionData
    | ActionDataGuide__Strictness Route.Guide.Strictness.ActionData
    | ActionDataGuide__TheLayers Route.Guide.TheLayers.ActionData
    | ActionDataGuide__Theming Route.Guide.Theming.ActionData
    | ActionDataGuide__ToolingRefactors Route.Guide.ToolingRefactors.ActionData
    | ActionDataGuide__Troubleshooting Route.Guide.Troubleshooting.ActionData
    | ActionDataStyles__Color Route.Styles.Color.ActionData
    | ActionDataStyles__Density Route.Styles.Density.ActionData
    | ActionDataStyles__Elevation Route.Styles.Elevation.ActionData
    | ActionDataStyles__Motion Route.Styles.Motion.ActionData
    | ActionDataStyles__Shape Route.Styles.Shape.ActionData
    | ActionDataStyles__StateLayers Route.Styles.StateLayers.ActionData
    | ActionDataStyles__Typography Route.Styles.Typography.ActionData
    | ActionDataComponents__Name_ Route.Components.Name_.ActionData
    | ActionDataExamples Route.Examples.ActionData
    | ActionDataGuide Route.Guide.ActionData
    | ActionDataIndex Route.Index.ActionData


config =
    { init = init Nothing
    , update = update
    , subscriptions = subscriptions
    , sharedData = Shared.template.data
    , data = dataForRoute
    , action = action
    , onActionData = onActionData
    , view = view
    , handleRoute = handleRoute
    , getStaticRoutes = BackendTask.succeed []
    , urlToRoute = Route.urlToRoute
    , routeToPath =
        \route -> Maybe.withDefault [] (Maybe.map Route.routeToPath route)
    , site = Nothing
    , toJsPort = toJsPort
    , fromJsPort = fromJsPort Basics.identity
    , gotBatchSub = Sub.none
    , hotReloadData = hotReloadData Basics.identity
    , pageDataFromJs = pageDataFromJs Basics.identity
    , onPageChange = OnPageChange
    , apiRoutes = \htmlToString -> []
    , pathPatterns = routePatterns3
    , basePath = Route.baseUrlAsPath
    , sendPageData = sendPageData
    , byteEncodePageData = byteEncodePageData
    , byteDecodePageData = byteDecodePageData
    , encodeResponse = encodeResponse
    , encodeAction = encodeActionData
    , decodeResponse = decodeResponse
    , globalHeadTags = Nothing
    , cmdToEffect = Effect.fromCmd
    , perform = Effect.perform
    , errorStatusCode = ErrorPage.statusCode
    , notFoundPage = ErrorPage.notFound
    , internalError = ErrorPage.internalError
    , errorPageToData = DataErrorPage____
    , notFoundRoute = Nothing
    , pageModelToString = \_ -> ""
    }


main :
    Platform.Program Pages.Internal.Platform.Flags (Pages.Internal.Platform.Model Model PageData ActionData Shared.Data) (Pages.Internal.Platform.Msg Msg PageData ActionData Shared.Data ErrorPage.ErrorPage)
main =
    Pages.Internal.Platform.application
        { init = init Nothing
        , update = update
        , subscriptions = subscriptions
        , sharedData = Shared.template.data
        , data = dataForRoute
        , action = action
        , onActionData = onActionData
        , view = view
        , handleRoute = handleRoute
        , getStaticRoutes = BackendTask.succeed []
        , urlToRoute = Route.urlToRoute
        , routeToPath =
            \route -> Maybe.withDefault [] (Maybe.map Route.routeToPath route)
        , site = Nothing
        , toJsPort = toJsPort
        , fromJsPort = fromJsPort Basics.identity
        , gotBatchSub = Sub.none
        , hotReloadData = hotReloadData Basics.identity
        , pageDataFromJs = pageDataFromJs Basics.identity
        , onPageChange = OnPageChange
        , apiRoutes = \htmlToString -> []
        , pathPatterns = routePatterns3
        , basePath = Route.baseUrlAsPath
        , sendPageData = sendPageData
        , byteEncodePageData = byteEncodePageData
        , byteDecodePageData = byteDecodePageData
        , encodeResponse = encodeResponse
        , encodeAction = encodeActionData
        , decodeResponse = decodeResponse
        , globalHeadTags = Nothing
        , cmdToEffect = Effect.fromCmd
        , perform = Effect.perform
        , errorStatusCode = ErrorPage.statusCode
        , notFoundPage = ErrorPage.notFound
        , internalError = ErrorPage.internalError
        , errorPageToData = DataErrorPage____
        , notFoundRoute = Nothing
        , pageModelToString = \_ -> ""
        }


dataForRoute :
    Server.Request.Request
    -> Maybe Route.Route
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response PageData ErrorPage.ErrorPage)
dataForRoute requestPayload maybeRoute =
    case maybeRoute of
        Nothing ->
            BackendTask.succeed
                (Server.Response.mapError
                     Basics.never
                     (Server.Response.withStatusCode
                          404
                          (Server.Response.render Data404NotFoundPage____)
                     )
                )
    
        Just justRoute ->
            case justRoute of
                Route.Components__All ->
                    BackendTask.map
                        (Server.Response.map DataComponents__All)
                        (Route.Components.All.route.data requestPayload {})
            
                Route.Examples__Dashboard ->
                    BackendTask.map
                        (Server.Response.map DataExamples__Dashboard)
                        (Route.Examples.Dashboard.route.data requestPayload {})
            
                Route.Examples__Feed ->
                    BackendTask.map
                        (Server.Response.map DataExamples__Feed)
                        (Route.Examples.Feed.route.data requestPayload {})
            
                Route.Examples__ListDetail ->
                    BackendTask.map
                        (Server.Response.map DataExamples__ListDetail)
                        (Route.Examples.ListDetail.route.data requestPayload {})
            
                Route.Examples__Mail ->
                    BackendTask.map
                        (Server.Response.map DataExamples__Mail)
                        (Route.Examples.Mail.route.data requestPayload {})
            
                Route.Examples__Settings ->
                    BackendTask.map
                        (Server.Response.map DataExamples__Settings)
                        (Route.Examples.Settings.route.data requestPayload {})
            
                Route.Examples__Shop ->
                    BackendTask.map
                        (Server.Response.map DataExamples__Shop)
                        (Route.Examples.Shop.route.data requestPayload {})
            
                Route.Examples__SupportingPane ->
                    BackendTask.map
                        (Server.Response.map DataExamples__SupportingPane)
                        (Route.Examples.SupportingPane.route.data
                             requestPayload
                             {}
                        )
            
                Route.Examples__Travel ->
                    BackendTask.map
                        (Server.Response.map DataExamples__Travel)
                        (Route.Examples.Travel.route.data requestPayload {})
            
                Route.GettingStarted__BrowserSupport ->
                    BackendTask.map
                        (Server.Response.map DataGettingStarted__BrowserSupport)
                        (Route.GettingStarted.BrowserSupport.route.data
                             requestPayload
                             {}
                        )
            
                Route.GettingStarted__Installation ->
                    BackendTask.map
                        (Server.Response.map DataGettingStarted__Installation)
                        (Route.GettingStarted.Installation.route.data
                             requestPayload
                             {}
                        )
            
                Route.GettingStarted__Welcome ->
                    BackendTask.map
                        (Server.Response.map DataGettingStarted__Welcome)
                        (Route.GettingStarted.Welcome.route.data
                             requestPayload
                             {}
                        )
            
                Route.Guide__Accessibility ->
                    BackendTask.map
                        (Server.Response.map DataGuide__Accessibility)
                        (Route.Guide.Accessibility.route.data requestPayload {})
            
                Route.Guide__AccessibleByConstruction ->
                    BackendTask.map
                        (Server.Response.map DataGuide__AccessibleByConstruction
                        )
                        (Route.Guide.AccessibleByConstruction.route.data
                             requestPayload
                             {}
                        )
            
                Route.Guide__CheatSheet ->
                    BackendTask.map
                        (Server.Response.map DataGuide__CheatSheet)
                        (Route.Guide.CheatSheet.route.data requestPayload {})
            
                Route.Guide__CompositionTextField ->
                    BackendTask.map
                        (Server.Response.map DataGuide__CompositionTextField)
                        (Route.Guide.CompositionTextField.route.data
                             requestPayload
                             {}
                        )
            
                Route.Guide__FirstComponent ->
                    BackendTask.map
                        (Server.Response.map DataGuide__FirstComponent)
                        (Route.Guide.FirstComponent.route.data requestPayload {}
                        )
            
                Route.Guide__GeneratedAndInspectable ->
                    BackendTask.map
                        (Server.Response.map DataGuide__GeneratedAndInspectable)
                        (Route.Guide.GeneratedAndInspectable.route.data
                             requestPayload
                             {}
                        )
            
                Route.Guide__Glossary ->
                    BackendTask.map
                        (Server.Response.map DataGuide__Glossary)
                        (Route.Guide.Glossary.route.data requestPayload {})
            
                Route.Guide__HowWeProveIt ->
                    BackendTask.map
                        (Server.Response.map DataGuide__HowWeProveIt)
                        (Route.Guide.HowWeProveIt.route.data requestPayload {})
            
                Route.Guide__InvalidStates ->
                    BackendTask.map
                        (Server.Response.map DataGuide__InvalidStates)
                        (Route.Guide.InvalidStates.route.data requestPayload {})
            
                Route.Guide__Motion ->
                    BackendTask.map
                        (Server.Response.map DataGuide__Motion)
                        (Route.Guide.Motion.route.data requestPayload {})
            
                Route.Guide__Reference ->
                    BackendTask.map
                        (Server.Response.map DataGuide__Reference)
                        (Route.Guide.Reference.route.data requestPayload {})
            
                Route.Guide__Roundtrip ->
                    BackendTask.map
                        (Server.Response.map DataGuide__Roundtrip)
                        (Route.Guide.Roundtrip.route.data requestPayload {})
            
                Route.Guide__Seams ->
                    BackendTask.map
                        (Server.Response.map DataGuide__Seams)
                        (Route.Guide.Seams.route.data requestPayload {})
            
                Route.Guide__Strictness ->
                    BackendTask.map
                        (Server.Response.map DataGuide__Strictness)
                        (Route.Guide.Strictness.route.data requestPayload {})
            
                Route.Guide__TheLayers ->
                    BackendTask.map
                        (Server.Response.map DataGuide__TheLayers)
                        (Route.Guide.TheLayers.route.data requestPayload {})
            
                Route.Guide__Theming ->
                    BackendTask.map
                        (Server.Response.map DataGuide__Theming)
                        (Route.Guide.Theming.route.data requestPayload {})
            
                Route.Guide__ToolingRefactors ->
                    BackendTask.map
                        (Server.Response.map DataGuide__ToolingRefactors)
                        (Route.Guide.ToolingRefactors.route.data
                             requestPayload
                             {}
                        )
            
                Route.Guide__Troubleshooting ->
                    BackendTask.map
                        (Server.Response.map DataGuide__Troubleshooting)
                        (Route.Guide.Troubleshooting.route.data
                             requestPayload
                             {}
                        )
            
                Route.Styles__Color ->
                    BackendTask.map
                        (Server.Response.map DataStyles__Color)
                        (Route.Styles.Color.route.data requestPayload {})
            
                Route.Styles__Density ->
                    BackendTask.map
                        (Server.Response.map DataStyles__Density)
                        (Route.Styles.Density.route.data requestPayload {})
            
                Route.Styles__Elevation ->
                    BackendTask.map
                        (Server.Response.map DataStyles__Elevation)
                        (Route.Styles.Elevation.route.data requestPayload {})
            
                Route.Styles__Motion ->
                    BackendTask.map
                        (Server.Response.map DataStyles__Motion)
                        (Route.Styles.Motion.route.data requestPayload {})
            
                Route.Styles__Shape ->
                    BackendTask.map
                        (Server.Response.map DataStyles__Shape)
                        (Route.Styles.Shape.route.data requestPayload {})
            
                Route.Styles__StateLayers ->
                    BackendTask.map
                        (Server.Response.map DataStyles__StateLayers)
                        (Route.Styles.StateLayers.route.data requestPayload {})
            
                Route.Styles__Typography ->
                    BackendTask.map
                        (Server.Response.map DataStyles__Typography)
                        (Route.Styles.Typography.route.data requestPayload {})
            
                Route.Components__Name_ routeParams ->
                    BackendTask.map
                        (Server.Response.map DataComponents__Name_)
                        (Route.Components.Name_.route.data
                             requestPayload
                             routeParams
                        )
            
                Route.Examples ->
                    BackendTask.map
                        (Server.Response.map DataExamples)
                        (Route.Examples.route.data requestPayload {})
            
                Route.Guide ->
                    BackendTask.map
                        (Server.Response.map DataGuide)
                        (Route.Guide.route.data requestPayload {})
            
                Route.Index ->
                    BackendTask.map
                        (Server.Response.map DataIndex)
                        (Route.Index.route.data requestPayload {})


toTriple : a -> b -> c -> ( a, b, c )
toTriple a b c =
    ( a, b, c )


action :
    Server.Request.Request
    -> Maybe Route.Route
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response ActionData ErrorPage.ErrorPage)
action requestPayload maybeRoute =
    case maybeRoute of
        Nothing ->
            BackendTask.succeed (Server.Response.plainText "TODO")
    
        Just justRoute ->
            case justRoute of
                Route.Components__All ->
                    BackendTask.map
                        (Server.Response.map ActionDataComponents__All)
                        (Route.Components.All.route.action requestPayload {})
            
                Route.Examples__Dashboard ->
                    BackendTask.map
                        (Server.Response.map ActionDataExamples__Dashboard)
                        (Route.Examples.Dashboard.route.action requestPayload {}
                        )
            
                Route.Examples__Feed ->
                    BackendTask.map
                        (Server.Response.map ActionDataExamples__Feed)
                        (Route.Examples.Feed.route.action requestPayload {})
            
                Route.Examples__ListDetail ->
                    BackendTask.map
                        (Server.Response.map ActionDataExamples__ListDetail)
                        (Route.Examples.ListDetail.route.action
                             requestPayload
                             {}
                        )
            
                Route.Examples__Mail ->
                    BackendTask.map
                        (Server.Response.map ActionDataExamples__Mail)
                        (Route.Examples.Mail.route.action requestPayload {})
            
                Route.Examples__Settings ->
                    BackendTask.map
                        (Server.Response.map ActionDataExamples__Settings)
                        (Route.Examples.Settings.route.action requestPayload {})
            
                Route.Examples__Shop ->
                    BackendTask.map
                        (Server.Response.map ActionDataExamples__Shop)
                        (Route.Examples.Shop.route.action requestPayload {})
            
                Route.Examples__SupportingPane ->
                    BackendTask.map
                        (Server.Response.map ActionDataExamples__SupportingPane)
                        (Route.Examples.SupportingPane.route.action
                             requestPayload
                             {}
                        )
            
                Route.Examples__Travel ->
                    BackendTask.map
                        (Server.Response.map ActionDataExamples__Travel)
                        (Route.Examples.Travel.route.action requestPayload {})
            
                Route.GettingStarted__BrowserSupport ->
                    BackendTask.map
                        (Server.Response.map
                             ActionDataGettingStarted__BrowserSupport
                        )
                        (Route.GettingStarted.BrowserSupport.route.action
                             requestPayload
                             {}
                        )
            
                Route.GettingStarted__Installation ->
                    BackendTask.map
                        (Server.Response.map
                             ActionDataGettingStarted__Installation
                        )
                        (Route.GettingStarted.Installation.route.action
                             requestPayload
                             {}
                        )
            
                Route.GettingStarted__Welcome ->
                    BackendTask.map
                        (Server.Response.map ActionDataGettingStarted__Welcome)
                        (Route.GettingStarted.Welcome.route.action
                             requestPayload
                             {}
                        )
            
                Route.Guide__Accessibility ->
                    BackendTask.map
                        (Server.Response.map ActionDataGuide__Accessibility)
                        (Route.Guide.Accessibility.route.action
                             requestPayload
                             {}
                        )
            
                Route.Guide__AccessibleByConstruction ->
                    BackendTask.map
                        (Server.Response.map
                             ActionDataGuide__AccessibleByConstruction
                        )
                        (Route.Guide.AccessibleByConstruction.route.action
                             requestPayload
                             {}
                        )
            
                Route.Guide__CheatSheet ->
                    BackendTask.map
                        (Server.Response.map ActionDataGuide__CheatSheet)
                        (Route.Guide.CheatSheet.route.action requestPayload {})
            
                Route.Guide__CompositionTextField ->
                    BackendTask.map
                        (Server.Response.map
                             ActionDataGuide__CompositionTextField
                        )
                        (Route.Guide.CompositionTextField.route.action
                             requestPayload
                             {}
                        )
            
                Route.Guide__FirstComponent ->
                    BackendTask.map
                        (Server.Response.map ActionDataGuide__FirstComponent)
                        (Route.Guide.FirstComponent.route.action
                             requestPayload
                             {}
                        )
            
                Route.Guide__GeneratedAndInspectable ->
                    BackendTask.map
                        (Server.Response.map
                             ActionDataGuide__GeneratedAndInspectable
                        )
                        (Route.Guide.GeneratedAndInspectable.route.action
                             requestPayload
                             {}
                        )
            
                Route.Guide__Glossary ->
                    BackendTask.map
                        (Server.Response.map ActionDataGuide__Glossary)
                        (Route.Guide.Glossary.route.action requestPayload {})
            
                Route.Guide__HowWeProveIt ->
                    BackendTask.map
                        (Server.Response.map ActionDataGuide__HowWeProveIt)
                        (Route.Guide.HowWeProveIt.route.action requestPayload {}
                        )
            
                Route.Guide__InvalidStates ->
                    BackendTask.map
                        (Server.Response.map ActionDataGuide__InvalidStates)
                        (Route.Guide.InvalidStates.route.action
                             requestPayload
                             {}
                        )
            
                Route.Guide__Motion ->
                    BackendTask.map
                        (Server.Response.map ActionDataGuide__Motion)
                        (Route.Guide.Motion.route.action requestPayload {})
            
                Route.Guide__Reference ->
                    BackendTask.map
                        (Server.Response.map ActionDataGuide__Reference)
                        (Route.Guide.Reference.route.action requestPayload {})
            
                Route.Guide__Roundtrip ->
                    BackendTask.map
                        (Server.Response.map ActionDataGuide__Roundtrip)
                        (Route.Guide.Roundtrip.route.action requestPayload {})
            
                Route.Guide__Seams ->
                    BackendTask.map
                        (Server.Response.map ActionDataGuide__Seams)
                        (Route.Guide.Seams.route.action requestPayload {})
            
                Route.Guide__Strictness ->
                    BackendTask.map
                        (Server.Response.map ActionDataGuide__Strictness)
                        (Route.Guide.Strictness.route.action requestPayload {})
            
                Route.Guide__TheLayers ->
                    BackendTask.map
                        (Server.Response.map ActionDataGuide__TheLayers)
                        (Route.Guide.TheLayers.route.action requestPayload {})
            
                Route.Guide__Theming ->
                    BackendTask.map
                        (Server.Response.map ActionDataGuide__Theming)
                        (Route.Guide.Theming.route.action requestPayload {})
            
                Route.Guide__ToolingRefactors ->
                    BackendTask.map
                        (Server.Response.map ActionDataGuide__ToolingRefactors)
                        (Route.Guide.ToolingRefactors.route.action
                             requestPayload
                             {}
                        )
            
                Route.Guide__Troubleshooting ->
                    BackendTask.map
                        (Server.Response.map ActionDataGuide__Troubleshooting)
                        (Route.Guide.Troubleshooting.route.action
                             requestPayload
                             {}
                        )
            
                Route.Styles__Color ->
                    BackendTask.map
                        (Server.Response.map ActionDataStyles__Color)
                        (Route.Styles.Color.route.action requestPayload {})
            
                Route.Styles__Density ->
                    BackendTask.map
                        (Server.Response.map ActionDataStyles__Density)
                        (Route.Styles.Density.route.action requestPayload {})
            
                Route.Styles__Elevation ->
                    BackendTask.map
                        (Server.Response.map ActionDataStyles__Elevation)
                        (Route.Styles.Elevation.route.action requestPayload {})
            
                Route.Styles__Motion ->
                    BackendTask.map
                        (Server.Response.map ActionDataStyles__Motion)
                        (Route.Styles.Motion.route.action requestPayload {})
            
                Route.Styles__Shape ->
                    BackendTask.map
                        (Server.Response.map ActionDataStyles__Shape)
                        (Route.Styles.Shape.route.action requestPayload {})
            
                Route.Styles__StateLayers ->
                    BackendTask.map
                        (Server.Response.map ActionDataStyles__StateLayers)
                        (Route.Styles.StateLayers.route.action requestPayload {}
                        )
            
                Route.Styles__Typography ->
                    BackendTask.map
                        (Server.Response.map ActionDataStyles__Typography)
                        (Route.Styles.Typography.route.action requestPayload {})
            
                Route.Components__Name_ routeParams ->
                    BackendTask.map
                        (Server.Response.map ActionDataComponents__Name_)
                        (Route.Components.Name_.route.action
                             requestPayload
                             routeParams
                        )
            
                Route.Examples ->
                    BackendTask.map
                        (Server.Response.map ActionDataExamples)
                        (Route.Examples.route.action requestPayload {})
            
                Route.Guide ->
                    BackendTask.map
                        (Server.Response.map ActionDataGuide)
                        (Route.Guide.route.action requestPayload {})
            
                Route.Index ->
                    BackendTask.map
                        (Server.Response.map ActionDataIndex)
                        (Route.Index.route.action requestPayload {})


fooFn :
    (a -> PageModel)
    -> (b -> Msg)
    -> Model
    -> ( a, Effect.Effect b, Maybe Shared.Msg )
    -> ( PageModel, Effect.Effect Msg, ( Shared.Model, Effect.Effect Shared.Msg ) )
fooFn wrapModel wrapMsg model triple =
    case triple of
        ( a, b, c ) ->
            ( wrapModel a
            , Effect.map wrapMsg b
            , case c of
                Nothing ->
                    ( model.global, Effect.none )
              
                Just sharedMsg ->
                    Shared.template.update sharedMsg model.global
            )


templateSubscriptions :
    Maybe Route.Route -> UrlPath.UrlPath -> Model -> Sub.Sub Msg
templateSubscriptions route path model =
    case route of
        Nothing ->
            Sub.none
    
        Just justRoute ->
            case justRoute of
                Route.Components__All ->
                    case model.page of
                        ModelComponents__All templateModel ->
                            Sub.map
                                MsgComponents__All
                                (Route.Components.All.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Examples__Dashboard ->
                    case model.page of
                        ModelExamples__Dashboard templateModel ->
                            Sub.map
                                MsgExamples__Dashboard
                                (Route.Examples.Dashboard.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Examples__Feed ->
                    case model.page of
                        ModelExamples__Feed templateModel ->
                            Sub.map
                                MsgExamples__Feed
                                (Route.Examples.Feed.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Examples__ListDetail ->
                    case model.page of
                        ModelExamples__ListDetail templateModel ->
                            Sub.map
                                MsgExamples__ListDetail
                                (Route.Examples.ListDetail.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Examples__Mail ->
                    case model.page of
                        ModelExamples__Mail templateModel ->
                            Sub.map
                                MsgExamples__Mail
                                (Route.Examples.Mail.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Examples__Settings ->
                    case model.page of
                        ModelExamples__Settings templateModel ->
                            Sub.map
                                MsgExamples__Settings
                                (Route.Examples.Settings.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Examples__Shop ->
                    case model.page of
                        ModelExamples__Shop templateModel ->
                            Sub.map
                                MsgExamples__Shop
                                (Route.Examples.Shop.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Examples__SupportingPane ->
                    case model.page of
                        ModelExamples__SupportingPane templateModel ->
                            Sub.map
                                MsgExamples__SupportingPane
                                (Route.Examples.SupportingPane.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Examples__Travel ->
                    case model.page of
                        ModelExamples__Travel templateModel ->
                            Sub.map
                                MsgExamples__Travel
                                (Route.Examples.Travel.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.GettingStarted__BrowserSupport ->
                    case model.page of
                        ModelGettingStarted__BrowserSupport templateModel ->
                            Sub.map
                                MsgGettingStarted__BrowserSupport
                                (Route.GettingStarted.BrowserSupport.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.GettingStarted__Installation ->
                    case model.page of
                        ModelGettingStarted__Installation templateModel ->
                            Sub.map
                                MsgGettingStarted__Installation
                                (Route.GettingStarted.Installation.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.GettingStarted__Welcome ->
                    case model.page of
                        ModelGettingStarted__Welcome templateModel ->
                            Sub.map
                                MsgGettingStarted__Welcome
                                (Route.GettingStarted.Welcome.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Guide__Accessibility ->
                    case model.page of
                        ModelGuide__Accessibility templateModel ->
                            Sub.map
                                MsgGuide__Accessibility
                                (Route.Guide.Accessibility.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Guide__AccessibleByConstruction ->
                    case model.page of
                        ModelGuide__AccessibleByConstruction templateModel ->
                            Sub.map
                                MsgGuide__AccessibleByConstruction
                                (Route.Guide.AccessibleByConstruction.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Guide__CheatSheet ->
                    case model.page of
                        ModelGuide__CheatSheet templateModel ->
                            Sub.map
                                MsgGuide__CheatSheet
                                (Route.Guide.CheatSheet.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Guide__CompositionTextField ->
                    case model.page of
                        ModelGuide__CompositionTextField templateModel ->
                            Sub.map
                                MsgGuide__CompositionTextField
                                (Route.Guide.CompositionTextField.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Guide__FirstComponent ->
                    case model.page of
                        ModelGuide__FirstComponent templateModel ->
                            Sub.map
                                MsgGuide__FirstComponent
                                (Route.Guide.FirstComponent.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Guide__GeneratedAndInspectable ->
                    case model.page of
                        ModelGuide__GeneratedAndInspectable templateModel ->
                            Sub.map
                                MsgGuide__GeneratedAndInspectable
                                (Route.Guide.GeneratedAndInspectable.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Guide__Glossary ->
                    case model.page of
                        ModelGuide__Glossary templateModel ->
                            Sub.map
                                MsgGuide__Glossary
                                (Route.Guide.Glossary.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Guide__HowWeProveIt ->
                    case model.page of
                        ModelGuide__HowWeProveIt templateModel ->
                            Sub.map
                                MsgGuide__HowWeProveIt
                                (Route.Guide.HowWeProveIt.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Guide__InvalidStates ->
                    case model.page of
                        ModelGuide__InvalidStates templateModel ->
                            Sub.map
                                MsgGuide__InvalidStates
                                (Route.Guide.InvalidStates.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Guide__Motion ->
                    case model.page of
                        ModelGuide__Motion templateModel ->
                            Sub.map
                                MsgGuide__Motion
                                (Route.Guide.Motion.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Guide__Reference ->
                    case model.page of
                        ModelGuide__Reference templateModel ->
                            Sub.map
                                MsgGuide__Reference
                                (Route.Guide.Reference.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Guide__Roundtrip ->
                    case model.page of
                        ModelGuide__Roundtrip templateModel ->
                            Sub.map
                                MsgGuide__Roundtrip
                                (Route.Guide.Roundtrip.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Guide__Seams ->
                    case model.page of
                        ModelGuide__Seams templateModel ->
                            Sub.map
                                MsgGuide__Seams
                                (Route.Guide.Seams.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Guide__Strictness ->
                    case model.page of
                        ModelGuide__Strictness templateModel ->
                            Sub.map
                                MsgGuide__Strictness
                                (Route.Guide.Strictness.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Guide__TheLayers ->
                    case model.page of
                        ModelGuide__TheLayers templateModel ->
                            Sub.map
                                MsgGuide__TheLayers
                                (Route.Guide.TheLayers.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Guide__Theming ->
                    case model.page of
                        ModelGuide__Theming templateModel ->
                            Sub.map
                                MsgGuide__Theming
                                (Route.Guide.Theming.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Guide__ToolingRefactors ->
                    case model.page of
                        ModelGuide__ToolingRefactors templateModel ->
                            Sub.map
                                MsgGuide__ToolingRefactors
                                (Route.Guide.ToolingRefactors.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Guide__Troubleshooting ->
                    case model.page of
                        ModelGuide__Troubleshooting templateModel ->
                            Sub.map
                                MsgGuide__Troubleshooting
                                (Route.Guide.Troubleshooting.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Styles__Color ->
                    case model.page of
                        ModelStyles__Color templateModel ->
                            Sub.map
                                MsgStyles__Color
                                (Route.Styles.Color.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Styles__Density ->
                    case model.page of
                        ModelStyles__Density templateModel ->
                            Sub.map
                                MsgStyles__Density
                                (Route.Styles.Density.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Styles__Elevation ->
                    case model.page of
                        ModelStyles__Elevation templateModel ->
                            Sub.map
                                MsgStyles__Elevation
                                (Route.Styles.Elevation.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Styles__Motion ->
                    case model.page of
                        ModelStyles__Motion templateModel ->
                            Sub.map
                                MsgStyles__Motion
                                (Route.Styles.Motion.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Styles__Shape ->
                    case model.page of
                        ModelStyles__Shape templateModel ->
                            Sub.map
                                MsgStyles__Shape
                                (Route.Styles.Shape.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Styles__StateLayers ->
                    case model.page of
                        ModelStyles__StateLayers templateModel ->
                            Sub.map
                                MsgStyles__StateLayers
                                (Route.Styles.StateLayers.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Styles__Typography ->
                    case model.page of
                        ModelStyles__Typography templateModel ->
                            Sub.map
                                MsgStyles__Typography
                                (Route.Styles.Typography.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Components__Name_ routeParams ->
                    case model.page of
                        ModelComponents__Name_ templateModel ->
                            Sub.map
                                MsgComponents__Name_
                                (Route.Components.Name_.route.subscriptions
                                     routeParams
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Examples ->
                    case model.page of
                        ModelExamples templateModel ->
                            Sub.map
                                MsgExamples
                                (Route.Examples.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Guide ->
                    case model.page of
                        ModelGuide templateModel ->
                            Sub.map
                                MsgGuide
                                (Route.Guide.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none
            
                Route.Index ->
                    case model.page of
                        ModelIndex templateModel ->
                            Sub.map
                                MsgIndex
                                (Route.Index.route.subscriptions
                                     {}
                                     path
                                     templateModel
                                     model.global
                                )
                    
                        _ ->
                            Sub.none


onActionData : ActionData -> Maybe Msg
onActionData actionData =
    case actionData of
        ActionDataComponents__All thisActionData ->
            Maybe.map
                (\mapUnpack -> MsgComponents__All (mapUnpack thisActionData))
                Route.Components.All.route.onAction
    
        ActionDataExamples__Dashboard thisActionData ->
            Maybe.map
                (\mapUnpack -> MsgExamples__Dashboard (mapUnpack thisActionData)
                )
                Route.Examples.Dashboard.route.onAction
    
        ActionDataExamples__Feed thisActionData ->
            Maybe.map
                (\mapUnpack -> MsgExamples__Feed (mapUnpack thisActionData))
                Route.Examples.Feed.route.onAction
    
        ActionDataExamples__ListDetail thisActionData ->
            Maybe.map
                (\mapUnpack ->
                     MsgExamples__ListDetail (mapUnpack thisActionData)
                )
                Route.Examples.ListDetail.route.onAction
    
        ActionDataExamples__Mail thisActionData ->
            Maybe.map
                (\mapUnpack -> MsgExamples__Mail (mapUnpack thisActionData))
                Route.Examples.Mail.route.onAction
    
        ActionDataExamples__Settings thisActionData ->
            Maybe.map
                (\mapUnpack -> MsgExamples__Settings (mapUnpack thisActionData))
                Route.Examples.Settings.route.onAction
    
        ActionDataExamples__Shop thisActionData ->
            Maybe.map
                (\mapUnpack -> MsgExamples__Shop (mapUnpack thisActionData))
                Route.Examples.Shop.route.onAction
    
        ActionDataExamples__SupportingPane thisActionData ->
            Maybe.map
                (\mapUnpack ->
                     MsgExamples__SupportingPane (mapUnpack thisActionData)
                )
                Route.Examples.SupportingPane.route.onAction
    
        ActionDataExamples__Travel thisActionData ->
            Maybe.map
                (\mapUnpack -> MsgExamples__Travel (mapUnpack thisActionData))
                Route.Examples.Travel.route.onAction
    
        ActionDataGettingStarted__BrowserSupport thisActionData ->
            Maybe.map
                (\mapUnpack ->
                     MsgGettingStarted__BrowserSupport
                         (mapUnpack thisActionData)
                )
                Route.GettingStarted.BrowserSupport.route.onAction
    
        ActionDataGettingStarted__Installation thisActionData ->
            Maybe.map
                (\mapUnpack ->
                     MsgGettingStarted__Installation (mapUnpack thisActionData)
                )
                Route.GettingStarted.Installation.route.onAction
    
        ActionDataGettingStarted__Welcome thisActionData ->
            Maybe.map
                (\mapUnpack ->
                     MsgGettingStarted__Welcome (mapUnpack thisActionData)
                )
                Route.GettingStarted.Welcome.route.onAction
    
        ActionDataGuide__Accessibility thisActionData ->
            Maybe.map
                (\mapUnpack ->
                     MsgGuide__Accessibility (mapUnpack thisActionData)
                )
                Route.Guide.Accessibility.route.onAction
    
        ActionDataGuide__AccessibleByConstruction thisActionData ->
            Maybe.map
                (\mapUnpack ->
                     MsgGuide__AccessibleByConstruction
                         (mapUnpack thisActionData)
                )
                Route.Guide.AccessibleByConstruction.route.onAction
    
        ActionDataGuide__CheatSheet thisActionData ->
            Maybe.map
                (\mapUnpack -> MsgGuide__CheatSheet (mapUnpack thisActionData))
                Route.Guide.CheatSheet.route.onAction
    
        ActionDataGuide__CompositionTextField thisActionData ->
            Maybe.map
                (\mapUnpack ->
                     MsgGuide__CompositionTextField (mapUnpack thisActionData)
                )
                Route.Guide.CompositionTextField.route.onAction
    
        ActionDataGuide__FirstComponent thisActionData ->
            Maybe.map
                (\mapUnpack ->
                     MsgGuide__FirstComponent (mapUnpack thisActionData)
                )
                Route.Guide.FirstComponent.route.onAction
    
        ActionDataGuide__GeneratedAndInspectable thisActionData ->
            Maybe.map
                (\mapUnpack ->
                     MsgGuide__GeneratedAndInspectable
                         (mapUnpack thisActionData)
                )
                Route.Guide.GeneratedAndInspectable.route.onAction
    
        ActionDataGuide__Glossary thisActionData ->
            Maybe.map
                (\mapUnpack -> MsgGuide__Glossary (mapUnpack thisActionData))
                Route.Guide.Glossary.route.onAction
    
        ActionDataGuide__HowWeProveIt thisActionData ->
            Maybe.map
                (\mapUnpack -> MsgGuide__HowWeProveIt (mapUnpack thisActionData)
                )
                Route.Guide.HowWeProveIt.route.onAction
    
        ActionDataGuide__InvalidStates thisActionData ->
            Maybe.map
                (\mapUnpack ->
                     MsgGuide__InvalidStates (mapUnpack thisActionData)
                )
                Route.Guide.InvalidStates.route.onAction
    
        ActionDataGuide__Motion thisActionData ->
            Maybe.map
                (\mapUnpack -> MsgGuide__Motion (mapUnpack thisActionData))
                Route.Guide.Motion.route.onAction
    
        ActionDataGuide__Reference thisActionData ->
            Maybe.map
                (\mapUnpack -> MsgGuide__Reference (mapUnpack thisActionData))
                Route.Guide.Reference.route.onAction
    
        ActionDataGuide__Roundtrip thisActionData ->
            Maybe.map
                (\mapUnpack -> MsgGuide__Roundtrip (mapUnpack thisActionData))
                Route.Guide.Roundtrip.route.onAction
    
        ActionDataGuide__Seams thisActionData ->
            Maybe.map
                (\mapUnpack -> MsgGuide__Seams (mapUnpack thisActionData))
                Route.Guide.Seams.route.onAction
    
        ActionDataGuide__Strictness thisActionData ->
            Maybe.map
                (\mapUnpack -> MsgGuide__Strictness (mapUnpack thisActionData))
                Route.Guide.Strictness.route.onAction
    
        ActionDataGuide__TheLayers thisActionData ->
            Maybe.map
                (\mapUnpack -> MsgGuide__TheLayers (mapUnpack thisActionData))
                Route.Guide.TheLayers.route.onAction
    
        ActionDataGuide__Theming thisActionData ->
            Maybe.map
                (\mapUnpack -> MsgGuide__Theming (mapUnpack thisActionData))
                Route.Guide.Theming.route.onAction
    
        ActionDataGuide__ToolingRefactors thisActionData ->
            Maybe.map
                (\mapUnpack ->
                     MsgGuide__ToolingRefactors (mapUnpack thisActionData)
                )
                Route.Guide.ToolingRefactors.route.onAction
    
        ActionDataGuide__Troubleshooting thisActionData ->
            Maybe.map
                (\mapUnpack ->
                     MsgGuide__Troubleshooting (mapUnpack thisActionData)
                )
                Route.Guide.Troubleshooting.route.onAction
    
        ActionDataStyles__Color thisActionData ->
            Maybe.map
                (\mapUnpack -> MsgStyles__Color (mapUnpack thisActionData))
                Route.Styles.Color.route.onAction
    
        ActionDataStyles__Density thisActionData ->
            Maybe.map
                (\mapUnpack -> MsgStyles__Density (mapUnpack thisActionData))
                Route.Styles.Density.route.onAction
    
        ActionDataStyles__Elevation thisActionData ->
            Maybe.map
                (\mapUnpack -> MsgStyles__Elevation (mapUnpack thisActionData))
                Route.Styles.Elevation.route.onAction
    
        ActionDataStyles__Motion thisActionData ->
            Maybe.map
                (\mapUnpack -> MsgStyles__Motion (mapUnpack thisActionData))
                Route.Styles.Motion.route.onAction
    
        ActionDataStyles__Shape thisActionData ->
            Maybe.map
                (\mapUnpack -> MsgStyles__Shape (mapUnpack thisActionData))
                Route.Styles.Shape.route.onAction
    
        ActionDataStyles__StateLayers thisActionData ->
            Maybe.map
                (\mapUnpack -> MsgStyles__StateLayers (mapUnpack thisActionData)
                )
                Route.Styles.StateLayers.route.onAction
    
        ActionDataStyles__Typography thisActionData ->
            Maybe.map
                (\mapUnpack -> MsgStyles__Typography (mapUnpack thisActionData))
                Route.Styles.Typography.route.onAction
    
        ActionDataComponents__Name_ thisActionData ->
            Maybe.map
                (\mapUnpack -> MsgComponents__Name_ (mapUnpack thisActionData))
                Route.Components.Name_.route.onAction
    
        ActionDataExamples thisActionData ->
            Maybe.map
                (\mapUnpack -> MsgExamples (mapUnpack thisActionData))
                Route.Examples.route.onAction
    
        ActionDataGuide thisActionData ->
            Maybe.map
                (\mapUnpack -> MsgGuide (mapUnpack thisActionData))
                Route.Guide.route.onAction
    
        ActionDataIndex thisActionData ->
            Maybe.map
                (\mapUnpack -> MsgIndex (mapUnpack thisActionData))
                Route.Index.route.onAction


byteEncodePageData : PageData -> Bytes.Encode.Encoder
byteEncodePageData pageData =
    case pageData of
        DataErrorPage____ thisPageData ->
            ErrorPage.w3_encode_ErrorPage thisPageData
    
        Data404NotFoundPage____ ->
            Bytes.Encode.unsignedInt8 0
    
        DataComponents__All thisPageData ->
            Route.Components.All.w3_encode_Data thisPageData
    
        DataExamples__Dashboard thisPageData ->
            Route.Examples.Dashboard.w3_encode_Data thisPageData
    
        DataExamples__Feed thisPageData ->
            Route.Examples.Feed.w3_encode_Data thisPageData
    
        DataExamples__ListDetail thisPageData ->
            Route.Examples.ListDetail.w3_encode_Data thisPageData
    
        DataExamples__Mail thisPageData ->
            Route.Examples.Mail.w3_encode_Data thisPageData
    
        DataExamples__Settings thisPageData ->
            Route.Examples.Settings.w3_encode_Data thisPageData
    
        DataExamples__Shop thisPageData ->
            Route.Examples.Shop.w3_encode_Data thisPageData
    
        DataExamples__SupportingPane thisPageData ->
            Route.Examples.SupportingPane.w3_encode_Data thisPageData
    
        DataExamples__Travel thisPageData ->
            Route.Examples.Travel.w3_encode_Data thisPageData
    
        DataGettingStarted__BrowserSupport thisPageData ->
            Route.GettingStarted.BrowserSupport.w3_encode_Data thisPageData
    
        DataGettingStarted__Installation thisPageData ->
            Route.GettingStarted.Installation.w3_encode_Data thisPageData
    
        DataGettingStarted__Welcome thisPageData ->
            Route.GettingStarted.Welcome.w3_encode_Data thisPageData
    
        DataGuide__Accessibility thisPageData ->
            Route.Guide.Accessibility.w3_encode_Data thisPageData
    
        DataGuide__AccessibleByConstruction thisPageData ->
            Route.Guide.AccessibleByConstruction.w3_encode_Data thisPageData
    
        DataGuide__CheatSheet thisPageData ->
            Route.Guide.CheatSheet.w3_encode_Data thisPageData
    
        DataGuide__CompositionTextField thisPageData ->
            Route.Guide.CompositionTextField.w3_encode_Data thisPageData
    
        DataGuide__FirstComponent thisPageData ->
            Route.Guide.FirstComponent.w3_encode_Data thisPageData
    
        DataGuide__GeneratedAndInspectable thisPageData ->
            Route.Guide.GeneratedAndInspectable.w3_encode_Data thisPageData
    
        DataGuide__Glossary thisPageData ->
            Route.Guide.Glossary.w3_encode_Data thisPageData
    
        DataGuide__HowWeProveIt thisPageData ->
            Route.Guide.HowWeProveIt.w3_encode_Data thisPageData
    
        DataGuide__InvalidStates thisPageData ->
            Route.Guide.InvalidStates.w3_encode_Data thisPageData
    
        DataGuide__Motion thisPageData ->
            Route.Guide.Motion.w3_encode_Data thisPageData
    
        DataGuide__Reference thisPageData ->
            Route.Guide.Reference.w3_encode_Data thisPageData
    
        DataGuide__Roundtrip thisPageData ->
            Route.Guide.Roundtrip.w3_encode_Data thisPageData
    
        DataGuide__Seams thisPageData ->
            Route.Guide.Seams.w3_encode_Data thisPageData
    
        DataGuide__Strictness thisPageData ->
            Route.Guide.Strictness.w3_encode_Data thisPageData
    
        DataGuide__TheLayers thisPageData ->
            Route.Guide.TheLayers.w3_encode_Data thisPageData
    
        DataGuide__Theming thisPageData ->
            Route.Guide.Theming.w3_encode_Data thisPageData
    
        DataGuide__ToolingRefactors thisPageData ->
            Route.Guide.ToolingRefactors.w3_encode_Data thisPageData
    
        DataGuide__Troubleshooting thisPageData ->
            Route.Guide.Troubleshooting.w3_encode_Data thisPageData
    
        DataStyles__Color thisPageData ->
            Route.Styles.Color.w3_encode_Data thisPageData
    
        DataStyles__Density thisPageData ->
            Route.Styles.Density.w3_encode_Data thisPageData
    
        DataStyles__Elevation thisPageData ->
            Route.Styles.Elevation.w3_encode_Data thisPageData
    
        DataStyles__Motion thisPageData ->
            Route.Styles.Motion.w3_encode_Data thisPageData
    
        DataStyles__Shape thisPageData ->
            Route.Styles.Shape.w3_encode_Data thisPageData
    
        DataStyles__StateLayers thisPageData ->
            Route.Styles.StateLayers.w3_encode_Data thisPageData
    
        DataStyles__Typography thisPageData ->
            Route.Styles.Typography.w3_encode_Data thisPageData
    
        DataComponents__Name_ thisPageData ->
            Route.Components.Name_.w3_encode_Data thisPageData
    
        DataExamples thisPageData ->
            Route.Examples.w3_encode_Data thisPageData
    
        DataGuide thisPageData ->
            Route.Guide.w3_encode_Data thisPageData
    
        DataIndex thisPageData ->
            Route.Index.w3_encode_Data thisPageData


byteDecodePageData : Maybe Route.Route -> Bytes.Decode.Decoder PageData
byteDecodePageData maybeRoute =
    case maybeRoute of
        Nothing ->
            Bytes.Decode.fail
    
        Just route ->
            case route of
                Route.Components__All ->
                    Bytes.Decode.map
                        DataComponents__All
                        Route.Components.All.w3_decode_Data
            
                Route.Examples__Dashboard ->
                    Bytes.Decode.map
                        DataExamples__Dashboard
                        Route.Examples.Dashboard.w3_decode_Data
            
                Route.Examples__Feed ->
                    Bytes.Decode.map
                        DataExamples__Feed
                        Route.Examples.Feed.w3_decode_Data
            
                Route.Examples__ListDetail ->
                    Bytes.Decode.map
                        DataExamples__ListDetail
                        Route.Examples.ListDetail.w3_decode_Data
            
                Route.Examples__Mail ->
                    Bytes.Decode.map
                        DataExamples__Mail
                        Route.Examples.Mail.w3_decode_Data
            
                Route.Examples__Settings ->
                    Bytes.Decode.map
                        DataExamples__Settings
                        Route.Examples.Settings.w3_decode_Data
            
                Route.Examples__Shop ->
                    Bytes.Decode.map
                        DataExamples__Shop
                        Route.Examples.Shop.w3_decode_Data
            
                Route.Examples__SupportingPane ->
                    Bytes.Decode.map
                        DataExamples__SupportingPane
                        Route.Examples.SupportingPane.w3_decode_Data
            
                Route.Examples__Travel ->
                    Bytes.Decode.map
                        DataExamples__Travel
                        Route.Examples.Travel.w3_decode_Data
            
                Route.GettingStarted__BrowserSupport ->
                    Bytes.Decode.map
                        DataGettingStarted__BrowserSupport
                        Route.GettingStarted.BrowserSupport.w3_decode_Data
            
                Route.GettingStarted__Installation ->
                    Bytes.Decode.map
                        DataGettingStarted__Installation
                        Route.GettingStarted.Installation.w3_decode_Data
            
                Route.GettingStarted__Welcome ->
                    Bytes.Decode.map
                        DataGettingStarted__Welcome
                        Route.GettingStarted.Welcome.w3_decode_Data
            
                Route.Guide__Accessibility ->
                    Bytes.Decode.map
                        DataGuide__Accessibility
                        Route.Guide.Accessibility.w3_decode_Data
            
                Route.Guide__AccessibleByConstruction ->
                    Bytes.Decode.map
                        DataGuide__AccessibleByConstruction
                        Route.Guide.AccessibleByConstruction.w3_decode_Data
            
                Route.Guide__CheatSheet ->
                    Bytes.Decode.map
                        DataGuide__CheatSheet
                        Route.Guide.CheatSheet.w3_decode_Data
            
                Route.Guide__CompositionTextField ->
                    Bytes.Decode.map
                        DataGuide__CompositionTextField
                        Route.Guide.CompositionTextField.w3_decode_Data
            
                Route.Guide__FirstComponent ->
                    Bytes.Decode.map
                        DataGuide__FirstComponent
                        Route.Guide.FirstComponent.w3_decode_Data
            
                Route.Guide__GeneratedAndInspectable ->
                    Bytes.Decode.map
                        DataGuide__GeneratedAndInspectable
                        Route.Guide.GeneratedAndInspectable.w3_decode_Data
            
                Route.Guide__Glossary ->
                    Bytes.Decode.map
                        DataGuide__Glossary
                        Route.Guide.Glossary.w3_decode_Data
            
                Route.Guide__HowWeProveIt ->
                    Bytes.Decode.map
                        DataGuide__HowWeProveIt
                        Route.Guide.HowWeProveIt.w3_decode_Data
            
                Route.Guide__InvalidStates ->
                    Bytes.Decode.map
                        DataGuide__InvalidStates
                        Route.Guide.InvalidStates.w3_decode_Data
            
                Route.Guide__Motion ->
                    Bytes.Decode.map
                        DataGuide__Motion
                        Route.Guide.Motion.w3_decode_Data
            
                Route.Guide__Reference ->
                    Bytes.Decode.map
                        DataGuide__Reference
                        Route.Guide.Reference.w3_decode_Data
            
                Route.Guide__Roundtrip ->
                    Bytes.Decode.map
                        DataGuide__Roundtrip
                        Route.Guide.Roundtrip.w3_decode_Data
            
                Route.Guide__Seams ->
                    Bytes.Decode.map
                        DataGuide__Seams
                        Route.Guide.Seams.w3_decode_Data
            
                Route.Guide__Strictness ->
                    Bytes.Decode.map
                        DataGuide__Strictness
                        Route.Guide.Strictness.w3_decode_Data
            
                Route.Guide__TheLayers ->
                    Bytes.Decode.map
                        DataGuide__TheLayers
                        Route.Guide.TheLayers.w3_decode_Data
            
                Route.Guide__Theming ->
                    Bytes.Decode.map
                        DataGuide__Theming
                        Route.Guide.Theming.w3_decode_Data
            
                Route.Guide__ToolingRefactors ->
                    Bytes.Decode.map
                        DataGuide__ToolingRefactors
                        Route.Guide.ToolingRefactors.w3_decode_Data
            
                Route.Guide__Troubleshooting ->
                    Bytes.Decode.map
                        DataGuide__Troubleshooting
                        Route.Guide.Troubleshooting.w3_decode_Data
            
                Route.Styles__Color ->
                    Bytes.Decode.map
                        DataStyles__Color
                        Route.Styles.Color.w3_decode_Data
            
                Route.Styles__Density ->
                    Bytes.Decode.map
                        DataStyles__Density
                        Route.Styles.Density.w3_decode_Data
            
                Route.Styles__Elevation ->
                    Bytes.Decode.map
                        DataStyles__Elevation
                        Route.Styles.Elevation.w3_decode_Data
            
                Route.Styles__Motion ->
                    Bytes.Decode.map
                        DataStyles__Motion
                        Route.Styles.Motion.w3_decode_Data
            
                Route.Styles__Shape ->
                    Bytes.Decode.map
                        DataStyles__Shape
                        Route.Styles.Shape.w3_decode_Data
            
                Route.Styles__StateLayers ->
                    Bytes.Decode.map
                        DataStyles__StateLayers
                        Route.Styles.StateLayers.w3_decode_Data
            
                Route.Styles__Typography ->
                    Bytes.Decode.map
                        DataStyles__Typography
                        Route.Styles.Typography.w3_decode_Data
            
                Route.Components__Name_ _ ->
                    Bytes.Decode.map
                        DataComponents__Name_
                        Route.Components.Name_.w3_decode_Data
            
                Route.Examples ->
                    Bytes.Decode.map DataExamples Route.Examples.w3_decode_Data
            
                Route.Guide ->
                    Bytes.Decode.map DataGuide Route.Guide.w3_decode_Data
            
                Route.Index ->
                    Bytes.Decode.map DataIndex Route.Index.w3_decode_Data


apiPatterns : ApiRoute.ApiRoute ApiRoute.Response
apiPatterns =
    ApiRoute.single
        (ApiRoute.literal
             "api-patterns.json"
             (ApiRoute.succeed
                  (BackendTask.succeed
                       (Json.Encode.encode
                            0
                            (Json.Encode.list
                                 Basics.identity
                                 (List.map
                                      ApiRoute.toJson
                                      (Api.routes
                                           getStaticRoutes
                                           (\routesUnpack -> \unpack -> "")
                                      )
                                 )
                            )
                       )
                  )
             )
        )


init :
    Maybe Shared.Model
    -> Pages.Flags.Flags
    -> Shared.Data
    -> PageData
    -> Maybe ActionData
    -> Maybe { path :
        { path : UrlPath.UrlPath
        , query : Maybe String
        , fragment : Maybe String
        }
    , metadata : Maybe Route.Route
    , pageUrl : Maybe Pages.PageUrl.PageUrl
    }
    -> ( Model, Effect.Effect Msg )
init currentGlobalModel userFlags sharedData pageData actionData maybePagePath =
    let
        ( sharedModel, globalCmd ) =
            Maybe.withDefault
                (Shared.template.init userFlags maybePagePath)
                (Maybe.map
                     (\mapUnpack -> ( mapUnpack, Effect.none ))
                     currentGlobalModel
                )
        
        ( templateModel, templateCmd ) =
            case
                Maybe.map2
                    Tuple.pair
                    (Maybe.andThen .metadata maybePagePath)
                    (Maybe.map .path maybePagePath)
            of
                Nothing ->
                    initErrorPage pageData
            
                Just justRouteAndPath ->
                    case ( Tuple.first justRouteAndPath, pageData ) of
                        ( Route.Components__All, DataComponents__All thisPageData ) ->
                            Tuple.mapBoth
                                ModelComponents__All
                                (Effect.map MsgComponents__All)
                                (Route.Components.All.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataComponents__All thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Components.All.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Examples__Dashboard, DataExamples__Dashboard thisPageData ) ->
                            Tuple.mapBoth
                                ModelExamples__Dashboard
                                (Effect.map MsgExamples__Dashboard)
                                (Route.Examples.Dashboard.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataExamples__Dashboard thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Examples.Dashboard.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Examples__Feed, DataExamples__Feed thisPageData ) ->
                            Tuple.mapBoth
                                ModelExamples__Feed
                                (Effect.map MsgExamples__Feed)
                                (Route.Examples.Feed.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataExamples__Feed thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Examples.Feed.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Examples__ListDetail, DataExamples__ListDetail thisPageData ) ->
                            Tuple.mapBoth
                                ModelExamples__ListDetail
                                (Effect.map MsgExamples__ListDetail)
                                (Route.Examples.ListDetail.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataExamples__ListDetail thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Examples.ListDetail.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Examples__Mail, DataExamples__Mail thisPageData ) ->
                            Tuple.mapBoth
                                ModelExamples__Mail
                                (Effect.map MsgExamples__Mail)
                                (Route.Examples.Mail.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataExamples__Mail thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Examples.Mail.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Examples__Settings, DataExamples__Settings thisPageData ) ->
                            Tuple.mapBoth
                                ModelExamples__Settings
                                (Effect.map MsgExamples__Settings)
                                (Route.Examples.Settings.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataExamples__Settings thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Examples.Settings.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Examples__Shop, DataExamples__Shop thisPageData ) ->
                            Tuple.mapBoth
                                ModelExamples__Shop
                                (Effect.map MsgExamples__Shop)
                                (Route.Examples.Shop.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataExamples__Shop thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Examples.Shop.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Examples__SupportingPane, DataExamples__SupportingPane thisPageData ) ->
                            Tuple.mapBoth
                                ModelExamples__SupportingPane
                                (Effect.map MsgExamples__SupportingPane)
                                (Route.Examples.SupportingPane.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataExamples__SupportingPane thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Examples.SupportingPane.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Examples__Travel, DataExamples__Travel thisPageData ) ->
                            Tuple.mapBoth
                                ModelExamples__Travel
                                (Effect.map MsgExamples__Travel)
                                (Route.Examples.Travel.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataExamples__Travel thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Examples.Travel.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.GettingStarted__BrowserSupport, DataGettingStarted__BrowserSupport thisPageData ) ->
                            Tuple.mapBoth
                                ModelGettingStarted__BrowserSupport
                                (Effect.map MsgGettingStarted__BrowserSupport)
                                (Route.GettingStarted.BrowserSupport.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataGettingStarted__BrowserSupport thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.GettingStarted.BrowserSupport.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.GettingStarted__Installation, DataGettingStarted__Installation thisPageData ) ->
                            Tuple.mapBoth
                                ModelGettingStarted__Installation
                                (Effect.map MsgGettingStarted__Installation)
                                (Route.GettingStarted.Installation.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataGettingStarted__Installation thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.GettingStarted.Installation.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.GettingStarted__Welcome, DataGettingStarted__Welcome thisPageData ) ->
                            Tuple.mapBoth
                                ModelGettingStarted__Welcome
                                (Effect.map MsgGettingStarted__Welcome)
                                (Route.GettingStarted.Welcome.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataGettingStarted__Welcome thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.GettingStarted.Welcome.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Guide__Accessibility, DataGuide__Accessibility thisPageData ) ->
                            Tuple.mapBoth
                                ModelGuide__Accessibility
                                (Effect.map MsgGuide__Accessibility)
                                (Route.Guide.Accessibility.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataGuide__Accessibility thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Guide.Accessibility.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Guide__AccessibleByConstruction, DataGuide__AccessibleByConstruction thisPageData ) ->
                            Tuple.mapBoth
                                ModelGuide__AccessibleByConstruction
                                (Effect.map MsgGuide__AccessibleByConstruction)
                                (Route.Guide.AccessibleByConstruction.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataGuide__AccessibleByConstruction thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Guide.AccessibleByConstruction.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Guide__CheatSheet, DataGuide__CheatSheet thisPageData ) ->
                            Tuple.mapBoth
                                ModelGuide__CheatSheet
                                (Effect.map MsgGuide__CheatSheet)
                                (Route.Guide.CheatSheet.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataGuide__CheatSheet thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Guide.CheatSheet.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Guide__CompositionTextField, DataGuide__CompositionTextField thisPageData ) ->
                            Tuple.mapBoth
                                ModelGuide__CompositionTextField
                                (Effect.map MsgGuide__CompositionTextField)
                                (Route.Guide.CompositionTextField.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataGuide__CompositionTextField thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Guide.CompositionTextField.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Guide__FirstComponent, DataGuide__FirstComponent thisPageData ) ->
                            Tuple.mapBoth
                                ModelGuide__FirstComponent
                                (Effect.map MsgGuide__FirstComponent)
                                (Route.Guide.FirstComponent.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataGuide__FirstComponent thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Guide.FirstComponent.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Guide__GeneratedAndInspectable, DataGuide__GeneratedAndInspectable thisPageData ) ->
                            Tuple.mapBoth
                                ModelGuide__GeneratedAndInspectable
                                (Effect.map MsgGuide__GeneratedAndInspectable)
                                (Route.Guide.GeneratedAndInspectable.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataGuide__GeneratedAndInspectable thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Guide.GeneratedAndInspectable.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Guide__Glossary, DataGuide__Glossary thisPageData ) ->
                            Tuple.mapBoth
                                ModelGuide__Glossary
                                (Effect.map MsgGuide__Glossary)
                                (Route.Guide.Glossary.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataGuide__Glossary thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Guide.Glossary.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Guide__HowWeProveIt, DataGuide__HowWeProveIt thisPageData ) ->
                            Tuple.mapBoth
                                ModelGuide__HowWeProveIt
                                (Effect.map MsgGuide__HowWeProveIt)
                                (Route.Guide.HowWeProveIt.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataGuide__HowWeProveIt thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Guide.HowWeProveIt.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Guide__InvalidStates, DataGuide__InvalidStates thisPageData ) ->
                            Tuple.mapBoth
                                ModelGuide__InvalidStates
                                (Effect.map MsgGuide__InvalidStates)
                                (Route.Guide.InvalidStates.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataGuide__InvalidStates thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Guide.InvalidStates.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Guide__Motion, DataGuide__Motion thisPageData ) ->
                            Tuple.mapBoth
                                ModelGuide__Motion
                                (Effect.map MsgGuide__Motion)
                                (Route.Guide.Motion.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataGuide__Motion thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Guide.Motion.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Guide__Reference, DataGuide__Reference thisPageData ) ->
                            Tuple.mapBoth
                                ModelGuide__Reference
                                (Effect.map MsgGuide__Reference)
                                (Route.Guide.Reference.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataGuide__Reference thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Guide.Reference.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Guide__Roundtrip, DataGuide__Roundtrip thisPageData ) ->
                            Tuple.mapBoth
                                ModelGuide__Roundtrip
                                (Effect.map MsgGuide__Roundtrip)
                                (Route.Guide.Roundtrip.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataGuide__Roundtrip thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Guide.Roundtrip.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Guide__Seams, DataGuide__Seams thisPageData ) ->
                            Tuple.mapBoth
                                ModelGuide__Seams
                                (Effect.map MsgGuide__Seams)
                                (Route.Guide.Seams.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataGuide__Seams thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Guide.Seams.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Guide__Strictness, DataGuide__Strictness thisPageData ) ->
                            Tuple.mapBoth
                                ModelGuide__Strictness
                                (Effect.map MsgGuide__Strictness)
                                (Route.Guide.Strictness.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataGuide__Strictness thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Guide.Strictness.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Guide__TheLayers, DataGuide__TheLayers thisPageData ) ->
                            Tuple.mapBoth
                                ModelGuide__TheLayers
                                (Effect.map MsgGuide__TheLayers)
                                (Route.Guide.TheLayers.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataGuide__TheLayers thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Guide.TheLayers.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Guide__Theming, DataGuide__Theming thisPageData ) ->
                            Tuple.mapBoth
                                ModelGuide__Theming
                                (Effect.map MsgGuide__Theming)
                                (Route.Guide.Theming.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataGuide__Theming thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Guide.Theming.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Guide__ToolingRefactors, DataGuide__ToolingRefactors thisPageData ) ->
                            Tuple.mapBoth
                                ModelGuide__ToolingRefactors
                                (Effect.map MsgGuide__ToolingRefactors)
                                (Route.Guide.ToolingRefactors.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataGuide__ToolingRefactors thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Guide.ToolingRefactors.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Guide__Troubleshooting, DataGuide__Troubleshooting thisPageData ) ->
                            Tuple.mapBoth
                                ModelGuide__Troubleshooting
                                (Effect.map MsgGuide__Troubleshooting)
                                (Route.Guide.Troubleshooting.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataGuide__Troubleshooting thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Guide.Troubleshooting.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Styles__Color, DataStyles__Color thisPageData ) ->
                            Tuple.mapBoth
                                ModelStyles__Color
                                (Effect.map MsgStyles__Color)
                                (Route.Styles.Color.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataStyles__Color thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Styles.Color.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Styles__Density, DataStyles__Density thisPageData ) ->
                            Tuple.mapBoth
                                ModelStyles__Density
                                (Effect.map MsgStyles__Density)
                                (Route.Styles.Density.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataStyles__Density thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Styles.Density.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Styles__Elevation, DataStyles__Elevation thisPageData ) ->
                            Tuple.mapBoth
                                ModelStyles__Elevation
                                (Effect.map MsgStyles__Elevation)
                                (Route.Styles.Elevation.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataStyles__Elevation thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Styles.Elevation.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Styles__Motion, DataStyles__Motion thisPageData ) ->
                            Tuple.mapBoth
                                ModelStyles__Motion
                                (Effect.map MsgStyles__Motion)
                                (Route.Styles.Motion.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataStyles__Motion thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Styles.Motion.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Styles__Shape, DataStyles__Shape thisPageData ) ->
                            Tuple.mapBoth
                                ModelStyles__Shape
                                (Effect.map MsgStyles__Shape)
                                (Route.Styles.Shape.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataStyles__Shape thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Styles.Shape.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Styles__StateLayers, DataStyles__StateLayers thisPageData ) ->
                            Tuple.mapBoth
                                ModelStyles__StateLayers
                                (Effect.map MsgStyles__StateLayers)
                                (Route.Styles.StateLayers.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataStyles__StateLayers thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Styles.StateLayers.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Styles__Typography, DataStyles__Typography thisPageData ) ->
                            Tuple.mapBoth
                                ModelStyles__Typography
                                (Effect.map MsgStyles__Typography)
                                (Route.Styles.Typography.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataStyles__Typography thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Styles.Typography.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Components__Name_ routeParams, DataComponents__Name_ thisPageData ) ->
                            Tuple.mapBoth
                                ModelComponents__Name_
                                (Effect.map MsgComponents__Name_)
                                (Route.Components.Name_.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataComponents__Name_ thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = routeParams
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Components.Name_.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Examples, DataExamples thisPageData ) ->
                            Tuple.mapBoth
                                ModelExamples
                                (Effect.map MsgExamples)
                                (Route.Examples.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataExamples thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Examples.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Guide, DataGuide thisPageData ) ->
                            Tuple.mapBoth
                                ModelGuide
                                (Effect.map MsgGuide)
                                (Route.Guide.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataGuide thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Guide.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        ( Route.Index, DataIndex thisPageData ) ->
                            Tuple.mapBoth
                                ModelIndex
                                (Effect.map MsgIndex)
                                (Route.Index.route.init
                                     sharedModel
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action =
                                         Maybe.andThen
                                             (\andThenUnpack ->
                                                  case andThenUnpack of
                                                      ActionDataIndex thisActionData ->
                                                          Just thisActionData
                                                  
                                                      _ ->
                                                          Nothing
                                             )
                                             actionData
                                     , routeParams = {}
                                     , path =
                                         (Tuple.second justRouteAndPath).path
                                     , url =
                                         Maybe.andThen .pageUrl maybePagePath
                                     , submit =
                                         Pages.Fetcher.submit
                                             Route.Index.w3_decode_ActionData
                                     , navigation = Nothing
                                     , concurrentSubmissions = Dict.empty
                                     , pageFormState = Dict.empty
                                     }
                                )
                    
                        _ ->
                            initErrorPage pageData
    in
    ( { global = sharedModel, page = templateModel, current = maybePagePath }
    , Effect.batch [ templateCmd, Effect.map MsgGlobal globalCmd ]
    )


update :
    Form.Model
    -> Dict.Dict String (Pages.ConcurrentSubmission.ConcurrentSubmission ActionData)
    -> Maybe Pages.Navigation.Navigation
    -> Shared.Data
    -> PageData
    -> Maybe Browser.Navigation.Key
    -> Msg
    -> Model
    -> ( Model, Effect.Effect Msg )
update pageFormState concurrentSubmissions navigation sharedData pageData navigationKey msg model =
    case msg of
        MsgErrorPage____ msg_ ->
            let
                ( updatedPageModel, pageCmd ) =
                    case ( model.page, pageData ) of
                        ( ModelErrorPage____ pageModel, DataErrorPage____ thisPageData ) ->
                            Tuple.mapBoth
                                ModelErrorPage____
                                (Effect.map MsgErrorPage____)
                                (ErrorPage.update thisPageData msg_ pageModel)
                    
                        _ ->
                            ( model.page, Effect.none )
            in
            ( { model | page = updatedPageModel }, pageCmd )
    
        MsgGlobal msg_ ->
            let
                ( sharedModel, globalCmd ) =
                    Shared.template.update msg_ model.global
            in
            ( { model | global = sharedModel }, Effect.map MsgGlobal globalCmd )
    
        OnPageChange record ->
            let
                ( updatedModel, cmd ) =
                    init
                        (Just model.global)
                        Pages.Flags.PreRenderFlags
                        sharedData
                        pageData
                        Nothing
                        (Just
                             { path =
                                 { path = record.path
                                 , query = record.query
                                 , fragment = record.fragment
                                 }
                             , metadata = record.metadata
                             , pageUrl =
                                 Just
                                     { protocol = record.protocol
                                     , host = record.host
                                     , port_ = record.port_
                                     , path = record.path
                                     , query =
                                         Maybe.withDefault
                                             Dict.empty
                                             (Maybe.map
                                                  Pages.PageUrl.parseQueryParams
                                                  record.query
                                             )
                                     , fragment = record.fragment
                                     }
                             }
                        )
            in
            case Shared.template.onPageChange of
                Nothing ->
                    ( updatedModel, cmd )
            
                Just thingy ->
                    let
                        ( updatedGlobalModel, globalCmd ) =
                            Shared.template.update
                                (thingy
                                     { path = record.path
                                     , query = record.query
                                     , fragment = record.fragment
                                     }
                                )
                                model.global
                    in
                    ( { updatedModel | global = updatedGlobalModel }
                    , Effect.batch [ cmd, Effect.map MsgGlobal globalCmd ]
                    )
    
        MsgComponents__All msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelComponents__All pageModel, DataComponents__All thisPageData, Just ( Route.Components__All, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelComponents__All
                                MsgComponents__All
                                model
                                (Route.Components.All.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Components.All.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataComponents__All justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgExamples__Dashboard msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelExamples__Dashboard pageModel, DataExamples__Dashboard thisPageData, Just ( Route.Examples__Dashboard, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelExamples__Dashboard
                                MsgExamples__Dashboard
                                model
                                (Route.Examples.Dashboard.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Examples.Dashboard.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataExamples__Dashboard justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgExamples__Feed msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelExamples__Feed pageModel, DataExamples__Feed thisPageData, Just ( Route.Examples__Feed, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelExamples__Feed
                                MsgExamples__Feed
                                model
                                (Route.Examples.Feed.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Examples.Feed.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataExamples__Feed justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgExamples__ListDetail msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelExamples__ListDetail pageModel, DataExamples__ListDetail thisPageData, Just ( Route.Examples__ListDetail, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelExamples__ListDetail
                                MsgExamples__ListDetail
                                model
                                (Route.Examples.ListDetail.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Examples.ListDetail.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataExamples__ListDetail justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgExamples__Mail msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelExamples__Mail pageModel, DataExamples__Mail thisPageData, Just ( Route.Examples__Mail, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelExamples__Mail
                                MsgExamples__Mail
                                model
                                (Route.Examples.Mail.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Examples.Mail.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataExamples__Mail justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgExamples__Settings msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelExamples__Settings pageModel, DataExamples__Settings thisPageData, Just ( Route.Examples__Settings, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelExamples__Settings
                                MsgExamples__Settings
                                model
                                (Route.Examples.Settings.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Examples.Settings.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataExamples__Settings justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgExamples__Shop msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelExamples__Shop pageModel, DataExamples__Shop thisPageData, Just ( Route.Examples__Shop, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelExamples__Shop
                                MsgExamples__Shop
                                model
                                (Route.Examples.Shop.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Examples.Shop.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataExamples__Shop justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgExamples__SupportingPane msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelExamples__SupportingPane pageModel, DataExamples__SupportingPane thisPageData, Just ( Route.Examples__SupportingPane, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelExamples__SupportingPane
                                MsgExamples__SupportingPane
                                model
                                (Route.Examples.SupportingPane.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Examples.SupportingPane.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataExamples__SupportingPane justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgExamples__Travel msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelExamples__Travel pageModel, DataExamples__Travel thisPageData, Just ( Route.Examples__Travel, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelExamples__Travel
                                MsgExamples__Travel
                                model
                                (Route.Examples.Travel.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Examples.Travel.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataExamples__Travel justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgGettingStarted__BrowserSupport msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelGettingStarted__BrowserSupport pageModel, DataGettingStarted__BrowserSupport thisPageData, Just ( Route.GettingStarted__BrowserSupport, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelGettingStarted__BrowserSupport
                                MsgGettingStarted__BrowserSupport
                                model
                                (Route.GettingStarted.BrowserSupport.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.GettingStarted.BrowserSupport.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataGettingStarted__BrowserSupport justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgGettingStarted__Installation msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelGettingStarted__Installation pageModel, DataGettingStarted__Installation thisPageData, Just ( Route.GettingStarted__Installation, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelGettingStarted__Installation
                                MsgGettingStarted__Installation
                                model
                                (Route.GettingStarted.Installation.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.GettingStarted.Installation.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataGettingStarted__Installation justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgGettingStarted__Welcome msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelGettingStarted__Welcome pageModel, DataGettingStarted__Welcome thisPageData, Just ( Route.GettingStarted__Welcome, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelGettingStarted__Welcome
                                MsgGettingStarted__Welcome
                                model
                                (Route.GettingStarted.Welcome.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.GettingStarted.Welcome.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataGettingStarted__Welcome justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgGuide__Accessibility msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelGuide__Accessibility pageModel, DataGuide__Accessibility thisPageData, Just ( Route.Guide__Accessibility, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelGuide__Accessibility
                                MsgGuide__Accessibility
                                model
                                (Route.Guide.Accessibility.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Guide.Accessibility.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataGuide__Accessibility justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgGuide__AccessibleByConstruction msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelGuide__AccessibleByConstruction pageModel, DataGuide__AccessibleByConstruction thisPageData, Just ( Route.Guide__AccessibleByConstruction, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelGuide__AccessibleByConstruction
                                MsgGuide__AccessibleByConstruction
                                model
                                (Route.Guide.AccessibleByConstruction.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Guide.AccessibleByConstruction.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataGuide__AccessibleByConstruction justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgGuide__CheatSheet msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelGuide__CheatSheet pageModel, DataGuide__CheatSheet thisPageData, Just ( Route.Guide__CheatSheet, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelGuide__CheatSheet
                                MsgGuide__CheatSheet
                                model
                                (Route.Guide.CheatSheet.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Guide.CheatSheet.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataGuide__CheatSheet justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgGuide__CompositionTextField msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelGuide__CompositionTextField pageModel, DataGuide__CompositionTextField thisPageData, Just ( Route.Guide__CompositionTextField, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelGuide__CompositionTextField
                                MsgGuide__CompositionTextField
                                model
                                (Route.Guide.CompositionTextField.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Guide.CompositionTextField.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataGuide__CompositionTextField justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgGuide__FirstComponent msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelGuide__FirstComponent pageModel, DataGuide__FirstComponent thisPageData, Just ( Route.Guide__FirstComponent, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelGuide__FirstComponent
                                MsgGuide__FirstComponent
                                model
                                (Route.Guide.FirstComponent.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Guide.FirstComponent.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataGuide__FirstComponent justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgGuide__GeneratedAndInspectable msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelGuide__GeneratedAndInspectable pageModel, DataGuide__GeneratedAndInspectable thisPageData, Just ( Route.Guide__GeneratedAndInspectable, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelGuide__GeneratedAndInspectable
                                MsgGuide__GeneratedAndInspectable
                                model
                                (Route.Guide.GeneratedAndInspectable.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Guide.GeneratedAndInspectable.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataGuide__GeneratedAndInspectable justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgGuide__Glossary msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelGuide__Glossary pageModel, DataGuide__Glossary thisPageData, Just ( Route.Guide__Glossary, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelGuide__Glossary
                                MsgGuide__Glossary
                                model
                                (Route.Guide.Glossary.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Guide.Glossary.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataGuide__Glossary justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgGuide__HowWeProveIt msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelGuide__HowWeProveIt pageModel, DataGuide__HowWeProveIt thisPageData, Just ( Route.Guide__HowWeProveIt, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelGuide__HowWeProveIt
                                MsgGuide__HowWeProveIt
                                model
                                (Route.Guide.HowWeProveIt.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Guide.HowWeProveIt.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataGuide__HowWeProveIt justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgGuide__InvalidStates msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelGuide__InvalidStates pageModel, DataGuide__InvalidStates thisPageData, Just ( Route.Guide__InvalidStates, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelGuide__InvalidStates
                                MsgGuide__InvalidStates
                                model
                                (Route.Guide.InvalidStates.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Guide.InvalidStates.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataGuide__InvalidStates justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgGuide__Motion msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelGuide__Motion pageModel, DataGuide__Motion thisPageData, Just ( Route.Guide__Motion, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelGuide__Motion
                                MsgGuide__Motion
                                model
                                (Route.Guide.Motion.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Guide.Motion.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataGuide__Motion justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgGuide__Reference msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelGuide__Reference pageModel, DataGuide__Reference thisPageData, Just ( Route.Guide__Reference, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelGuide__Reference
                                MsgGuide__Reference
                                model
                                (Route.Guide.Reference.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Guide.Reference.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataGuide__Reference justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgGuide__Roundtrip msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelGuide__Roundtrip pageModel, DataGuide__Roundtrip thisPageData, Just ( Route.Guide__Roundtrip, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelGuide__Roundtrip
                                MsgGuide__Roundtrip
                                model
                                (Route.Guide.Roundtrip.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Guide.Roundtrip.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataGuide__Roundtrip justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgGuide__Seams msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelGuide__Seams pageModel, DataGuide__Seams thisPageData, Just ( Route.Guide__Seams, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelGuide__Seams
                                MsgGuide__Seams
                                model
                                (Route.Guide.Seams.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Guide.Seams.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataGuide__Seams justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgGuide__Strictness msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelGuide__Strictness pageModel, DataGuide__Strictness thisPageData, Just ( Route.Guide__Strictness, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelGuide__Strictness
                                MsgGuide__Strictness
                                model
                                (Route.Guide.Strictness.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Guide.Strictness.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataGuide__Strictness justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgGuide__TheLayers msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelGuide__TheLayers pageModel, DataGuide__TheLayers thisPageData, Just ( Route.Guide__TheLayers, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelGuide__TheLayers
                                MsgGuide__TheLayers
                                model
                                (Route.Guide.TheLayers.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Guide.TheLayers.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataGuide__TheLayers justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgGuide__Theming msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelGuide__Theming pageModel, DataGuide__Theming thisPageData, Just ( Route.Guide__Theming, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelGuide__Theming
                                MsgGuide__Theming
                                model
                                (Route.Guide.Theming.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Guide.Theming.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataGuide__Theming justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgGuide__ToolingRefactors msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelGuide__ToolingRefactors pageModel, DataGuide__ToolingRefactors thisPageData, Just ( Route.Guide__ToolingRefactors, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelGuide__ToolingRefactors
                                MsgGuide__ToolingRefactors
                                model
                                (Route.Guide.ToolingRefactors.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Guide.ToolingRefactors.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataGuide__ToolingRefactors justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgGuide__Troubleshooting msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelGuide__Troubleshooting pageModel, DataGuide__Troubleshooting thisPageData, Just ( Route.Guide__Troubleshooting, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelGuide__Troubleshooting
                                MsgGuide__Troubleshooting
                                model
                                (Route.Guide.Troubleshooting.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Guide.Troubleshooting.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataGuide__Troubleshooting justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgStyles__Color msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelStyles__Color pageModel, DataStyles__Color thisPageData, Just ( Route.Styles__Color, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelStyles__Color
                                MsgStyles__Color
                                model
                                (Route.Styles.Color.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Styles.Color.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataStyles__Color justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgStyles__Density msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelStyles__Density pageModel, DataStyles__Density thisPageData, Just ( Route.Styles__Density, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelStyles__Density
                                MsgStyles__Density
                                model
                                (Route.Styles.Density.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Styles.Density.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataStyles__Density justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgStyles__Elevation msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelStyles__Elevation pageModel, DataStyles__Elevation thisPageData, Just ( Route.Styles__Elevation, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelStyles__Elevation
                                MsgStyles__Elevation
                                model
                                (Route.Styles.Elevation.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Styles.Elevation.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataStyles__Elevation justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgStyles__Motion msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelStyles__Motion pageModel, DataStyles__Motion thisPageData, Just ( Route.Styles__Motion, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelStyles__Motion
                                MsgStyles__Motion
                                model
                                (Route.Styles.Motion.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Styles.Motion.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataStyles__Motion justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgStyles__Shape msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelStyles__Shape pageModel, DataStyles__Shape thisPageData, Just ( Route.Styles__Shape, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelStyles__Shape
                                MsgStyles__Shape
                                model
                                (Route.Styles.Shape.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Styles.Shape.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataStyles__Shape justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgStyles__StateLayers msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelStyles__StateLayers pageModel, DataStyles__StateLayers thisPageData, Just ( Route.Styles__StateLayers, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelStyles__StateLayers
                                MsgStyles__StateLayers
                                model
                                (Route.Styles.StateLayers.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Styles.StateLayers.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataStyles__StateLayers justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgStyles__Typography msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelStyles__Typography pageModel, DataStyles__Typography thisPageData, Just ( Route.Styles__Typography, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelStyles__Typography
                                MsgStyles__Typography
                                model
                                (Route.Styles.Typography.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Styles.Typography.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataStyles__Typography justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgComponents__Name_ msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelComponents__Name_ pageModel, DataComponents__Name_ thisPageData, Just ( Route.Components__Name_ routeParams, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelComponents__Name_
                                MsgComponents__Name_
                                model
                                (Route.Components.Name_.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = routeParams
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Components.Name_.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataComponents__Name_ justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgExamples msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelExamples pageModel, DataExamples thisPageData, Just ( Route.Examples, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelExamples
                                MsgExamples
                                model
                                (Route.Examples.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Examples.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataExamples justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgGuide msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelGuide pageModel, DataGuide thisPageData, Just ( Route.Guide, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelGuide
                                MsgGuide
                                model
                                (Route.Guide.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Guide.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataGuide justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )
    
        MsgIndex msg_ ->
            case
                ( model.page
                , pageData
                , Maybe.map3
                    toTriple
                    (Maybe.andThen .metadata model.current)
                    (Maybe.andThen .pageUrl model.current)
                    (Maybe.map .path model.current)
                )
            of
                ( ModelIndex pageModel, DataIndex thisPageData, Just ( Route.Index, pageUrl, justPage ) ) ->
                    let
                        ( updatedPageModel, pageCmd, globalModelAndCmd ) =
                            fooFn
                                ModelIndex
                                MsgIndex
                                model
                                (Route.Index.route.update
                                     { data = thisPageData
                                     , sharedData = sharedData
                                     , action = Nothing
                                     , routeParams = {}
                                     , path = justPage.path
                                     , url = Just pageUrl
                                     , submit =
                                         \options ->
                                             Pages.Fetcher.submit
                                                 Route.Index.w3_decode_ActionData
                                                 options
                                     , navigation = navigation
                                     , concurrentSubmissions =
                                         Dict.map
                                             (\mapUnpack ->
                                                  Pages.ConcurrentSubmission.map
                                                      (\mapUnpack0 ->
                                                           case mapUnpack0 of
                                                               ActionDataIndex justActionData ->
                                                                   Just
                                                                       justActionData
                                                           
                                                               _ ->
                                                                   Nothing
                                                      )
                                             )
                                             concurrentSubmissions
                                     , pageFormState = pageFormState
                                     }
                                     msg_
                                     pageModel
                                     model.global
                                )
                        
                        ( newGlobalModel, newGlobalCmd ) =
                            globalModelAndCmd
                    in
                    ( { model
                        | page = updatedPageModel
                        , global = newGlobalModel
                      }
                    , Effect.batch
                        [ pageCmd, Effect.map MsgGlobal newGlobalCmd ]
                    )
            
                _ ->
                    ( model, Effect.none )


view :
    Form.Model
    -> Dict.Dict String (Pages.ConcurrentSubmission.ConcurrentSubmission ActionData)
    -> Maybe Pages.Navigation.Navigation
    -> { path : UrlPath.UrlPath, route : Maybe Route.Route }
    -> Maybe Pages.PageUrl.PageUrl
    -> Shared.Data
    -> PageData
    -> Maybe ActionData
    -> { view :
        Model
        -> { title : String, body : List (Html.Html (PagesMsg.PagesMsg Msg)) }
    , head : List Head.Tag
    }
view pageFormState concurrentSubmissions navigation page maybePageUrl globalData pageData actionData =
    case ( page.route, pageData ) of
        ( _, DataErrorPage____ data ) ->
            { view =
                \model ->
                    case model.page of
                        ModelErrorPage____ subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (\myMsg ->
                                          PagesMsg.fromMsg
                                              (MsgErrorPage____ myMsg)
                                     )
                                     (ErrorPage.view data subModel)
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( _, Data404NotFoundPage____ ) ->
            { view =
                \model ->
                    case model.page of
                        ModelErrorPage____ subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (\myMsg ->
                                          PagesMsg.fromMsg
                                              (MsgErrorPage____ myMsg)
                                     )
                                     (ErrorPage.view ErrorPage.notFound subModel
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Components__All, DataComponents__All data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataComponents__All justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelComponents__All subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgComponents__All)
                                     (Route.Components.All.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Components.All.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Examples__Dashboard, DataExamples__Dashboard data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataExamples__Dashboard justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelExamples__Dashboard subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgExamples__Dashboard)
                                     (Route.Examples.Dashboard.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Examples.Dashboard.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Examples__Feed, DataExamples__Feed data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataExamples__Feed justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelExamples__Feed subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgExamples__Feed)
                                     (Route.Examples.Feed.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Examples.Feed.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Examples__ListDetail, DataExamples__ListDetail data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataExamples__ListDetail justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelExamples__ListDetail subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgExamples__ListDetail)
                                     (Route.Examples.ListDetail.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Examples.ListDetail.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Examples__Mail, DataExamples__Mail data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataExamples__Mail justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelExamples__Mail subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgExamples__Mail)
                                     (Route.Examples.Mail.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Examples.Mail.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Examples__Settings, DataExamples__Settings data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataExamples__Settings justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelExamples__Settings subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgExamples__Settings)
                                     (Route.Examples.Settings.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Examples.Settings.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Examples__Shop, DataExamples__Shop data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataExamples__Shop justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelExamples__Shop subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgExamples__Shop)
                                     (Route.Examples.Shop.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Examples.Shop.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Examples__SupportingPane, DataExamples__SupportingPane data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataExamples__SupportingPane justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelExamples__SupportingPane subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgExamples__SupportingPane)
                                     (Route.Examples.SupportingPane.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Examples.SupportingPane.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Examples__Travel, DataExamples__Travel data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataExamples__Travel justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelExamples__Travel subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgExamples__Travel)
                                     (Route.Examples.Travel.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Examples.Travel.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.GettingStarted__BrowserSupport, DataGettingStarted__BrowserSupport data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataGettingStarted__BrowserSupport justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelGettingStarted__BrowserSupport subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map
                                          MsgGettingStarted__BrowserSupport
                                     )
                                     (Route.GettingStarted.BrowserSupport.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.GettingStarted.BrowserSupport.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.GettingStarted__Installation, DataGettingStarted__Installation data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataGettingStarted__Installation justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelGettingStarted__Installation subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map
                                          MsgGettingStarted__Installation
                                     )
                                     (Route.GettingStarted.Installation.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.GettingStarted.Installation.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.GettingStarted__Welcome, DataGettingStarted__Welcome data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataGettingStarted__Welcome justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelGettingStarted__Welcome subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgGettingStarted__Welcome)
                                     (Route.GettingStarted.Welcome.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.GettingStarted.Welcome.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Guide__Accessibility, DataGuide__Accessibility data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataGuide__Accessibility justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelGuide__Accessibility subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgGuide__Accessibility)
                                     (Route.Guide.Accessibility.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Guide.Accessibility.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Guide__AccessibleByConstruction, DataGuide__AccessibleByConstruction data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataGuide__AccessibleByConstruction justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelGuide__AccessibleByConstruction subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map
                                          MsgGuide__AccessibleByConstruction
                                     )
                                     (Route.Guide.AccessibleByConstruction.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Guide.AccessibleByConstruction.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Guide__CheatSheet, DataGuide__CheatSheet data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataGuide__CheatSheet justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelGuide__CheatSheet subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgGuide__CheatSheet)
                                     (Route.Guide.CheatSheet.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Guide.CheatSheet.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Guide__CompositionTextField, DataGuide__CompositionTextField data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataGuide__CompositionTextField justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelGuide__CompositionTextField subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map
                                          MsgGuide__CompositionTextField
                                     )
                                     (Route.Guide.CompositionTextField.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Guide.CompositionTextField.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Guide__FirstComponent, DataGuide__FirstComponent data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataGuide__FirstComponent justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelGuide__FirstComponent subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgGuide__FirstComponent)
                                     (Route.Guide.FirstComponent.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Guide.FirstComponent.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Guide__GeneratedAndInspectable, DataGuide__GeneratedAndInspectable data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataGuide__GeneratedAndInspectable justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelGuide__GeneratedAndInspectable subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map
                                          MsgGuide__GeneratedAndInspectable
                                     )
                                     (Route.Guide.GeneratedAndInspectable.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Guide.GeneratedAndInspectable.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Guide__Glossary, DataGuide__Glossary data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataGuide__Glossary justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelGuide__Glossary subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgGuide__Glossary)
                                     (Route.Guide.Glossary.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Guide.Glossary.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Guide__HowWeProveIt, DataGuide__HowWeProveIt data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataGuide__HowWeProveIt justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelGuide__HowWeProveIt subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgGuide__HowWeProveIt)
                                     (Route.Guide.HowWeProveIt.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Guide.HowWeProveIt.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Guide__InvalidStates, DataGuide__InvalidStates data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataGuide__InvalidStates justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelGuide__InvalidStates subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgGuide__InvalidStates)
                                     (Route.Guide.InvalidStates.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Guide.InvalidStates.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Guide__Motion, DataGuide__Motion data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataGuide__Motion justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelGuide__Motion subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgGuide__Motion)
                                     (Route.Guide.Motion.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Guide.Motion.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Guide__Reference, DataGuide__Reference data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataGuide__Reference justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelGuide__Reference subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgGuide__Reference)
                                     (Route.Guide.Reference.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Guide.Reference.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Guide__Roundtrip, DataGuide__Roundtrip data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataGuide__Roundtrip justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelGuide__Roundtrip subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgGuide__Roundtrip)
                                     (Route.Guide.Roundtrip.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Guide.Roundtrip.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Guide__Seams, DataGuide__Seams data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataGuide__Seams justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelGuide__Seams subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgGuide__Seams)
                                     (Route.Guide.Seams.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Guide.Seams.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Guide__Strictness, DataGuide__Strictness data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataGuide__Strictness justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelGuide__Strictness subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgGuide__Strictness)
                                     (Route.Guide.Strictness.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Guide.Strictness.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Guide__TheLayers, DataGuide__TheLayers data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataGuide__TheLayers justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelGuide__TheLayers subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgGuide__TheLayers)
                                     (Route.Guide.TheLayers.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Guide.TheLayers.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Guide__Theming, DataGuide__Theming data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataGuide__Theming justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelGuide__Theming subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgGuide__Theming)
                                     (Route.Guide.Theming.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Guide.Theming.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Guide__ToolingRefactors, DataGuide__ToolingRefactors data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataGuide__ToolingRefactors justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelGuide__ToolingRefactors subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgGuide__ToolingRefactors)
                                     (Route.Guide.ToolingRefactors.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Guide.ToolingRefactors.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Guide__Troubleshooting, DataGuide__Troubleshooting data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataGuide__Troubleshooting justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelGuide__Troubleshooting subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgGuide__Troubleshooting)
                                     (Route.Guide.Troubleshooting.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Guide.Troubleshooting.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Styles__Color, DataStyles__Color data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataStyles__Color justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelStyles__Color subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgStyles__Color)
                                     (Route.Styles.Color.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Styles.Color.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Styles__Density, DataStyles__Density data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataStyles__Density justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelStyles__Density subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgStyles__Density)
                                     (Route.Styles.Density.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Styles.Density.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Styles__Elevation, DataStyles__Elevation data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataStyles__Elevation justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelStyles__Elevation subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgStyles__Elevation)
                                     (Route.Styles.Elevation.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Styles.Elevation.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Styles__Motion, DataStyles__Motion data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataStyles__Motion justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelStyles__Motion subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgStyles__Motion)
                                     (Route.Styles.Motion.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Styles.Motion.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Styles__Shape, DataStyles__Shape data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataStyles__Shape justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelStyles__Shape subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgStyles__Shape)
                                     (Route.Styles.Shape.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Styles.Shape.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Styles__StateLayers, DataStyles__StateLayers data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataStyles__StateLayers justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelStyles__StateLayers subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgStyles__StateLayers)
                                     (Route.Styles.StateLayers.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Styles.StateLayers.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Styles__Typography, DataStyles__Typography data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataStyles__Typography justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelStyles__Typography subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgStyles__Typography)
                                     (Route.Styles.Typography.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Styles.Typography.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just (Route.Components__Name_ routeParams), DataComponents__Name_ data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataComponents__Name_ justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelComponents__Name_ subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgComponents__Name_)
                                     (Route.Components.Name_.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = routeParams
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Components.Name_.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Examples, DataExamples data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataExamples justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelExamples subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgExamples)
                                     (Route.Examples.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Examples.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Guide, DataGuide data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataGuide justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelGuide subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgGuide)
                                     (Route.Guide.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Guide.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        ( Just Route.Index, DataIndex data ) ->
            let
                actionDataOrNothing thisActionData =
                    case thisActionData of
                        ActionDataIndex justActionData ->
                            Just justActionData
                    
                        _ ->
                            Nothing
            in
            { view =
                \model ->
                    case model.page of
                        ModelIndex subModel ->
                            Shared.template.view
                                globalData
                                page
                                model.global
                                (\myMsg -> PagesMsg.fromMsg (MsgGlobal myMsg))
                                (View.map
                                     (PagesMsg.map MsgIndex)
                                     (Route.Index.route.view
                                          model.global
                                          subModel
                                          { data = data
                                          , sharedData = globalData
                                          , routeParams = {}
                                          , action =
                                              Maybe.andThen
                                                  actionDataOrNothing
                                                  actionData
                                          , path = page.path
                                          , url = maybePageUrl
                                          , submit =
                                              Pages.Fetcher.submit
                                                  Route.Index.w3_decode_ActionData
                                          , navigation = navigation
                                          , concurrentSubmissions =
                                              Dict.map
                                                  (\mapUnpack ->
                                                       Pages.ConcurrentSubmission.map
                                                           actionDataOrNothing
                                                  )
                                                  concurrentSubmissions
                                          , pageFormState = pageFormState
                                          }
                                     )
                                )
                    
                        _ ->
                            modelMismatchView
            , head = []
            }
    
        _ ->
            { view =
                \_ ->
                    { title = "Page not found"
                    , body =
                        [ Html.div
                            []
                            [ Html.text "This page could not be found." ]
                        ]
                    }
            , head = []
            }


maybeToString : Maybe String -> String
maybeToString maybeString =
    case maybeString of
        Nothing ->
            "Nothing"
    
        Just string ->
            "Just " ++ stringToString string


stringToString : String -> String
stringToString string =
    "\"" ++ string ++ "\""


nonEmptyToString : ( String, List String ) -> String
nonEmptyToString nonEmpty =
    case nonEmpty of
        ( first, rest ) ->
            "( " ++ stringToString first ++ ", [ " ++ String.join
                                                                      ", "
                                                                      (List.map
                                                                                       stringToString
                                                                                       rest
                                                                      ) ++ " ] )"


listToString : List String -> String
listToString strings =
    "[ " ++ String.join ", " (List.map stringToString strings) ++ " ]"


initErrorPage : PageData -> ( PageModel, Effect.Effect Msg )
initErrorPage pageData =
    Tuple.mapBoth
        ModelErrorPage____
        (Effect.map MsgErrorPage____)
        (ErrorPage.init
             (case pageData of
                  DataErrorPage____ errorPage ->
                      errorPage
              
                  _ ->
                      ErrorPage.notFound
             )
        )


routePatterns : ApiRoute.ApiRoute ApiRoute.Response
routePatterns =
    ApiRoute.single
        (ApiRoute.literal
             "route-patterns.json"
             (ApiRoute.succeed
                  (BackendTask.succeed
                       (Json.Encode.encode
                            0
                            (Json.Encode.list
                                 (\listUnpack ->
                                      Json.Encode.object
                                          [ ( "kind"
                                            , Json.Encode.string listUnpack.kind
                                            )
                                          , ( "pathPattern"
                                            , Json.Encode.string
                                                  listUnpack.pathPattern
                                            )
                                          ]
                                 )
                                 [ { pathPattern = "/components/all"
                                   , kind = Route.Components.All.route.kind
                                   }
                                 , { pathPattern = "/examples/dashboard"
                                   , kind = Route.Examples.Dashboard.route.kind
                                   }
                                 , { pathPattern = "/examples/feed"
                                   , kind = Route.Examples.Feed.route.kind
                                   }
                                 , { pathPattern = "/examples/list-detail"
                                   , kind = Route.Examples.ListDetail.route.kind
                                   }
                                 , { pathPattern = "/examples/mail"
                                   , kind = Route.Examples.Mail.route.kind
                                   }
                                 , { pathPattern = "/examples/settings"
                                   , kind = Route.Examples.Settings.route.kind
                                   }
                                 , { pathPattern = "/examples/shop"
                                   , kind = Route.Examples.Shop.route.kind
                                   }
                                 , { pathPattern = "/examples/supporting-pane"
                                   , kind =
                                       Route.Examples.SupportingPane.route.kind
                                   }
                                 , { pathPattern = "/examples/travel"
                                   , kind = Route.Examples.Travel.route.kind
                                   }
                                 , { pathPattern =
                                       "/getting-started/browser-support"
                                   , kind =
                                       Route.GettingStarted.BrowserSupport.route.kind
                                   }
                                 , { pathPattern =
                                       "/getting-started/installation"
                                   , kind =
                                       Route.GettingStarted.Installation.route.kind
                                   }
                                 , { pathPattern = "/getting-started/welcome"
                                   , kind =
                                       Route.GettingStarted.Welcome.route.kind
                                   }
                                 , { pathPattern = "/guide/accessibility"
                                   , kind = Route.Guide.Accessibility.route.kind
                                   }
                                 , { pathPattern =
                                       "/guide/accessible-by-construction"
                                   , kind =
                                       Route.Guide.AccessibleByConstruction.route.kind
                                   }
                                 , { pathPattern = "/guide/cheat-sheet"
                                   , kind = Route.Guide.CheatSheet.route.kind
                                   }
                                 , { pathPattern =
                                       "/guide/composition-text-field"
                                   , kind =
                                       Route.Guide.CompositionTextField.route.kind
                                   }
                                 , { pathPattern = "/guide/first-component"
                                   , kind =
                                       Route.Guide.FirstComponent.route.kind
                                   }
                                 , { pathPattern =
                                       "/guide/generated-and-inspectable"
                                   , kind =
                                       Route.Guide.GeneratedAndInspectable.route.kind
                                   }
                                 , { pathPattern = "/guide/glossary"
                                   , kind = Route.Guide.Glossary.route.kind
                                   }
                                 , { pathPattern = "/guide/how-we-prove-it"
                                   , kind = Route.Guide.HowWeProveIt.route.kind
                                   }
                                 , { pathPattern = "/guide/invalid-states"
                                   , kind = Route.Guide.InvalidStates.route.kind
                                   }
                                 , { pathPattern = "/guide/motion"
                                   , kind = Route.Guide.Motion.route.kind
                                   }
                                 , { pathPattern = "/guide/reference"
                                   , kind = Route.Guide.Reference.route.kind
                                   }
                                 , { pathPattern = "/guide/roundtrip"
                                   , kind = Route.Guide.Roundtrip.route.kind
                                   }
                                 , { pathPattern = "/guide/seams"
                                   , kind = Route.Guide.Seams.route.kind
                                   }
                                 , { pathPattern = "/guide/strictness"
                                   , kind = Route.Guide.Strictness.route.kind
                                   }
                                 , { pathPattern = "/guide/the-layers"
                                   , kind = Route.Guide.TheLayers.route.kind
                                   }
                                 , { pathPattern = "/guide/theming"
                                   , kind = Route.Guide.Theming.route.kind
                                   }
                                 , { pathPattern = "/guide/tooling-refactors"
                                   , kind =
                                       Route.Guide.ToolingRefactors.route.kind
                                   }
                                 , { pathPattern = "/guide/troubleshooting"
                                   , kind =
                                       Route.Guide.Troubleshooting.route.kind
                                   }
                                 , { pathPattern = "/styles/color"
                                   , kind = Route.Styles.Color.route.kind
                                   }
                                 , { pathPattern = "/styles/density"
                                   , kind = Route.Styles.Density.route.kind
                                   }
                                 , { pathPattern = "/styles/elevation"
                                   , kind = Route.Styles.Elevation.route.kind
                                   }
                                 , { pathPattern = "/styles/motion"
                                   , kind = Route.Styles.Motion.route.kind
                                   }
                                 , { pathPattern = "/styles/shape"
                                   , kind = Route.Styles.Shape.route.kind
                                   }
                                 , { pathPattern = "/styles/state-layers"
                                   , kind = Route.Styles.StateLayers.route.kind
                                   }
                                 , { pathPattern = "/styles/typography"
                                   , kind = Route.Styles.Typography.route.kind
                                   }
                                 , { pathPattern = "/components/:name"
                                   , kind = Route.Components.Name_.route.kind
                                   }
                                 , { pathPattern = "/examples"
                                   , kind = Route.Examples.route.kind
                                   }
                                 , { pathPattern = "/guide"
                                   , kind = Route.Guide.route.kind
                                   }
                                 , { pathPattern = "/"
                                   , kind = Route.Index.route.kind
                                   }
                                 ]
                            )
                       )
                  )
             )
        )


pathsToGenerateHandler =
    ApiRoute.single
        (ApiRoute.literal
             "all-paths.json"
             (ApiRoute.succeed
                  (BackendTask.map2
                       (\map2Unpack ->
                            \unpack ->
                                Json.Encode.encode
                                    0
                                    (Json.Encode.list
                                         Json.Encode.string
                                         (map2Unpack ++ List.map
                                                                (\api ->
                                                                         "/" ++ api
                                                                )
                                                                unpack
                                         )
                                    )
                       )
                       (BackendTask.map
                            (List.map
                                 (\route ->
                                      UrlPath.toAbsolute (Route.toPath route)
                                 )
                            )
                            getStaticRoutes
                       )
                       (BackendTask.map
                            List.concat
                            (BackendTask.combine
                                 (List.map
                                      ApiRoute.getBuildTimeRoutes
                                      (routePatterns :: apiPatterns :: Api.routes
                                                                                   getStaticRoutes
                                                                                   (\routesUnpack ->
                                                                                                \unpack ->
                                                                                                    ""
                                                                                   )
                                      )
                                 )
                            )
                       )
                  )
             )
        )


getStaticRoutes :
    BackendTask.BackendTask FatalError.FatalError (List Route.Route)
getStaticRoutes =
    BackendTask.map
        List.concat
        (BackendTask.combine
             [ BackendTask.map
                 (List.map (\_ -> Route.Components__All))
                 Route.Components.All.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Examples__Dashboard))
                 Route.Examples.Dashboard.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Examples__Feed))
                 Route.Examples.Feed.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Examples__ListDetail))
                 Route.Examples.ListDetail.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Examples__Mail))
                 Route.Examples.Mail.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Examples__Settings))
                 Route.Examples.Settings.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Examples__Shop))
                 Route.Examples.Shop.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Examples__SupportingPane))
                 Route.Examples.SupportingPane.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Examples__Travel))
                 Route.Examples.Travel.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.GettingStarted__BrowserSupport))
                 Route.GettingStarted.BrowserSupport.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.GettingStarted__Installation))
                 Route.GettingStarted.Installation.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.GettingStarted__Welcome))
                 Route.GettingStarted.Welcome.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Guide__Accessibility))
                 Route.Guide.Accessibility.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Guide__AccessibleByConstruction))
                 Route.Guide.AccessibleByConstruction.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Guide__CheatSheet))
                 Route.Guide.CheatSheet.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Guide__CompositionTextField))
                 Route.Guide.CompositionTextField.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Guide__FirstComponent))
                 Route.Guide.FirstComponent.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Guide__GeneratedAndInspectable))
                 Route.Guide.GeneratedAndInspectable.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Guide__Glossary))
                 Route.Guide.Glossary.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Guide__HowWeProveIt))
                 Route.Guide.HowWeProveIt.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Guide__InvalidStates))
                 Route.Guide.InvalidStates.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Guide__Motion))
                 Route.Guide.Motion.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Guide__Reference))
                 Route.Guide.Reference.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Guide__Roundtrip))
                 Route.Guide.Roundtrip.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Guide__Seams))
                 Route.Guide.Seams.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Guide__Strictness))
                 Route.Guide.Strictness.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Guide__TheLayers))
                 Route.Guide.TheLayers.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Guide__Theming))
                 Route.Guide.Theming.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Guide__ToolingRefactors))
                 Route.Guide.ToolingRefactors.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Guide__Troubleshooting))
                 Route.Guide.Troubleshooting.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Styles__Color))
                 Route.Styles.Color.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Styles__Density))
                 Route.Styles.Density.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Styles__Elevation))
                 Route.Styles.Elevation.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Styles__Motion))
                 Route.Styles.Motion.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Styles__Shape))
                 Route.Styles.Shape.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Styles__StateLayers))
                 Route.Styles.StateLayers.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Styles__Typography))
                 Route.Styles.Typography.route.staticRoutes
             , BackendTask.map
                 (List.map Route.Components__Name_)
                 Route.Components.Name_.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Examples))
                 Route.Examples.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Guide))
                 Route.Guide.route.staticRoutes
             , BackendTask.map
                 (List.map (\_ -> Route.Index))
                 Route.Index.route.staticRoutes
             ]
        )


handleRoute :
    Maybe Route.Route
    -> BackendTask.BackendTask FatalError.FatalError (Maybe Pages.Internal.NotFoundReason.NotFoundReason)
handleRoute maybeRoute =
    case maybeRoute of
        Nothing ->
            BackendTask.succeed Nothing
    
        Just route ->
            case route of
                Route.Components__All ->
                    Route.Components.All.route.handleRoute
                        { moduleName = [ "Components", "All" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "components"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "all"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Examples__Dashboard ->
                    Route.Examples.Dashboard.route.handleRoute
                        { moduleName = [ "Examples", "Dashboard" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "examples"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "dashboard"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Examples__Feed ->
                    Route.Examples.Feed.route.handleRoute
                        { moduleName = [ "Examples", "Feed" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "examples"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "feed"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Examples__ListDetail ->
                    Route.Examples.ListDetail.route.handleRoute
                        { moduleName = [ "Examples", "ListDetail" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "examples"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "list-detail"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Examples__Mail ->
                    Route.Examples.Mail.route.handleRoute
                        { moduleName = [ "Examples", "Mail" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "examples"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "mail"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Examples__Settings ->
                    Route.Examples.Settings.route.handleRoute
                        { moduleName = [ "Examples", "Settings" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "examples"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "settings"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Examples__Shop ->
                    Route.Examples.Shop.route.handleRoute
                        { moduleName = [ "Examples", "Shop" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "examples"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "shop"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Examples__SupportingPane ->
                    Route.Examples.SupportingPane.route.handleRoute
                        { moduleName = [ "Examples", "SupportingPane" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "examples"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "supporting-pane"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Examples__Travel ->
                    Route.Examples.Travel.route.handleRoute
                        { moduleName = [ "Examples", "Travel" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "examples"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "travel"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.GettingStarted__BrowserSupport ->
                    Route.GettingStarted.BrowserSupport.route.handleRoute
                        { moduleName = [ "GettingStarted", "BrowserSupport" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "getting-started"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "browser-support"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.GettingStarted__Installation ->
                    Route.GettingStarted.Installation.route.handleRoute
                        { moduleName = [ "GettingStarted", "Installation" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "getting-started"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "installation"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.GettingStarted__Welcome ->
                    Route.GettingStarted.Welcome.route.handleRoute
                        { moduleName = [ "GettingStarted", "Welcome" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "getting-started"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "welcome"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Guide__Accessibility ->
                    Route.Guide.Accessibility.route.handleRoute
                        { moduleName = [ "Guide", "Accessibility" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "guide"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "accessibility"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Guide__AccessibleByConstruction ->
                    Route.Guide.AccessibleByConstruction.route.handleRoute
                        { moduleName = [ "Guide", "AccessibleByConstruction" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "guide"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "accessible-by-construction"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Guide__CheatSheet ->
                    Route.Guide.CheatSheet.route.handleRoute
                        { moduleName = [ "Guide", "CheatSheet" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "guide"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "cheat-sheet"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Guide__CompositionTextField ->
                    Route.Guide.CompositionTextField.route.handleRoute
                        { moduleName = [ "Guide", "CompositionTextField" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "guide"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "composition-text-field"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Guide__FirstComponent ->
                    Route.Guide.FirstComponent.route.handleRoute
                        { moduleName = [ "Guide", "FirstComponent" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "guide"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "first-component"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Guide__GeneratedAndInspectable ->
                    Route.Guide.GeneratedAndInspectable.route.handleRoute
                        { moduleName = [ "Guide", "GeneratedAndInspectable" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "guide"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "generated-and-inspectable"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Guide__Glossary ->
                    Route.Guide.Glossary.route.handleRoute
                        { moduleName = [ "Guide", "Glossary" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "guide"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "glossary"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Guide__HowWeProveIt ->
                    Route.Guide.HowWeProveIt.route.handleRoute
                        { moduleName = [ "Guide", "HowWeProveIt" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "guide"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "how-we-prove-it"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Guide__InvalidStates ->
                    Route.Guide.InvalidStates.route.handleRoute
                        { moduleName = [ "Guide", "InvalidStates" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "guide"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "invalid-states"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Guide__Motion ->
                    Route.Guide.Motion.route.handleRoute
                        { moduleName = [ "Guide", "Motion" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "guide"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "motion"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Guide__Reference ->
                    Route.Guide.Reference.route.handleRoute
                        { moduleName = [ "Guide", "Reference" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "guide"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "reference"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Guide__Roundtrip ->
                    Route.Guide.Roundtrip.route.handleRoute
                        { moduleName = [ "Guide", "Roundtrip" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "guide"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "roundtrip"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Guide__Seams ->
                    Route.Guide.Seams.route.handleRoute
                        { moduleName = [ "Guide", "Seams" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "guide"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "seams"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Guide__Strictness ->
                    Route.Guide.Strictness.route.handleRoute
                        { moduleName = [ "Guide", "Strictness" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "guide"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "strictness"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Guide__TheLayers ->
                    Route.Guide.TheLayers.route.handleRoute
                        { moduleName = [ "Guide", "TheLayers" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "guide"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "the-layers"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Guide__Theming ->
                    Route.Guide.Theming.route.handleRoute
                        { moduleName = [ "Guide", "Theming" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "guide"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "theming"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Guide__ToolingRefactors ->
                    Route.Guide.ToolingRefactors.route.handleRoute
                        { moduleName = [ "Guide", "ToolingRefactors" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "guide"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "tooling-refactors"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Guide__Troubleshooting ->
                    Route.Guide.Troubleshooting.route.handleRoute
                        { moduleName = [ "Guide", "Troubleshooting" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "guide"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "troubleshooting"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Styles__Color ->
                    Route.Styles.Color.route.handleRoute
                        { moduleName = [ "Styles", "Color" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "styles"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "color"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Styles__Density ->
                    Route.Styles.Density.route.handleRoute
                        { moduleName = [ "Styles", "Density" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "styles"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "density"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Styles__Elevation ->
                    Route.Styles.Elevation.route.handleRoute
                        { moduleName = [ "Styles", "Elevation" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "styles"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "elevation"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Styles__Motion ->
                    Route.Styles.Motion.route.handleRoute
                        { moduleName = [ "Styles", "Motion" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "styles"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "motion"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Styles__Shape ->
                    Route.Styles.Shape.route.handleRoute
                        { moduleName = [ "Styles", "Shape" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "styles"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "shape"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Styles__StateLayers ->
                    Route.Styles.StateLayers.route.handleRoute
                        { moduleName = [ "Styles", "StateLayers" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "styles"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "state-layers"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Styles__Typography ->
                    Route.Styles.Typography.route.handleRoute
                        { moduleName = [ "Styles", "Typography" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "styles"
                                , Pages.Internal.RoutePattern.StaticSegment
                                    "typography"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Components__Name_ routeParams ->
                    Route.Components.Name_.route.handleRoute
                        { moduleName = [ "Components", "Name_" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "components"
                                , Pages.Internal.RoutePattern.DynamicSegment
                                    "name"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [ ( "name", stringToString param.name ) ])
                        routeParams
            
                Route.Examples ->
                    Route.Examples.route.handleRoute
                        { moduleName = [ "Examples" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "examples"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Guide ->
                    Route.Guide.route.handleRoute
                        { moduleName = [ "Guide" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "guide"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}
            
                Route.Index ->
                    Route.Index.route.handleRoute
                        { moduleName = [ "Index" ]
                        , routePattern =
                            { segments =
                                [ Pages.Internal.RoutePattern.StaticSegment
                                    "index"
                                ]
                            , ending = Nothing
                            }
                        }
                        (\param -> [])
                        {}


encodeActionData : ActionData -> Bytes.Encode.Encoder
encodeActionData actionData =
    case actionData of
        ActionDataComponents__All thisActionData ->
            Route.Components.All.w3_encode_ActionData thisActionData
    
        ActionDataExamples__Dashboard thisActionData ->
            Route.Examples.Dashboard.w3_encode_ActionData thisActionData
    
        ActionDataExamples__Feed thisActionData ->
            Route.Examples.Feed.w3_encode_ActionData thisActionData
    
        ActionDataExamples__ListDetail thisActionData ->
            Route.Examples.ListDetail.w3_encode_ActionData thisActionData
    
        ActionDataExamples__Mail thisActionData ->
            Route.Examples.Mail.w3_encode_ActionData thisActionData
    
        ActionDataExamples__Settings thisActionData ->
            Route.Examples.Settings.w3_encode_ActionData thisActionData
    
        ActionDataExamples__Shop thisActionData ->
            Route.Examples.Shop.w3_encode_ActionData thisActionData
    
        ActionDataExamples__SupportingPane thisActionData ->
            Route.Examples.SupportingPane.w3_encode_ActionData thisActionData
    
        ActionDataExamples__Travel thisActionData ->
            Route.Examples.Travel.w3_encode_ActionData thisActionData
    
        ActionDataGettingStarted__BrowserSupport thisActionData ->
            Route.GettingStarted.BrowserSupport.w3_encode_ActionData
                thisActionData
    
        ActionDataGettingStarted__Installation thisActionData ->
            Route.GettingStarted.Installation.w3_encode_ActionData
                thisActionData
    
        ActionDataGettingStarted__Welcome thisActionData ->
            Route.GettingStarted.Welcome.w3_encode_ActionData thisActionData
    
        ActionDataGuide__Accessibility thisActionData ->
            Route.Guide.Accessibility.w3_encode_ActionData thisActionData
    
        ActionDataGuide__AccessibleByConstruction thisActionData ->
            Route.Guide.AccessibleByConstruction.w3_encode_ActionData
                thisActionData
    
        ActionDataGuide__CheatSheet thisActionData ->
            Route.Guide.CheatSheet.w3_encode_ActionData thisActionData
    
        ActionDataGuide__CompositionTextField thisActionData ->
            Route.Guide.CompositionTextField.w3_encode_ActionData thisActionData
    
        ActionDataGuide__FirstComponent thisActionData ->
            Route.Guide.FirstComponent.w3_encode_ActionData thisActionData
    
        ActionDataGuide__GeneratedAndInspectable thisActionData ->
            Route.Guide.GeneratedAndInspectable.w3_encode_ActionData
                thisActionData
    
        ActionDataGuide__Glossary thisActionData ->
            Route.Guide.Glossary.w3_encode_ActionData thisActionData
    
        ActionDataGuide__HowWeProveIt thisActionData ->
            Route.Guide.HowWeProveIt.w3_encode_ActionData thisActionData
    
        ActionDataGuide__InvalidStates thisActionData ->
            Route.Guide.InvalidStates.w3_encode_ActionData thisActionData
    
        ActionDataGuide__Motion thisActionData ->
            Route.Guide.Motion.w3_encode_ActionData thisActionData
    
        ActionDataGuide__Reference thisActionData ->
            Route.Guide.Reference.w3_encode_ActionData thisActionData
    
        ActionDataGuide__Roundtrip thisActionData ->
            Route.Guide.Roundtrip.w3_encode_ActionData thisActionData
    
        ActionDataGuide__Seams thisActionData ->
            Route.Guide.Seams.w3_encode_ActionData thisActionData
    
        ActionDataGuide__Strictness thisActionData ->
            Route.Guide.Strictness.w3_encode_ActionData thisActionData
    
        ActionDataGuide__TheLayers thisActionData ->
            Route.Guide.TheLayers.w3_encode_ActionData thisActionData
    
        ActionDataGuide__Theming thisActionData ->
            Route.Guide.Theming.w3_encode_ActionData thisActionData
    
        ActionDataGuide__ToolingRefactors thisActionData ->
            Route.Guide.ToolingRefactors.w3_encode_ActionData thisActionData
    
        ActionDataGuide__Troubleshooting thisActionData ->
            Route.Guide.Troubleshooting.w3_encode_ActionData thisActionData
    
        ActionDataStyles__Color thisActionData ->
            Route.Styles.Color.w3_encode_ActionData thisActionData
    
        ActionDataStyles__Density thisActionData ->
            Route.Styles.Density.w3_encode_ActionData thisActionData
    
        ActionDataStyles__Elevation thisActionData ->
            Route.Styles.Elevation.w3_encode_ActionData thisActionData
    
        ActionDataStyles__Motion thisActionData ->
            Route.Styles.Motion.w3_encode_ActionData thisActionData
    
        ActionDataStyles__Shape thisActionData ->
            Route.Styles.Shape.w3_encode_ActionData thisActionData
    
        ActionDataStyles__StateLayers thisActionData ->
            Route.Styles.StateLayers.w3_encode_ActionData thisActionData
    
        ActionDataStyles__Typography thisActionData ->
            Route.Styles.Typography.w3_encode_ActionData thisActionData
    
        ActionDataComponents__Name_ thisActionData ->
            Route.Components.Name_.w3_encode_ActionData thisActionData
    
        ActionDataExamples thisActionData ->
            Route.Examples.w3_encode_ActionData thisActionData
    
        ActionDataGuide thisActionData ->
            Route.Guide.w3_encode_ActionData thisActionData
    
        ActionDataIndex thisActionData ->
            Route.Index.w3_encode_ActionData thisActionData


subscriptions : Maybe Route.Route -> UrlPath.UrlPath -> Model -> Sub.Sub Msg
subscriptions route path model =
    Sub.batch
        [ Sub.map MsgGlobal (Shared.template.subscriptions path model.global)
        , templateSubscriptions route path model
        ]


modelMismatchView : { title : String, body : List (Html.Html msg) }
modelMismatchView =
    { title = "Model mismatch", body = [ Html.text "Model mismatch" ] }


port sendPageData :
    { oldThing : Json.Encode.Value, binaryPageData : Bytes.Bytes } -> Cmd msg


globalHeadTags :
    (Maybe { indent : Int, newLines : Bool } -> Html.Html Never -> String)
    -> BackendTask.BackendTask FatalError.FatalError (List Head.Tag)
globalHeadTags htmlToString =
    BackendTask.map
        List.concat
        (BackendTask.combine
             (Site.config.head :: List.filterMap
                                          ApiRoute.getGlobalHeadTagsBackendTask
                                          (Api.routes
                                                   getStaticRoutes
                                                   htmlToString
                                          )
             )
        )


encodePageDataForClient : PageData -> Bytes.Encode.Encoder
encodePageDataForClient pageData =
    case pageData of
        DataComponents__All thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 1
                , Route.Components.All.w3_encode_Data thisPageData
                ]
    
        DataExamples__Dashboard thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 5
                , Route.Examples.Dashboard.w3_encode_Data thisPageData
                ]
    
        DataExamples__Feed thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 6
                , Route.Examples.Feed.w3_encode_Data thisPageData
                ]
    
        DataExamples__ListDetail thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 7
                , Route.Examples.ListDetail.w3_encode_Data thisPageData
                ]
    
        DataExamples__Mail thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 8
                , Route.Examples.Mail.w3_encode_Data thisPageData
                ]
    
        DataExamples__Settings thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 9
                , Route.Examples.Settings.w3_encode_Data thisPageData
                ]
    
        DataExamples__Shop thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 10
                , Route.Examples.Shop.w3_encode_Data thisPageData
                ]
    
        DataExamples__SupportingPane thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 11
                , Route.Examples.SupportingPane.w3_encode_Data thisPageData
                ]
    
        DataExamples__Travel thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 12
                , Route.Examples.Travel.w3_encode_Data thisPageData
                ]
    
        DataGettingStarted__BrowserSupport thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 13
                , Route.GettingStarted.BrowserSupport.w3_encode_Data
                    thisPageData
                ]
    
        DataGettingStarted__Installation thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 14
                , Route.GettingStarted.Installation.w3_encode_Data thisPageData
                ]
    
        DataGettingStarted__Welcome thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 15
                , Route.GettingStarted.Welcome.w3_encode_Data thisPageData
                ]
    
        DataGuide__Accessibility thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 17
                , Route.Guide.Accessibility.w3_encode_Data thisPageData
                ]
    
        DataGuide__AccessibleByConstruction thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 18
                , Route.Guide.AccessibleByConstruction.w3_encode_Data
                    thisPageData
                ]
    
        DataGuide__CheatSheet thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 19
                , Route.Guide.CheatSheet.w3_encode_Data thisPageData
                ]
    
        DataGuide__CompositionTextField thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 20
                , Route.Guide.CompositionTextField.w3_encode_Data thisPageData
                ]
    
        DataGuide__FirstComponent thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 21
                , Route.Guide.FirstComponent.w3_encode_Data thisPageData
                ]
    
        DataGuide__GeneratedAndInspectable thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 22
                , Route.Guide.GeneratedAndInspectable.w3_encode_Data
                    thisPageData
                ]
    
        DataGuide__Glossary thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 23
                , Route.Guide.Glossary.w3_encode_Data thisPageData
                ]
    
        DataGuide__HowWeProveIt thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 24
                , Route.Guide.HowWeProveIt.w3_encode_Data thisPageData
                ]
    
        DataGuide__InvalidStates thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 25
                , Route.Guide.InvalidStates.w3_encode_Data thisPageData
                ]
    
        DataGuide__Motion thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 26
                , Route.Guide.Motion.w3_encode_Data thisPageData
                ]
    
        DataGuide__Reference thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 27
                , Route.Guide.Reference.w3_encode_Data thisPageData
                ]
    
        DataGuide__Roundtrip thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 28
                , Route.Guide.Roundtrip.w3_encode_Data thisPageData
                ]
    
        DataGuide__Seams thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 29
                , Route.Guide.Seams.w3_encode_Data thisPageData
                ]
    
        DataGuide__Strictness thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 30
                , Route.Guide.Strictness.w3_encode_Data thisPageData
                ]
    
        DataGuide__TheLayers thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 31
                , Route.Guide.TheLayers.w3_encode_Data thisPageData
                ]
    
        DataGuide__Theming thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 32
                , Route.Guide.Theming.w3_encode_Data thisPageData
                ]
    
        DataGuide__ToolingRefactors thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 33
                , Route.Guide.ToolingRefactors.w3_encode_Data thisPageData
                ]
    
        DataGuide__Troubleshooting thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 34
                , Route.Guide.Troubleshooting.w3_encode_Data thisPageData
                ]
    
        DataStyles__Color thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 36
                , Route.Styles.Color.w3_encode_Data thisPageData
                ]
    
        DataStyles__Density thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 37
                , Route.Styles.Density.w3_encode_Data thisPageData
                ]
    
        DataStyles__Elevation thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 38
                , Route.Styles.Elevation.w3_encode_Data thisPageData
                ]
    
        DataStyles__Motion thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 39
                , Route.Styles.Motion.w3_encode_Data thisPageData
                ]
    
        DataStyles__Shape thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 40
                , Route.Styles.Shape.w3_encode_Data thisPageData
                ]
    
        DataStyles__StateLayers thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 41
                , Route.Styles.StateLayers.w3_encode_Data thisPageData
                ]
    
        DataStyles__Typography thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 42
                , Route.Styles.Typography.w3_encode_Data thisPageData
                ]
    
        DataComponents__Name_ thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 2
                , Route.Components.Name_.w3_encode_Data thisPageData
                ]
    
        DataExamples thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 4
                , Route.Examples.w3_encode_Data thisPageData
                ]
    
        DataGuide thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 16
                , Route.Guide.w3_encode_Data thisPageData
                ]
    
        DataIndex thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 35
                , Route.Index.w3_encode_Data thisPageData
                ]
    
        Data404NotFoundPage____ ->
            Bytes.Encode.unsignedInt8 0
    
        DataErrorPage____ thisPageData ->
            Lamdera.Wire3.encodeSequenceWithoutLength
                [ Bytes.Encode.unsignedInt8 3
                , ErrorPage.w3_encode_ErrorPage thisPageData
                ]


encodeResponse :
    Pages.Internal.ResponseSketch.ResponseSketch PageData ActionData Shared.Data
    -> Bytes.Encode.Encoder
encodeResponse =
    Pages.Internal.ResponseSketch.w3_encode_ResponseSketch
        w3_encode_PageData
        w3_encode_ActionData
        Shared.w3_encode_Data


routePatterns3 : List Pages.Internal.RoutePattern.RoutePattern
routePatterns3 =
    [ { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "components"
          , Pages.Internal.RoutePattern.StaticSegment "all"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "examples"
          , Pages.Internal.RoutePattern.StaticSegment "dashboard"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "examples"
          , Pages.Internal.RoutePattern.StaticSegment "feed"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "examples"
          , Pages.Internal.RoutePattern.StaticSegment "list-detail"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "examples"
          , Pages.Internal.RoutePattern.StaticSegment "mail"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "examples"
          , Pages.Internal.RoutePattern.StaticSegment "settings"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "examples"
          , Pages.Internal.RoutePattern.StaticSegment "shop"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "examples"
          , Pages.Internal.RoutePattern.StaticSegment "supporting-pane"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "examples"
          , Pages.Internal.RoutePattern.StaticSegment "travel"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "getting-started"
          , Pages.Internal.RoutePattern.StaticSegment "browser-support"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "getting-started"
          , Pages.Internal.RoutePattern.StaticSegment "installation"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "getting-started"
          , Pages.Internal.RoutePattern.StaticSegment "welcome"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "guide"
          , Pages.Internal.RoutePattern.StaticSegment "accessibility"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "guide"
          , Pages.Internal.RoutePattern.StaticSegment
              "accessible-by-construction"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "guide"
          , Pages.Internal.RoutePattern.StaticSegment "cheat-sheet"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "guide"
          , Pages.Internal.RoutePattern.StaticSegment "composition-text-field"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "guide"
          , Pages.Internal.RoutePattern.StaticSegment "first-component"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "guide"
          , Pages.Internal.RoutePattern.StaticSegment
              "generated-and-inspectable"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "guide"
          , Pages.Internal.RoutePattern.StaticSegment "glossary"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "guide"
          , Pages.Internal.RoutePattern.StaticSegment "how-we-prove-it"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "guide"
          , Pages.Internal.RoutePattern.StaticSegment "invalid-states"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "guide"
          , Pages.Internal.RoutePattern.StaticSegment "motion"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "guide"
          , Pages.Internal.RoutePattern.StaticSegment "reference"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "guide"
          , Pages.Internal.RoutePattern.StaticSegment "roundtrip"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "guide"
          , Pages.Internal.RoutePattern.StaticSegment "seams"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "guide"
          , Pages.Internal.RoutePattern.StaticSegment "strictness"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "guide"
          , Pages.Internal.RoutePattern.StaticSegment "the-layers"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "guide"
          , Pages.Internal.RoutePattern.StaticSegment "theming"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "guide"
          , Pages.Internal.RoutePattern.StaticSegment "tooling-refactors"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "guide"
          , Pages.Internal.RoutePattern.StaticSegment "troubleshooting"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "styles"
          , Pages.Internal.RoutePattern.StaticSegment "color"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "styles"
          , Pages.Internal.RoutePattern.StaticSegment "density"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "styles"
          , Pages.Internal.RoutePattern.StaticSegment "elevation"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "styles"
          , Pages.Internal.RoutePattern.StaticSegment "motion"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "styles"
          , Pages.Internal.RoutePattern.StaticSegment "shape"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "styles"
          , Pages.Internal.RoutePattern.StaticSegment "state-layers"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "styles"
          , Pages.Internal.RoutePattern.StaticSegment "typography"
          ]
      , ending = Nothing
      }
    , { segments =
          [ Pages.Internal.RoutePattern.StaticSegment "components"
          , Pages.Internal.RoutePattern.DynamicSegment "name"
          ]
      , ending = Nothing
      }
    , { segments = [ Pages.Internal.RoutePattern.StaticSegment "examples" ]
      , ending = Nothing
      }
    , { segments = [ Pages.Internal.RoutePattern.StaticSegment "guide" ]
      , ending = Nothing
      }
    , { segments = [ Pages.Internal.RoutePattern.StaticSegment "index" ]
      , ending = Nothing
      }
    ]


skipFrozenViewsPrefix : Bytes.Decode.Decoder a -> Bytes.Decode.Decoder a
skipFrozenViewsPrefix innerDecoder =
    Bytes.Decode.andThen
        (\andThenUnpack ->
             Bytes.Decode.andThen
                 (\andThenUnpack0 -> innerDecoder)
                 (Bytes.Decode.bytes andThenUnpack)
        )
        (Bytes.Decode.unsignedInt32 Bytes.BE)


decodeResponse :
    Bytes.Decode.Decoder (Pages.Internal.ResponseSketch.ResponseSketch PageData ActionData Shared.Data)
decodeResponse =
    skipFrozenViewsPrefix
        (Pages.Internal.ResponseSketch.w3_decode_ResponseSketch
             w3_decode_PageData
             w3_decode_ActionData
             Shared.w3_decode_Data
        )


port hotReloadData : (Bytes.Bytes -> msg) -> Sub msg


port pageDataFromJs : (Bytes.Bytes -> msg) -> Sub msg


port toJsPort :
    { json : Json.Encode.Value
    , bytes : List { key : String, data : Bytes.Bytes }
    }
    -> Cmd msg


port fromJsPort : (Json.Decode.Value -> msg) -> Sub msg


port gotBatchSub :
    (List { key : String, json : Json.Decode.Value, bytes : Maybe Bytes.Bytes }
    -> msg)
    -> Sub msg