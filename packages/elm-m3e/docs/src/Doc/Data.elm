module Doc.Data exposing
    ( Component
    , ExampleUsage
    , Member
    , allComponents
    , allExampleUsage
    , allUsage
    )

import BackendTask exposing (BackendTask)
import BackendTask.File
import Dict exposing (Dict)
import Doc.Usage exposing (UsageExample, usageExampleDecoder)
import FatalError exposing (FatalError)
import Json.Decode as Decode


type alias Member =
    { name : String, kind : String, signature : String, doc : String, role : String }


type alias Component =
    { name : String
    , slug : String
    , category : String
    , label : String
    , summary : String
    , overview : String
    , members : List Member
    }


memberDecoder : Decode.Decoder Member
memberDecoder =
    Decode.map5 Member
        (Decode.field "name" Decode.string)
        (Decode.field "kind" Decode.string)
        (Decode.field "signature" Decode.string)
        (Decode.field "doc" Decode.string)
        (Decode.oneOf [ Decode.field "role" Decode.string, Decode.succeed "" ])


componentDecoder : Decode.Decoder Component
componentDecoder =
    Decode.map7 Component
        (Decode.field "name" Decode.string)
        (Decode.field "slug" Decode.string)
        (Decode.oneOf [ Decode.field "category" Decode.string, Decode.succeed "" ])
        -- The editorial nav label; older reference.json lacked it, so fall back
        -- to the bare `name`.
        (Decode.oneOf [ Decode.field "label" Decode.string, Decode.field "name" Decode.string ])
        (Decode.oneOf [ Decode.field "summary" Decode.string, Decode.succeed "" ])
        (Decode.field "overview" Decode.string)
        (Decode.field "members" (Decode.list memberDecoder))


allComponents : BackendTask FatalError (List Component)
allComponents =
    BackendTask.File.jsonFile (Decode.list componentDecoder) "data/reference.json"
        |> BackendTask.allowFatal


{-| All Usage examples keyed by component slug. Missing file / entry ⇒ no Usage.
-}
allUsage : BackendTask FatalError (Dict String (List UsageExample))
allUsage =
    BackendTask.File.jsonFile
        (Decode.dict (Decode.field "examples" (Decode.list usageExampleDecoder)))
        "data/examples.json"
        |> BackendTask.allowFatal


{-| One example-app that instantiates a component: its display title and route.
-}
type alias ExampleUsage =
    { title : String, route : String }


exampleUsageDecoder : Decode.Decoder ExampleUsage
exampleUsageDecoder =
    Decode.map2 ExampleUsage
        (Decode.field "title" Decode.string)
        (Decode.field "route" Decode.string)


{-| For each component slug, the example apps that use it (built by
`build-examples-data.mjs`). Missing file / entry ⇒ no "In the example apps"
section on that component page.
-}
allExampleUsage : BackendTask FatalError (Dict String (List ExampleUsage))
allExampleUsage =
    BackendTask.File.jsonFile
        (Decode.dict (Decode.list exampleUsageDecoder))
        "data/example-usage.json"
        |> BackendTask.allowFatal
