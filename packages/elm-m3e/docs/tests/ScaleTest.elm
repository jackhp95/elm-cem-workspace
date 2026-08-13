port module ScaleTest exposing (main)

{-| Unit tests for `Theme.Scale`'s pure scale-mode computation.

Run via `elm make` + a tiny node runner (see `scripts/run-elm-worker-test.cjs`,
invoked as `node scripts/run-elm-worker-test.cjs <compiled-elm.js> ScaleTest`);
the docs project has no `elm-test` runner wired, so this
is a self-checking `Platform.worker` that emits per-case `PASS`/`FAIL`
diagnostics plus a final structured `RESULT ok=<passed>/<total>` line through
a port. The runner keys the exit code off that structured count (0 = all
pass, 1 = any fail), not off the human-readable text.

-}

import Theme.Scale as Scale


port emit : String -> Cmd msg


approxEqual : Float -> Float -> Bool
approxEqual a b =
    abs (a - b) < 0.0001


type alias Case =
    { name : String
    , config : Scale.ScaleConfig
    , token : { defaultRem : Float, step : Int }
    , expected : Float
    }


cases : List Case
cases =
    [ { name = "Linear mode multiplies defaultRem by factor"
      , config = { mode = Scale.Linear, factor = 1.5, ratio = 1, base = 1, bump = 0, exponent = 1 }
      , token = { defaultRem = 1, step = 0 }
      , expected = 1.5
      }
    , { name = "Modular mode computes base * ratio^step"
      , config = { mode = Scale.Modular, factor = 1, ratio = 1.2, base = 1, bump = 0, exponent = 1 }
      , token = { defaultRem = 1, step = 2 }
      , expected = 1.44
      }
    , { name = "Bump mode adds a flat offset to defaultRem"
      , config = { mode = Scale.Bump, factor = 1, ratio = 1, base = 1, bump = 0.25, exponent = 1 }
      , token = { defaultRem = 1, step = 0 }
      , expected = 1.25
      }
    , { name = "Power mode computes base * (defaultRem/base)^exponent"
      , config = { mode = Scale.Power, factor = 1, ratio = 1, base = 1, bump = 0, exponent = 2 }
      , token = { defaultRem = 2, step = 0 }
      , expected = 4
      }
    , { name = "Linear mode with factor 1 is a no-op"
      , config = { mode = Scale.Linear, factor = 1, ratio = 1, base = 1, bump = 0, exponent = 1 }
      , token = { defaultRem = 2.25, step = 5 }
      , expected = 2.25
      }
    ]


runCase : Case -> ( Bool, String )
runCase { name, config, token, expected } =
    let
        got : Float
        got =
            Scale.compute config token
    in
    if approxEqual got expected then
        ( True, "PASS  " ++ name )

    else
        ( False
        , "FAIL  "
            ++ name
            ++ "\n        expected: "
            ++ String.fromFloat expected
            ++ "\n        got:      "
            ++ String.fromFloat got
        )


report : String
report =
    let
        results : List ( Bool, String )
        results =
            List.map runCase cases

        passed : Int
        passed =
            List.filter Tuple.first results |> List.length

        total : Int
        total =
            List.length results

        lines : String
        lines =
            List.map Tuple.second results |> String.join "\n"

        summary : String
        summary =
            "\n"
                ++ String.fromInt passed
                ++ "/"
                ++ String.fromInt total
                ++ " passed"
                ++ (if passed == total then
                        " — OK"

                    else
                        " — FAILURES"
                   )

        result : String
        result =
            "\nRESULT ok=" ++ String.fromInt passed ++ "/" ++ String.fromInt total
    in
    lines ++ summary ++ result


main : Program () () ()
main =
    Platform.worker
        { init = \_ -> ( (), emit report )
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }
