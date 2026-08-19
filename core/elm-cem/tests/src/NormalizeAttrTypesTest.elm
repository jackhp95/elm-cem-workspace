module NormalizeAttrTypesTest exposing (suite)

{-| Regression tests for `Generate.Normalize.normalizeAttrTypes` — the pass that repairs
attributes the CEM left untyped (`type_ = Nothing`) by inheriting the type of the
same-named attribute where other components declare it. Motivating bug: elm-m3e#95
— `m3e-dialog`'s `open` and `m3e-radio`'s `required` are declared with a null type
while siblings declare them `boolean`, so without inheritance they degrade to a
`String` setter with HTML presence semantics and `open "false"` renders open.
-}

import Attr exposing (AttrType(..))
import Cem
import Expect
import Generate
import Generate.Normalize
import Test exposing (Test, describe, test)


{-| A CEM declaration carrying just the attributes under test; every other field
is empty/default so the fixtures stay readable.
-}
decl : String -> List Cem.Attribute -> Cem.Declaration
decl name attrs =
    { kind = "class"
    , name = name
    , description = Nothing
    , tagName = Just name
    , cssProperties = []
    , cssParts = []
    , slots = []
    , members = []
    , events = []
    , attributes = attrs
    , customElement = Just True
    , summary = Nothing
    , documentation = Nothing
    , status = Nothing
    , since = Nothing
    , superclass = Nothing
    , dependencies = []
    , cssStates = []
    }


attr : String -> Maybe String -> Cem.Attribute
attr name typeText =
    { name = name
    , description = Nothing
    , type_ = Maybe.map (\t -> { text = t, aliasName = Nothing }) typeText
    , default = Nothing
    , fieldName = Nothing
    , typeOverride = Nothing
    , elmNameOverride = Nothing
    , global = False
    }


{-| Classify the named attribute of the named component after normalization.
-}
classifyOf : String -> String -> List Cem.Declaration -> Maybe AttrType
classifyOf compName attrName components =
    components
        |> Generate.Normalize.normalizeAttrTypes
        |> List.filter (\c -> c.name == compName)
        |> List.concatMap .attributes
        |> List.filter (\a -> a.name == attrName)
        |> List.head
        |> Maybe.map Attr.classify


suite : Test
suite =
    describe "Generate.Normalize.normalizeAttrTypes"
        [ test "a null-typed attribute inherits a unanimous boolean sibling" <|
            \_ ->
                [ decl "m3e-expansion-panel" [ attr "open" (Just "boolean") ]
                , decl "m3e-dialog" [ attr "open" Nothing ]
                ]
                    |> classifyOf "m3e-dialog" "open"
                    |> Expect.equal (Just ABool)
        , test "inheritance tolerates nullable sibling forms (boolean | undefined)" <|
            \_ ->
                [ decl "m3e-tree-item" [ attr "open" (Just "boolean | undefined") ]
                , decl "m3e-dialog" [ attr "open" Nothing ]
                ]
                    |> classifyOf "m3e-dialog" "open"
                    |> Expect.equal (Just ABool)
        , test "required inherits boolean from typed siblings" <|
            \_ ->
                [ decl "m3e-checkbox" [ attr "required" (Just "boolean") ]
                , decl "m3e-radio-group" [ attr "required" (Just "boolean") ]
                , decl "m3e-radio" [ attr "required" Nothing ]
                ]
                    |> classifyOf "m3e-radio" "required"
                    |> Expect.equal (Just ABool)
        , test "conflicting sibling types leave the null attribute untouched (String)" <|
            \_ ->
                [ decl "a-comp" [ attr "value" (Just "string") ]
                , decl "b-comp" [ attr "value" (Just "number") ]
                , decl "c-comp" [ attr "value" Nothing ]
                ]
                    |> classifyOf "c-comp" "value"
                    |> Expect.equal (Just AString)
        , test "no typed sibling leaves the null attribute untouched (String)" <|
            \_ ->
                [ decl "only-comp" [ attr "orphan" Nothing ] ]
                    |> classifyOf "only-comp" "orphan"
                    |> Expect.equal (Just AString)
        , test "an already-typed attribute is never overwritten" <|
            \_ ->
                [ decl "x-comp" [ attr "count" (Just "number") ]
                , decl "y-comp" [ attr "count" (Just "boolean") ]
                ]
                    |> classifyOf "x-comp" "count"
                    |> Expect.equal (Just ANumber)
        ]
