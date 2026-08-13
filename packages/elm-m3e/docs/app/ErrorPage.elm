module ErrorPage exposing (ErrorPage, Model, Msg, init, internalError, notFound, statusCode, update, view)

import Doc
import Effect exposing (Effect)
import M3e
import M3e.Attributes
import M3e.Component.Button
import M3e.Component.Heading
import M3e.Values as Value
import TypedHtml
import TypedHtml.Attributes as TA
import View exposing (View)


type alias Msg =
    ()


type alias Model =
    {}


init : ErrorPage -> ( Model, Effect Msg )
init _ =
    ( {}, Effect.none )


update : ErrorPage -> Msg -> Model -> ( Model, Effect Msg )
update _ _ model =
    ( model, Effect.none )


type ErrorPage
    = NotFound
    | InternalError String


notFound : ErrorPage
notFound =
    NotFound


internalError : String -> ErrorPage
internalError =
    InternalError


view : ErrorPage -> Model -> View Msg
view error _ =
    case error of
        NotFound ->
            notFoundView

        InternalError string ->
            View.fromElement "Unexpected Error"
                (Doc.message ("Something went wrong.\n" ++ string))


notFoundView : View Msg
notFoundView =
    View.fromElement "Page Not Found"
        (Doc.pane
            [ TypedHtml.section [ TA.class "space-y-6" ]
                [ M3e.heading
                    [ M3e.Component.Heading.variant Value.display
                    , M3e.Component.Heading.size Value.small
                    , M3e.Attributes.level 1
                    ]
                    [ M3e.text "Page not found" ]
                , TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant max-w-md" ]
                    [ M3e.text "The page you’re looking for doesn’t exist or has moved." ]
                , TypedHtml.div [ TA.class "flex flex-wrap gap-3" ]
                    [ M3e.button
                        [ M3e.Component.Button.variant Value.filled
                        , M3e.Component.Button.href "/getting-started/welcome"
                        ]
                        [ M3e.text "Go to Welcome" ]
                    ]
                ]
            ]
        )


statusCode : ErrorPage -> number
statusCode error =
    case error of
        NotFound ->
            404

        InternalError _ ->
            500
