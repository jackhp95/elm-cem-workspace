module Main exposing (main)

import Probe.Lib exposing (probeAnswer)


main : Program () Int msg
main =
    Platform.worker
        { init = \_ -> ( probeAnswer, Cmd.none )
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }
