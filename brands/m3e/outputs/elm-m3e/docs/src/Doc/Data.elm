module Doc.Data exposing
    ( Component
    , ExampleUsage
    , Layers
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


{-| The four API layers of a component, one per API-reference tab: `m3e` (the
barrel's thin per-component slice — normally just the constructor), `components`
(the `M3e.Component.<Name>` module's own members), `builder` (`M3e.Build.<Name>`'s
pipe surface), and `raw` (the underlying custom element's CEM
attributes/events/slots, read from `@m3e/web`'s `custom-elements.json`). Type
aliases/unions are lifted OUT of the layers into `Component.types` — they are
shared across layers — so a layer holds only its value members.
-}
type alias Layers =
    { m3e : List Member
    , components : List Member
    , builder : List Member
    , raw : List Member
    }


type alias Component =
    { name : String
    , slug : String
    , category : String
    , label : String
    , summary : String
    , overview : String
    , types : List Member
    , layers : Layers
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
    Decode.map8 Component
        (Decode.field "name" Decode.string)
        (Decode.field "slug" Decode.string)
        (Decode.oneOf [ Decode.field "category" Decode.string, Decode.succeed "" ])
        -- The editorial nav label; older reference.json lacked it, so fall back
        -- to the bare `name`.
        (Decode.oneOf [ Decode.field "label" Decode.string, Decode.field "name" Decode.string ])
        (Decode.oneOf [ Decode.field "summary" Decode.string, Decode.succeed "" ])
        (Decode.field "overview" Decode.string)
        (Decode.oneOf
            [ Decode.field "types" (Decode.list memberDecoder)
            , legacyMembers |> Decode.map (List.filter (\m -> m.kind == "type"))
            ]
        )
        layersDecoder


{-| An older flat `reference.json` carried one `members` array. Decode it (or an
empty list) so the layered decoders can fall back gracefully instead of failing
the whole file on a stale generated artifact.
-}
legacyMembers : Decode.Decoder (List Member)
legacyMembers =
    Decode.oneOf [ Decode.field "members" (Decode.list memberDecoder), Decode.succeed [] ]


layersDecoder : Decode.Decoder Layers
layersDecoder =
    Decode.oneOf
        [ Decode.field "layers"
            (Decode.map4 Layers
                (Decode.field "m3e" (Decode.list memberDecoder))
                (Decode.field "components" (Decode.list memberDecoder))
                (Decode.field "builder" (Decode.list memberDecoder))
                (Decode.oneOf [ Decode.field "raw" (Decode.list memberDecoder), Decode.succeed [] ])
            )
        , legacyMembers
            |> Decode.map (\ms -> Layers [] (List.filter (\m -> m.kind /= "type") ms) [] [])
        ]


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
