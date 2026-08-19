module CemDecoderTest exposing (suite)

import Cem
import Expect
import Json.Decode as Decode
import Test exposing (..)


decodeAndThen : String -> (Cem.Manifest -> Maybe a) -> Result String a
decodeAndThen json extract =
    Decode.decodeString Cem.manifestDecoder json
        |> Result.mapError Decode.errorToString
        |> Result.andThen
            (\manifest ->
                extract manifest
                    |> Result.fromMaybe "Field not found"
            )


suite : Test
suite =
    describe "CEM Decoder"
        [ describe "Manifest Decoder"
            [ test "decodes minimal valid manifest" <|
                \_ ->
                    let
                        json =
                            """
                            {
                              "schemaVersion": "1.0.0",
                              "modules": []
                            }
                            """
                    in
                    Decode.decodeString Cem.manifestDecoder json
                        |> Result.map (\manifest -> manifest.schemaVersion)
                        |> Expect.equal (Ok "1.0.0")
            , test "decodes manifest with package metadata" <|
                \_ ->
                    let
                        json =
                            """
                            {
                              "schemaVersion": "2.0.0",
                              "modules": [],
                              "package": {
                                "name": "@shoelace-style/shoelace",
                                "description": "A forward-thinking library of web components.",
                                "version": "2.20.1",
                                "license": "MIT"
                              }
                            }
                            """
                    in
                    decodeAndThen json
                        (\manifest ->
                            manifest.package
                                |> Maybe.map .name
                        )
                        |> Expect.equal (Ok "@shoelace-style/shoelace")
            , test "handles missing optional package field" <|
                \_ ->
                    let
                        json =
                            """
                            {
                              "schemaVersion": "1.0.0",
                              "modules": []
                            }
                            """
                    in
                    Decode.decodeString Cem.manifestDecoder json
                        |> Result.map (\manifest -> manifest.package)
                        |> Expect.equal (Ok Nothing)
            ]
        , describe "Module Decoder"
            [ test "decodes module with declarations" <|
                \_ ->
                    let
                        json =
                            """
                            {
                              "schemaVersion": "1.0.0",
                              "modules": [
                                {
                                  "kind": "javascript-module",
                                  "path": "components/button/button.js",
                                  "declarations": []
                                }
                              ]
                            }
                            """
                    in
                    Decode.decodeString Cem.manifestDecoder json
                        |> Result.map (\manifest -> List.length manifest.modules)
                        |> Expect.equal (Ok 1)
            ]
        , describe "Declaration Decoder"
            [ test "decodes custom element declaration" <|
                \_ ->
                    let
                        json =
                            """
                            {
                              "schemaVersion": "1.0.0",
                              "modules": [
                                {
                                  "kind": "javascript-module",
                                  "path": "button.js",
                                  "declarations": [
                                    {
                                      "kind": "class",
                                      "name": "SlButton",
                                      "tagName": "sl-button",
                                      "customElement": true,
                                      "description": "Buttons represent actions that are available to the user.",
                                      "members": [],
                                      "events": [],
                                      "attributes": [],
                                      "slots": [],
                                      "cssProperties": [],
                                      "cssParts": [],
                                      "cssStates": []
                                    }
                                  ]
                                }
                              ]
                            }
                            """
                    in
                    decodeAndThen json
                        (\manifest ->
                            manifest.modules
                                |> List.head
                                |> Maybe.andThen (\m -> List.head m.declarations)
                                |> Maybe.map .tagName
                        )
                        |> Expect.equal (Ok (Just "sl-button"))
            , test "decodes attributes with types" <|
                \_ ->
                    let
                        json =
                            """
                            {
                              "schemaVersion": "1.0.0",
                              "modules": [
                                {
                                  "kind": "javascript-module",
                                  "path": "button.js",
                                  "declarations": [
                                    {
                                      "kind": "class",
                                      "name": "Button",
                                      "tagName": "sl-button",
                                      "customElement": true,
                                      "members": [],
                                      "events": [],
                                      "attributes": [
                                        {
                                          "name": "disabled",
                                          "type": {
                                            "text": "boolean"
                                          },
                                          "description": "Disables the button."
                                        },
                                        {
                                          "name": "variant",
                                          "type": {
                                            "text": "'primary' | 'success' | 'neutral'"
                                          },
                                          "description": "The button's theme variant."
                                        }
                                      ],
                                      "slots": [],
                                      "cssProperties": [],
                                      "cssParts": [],
                                      "cssStates": []
                                    }
                                  ]
                                }
                              ]
                            }
                            """
                    in
                    decodeAndThen json
                        (\manifest ->
                            manifest.modules
                                |> List.head
                                |> Maybe.andThen (\m -> List.head m.declarations)
                                |> Maybe.map .attributes
                                |> Maybe.map List.length
                        )
                        |> Expect.equal (Ok 2)
            , test "decodes events with custom types" <|
                \_ ->
                    let
                        json =
                            """
                            {
                              "schemaVersion": "1.0.0",
                              "modules": [
                                {
                                  "kind": "javascript-module",
                                  "path": "dialog.js",
                                  "declarations": [
                                    {
                                      "kind": "class",
                                      "name": "Dialog",
                                      "tagName": "sl-dialog",
                                      "customElement": true,
                                      "members": [],
                                      "attributes": [],
                                      "events": [
                                        {
                                          "name": "sl-show",
                                          "description": "Emitted when the dialog opens.",
                                          "type": {
                                            "text": "CustomEvent"
                                          }
                                        },
                                        {
                                          "name": "sl-after-show",
                                          "description": "Emitted after the dialog opens and all animations are complete."
                                        }
                                      ],
                                      "slots": [],
                                      "cssProperties": [],
                                      "cssParts": [],
                                      "cssStates": []
                                    }
                                  ]
                                }
                              ]
                            }
                            """
                    in
                    decodeAndThen json
                        (\manifest ->
                            manifest.modules
                                |> List.head
                                |> Maybe.andThen (\m -> List.head m.declarations)
                                |> Maybe.map (.events >> List.length)
                        )
                        |> Expect.equal (Ok 2)
            , test "decodes slots with descriptions" <|
                \_ ->
                    let
                        json =
                            """
                            {
                              "schemaVersion": "1.0.0",
                              "modules": [
                                {
                                  "kind": "javascript-module",
                                  "path": "button.js",
                                  "declarations": [
                                    {
                                      "kind": "class",
                                      "name": "Button",
                                      "tagName": "sl-button",
                                      "customElement": true,
                                      "members": [],
                                      "attributes": [],
                                      "events": [],
                                      "slots": [
                                        {
                                          "name": "",
                                          "description": "The button's label."
                                        },
                                        {
                                          "name": "prefix",
                                          "description": "A presentational prefix icon."
                                        }
                                      ],
                                      "cssProperties": [],
                                      "cssParts": [],
                                      "cssStates": []
                                    }
                                  ]
                                }
                              ]
                            }
                            """
                    in
                    decodeAndThen json
                        (\manifest ->
                            manifest.modules
                                |> List.head
                                |> Maybe.andThen (\m -> List.head m.declarations)
                                |> Maybe.map (.slots >> List.length)
                        )
                        |> Expect.equal (Ok 2)
            , test "decodes CSS custom properties" <|
                \_ ->
                    let
                        json =
                            """
                            {
                              "schemaVersion": "1.0.0",
                              "modules": [
                                {
                                  "kind": "javascript-module",
                                  "path": "button.js",
                                  "declarations": [
                                    {
                                      "kind": "class",
                                      "name": "Button",
                                      "tagName": "sl-button",
                                      "customElement": true,
                                      "members": [],
                                      "attributes": [],
                                      "events": [],
                                      "slots": [],
                                      "cssProperties": [
                                        {
                                          "name": "--border-radius",
                                          "description": "The border radius of the button.",
                                          "default": "4px"
                                        }
                                      ],
                                      "cssParts": [],
                                      "cssStates": []
                                    }
                                  ]
                                }
                              ]
                            }
                            """
                    in
                    decodeAndThen json
                        (\manifest ->
                            manifest.modules
                                |> List.head
                                |> Maybe.andThen (\m -> List.head m.declarations)
                                |> Maybe.andThen (\d -> List.head d.cssProperties)
                                |> Maybe.map .name
                        )
                        |> Expect.equal (Ok "--border-radius")
            ]
        , describe "Type Handling"
            [ test "handles missing type field" <|
                \_ ->
                    let
                        json =
                            """
                            {
                              "schemaVersion": "1.0.0",
                              "modules": [
                                {
                                  "kind": "javascript-module",
                                  "path": "button.js",
                                  "declarations": [
                                    {
                                      "kind": "class",
                                      "name": "Button",
                                      "tagName": "sl-button",
                                      "customElement": true,
                                      "members": [],
                                      "attributes": [
                                        {
                                          "name": "size",
                                          "description": "The button size."
                                        }
                                      ],
                                      "events": [],
                                      "slots": [],
                                      "cssProperties": [],
                                      "cssParts": [],
                                      "cssStates": []
                                    }
                                  ]
                                }
                              ]
                            }
                            """
                    in
                    decodeAndThen json
                        (\manifest ->
                            manifest.modules
                                |> List.head
                                |> Maybe.andThen (\m -> List.head m.declarations)
                                |> Maybe.andThen (\d -> List.head d.attributes)
                                |> Maybe.map .type_
                        )
                        |> Expect.equal (Ok Nothing)
            , test "decodes union types" <|
                \_ ->
                    let
                        json =
                            """
                            {
                              "schemaVersion": "1.0.0",
                              "modules": [
                                {
                                  "kind": "javascript-module",
                                  "path": "button.js",
                                  "declarations": [
                                    {
                                      "kind": "class",
                                      "name": "Button",
                                      "tagName": "sl-button",
                                      "customElement": true,
                                      "members": [],
                                      "attributes": [
                                        {
                                          "name": "variant",
                                          "type": {
                                            "text": "'primary' | 'secondary' | 'tertiary'"
                                          }
                                        }
                                      ],
                                      "events": [],
                                      "slots": [],
                                      "cssProperties": [],
                                      "cssParts": [],
                                      "cssStates": []
                                    }
                                  ]
                                }
                              ]
                            }
                            """
                    in
                    decodeAndThen json
                        (\manifest ->
                            manifest.modules
                                |> List.head
                                |> Maybe.andThen (\m -> List.head m.declarations)
                                |> Maybe.andThen (\d -> List.head d.attributes)
                                |> Maybe.andThen .type_
                                |> Maybe.map .text
                        )
                        |> Expect.equal (Ok "'primary' | 'secondary' | 'tertiary'")
            ]
        , describe "Edge Cases"
            [ test "handles empty arrays" <|
                \_ ->
                    let
                        json =
                            """
                            {
                              "schemaVersion": "1.0.0",
                              "modules": []
                            }
                            """
                    in
                    Decode.decodeString Cem.manifestDecoder json
                        |> Result.map (\manifest -> List.length manifest.modules)
                        |> Expect.equal (Ok 0)
            , test "handles declaration without customElement flag" <|
                \_ ->
                    let
                        json =
                            """
                            {
                              "schemaVersion": "1.0.0",
                              "modules": [
                                {
                                  "kind": "javascript-module",
                                  "path": "helper.js",
                                  "declarations": [
                                    {
                                      "kind": "class",
                                      "name": "Helper",
                                      "members": [],
                                      "attributes": [],
                                      "events": [],
                                      "slots": [],
                                      "cssProperties": [],
                                      "cssParts": [],
                                      "cssStates": []
                                    }
                                  ]
                                }
                              ]
                            }
                            """
                    in
                    decodeAndThen json
                        (\manifest ->
                            manifest.modules
                                |> List.head
                                |> Maybe.andThen (\m -> List.head m.declarations)
                                |> Maybe.map .customElement
                        )
                        |> Expect.equal (Ok Nothing)
            , test "handles superclass information" <|
                \_ ->
                    let
                        json =
                            """
                            {
                              "schemaVersion": "1.0.0",
                              "modules": [
                                {
                                  "kind": "javascript-module",
                                  "path": "button.js",
                                  "declarations": [
                                    {
                                      "kind": "class",
                                      "name": "Button",
                                      "customElement": true,
                                      "superclass": {
                                        "name": "ShoelaceElement",
                                        "module": "/src/internal/shoelace-element.js"
                                      },
                                      "members": [],
                                      "attributes": [],
                                      "events": [],
                                      "slots": [],
                                      "cssProperties": [],
                                      "cssParts": [],
                                      "cssStates": []
                                    }
                                  ]
                                }
                              ]
                            }
                            """
                    in
                    decodeAndThen json
                        (\manifest ->
                            manifest.modules
                                |> List.head
                                |> Maybe.andThen (\m -> List.head m.declarations)
                                |> Maybe.andThen .superclass
                                |> Maybe.map .name
                        )
                        |> Expect.equal (Ok "ShoelaceElement")
            , test "decodes a superclass with no module (issue #29): keeps the superclass, modulePath = Nothing" <|
                \_ ->
                    let
                        json =
                            """
                            {
                              "schemaVersion": "1.0.0",
                              "modules": [
                                {
                                  "kind": "javascript-module",
                                  "path": "button.js",
                                  "declarations": [
                                    {
                                      "kind": "class",
                                      "name": "Button",
                                      "customElement": true,
                                      "superclass": { "name": "LitElement" },
                                      "members": [],
                                      "attributes": [],
                                      "events": [],
                                      "slots": [],
                                      "cssProperties": [],
                                      "cssParts": [],
                                      "cssStates": []
                                    }
                                  ]
                                }
                              ]
                            }
                            """
                    in
                    decodeAndThen json
                        (\manifest ->
                            manifest.modules
                                |> List.head
                                |> Maybe.andThen (\m -> List.head m.declarations)
                                |> Maybe.andThen .superclass
                                |> Maybe.map (\sc -> ( sc.name, sc.modulePath ))
                        )
                        |> Expect.equal (Ok ( "LitElement", Nothing ))
            ]
        ]
