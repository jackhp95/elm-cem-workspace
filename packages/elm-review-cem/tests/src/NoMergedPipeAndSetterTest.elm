module NoMergedPipeAndSetterTest exposing (all)

import NoMergedPipeAndSetter exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


error : String -> String -> String
error pipe stem =
    "`" ++ pipe ++ "` pipe and `" ++ stem ++ "` setter must not be in the same module"


detailMsg : String -> String -> List String
detailMsg pipe stem =
    [ "The K5/#58 structural guarantee requires pipes (with<X> family) to live in M3e.<Component>.Build modules and bare setters (<x> family) to live in M3e.<Component> modules. Merging both into one module recreates the name collision the 3‑package split was designed to avoid."
    , "Remove the `" ++ pipe ++ "` pipe or the `" ++ stem ++ "` setter from this module, or split the exposing list so that this module exposes only one family."
    ]


all : Test
all =
    describe "NoMergedPipeAndSetter"
        [ test "flags a module exposing both withDisabled and disabled" <|
            \() ->
                """module Bad exposing (withDisabled, disabled)
"""
                    |> Review.Test.run (rule { allowedModules = [] })
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = error "withDisabled" "Disabled"
                            , details = detailMsg "withDisabled" "Disabled"
                            , under = "withDisabled"
                            }
                        ]
        , test "flags a module exposing withLabel and label" <|
            \() ->
                """module Bad exposing (withLabel, label)
"""
                    |> Review.Test.run (rule { allowedModules = [] })
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = error "withLabel" "Label"
                            , details = detailMsg "withLabel" "Label"
                            , under = "withLabel"
                            }
                        ]
        , test "passes a module exposing only pipes (withX)" <|
            \() ->
                """module Good exposing (withDisabled, withLabel, withClass)
"""
                    |> Review.Test.run (rule { allowedModules = [] })
                    |> Review.Test.expectNoErrors
        , test "passes a module exposing only setters (x)" <|
            \() ->
                """module Good exposing (disabled, label, class_)
"""
                    |> Review.Test.run (rule { allowedModules = [] })
                    |> Review.Test.expectNoErrors
        , test "passes a module exposing unrelated values" <|
            \() ->
                """module Good exposing (view, update, Msg(..))
"""
                    |> Review.Test.run (rule { allowedModules = [] })
                    |> Review.Test.expectNoErrors
        , test "flags a module exposing withS and S (type with matching short name)" <|
            \() ->
                """module Bad exposing (withS, S)
"""
                    |> Review.Test.run (rule { allowedModules = [] })
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = error "withS" "S"
                            , details = detailMsg "withS" "S"
                            , under = "withS"
                            }
                        ]
        , test "passes a module with exposing (..)" <|
            \() ->
                """module Good exposing (..)
"""
                    |> Review.Test.run (rule { allowedModules = [] })
                    |> Review.Test.expectNoErrors
        , test "passes withX where the stem is not present as a setter" <|
            \() ->
                """module Good exposing (withSomethingOnly)
"""
                    |> Review.Test.run (rule { allowedModules = [] })
                    |> Review.Test.expectNoErrors
        , test "passes withType and type_ (dissimilar stems)" <|
            \() ->
                """module Good exposing (withType, type_)
"""
                    |> Review.Test.run (rule { allowedModules = [] })
                    |> Review.Test.expectNoErrors
        , test "flags multiple merged pairs" <|
            \() ->
                """module Bad exposing (withLabel, label, withDisabled, disabled)
"""
                    |> Review.Test.run (rule { allowedModules = [] })
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = error "withLabel" "Label"
                            , details = detailMsg "withLabel" "Label"
                            , under = "withLabel"
                            }
                        , Review.Test.error
                            { message = error "withDisabled" "Disabled"
                            , details = detailMsg "withDisabled" "Disabled"
                            , under = "withDisabled"
                            }
                        ]
        , test "passes a module with allowedModules prefix (generated module)" <|
            \() ->
                """module M3e.Button exposing (withDisabled, disabled, withIcon, icon)
"""
                    |> Review.Test.run (rule { allowedModules = [ "M3e" ] })
                    |> Review.Test.expectNoErrors
        , test "passes a builder module with allowedModules prefix" <|
            \() ->
                """module M3e.Button.Build exposing (withDisabled, disabled, withIcon, icon)
"""
                    |> Review.Test.run (rule { allowedModules = [ "M3e" ] })
                    |> Review.Test.expectNoErrors
        , test "flags a non-allowed module even when allowedModules has a different prefix" <|
            \() ->
                """module MyApp.Barrel exposing (withDisabled, disabled)
"""
                    |> Review.Test.run (rule { allowedModules = [ "M3e" ] })
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = error "withDisabled" "Disabled"
                            , details = detailMsg "withDisabled" "Disabled"
                            , under = "withDisabled"
                            }
                        ]
        ]
