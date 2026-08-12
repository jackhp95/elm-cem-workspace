module GenerationTest exposing (suite)

import Cem
import Expect
import Test exposing (..)


{-| Test suite for code generation logic
-}
suite : Test
suite =
    describe "Code Generation"
        [ describe "Component Extraction"
            [ test "filters custom elements only" <|
                \_ ->
                    let
                        manifest =
                            { schemaVersion = "1.0.0"
                            , modules =
                                [ { kind = "javascript-module"
                                  , path = "button.js"
                                  , declarations =
                                        [ { kind = "class"
                                          , name = "Button"
                                          , tagName = Just "sl-button"
                                          , customElement = Just True
                                          , description = Nothing
                                          , members = []
                                          , attributes = []
                                          , events = []
                                          , slots = []
                                          , cssProperties = []
                                          , cssParts = []
                                          , cssStates = []
                                          , summary = Nothing
                                          , documentation = Nothing
                                          , status = Nothing
                                          , since = Nothing
                                          , superclass = Nothing
                                          , dependencies = []
                                          }
                                        , { kind = "class"
                                          , name = "Helper"
                                          , tagName = Nothing
                                          , customElement = Nothing
                                          , description = Nothing
                                          , members = []
                                          , attributes = []
                                          , events = []
                                          , slots = []
                                          , cssProperties = []
                                          , cssParts = []
                                          , cssStates = []
                                          , summary = Nothing
                                          , documentation = Nothing
                                          , status = Nothing
                                          , since = Nothing
                                          , superclass = Nothing
                                          , dependencies = []
                                          }
                                        ]
                                  , exports = Nothing
                                  }
                                ]
                            , package = Nothing
                            }

                        components =
                            extractComponents manifest
                    in
                    List.length components |> Expect.equal 1
            , test "includes components with customElement=true" <|
                \_ ->
                    let
                        manifest =
                            { schemaVersion = "1.0.0"
                            , modules =
                                [ { kind = "javascript-module"
                                  , path = "alert.js"
                                  , declarations =
                                        [ { kind = "class"
                                          , name = "Alert"
                                          , tagName = Just "sl-alert"
                                          , customElement = Just True
                                          , description = Just "An alert component"
                                          , members = []
                                          , attributes = []
                                          , events = []
                                          , slots = []
                                          , cssProperties = []
                                          , cssParts = []
                                          , cssStates = []
                                          , summary = Nothing
                                          , documentation = Nothing
                                          , status = Nothing
                                          , since = Nothing
                                          , superclass = Nothing
                                          , dependencies = []
                                          }
                                        ]
                                  , exports = Nothing
                                  }
                                ]
                            , package = Nothing
                            }

                        components =
                            extractComponents manifest
                    in
                    components
                        |> List.head
                        |> Maybe.andThen .tagName
                        |> Expect.equal (Just "sl-alert")
            ]
        , describe "Library Info Extraction"
            [ test "extracts module name from package" <|
                \_ ->
                    let
                        manifest =
                            { schemaVersion = "1.0.0"
                            , modules =
                                [ { kind = "javascript-module"
                                  , path = "button.js"
                                  , declarations =
                                        [ { kind = "class"
                                          , name = "SlButton"
                                          , tagName = Just "sl-button"
                                          , customElement = Just True
                                          , description = Nothing
                                          , members = []
                                          , attributes = []
                                          , events = []
                                          , slots = []
                                          , cssProperties = []
                                          , cssParts = []
                                          , cssStates = []
                                          , summary = Nothing
                                          , documentation = Nothing
                                          , status = Nothing
                                          , since = Nothing
                                          , superclass = Nothing
                                          , dependencies = []
                                          }
                                        ]
                                  , exports = Nothing
                                  }
                                ]
                            , package =
                                Just
                                    { name = "@shoelace-style/shoelace"
                                    , description = "A library"
                                    , version = "2.0.0"
                                    , author = Nothing
                                    , homepage = Nothing
                                    , license = "MIT"
                                    }
                            }

                        libraryInfo =
                            extractLibraryInfo manifest
                    in
                    libraryInfo.moduleName |> Expect.equal "Sl"
            , test "extracts component prefix from tagName" <|
                \_ ->
                    let
                        manifest =
                            { schemaVersion = "1.0.0"
                            , modules =
                                [ { kind = "javascript-module"
                                  , path = "button.js"
                                  , declarations =
                                        [ { kind = "class"
                                          , name = "IonButton"
                                          , tagName = Just "ion-button"
                                          , customElement = Just True
                                          , description = Nothing
                                          , members = []
                                          , attributes = []
                                          , events = []
                                          , slots = []
                                          , cssProperties = []
                                          , cssParts = []
                                          , cssStates = []
                                          , summary = Nothing
                                          , documentation = Nothing
                                          , status = Nothing
                                          , since = Nothing
                                          , superclass = Nothing
                                          , dependencies = []
                                          }
                                        ]
                                  , exports = Nothing
                                  }
                                ]
                            , package = Nothing
                            }

                        libraryInfo =
                            extractLibraryInfo manifest
                    in
                    libraryInfo.componentPrefix |> Expect.equal "ion-"
            ]
        , describe "Attribute Type Detection"
            [ test "identifies boolean attributes" <|
                \_ ->
                    let
                        attr =
                            { name = "disabled"
                            , description = Just "Disables the button"
                            , type_ = Just { text = "boolean", aliasName = Nothing }
                            , default = Just "false"
                            , fieldName = Nothing
                            , typeOverride = Nothing
                            , elmNameOverride = Nothing
                            , global = False
                            }
                    in
                    attr.type_
                        |> Maybe.map .text
                        |> Maybe.map (String.contains "boolean")
                        |> Expect.equal (Just True)
            , test "identifies union types" <|
                \_ ->
                    let
                        attr =
                            { name = "variant"
                            , description = Just "The variant"
                            , type_ = Just { text = "'primary' | 'secondary' | 'tertiary'", aliasName = Nothing }
                            , default = Just "'primary'"
                            , fieldName = Nothing
                            , typeOverride = Nothing
                            , elmNameOverride = Nothing
                            , global = False
                            }
                    in
                    attr.type_
                        |> Maybe.map .text
                        |> Maybe.map (String.contains "|")
                        |> Expect.equal (Just True)
            , test "handles missing type gracefully" <|
                \_ ->
                    let
                        attr =
                            { name = "custom"
                            , description = Just "Custom attribute"
                            , type_ = Nothing
                            , default = Nothing
                            , fieldName = Nothing
                            , typeOverride = Nothing
                            , elmNameOverride = Nothing
                            , global = False
                            }
                    in
                    attr.type_ |> Expect.equal Nothing
            ]
        , describe "Component Merging"
            [ test "merges components with same tagName" <|
                \_ ->
                    let
                        comp1 =
                            { kind = "class"
                            , name = "PickerBase"
                            , tagName = Just "sp-picker"
                            , customElement = Just True
                            , description = Just "Base picker"
                            , members = []
                            , attributes =
                                [ { name = "size"
                                  , description = Just "Size"
                                  , type_ = Nothing
                                  , default = Nothing
                                  , fieldName = Nothing
                                  , typeOverride = Nothing
                                  , elmNameOverride = Nothing
                                  , global = False
                                  }
                                ]
                            , events = []
                            , slots = []
                            , cssProperties = []
                            , cssParts = []
                            , cssStates = []
                            , summary = Nothing
                            , documentation = Nothing
                            , status = Nothing
                            , since = Nothing
                            , superclass = Nothing
                            , dependencies = []
                            }

                        comp2 =
                            { kind = "class"
                            , name = "Picker"
                            , tagName = Just "sp-picker"
                            , customElement = Just True
                            , description = Just "Picker implementation"
                            , members = []
                            , attributes =
                                [ { name = "disabled"
                                  , description = Just "Disabled"
                                  , type_ = Nothing
                                  , default = Nothing
                                  , fieldName = Nothing
                                  , typeOverride = Nothing
                                  , elmNameOverride = Nothing
                                  , global = False
                                  }
                                ]
                            , events = []
                            , slots = []
                            , cssProperties = []
                            , cssParts = []
                            , cssStates = []
                            , summary = Nothing
                            , documentation = Nothing
                            , status = Nothing
                            , since = Nothing
                            , superclass = Nothing
                            , dependencies = []
                            }

                        merged =
                            mergeComponents comp1 comp2
                    in
                    List.length merged.attributes |> Expect.equal 2
            , test "keeps longest description when merging" <|
                \_ ->
                    let
                        comp1 =
                            { kind = "class"
                            , name = "Base"
                            , tagName = Just "my-comp"
                            , customElement = Just True
                            , description = Just "Short"
                            , members = []
                            , attributes = []
                            , events = []
                            , slots = []
                            , cssProperties = []
                            , cssParts = []
                            , cssStates = []
                            , summary = Nothing
                            , documentation = Nothing
                            , status = Nothing
                            , since = Nothing
                            , superclass = Nothing
                            , dependencies = []
                            }

                        comp2 =
                            { kind = "class"
                            , name = "Extended"
                            , tagName = Just "my-comp"
                            , customElement = Just True
                            , description = Just "This is a much longer description"
                            , members = []
                            , attributes = []
                            , events = []
                            , slots = []
                            , cssProperties = []
                            , cssParts = []
                            , cssStates = []
                            , summary = Nothing
                            , documentation = Nothing
                            , status = Nothing
                            , since = Nothing
                            , superclass = Nothing
                            , dependencies = []
                            }

                        merged =
                            mergeComponents comp1 comp2
                    in
                    merged.description |> Expect.equal (Just "This is a much longer description")
            ]
        , describe "Name Sanitization"
            [ test "capitalizes module names from tag names" <|
                \_ ->
                    "sl-button"
                        |> String.split "-"
                        |> List.map capitalize
                        |> String.concat
                        |> Expect.equal "SlButton"
            , test "removes prefix from component names" <|
                \_ ->
                    "sl-button"
                        |> String.replace "sl-" ""
                        |> String.split "-"
                        |> List.map capitalize
                        |> String.concat
                        |> Expect.equal "Button"
            , test "handles multi-dash names" <|
                \_ ->
                    "my-custom-element"
                        |> String.split "-"
                        |> List.map capitalize
                        |> String.concat
                        |> Expect.equal "MyCustomElement"
            ]
        ]


{-| Helper function to extract components (mimics Generate.elm logic)
-}
extractComponents : Cem.Manifest -> List Cem.Declaration
extractComponents manifest =
    manifest.modules
        |> List.concatMap .declarations
        |> List.filter (\decl -> decl.customElement == Just True)


{-| Helper function to extract library info (mimics Generate.elm logic)
-}
extractLibraryInfo : Cem.Manifest -> { moduleName : String, libraryName : String, componentPrefix : String, eventPrefix : String }
extractLibraryInfo manifest =
    let
        packageName =
            case manifest.package of
                Just pkg ->
                    pkg.name

                Nothing ->
                    ""

        componentPrefix =
            extractComponents manifest
                |> List.filterMap .tagName
                |> List.head
                |> Maybe.map
                    (\tagName ->
                        case String.split "-" tagName |> List.head of
                            Just prefix ->
                                prefix ++ "-"

                            Nothing ->
                                ""
                    )
                |> Maybe.withDefault ""

        moduleName =
            if componentPrefix == "" then
                "Components"

            else
                componentPrefix
                    |> String.dropRight 1
                    |> capitalize
    in
    { moduleName = moduleName
    , libraryName = packageName
    , componentPrefix = componentPrefix
    , eventPrefix = componentPrefix
    }


{-| Helper to merge two components (mimics Generate.elm logic)
-}
mergeComponents : Cem.Declaration -> Cem.Declaration -> Cem.Declaration
mergeComponents comp1 comp2 =
    { comp1
        | attributes = deduplicateBy .name (comp1.attributes ++ comp2.attributes)
        , events = deduplicateBy .name (comp1.events ++ comp2.events)
        , slots = deduplicateBy .name (comp1.slots ++ comp2.slots)
        , description =
            case ( comp1.description, comp2.description ) of
                ( Just desc1, Just desc2 ) ->
                    if String.length desc1 > String.length desc2 then
                        Just desc1

                    else
                        Just desc2

                ( Just desc, Nothing ) ->
                    Just desc

                ( Nothing, Just desc ) ->
                    Just desc

                ( Nothing, Nothing ) ->
                    Nothing
    }


{-| Helper to deduplicate list by key
-}
deduplicateBy : (a -> comparable) -> List a -> List a
deduplicateBy keyFn list =
    list
        |> List.foldl
            (\item acc ->
                if List.any (\existing -> keyFn existing == keyFn item) acc.seen then
                    acc

                else
                    { seen = item :: acc.seen, result = item :: acc.result }
            )
            { seen = [], result = [] }
        |> .result
        |> List.reverse


{-| Helper to capitalize string
-}
capitalize : String -> String
capitalize str =
    case String.uncons str of
        Nothing ->
            str

        Just ( first, rest ) ->
            String.cons (Char.toUpper first) rest
