module Route.Components.Compose exposing (ActionData, Data, Model, Msg, route)

{-| **Compose** — a headless, type-directed editor for building a valid tree
of custom elements from `M3e.Review.Facts`, backed by `Cem.Compose`.

This route owns no editing logic itself: `Cem.Compose` owns the tree and the
path-addressed edits, `Compose.Attrs` (generated) supplies the attribute
kind/dispatch table, and `Compose.Render` folds the tree to the live
preview. This module is the app-shell boundary — where the phantom `M3e`
rows get erased once via `M3e.Unsafe.fromHtml`, because which component is
on screen is only known at runtime.

For this task the screen is a live preview only; the editor chips (Task 12)
and the generated-code snippet (Task 13) are not wired up yet.

-}

import BackendTask
import Cem.Compose
import Compose.Attrs as Attrs
import Compose.Render as Render
import Doc
import Effect exposing (Effect)
import Head
import M3e exposing (Element)
import M3e.Review.Facts
import M3e.Unsafe
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatefulRoute)
import Shared
import TypedHtml
import TypedHtml.Attributes as TA
import TypedHtml.Grouping
import UrlPath exposing (UrlPath)
import View exposing (View)


type alias Model =
    { compose : Cem.Compose.Model }


type Msg
    = ComposeMsg Cem.Compose.Msg


type alias RouteParams =
    {}


type alias Data =
    {}


type alias ActionData =
    {}


route : StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.single { head = head, data = BackendTask.succeed {} }
        |> RouteBuilder.buildWithLocalState
            { view = view
            , init = init
            , update = update
            , subscriptions = subscriptions
            }


{-| Root component `"list"` is a deliberate starting choice: `list.unnamed`
is a pure-nesting slot with five component options and no text, so the
recursive case is visible immediately.
-}
init : App Data ActionData RouteParams -> Shared.Model -> ( Model, Effect Msg )
init _ _ =
    ( { compose =
            Cem.Compose.init
                { facts = M3e.Review.Facts.facts
                , attrKinds = Attrs.kinds
                , root = "list"
                }
      }
    , Effect.none
    )


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update _ _ (ComposeMsg composeMsg) model =
    ( { model | compose = Cem.Compose.update composeMsg model.compose }, Effect.none )


subscriptions : RouteParams -> UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions _ _ _ _ =
    Sub.none


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    []


view : App Data ActionData RouteParams -> Shared.Model -> Model -> View (PagesMsg Msg)
view _ _ model =
    View.fromElement "Compose"
        (M3e.mapMsg PagesMsg.fromMsg
            (M3e.mapMsg ComposeMsg (Doc.pane [ screen model.compose ]))
        )


{-| The live preview only, for now: a heading naming the root component and
the rendered custom-element tree. The full editor chips (`viewNode`) arrive
in Task 12, the generated-code snippet in Task 13.
-}
screen : Cem.Compose.Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Cem.Compose.Msg
screen compose =
    TypedHtml.div [ TA.class "space-y-4" ]
        [ Doc.pageHeading ("Compose: " ++ Cem.Compose.componentOf compose.root)
        , M3e.Unsafe.fromHtml (Render.renderNode compose.root)
        ]
