module Cem exposing
    ( AttrTypeOverride(..)
    , Attribute
    , Author
    , CssPart
    , CssProperty
    , CssState
    , Declaration
    , Event
    , Export
    , ExportDeclaration
    , Manifest
    , Member
    , Module
    , Package
    , Parameter
    , Payload(..)
    , Return
    , Slot
    , Superclass
    , TypeInfo
    , manifestDecoder
    )

{-| Custom Elements Manifest data model and decoder

This module defines the types and JSON decoders for parsing
Custom Elements Manifest files.

-}

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline


{-| The root structure of a Custom Elements Manifest
-}
type alias Manifest =
    { schemaVersion : String
    , modules : List Module
    , package : Maybe Package
    }


{-| A JavaScript module containing component declarations
-}
type alias Module =
    { kind : String
    , path : String
    , declarations : List Declaration
    , exports : Maybe (List Export)
    }


{-| A component declaration (class)
-}
type alias Declaration =
    { kind : String
    , name : String
    , description : Maybe String
    , tagName : Maybe String
    , cssProperties : List CssProperty
    , cssParts : List CssPart
    , slots : List Slot
    , members : List Member
    , events : List Event
    , attributes : List Attribute
    , customElement : Maybe Bool
    , summary : Maybe String
    , documentation : Maybe String
    , status : Maybe String
    , since : Maybe String
    , superclass : Maybe Superclass
    , dependencies : List String
    , cssStates : List CssState
    }


{-| A CSS custom property
-}
type alias CssProperty =
    { name : String
    , description : Maybe String
    , default : Maybe String
    }


{-| A CSS shadow part
-}
type alias CssPart =
    { name : String
    , description : Maybe String
    }


{-| A CSS state
-}
type alias CssState =
    { name : String
    , description : Maybe String
    }


{-| Component superclass information.

In the CEM schema a superclass is a `Reference`: only `name` is required;
`module` (and `package`) are optional. `modulePath` is therefore `Maybe` — a
superclass declared as just `{ "name": "LitElement" }` is common and must decode,
not be dropped or reject the whole manifest (issue #29).

-}
type alias Superclass =
    { name : String
    , modulePath : Maybe String
    }


{-| A slot definition
-}
type alias Slot =
    { name : String
    , description : Maybe String
    }


{-| A class member (field or method)
-}
type alias Member =
    { kind : String -- "field" or "method"
    , name : String
    , description : Maybe String
    , type_ : Maybe TypeInfo
    , default : Maybe String
    , attribute : Maybe String
    , reflects : Maybe Bool
    , privacy : Maybe String
    , return : Maybe Return
    , parameters : List Parameter
    }


{-| Type information

`aliasName` is a generator-level enrichment (not core CEM schema): the NAME of
the TypeScript alias this type came from. The alias-recording pass
(bin/elm-cem.js) resolves `ButtonVariant` to its literal union in `text` and
keeps the name here, so emitters can use it as docs provenance without losing
the resolved union that enum classification needs.

-}
type alias TypeInfo =
    { text : String
    , aliasName : Maybe String
    }


{-| Method return type
-}
type alias Return =
    { type_ : Maybe TypeInfo }


{-| Method parameter
-}
type alias Parameter =
    { name : String
    , type_ : Maybe TypeInfo
    , optional : Maybe Bool
    , description : Maybe String
    }


{-| The closed vocabulary of standard native-control payload decoders. Both are
generator-level enrichments (populated from CONFIG, never from CEM JSON):

  - `TargetValue` → decodes `["target","value"]` as `String` (input/textarea/select).
  - `TargetChecked` → decodes `["target","checked"]` as `Bool` (checkbox/radio).

-}
type Payload
    = TargetValue
    | TargetChecked


{-| Event definition.

`setter` and `payload` are NOT part of the Custom Elements Manifest — they are
generator-level enrichment slots (like `AttrTypeOverride` on `Attribute`),
populated post-decode from CONFIG (never from the CEM JSON, where they always
decode to `Nothing`). When present they turn the emitted event handler into a
payload-typed `(payload -> msg)` setter (baking the standard decoder in) named
`setter`, instead of the bare `msg` form. Both stay `Nothing` for every ordinary
CEM event, so brand events (CustomEvents with no standard payload) are untouched.

-}
type alias Event =
    { name : String
    , description : Maybe String
    , type_ : Maybe TypeInfo
    , setter : Maybe String
    , payload : Maybe Payload
    }


{-| Attribute definition.

`typeOverride` is NOT part of the Custom Elements Manifest — it is a
generator-level enrichment slot, populated post-decode from CONFIG (never from the
CEM JSON, where it always decodes to `Nothing`). When present it forces the Elm
type an attribute classifies to, so a wrong/under-specified CEM `type.text` can be
corrected declaratively per component-attribute (see `AttrTypeOverride`). Keeping
the mechanism generic here — rather than baking any specific component's knowledge
into the classifier — is what lets the generator stay library-agnostic while the
specifics live entirely in config.

-}
type alias Attribute =
    { name : String
    , description : Maybe String
    , type_ : Maybe TypeInfo
    , default : Maybe String
    , fieldName : Maybe String
    , typeOverride : Maybe AttrTypeOverride

    -- `elmNameOverride` is NOT part of the Custom Elements Manifest — like
    -- `typeOverride` it is a generator-level enrichment slot, populated post-decode
    -- from CONFIG (never from the CEM JSON, where it always decodes to `Nothing`).
    -- It decouples an attribute's Elm-facing name (the setter / phantom-capability
    -- name) from its HTML `name`. It is the mechanism a SYNTHETIC attribute needs: a
    -- valueless marker like `m3e-toc-ignore` should surface as `tocIgnore`, not the
    -- literal `m3eTocIgnore` its kebab name would camel-case to. When `Nothing`
    -- (the default for every real CEM attribute) the Elm name is derived from `name`
    -- exactly as before, so this stays library-agnostic.
    , elmNameOverride : Maybe String

    -- `global = True` marks an attribute that the manifest stamped onto EVERY element
    -- as an enumerated global (e.g. `dir`, `draggable`). Such attrs stay in each
    -- element's capability ROW but their setter is emitted ONCE in the shared vocab,
    -- never per-element (per-element duplication tripled the docs size). Unlike
    -- `typeOverride`/`elmNameOverride`, this DOES come from the CEM JSON. Defaults
    -- `False` for every ordinary attribute, so it stays library-agnostic.
    , global : Bool
    }


{-| A declarative override for an attribute's classified Elm type, supplied by
config (not the manifest). This is the generic MECHANISM; which attribute gets
which override is the config's business.

  - `OverrideScalar kind` — force a scalar setter; `kind` is one of `"int"`,
    `"float"`, `"bool"`, `"string"`.
  - `OverrideEnum tokenValues` — force a typed enum setter. Each pair is
    `( token, value )`: `token` is the Elm-facing name (the `Value` token / record
    field) and `value` is the string actually emitted as the attribute value. A
    simple list-style override (`["a","b"]`) decodes to `[ ( "a", "a" ), ( "b", "b" ) ]`
    (token == value); a map-style override (`{"always":"true"}`) decodes to
    `[ ( "always", "true" ) ]`, so the emitted string can differ from the token.

-}
type AttrTypeOverride
    = OverrideScalar String
    | OverrideEnum (List ( String, String ))


{-| Package metadata from the manifest
-}
type alias Package =
    { name : String
    , description : String
    , version : String
    , author : Maybe Author
    , homepage : Maybe String
    , license : String
    }


{-| Package author information
-}
type alias Author =
    { name : String
    , url : Maybe String
    }


{-| Export definition
-}
type alias Export =
    { kind : String
    , name : String
    , declaration : Maybe ExportDeclaration
    }


type alias ExportDeclaration =
    { name : String }



-- DECODERS


manifestDecoder : Decoder Manifest
manifestDecoder =
    Decode.succeed Manifest
        |> Pipeline.required "schemaVersion" Decode.string
        |> Pipeline.required "modules" (Decode.list moduleDecoder)
        |> Pipeline.optional "package" (Decode.maybe packageDecoder) Nothing


packageDecoder : Decoder Package
packageDecoder =
    Decode.succeed Package
        |> Pipeline.required "name" Decode.string
        |> Pipeline.optional "description" Decode.string ""
        |> Pipeline.optional "version" Decode.string ""
        |> Pipeline.optional "author" (Decode.maybe authorDecoder) Nothing
        |> Pipeline.optional "homepage" (Decode.maybe Decode.string) Nothing
        |> Pipeline.optional "license" Decode.string ""


authorDecoder : Decoder Author
authorDecoder =
    Decode.succeed Author
        |> Pipeline.required "name" Decode.string
        |> Pipeline.optional "url" (Decode.maybe Decode.string) Nothing


moduleDecoder : Decoder Module
moduleDecoder =
    Decode.succeed Module
        |> Pipeline.required "kind" Decode.string
        |> Pipeline.required "path" Decode.string
        |> Pipeline.required "declarations" (Decode.list declarationDecoder)
        |> Pipeline.optional "exports" (Decode.maybe (Decode.list exportDecoder)) Nothing


declarationDecoder : Decoder Declaration
declarationDecoder =
    Decode.succeed Declaration
        |> Pipeline.required "kind" Decode.string
        |> Pipeline.required "name" Decode.string
        |> Pipeline.optional "description" (Decode.maybe Decode.string) Nothing
        |> Pipeline.optional "tagName" (Decode.maybe Decode.string) Nothing
        |> Pipeline.optional "cssProperties" (Decode.list cssPropertyDecoder) []
        |> Pipeline.optional "cssParts" (Decode.list cssPartDecoder) []
        |> Pipeline.optional "slots" (Decode.list slotDecoder) []
        |> Pipeline.optional "members" (Decode.list memberDecoder) []
        |> Pipeline.optional "events" (Decode.list eventDecoder) []
        |> Pipeline.optional "attributes" (Decode.list attributeDecoder) []
        |> Pipeline.optional "customElement" (Decode.maybe Decode.bool) Nothing
        |> Pipeline.optional "summary" (Decode.maybe Decode.string) Nothing
        |> Pipeline.optional "documentation" (Decode.maybe Decode.string) Nothing
        |> Pipeline.optional "status" (Decode.maybe Decode.string) Nothing
        |> Pipeline.optional "since" (Decode.maybe Decode.string) Nothing
        |> Pipeline.optional "superclass" (Decode.maybe superclassDecoder) Nothing
        |> Pipeline.optional "dependencies" (Decode.list Decode.string) []
        |> Pipeline.optional "cssStates" (Decode.list cssStateDecoder) []


cssPropertyDecoder : Decoder CssProperty
cssPropertyDecoder =
    Decode.succeed CssProperty
        |> Pipeline.required "name" Decode.string
        |> Pipeline.optional "description" (Decode.maybe Decode.string) Nothing
        |> Pipeline.optional "default" (Decode.maybe Decode.string) Nothing


cssPartDecoder : Decoder CssPart
cssPartDecoder =
    Decode.succeed CssPart
        |> Pipeline.required "name" Decode.string
        |> Pipeline.optional "description" (Decode.maybe Decode.string) Nothing


slotDecoder : Decoder Slot
slotDecoder =
    Decode.succeed Slot
        |> Pipeline.required "name" Decode.string
        |> Pipeline.optional "description" (Decode.maybe Decode.string) Nothing


memberDecoder : Decoder Member
memberDecoder =
    Decode.succeed Member
        |> Pipeline.required "kind" Decode.string
        |> Pipeline.optional "name" Decode.string ""
        |> Pipeline.optional "description" (Decode.maybe Decode.string) Nothing
        |> Pipeline.optional "type" (Decode.maybe typeInfoDecoder) Nothing
        |> Pipeline.optional "default" (Decode.maybe Decode.string) Nothing
        |> Pipeline.optional "attribute" (Decode.maybe Decode.string) Nothing
        |> Pipeline.optional "reflects" (Decode.maybe Decode.bool) Nothing
        |> Pipeline.optional "privacy" (Decode.maybe Decode.string) Nothing
        |> Pipeline.optional "return" (Decode.maybe returnDecoder) Nothing
        |> Pipeline.optional "parameters" (Decode.list parameterDecoder) []


typeInfoDecoder : Decoder TypeInfo
typeInfoDecoder =
    Decode.succeed TypeInfo
        |> Pipeline.required "text" Decode.string
        |> Pipeline.optional "aliasName" (Decode.maybe Decode.string) Nothing


returnDecoder : Decoder Return
returnDecoder =
    Decode.succeed Return
        |> Pipeline.optional "type" (Decode.maybe typeInfoDecoder) Nothing


parameterDecoder : Decoder Parameter
parameterDecoder =
    Decode.succeed Parameter
        |> Pipeline.required "name" Decode.string
        |> Pipeline.optional "type" (Decode.maybe typeInfoDecoder) Nothing
        |> Pipeline.optional "optional" (Decode.maybe Decode.bool) Nothing
        |> Pipeline.optional "description" (Decode.maybe Decode.string) Nothing


eventDecoder : Decoder Event
eventDecoder =
    Decode.succeed Event
        |> Pipeline.optional "name" Decode.string ""
        |> Pipeline.optional "description" (Decode.maybe Decode.string) Nothing
        |> Pipeline.optional "type" (Decode.maybe typeInfoDecoder) Nothing
        -- `setter`/`payload` are config-only enrichments; CEM JSON never carries
        -- them, so they always decode to Nothing here (populated in Model.resolve).
        |> Pipeline.hardcoded Nothing
        |> Pipeline.hardcoded Nothing


attributeDecoder : Decoder Attribute
attributeDecoder =
    let
        -- Try to get name from either "name" or "fieldName" field
        -- Prefer "name", fall back to "fieldName". A nameless attribute decodes
        -- to "" and is dropped downstream (dropNamelessMembers) rather than
        -- emitted as a bogus `unknown` setter.
        nameDecoder : Decoder String
        nameDecoder =
            Decode.oneOf
                [ Decode.field "name" Decode.string
                , Decode.field "fieldName" Decode.string
                , Decode.succeed ""
                ]
    in
    Decode.succeed Attribute
        |> Pipeline.custom nameDecoder
        |> Pipeline.optional "description" (Decode.maybe Decode.string) Nothing
        |> Pipeline.optional "type" (Decode.maybe typeInfoDecoder) Nothing
        |> Pipeline.optional "default" (Decode.maybe Decode.string) Nothing
        |> Pipeline.optional "fieldName" (Decode.maybe Decode.string) Nothing
        -- `typeOverride` never comes from the CEM JSON; it is injected from config
        -- after decoding, so it always starts `Nothing` here.
        |> Pipeline.hardcoded Nothing
        -- `elmNameOverride` likewise never comes from the CEM JSON; a synthetic
        -- attribute injected from config supplies it after decoding.
        |> Pipeline.hardcoded Nothing
        -- `global` DOES come from the CEM JSON (the manifest stamps enumerated
        -- globals); defaults False for every ordinary attribute.
        |> Pipeline.optional "global" Decode.bool False


exportDecoder : Decoder Export
exportDecoder =
    Decode.succeed Export
        |> Pipeline.required "kind" Decode.string
        |> Pipeline.required "name" Decode.string
        |> Pipeline.optional "declaration" (Decode.maybe exportDeclarationDecoder) Nothing


exportDeclarationDecoder : Decoder ExportDeclaration
exportDeclarationDecoder =
    Decode.succeed ExportDeclaration
        |> Pipeline.required "name" Decode.string


cssStateDecoder : Decoder CssState
cssStateDecoder =
    Decode.succeed CssState
        |> Pipeline.required "name" Decode.string
        |> Pipeline.optional "description" (Decode.maybe Decode.string) Nothing


superclassDecoder : Decoder Superclass
superclassDecoder =
    Decode.succeed Superclass
        |> Pipeline.required "name" Decode.string
        |> Pipeline.optional "module" (Decode.maybe Decode.string) Nothing
