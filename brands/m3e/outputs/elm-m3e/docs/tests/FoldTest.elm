port module FoldTest exposing (main)

{-| Unit tests for `Doc.Fold`'s pure fold-tree computation.

Run via `elm make` + a tiny node runner (see `scripts/run-elm-worker-test.cjs`,
invoked as `node scripts/run-elm-worker-test.cjs <compiled-elm.js> FoldTest`);
the docs project has no `elm-test` runner wired, so this is a self-checking
`Platform.worker` that emits per-case `PASS`/`FAIL` diagnostics plus a final
structured `RESULT ok=<passed>/<total>` line through a port. The runner keys the
exit code off that structured count (0 = all pass, 1 = any fail), not off the
human-readable text. The serialization is `Doc.Fold.serialize`:

  - `L{trimmed}` — a plain line
  - `F[..]` / `F*[..]` — an indentation fold (`*` = default-collapsed)
  - `S<n>` — an `n`-line repeated-sibling `…` run

-}

import Doc.Fold as Fold


port emit : String -> Cmd msg


cases : List ( String, String, String )
cases =
    [ ( "single line"
      , "hello"
      , "L{hello}"
      )
    , ( "all-same-indent, distinct heads -> flat leaves"
      , "alpha\nbeta\ngamma"
      , "L{alpha},L{beta},L{gamma}"
      )
    , ( "nested header + one-line body"
      , "foo\n    bar"
      , "F[L{bar}]"
      )
    , ( "trailing dedent closes the fold"
      , "foo\n    bar\nbaz"
      , "F[L{bar}],L{baz}"
      )
    , ( "blank line inside a body stays in the body"
      , "foo\n    bar\n\n    qux"
      , "F[L{bar},L{},L{qux}]"
      )
    , ( "deep nesting nests folds"
      , "a\n  b\n    c"
      , "F[F[L{c}]]"
      )
    , ( "body of exactly threshold (6) stays open"
      , "h\n a\n b\n c\n d\n e\n f"
      , "F[L{a},L{b},L{c},L{d},L{e},L{f}]"
      )
    , ( "body over threshold (7) collapses"
      , "h\n a\n b\n c\n d\n e\n f\n g"
      , "F*[L{a},L{b},L{c},L{d},L{e},L{f},L{g}]"
      )
    , ( "three repeated Elm siblings -> S3"
      , "[ M3e.opt x\n, M3e.opt y\n, M3e.opt z"
      , "S3"
      )
    , ( "only two repeats -> not a sibling fold"
      , "[ M3e.opt x\n, M3e.opt y"
      , "L{[ M3e.opt x},L{, M3e.opt y}"
      )
    , ( "three repeated HTML tags -> S3"
      , "<m3e-option>Apples</m3e-option>\n<m3e-option>Pears</m3e-option>\n<m3e-option>Plums</m3e-option>"
      , "S3"
      )
    , ( "distinct slot heads never group"
      , ", M3e.slotLeading a\n, M3e.slotTitle b\n, M3e.slotTrailing c"
      , "L{, M3e.slotLeading a},L{, M3e.slotTitle b},L{, M3e.slotTrailing c}"
      )
    , ( "same head at differing indent never groups"
      , "    M3e.opt x\n  M3e.opt y\nM3e.opt z"
      , "L{M3e.opt x},L{M3e.opt y},L{M3e.opt z}"
      )
    , ( "a blank line breaks a sibling run"
      , "M3e.opt x\nM3e.opt y\n\nM3e.opt z"
      , "L{M3e.opt x},L{M3e.opt y},L{},L{M3e.opt z}"
      )
    ]


runCase : ( String, String, String ) -> ( Bool, String )
runCase ( name, input, expected ) =
    let
        got : String
        got =
            Fold.serialize (Fold.buildForest input)
    in
    if got == expected then
        ( True, "PASS  " ++ name )

    else
        ( False
        , "FAIL  "
            ++ name
            ++ "\n        expected: "
            ++ expected
            ++ "\n        got:      "
            ++ got
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
            -- Structured, machine-parsed signal the runner keys the exit code
            -- off of (never substring-matches human-readable PASS/FAIL text).
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
