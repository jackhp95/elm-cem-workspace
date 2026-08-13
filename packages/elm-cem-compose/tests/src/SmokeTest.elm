module SmokeTest exposing (all)

import Cem.Compose
import Expect
import Test exposing (Test, describe, test)


all : Test
all =
    describe "scaffold"
        [ test "the package compiles and is importable from tests" <|
            \_ ->
                Cem.Compose.version
                    |> Expect.equal 1
        ]
