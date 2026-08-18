module NoHandEditedGeneratedM3eTest exposing (all)

import NoHandEditedGeneratedM3e exposing (rule)
import Review.Project as Project exposing (Project)
import Review.Test
import Test exposing (Test, describe, test)


all : Test
all =
    describe "NoHandEditedGeneratedM3e"
        [ test "clean vendored tree with a matching manifest → no errors" <|
            \() ->
                dummyModule
                    |> Review.Test.runWithProjectData
                        (projectWith
                            [ ( pathA, fileA )
                            , ( manifest, manifestJson [ ( pathA, String.length fileA ) ] )
                            ]
                        )
                        rule
                    |> Review.Test.expectNoErrors
        , test "a repo with no vendor/ at all → no errors" <|
            \() ->
                dummyModule
                    |> Review.Test.runWithProjectData (projectWith []) rule
                    |> Review.Test.expectNoErrors
        , test "hand-edited vendored file (length differs from manifest) → error on that file" <|
            \() ->
                dummyModule
                    |> Review.Test.runWithProjectData
                        (projectWith
                            [ ( pathA, fileA ++ "-- tampered\n" )
                            , ( manifest, manifestJson [ ( pathA, String.length fileA ) ] )
                            ]
                        )
                        rule
                    |> Review.Test.expectErrorsForExtraFile pathA
                        [ Review.Test.error
                            { message = "Vendored M3e file has been hand-edited: " ++ pathA
                            , details = editedDetails
                            , under = firstLineOf fileA
                            }
                        ]
        , test "vendored file absent from the manifest (added by hand) → error on that file" <|
            \() ->
                dummyModule
                    |> Review.Test.runWithProjectData
                        (projectWith
                            [ ( pathA, fileA )
                            , ( pathB, fileB )
                            , ( manifest, manifestJson [ ( pathA, String.length fileA ) ] )
                            ]
                        )
                        rule
                    |> Review.Test.expectErrorsForExtraFile pathB
                        [ Review.Test.error
                            { message = "Vendored M3e file is not in the manifest: " ++ pathB
                            , details = addedDetails
                            , under = firstLineOf fileB
                            }
                        ]
        , test "manifest lists a file that is absent (deleted by hand) → error on the manifest" <|
            \() ->
                dummyModule
                    |> Review.Test.runWithProjectData
                        (projectWith
                            [ ( pathA, fileA )
                            , ( manifest
                              , manifestJson
                                    [ ( pathA, String.length fileA )
                                    , ( pathB, String.length fileB )
                                    ]
                              )
                            ]
                        )
                        rule
                    |> Review.Test.expectErrorsForExtraFile manifest
                        [ Review.Test.error
                            { message = "Vendored M3e file is missing (listed in the manifest but absent): " ++ pathB
                            , details = missingDetails
                            , under = "\"" ++ pathB ++ "\""
                            }
                        ]
        , test "missing manifest while vendor/ has files → error on a vendored file" <|
            \() ->
                dummyModule
                    |> Review.Test.runWithProjectData
                        (projectWith [ ( pathA, fileA ) ])
                        rule
                    |> Review.Test.expectErrorsForExtraFile pathA
                        [ Review.Test.error
                            { message = "vendor/ has files but no " ++ manifest
                            , details = noManifestDetails
                            , under = firstLineOf fileA
                            }
                        ]
        ]



-- FIXTURES


manifest : String
manifest =
    "vendor/m3e-manifest.json"


pathA : String
pathA =
    "vendor/elm-m3e/M3e/Alpha.elm"


pathB : String
pathB =
    "vendor/elm-m3e/M3e/Beta.elm"


fileA : String
fileA =
    "module M3e.Alpha exposing (alpha)\n\nalpha : Int\nalpha =\n    1\n"


fileB : String
fileB =
    "module M3e.Beta exposing (beta)\n\nbeta : Int\nbeta =\n    2\n"


dummyModule : String
dummyModule =
    "module A exposing (a)\n\na : Int\na =\n    1\n"


firstLineOf : String -> String
firstLineOf s =
    s |> String.lines |> List.head |> Maybe.withDefault ""


projectWith : List ( String, String ) -> Project
projectWith extra =
    List.foldl (\( p, s ) proj -> Project.addExtraFile { path = p, source = s } proj) Project.new extra


{-| A minimal but shape-faithful manifest: the `files` object with a `sha256`
(unused by the rule) and a `len` per path. Matches revendor-m3e.mjs's output shape.
-}
manifestJson : List ( String, Int ) -> String
manifestJson entries =
    let
        fileLine : ( String, Int ) -> String
        fileLine ( path, len ) =
            "    \"" ++ path ++ "\": { \"sha256\": \"deadbeef\", \"len\": " ++ String.fromInt len ++ " }"
    in
    "{\n  \"schema\": \"m3e-vendor-manifest/1\",\n  \"algo\": \"sha256\",\n  \"files\": {\n"
        ++ (entries |> List.map fileLine |> String.join ",\n")
        ++ "\n  }\n}\n"



-- DETAILS (must match NoHandEditedGeneratedM3e exactly)


editedDetails : List String
editedDetails =
    [ "This vendored file's content no longer matches the length recorded in vendor/m3e-manifest.json, so it was edited by hand."
    , "Run: node scripts/revendor-m3e.mjs --commit <sha> to restore it from canonical — never hand-edit vendor/. (Byte-exact drift is also enforced by the check:vendor gate.)"
    ]


addedDetails : List String
addedDetails =
    [ "This file under vendor/ is not recorded in vendor/m3e-manifest.json, so it was added by hand."
    , "The vendor/ tree is a committed copy of unpublished elm-cem-workspace source; only scripts/revendor-m3e.mjs may write it. Run: node scripts/revendor-m3e.mjs --commit <sha> — never hand-edit vendor/."
    ]


missingDetails : List String
missingDetails =
    [ "vendor/m3e-manifest.json records vendor/elm-m3e/M3e/Beta.elm, but that file is not present under vendor/ — it was deleted by hand."
    , "Run: node scripts/revendor-m3e.mjs --commit <sha> to restore the full vendored tree — never hand-edit vendor/."
    ]


noManifestDetails : List String
noManifestDetails =
    [ "There are files under vendor/ but no vendor/m3e-manifest.json recording them, so drift cannot be verified."
    , "Run: node scripts/revendor-m3e.mjs --commit <sha> to (re)generate the manifest, or remove the stray vendor/ files."
    ]
