module Generate.Types exposing
    ( ActionConfig
    , ActionWrapper
    , Config
    , ConfigResult
    , EventDecoder(..)
    , EventScalar(..)
    , ExampleRecord
    , IdWiring
    , LibraryInfo
    , Native
    , SlotKinds(..)
    , SlotSpec
    , SyntheticAttr
    )

import Cem
import Dict


{-| Information about the library extracted from the manifest
-}
type alias LibraryInfo =
    { moduleName : String
    , libraryName : String
    , componentPrefix : String
    , eventPrefix : String

    -- The interior namespace segments for the two generated layers, inserted
    -- after the library name in every generated module path (default "Html"
    -- and "Raw"; override via top-level config keys `_htmlNamespace` /
    -- `_rawNamespace`). These replace the former fixed marker segment so the
    -- un-prefixed `<Lib>.*` name stays free for the hand-written top layer.
    , htmlNamespace : String
    , rawNamespace : String

    -- The module-name prefix to use when referencing RUNTIME modules (Element,
    -- Node, Token.Core, Html.Attr, Aria, Attributes). Equals `moduleName` when
    -- ownsRuntime = True (the lib emits its own runtime copies). Equals
    -- "Markup" when ownsRuntime = False (the lib imports from markup-core).
    , runtimeBase : String

    -- Attribute elmNames present on EVERY component (the enumerated globals like
    -- dir/draggable). Their one canonical setter lives in the shared vocab; per-element
    -- modules keep them in the capability ROW but suppress the duplicate per-element
    -- setter (emitting it on every element tripled the docs size). Populated in
    -- `generateFromManifest` from the final component set; empty from `extractLibraryInfo`.
    , universalGlobalNames : List String
    }


type alias SlotSpec =
    { name : String, kinds : SlotKinds, multi : Bool, required : Bool }


{-| The scalar leaf-decoder an `EventAt` descriptor extracts, and the Elm input
type its setter therefore takes: `EInt` → `Json.Decode.int` / `Int -> msg`, etc.
-}
type EventScalar
    = EInt
    | EFloat
    | EBool
    | EString


{-| A wrapper behaviour: a trigger/action element the label is nested inside
(`opensMenu` → `<m3e-menu-trigger>`, …). Each one names a concrete component
module (`comp`) that MUST exist in the manifest for the behaviour to be emitted.
-}
type alias ActionWrapper =
    { ctor : String
    , cap : String
    , variant : String
    , comp : String
    , doc : String
    }


{-| The complete action roster decoded from the `_actions` config block.

  - `forWrappers` — wrappers taking a single `String` `for` id argument.
  - `nullaryWrappers` — wrappers taking no argument (dismiss/reset/navigate).
  - `bottomSheetComp` — the component name for the special bottom-sheet trigger
    (two ctors: `opensBottomSheet` + `opensBottomSheetWith`). `Nothing` means no
    bottom-sheet trigger in this library.
  - `dialogActionComp` — the component name for the special dialog-action wrapper
    (`dialogAction` ctor). `Nothing` means no dialog action in this library.

An absent `_actions` block is represented as `Nothing` in `ConfigResult.actions`:
the generator emits no Action module.

-}
type alias ActionConfig =
    Maybe
        { forWrappers : List ActionWrapper
        , nullaryWrappers : List ActionWrapper
        , bottomSheetComp : Maybe String
        , dialogActionComp : Maybe String
        }


{-| The declarative config (the Decl layer), merged into the CEM flags under the
reserved `_config` key by `bin/elm-cem.js`. Today: per component module name, the
accepted child KINDS for the top-layer `view` (drives typed-slot children). A
component absent from the config gets a free child row (the config-free path that
keeps the generator generic across libraries).

Three shapes (§2.9-B):

  - `Arbitrary` — spec-open content (`Element any_`), the config-free / `"arbitrary"`
    default. No child constraint.
  - `Kinds ks` — a CLOSED whitelist of specific child kind strings (the 21 structural
    families: `tr → {th,td}`, `select → {…}`). Each string is a tag name (`"option"`)
    or a `"shared:<atom>"` role.
  - `Category { name, extras, nested }` — a CONTENT-CATEGORY slot (§2.3): the child
    row is the generated `<Lib>.Category.<name>` alias
    (`Phrasing`/`Flow`/`Heading`/`Metadata`) applied to an extension argument. That
    argument is EITHER a record of dual-mode `extras` (specific extra element kinds,
    e.g. `datalist` = `Phrasing { option : Brand }`) OR — when `nested = Just c` — a
    NESTED category alias `<Lib>.Category.<c> { extras }`, so a category UNION reads as
    `Phrasing (Heading {})` (§2.4.4, e.g. `<legend>`/`<summary>` = phrasing ∪ heading).
    `name`/`nested` are PascalCase alias type names; `extras` are slot-kind strings
    (same vocabulary as `Kinds`). Most slots have `extras = []` and `nested = Nothing`.

-}
type SlotKinds
    = Arbitrary
    | Kinds (List String)
    | Category { name : String, extras : List String, nested : Maybe String }


{-| The config-declared **typed native/HTML IR** opt-in. `emit` is
the list of native HTML tags to generate as a public typed facade in
`<lib>.Native`; `semantics` maps a subset of those tags to a semantic slot-kind
(`a` → `link`, `label` → `label`) so the constructor stamps that kind rather than
returning `Element any`. The native attr setters are constrained by a built-in
HTML-natural attr→element table the generator ships (so `Native.div [ href … ]`
is a compile error), keyed off the emitted tags. `_native` is library-agnostic
mechanism; the specific tag list lives in the library's config.

`summaries` supplies the doc-comment prose — element-tag → summary and
attribute-name → summary — that the generator stamps above each `<lib>.Native`
member. The generator ships NO prose of its own (only a generic fallback), so the
descriptions are config, not built-in opinion: a library's config sources them verbatim
from MDN (see `config/slots.json` `_native.summaries`, refreshed by
`scripts/fetch-mdn-native-summaries.mjs`). A tag/attr with no entry falls back to
a generic sentence so `elm make --docs` always passes.

-}
type alias Native =
    { emit : List String
    , semantics : List ( String, String )
    , elementSummaries : List ( String, String )
    , attrSummaries : List ( String, String )
    }


type alias ExampleRecord =
    { title : String, code : String, section : Maybe String, codeRecord : Maybe String }


{-| The subset of the decoded `_config` the phantom pipeline reuses from the
legacy front-end decoder. `Generate.elm` reads only `components` (for type
overrides + synthetic attrs) and `exclude` (custom-element curation); the
remaining fields carry the other top-level config keys through the shared
decoder. The phantom emitter resolves everything else (slots, actions,
categories, brands) directly from the raw flags in `Generate.Phantom.Model`.
-}
type alias ConfigResult =
    { components : Config
    , native : Native

    -- Interior namespace segments for the two generated layers (default "Html"
    -- / "Raw"), decoded from the optional top-level `_htmlNamespace` /
    -- `_rawNamespace` config keys.
    , htmlNamespace : String
    , rawNamespace : String

    -- Declaration NAMES (e.g. "ActionElementBase") to drop from the emitted
    -- component set, from the optional top-level `_exclude` config list. CEM
    -- manifests can leak abstract Lit base classes as custom elements; this
    -- curates them out of the barrel. Default empty.
    , exclude : List String

    -- The Action roster: the library-specific wrapper behaviours (`forWrappers`
    -- + `nullaryWrappers`) declared in the `_actions` config block. An empty
    -- list means no `_actions` block was present, and no Action module is
    -- emitted. The roster lives in a library's `_actions` config block; a library without
    -- custom action wrappers simply omits `_actions`. The special bottomSheet/dialogAction wrappers are
    -- folded in separately.
    -- Default: Nothing (no Action module emitted).
    , actions : ActionConfig

    -- The HTML-natural attr→element constraint table, injected from the
    -- bundled `data/native-attrs.json` data file by `bin/elm-cem.js`.
    -- Each entry names an Elm setter, its value type, and the HTML elements
    -- it is valid on.
    -- Default: [] (no attr setters — the CLI always injects the
    -- bundled table unless overridden by `--config-from`).
    , nativeAttrTable : List { elmName : String, valueType : String, tags : List String }
    }


{-| Config-declared **for/id auto-wiring**. A sibling-slot form
component (`m3e-form-field`) performs no label↔control association itself, so the
generator wires it structurally: the `control` slot's setter takes a required
`id` and stamps `id="<id>"`, and the `label` slot's setter takes the same `id`
and stamps `for="<id>"`. Wrapping components (RadioButton) get implicit
association for free and carry NO `idWiring`. Library-agnostic: the specifics
(which component, which slots) live in the library's config file.
-}
type alias IdWiring =
    { control : String, label : String }


{-| A config-declared SYNTHETIC attribute: a settable attribute that is NOT in the
CEM, carrying a real phantom capability so it only type-checks on the component(s)
it is declared on.

This is the generic MECHANISM (issue #38); which component gets which synthetic
attribute is the config's business, so the generator stays library-agnostic. The
motivating case is `m3e-toc-ignore`, a valueless boolean marker the `m3e-toc`
component reads FROM heading elements — it is not a CEM attribute and is meaningful
only on headings, so it must be a heading-scoped typed capability rather than a
universal open-row setter.

  - `elmName` — the Elm-facing setter and phantom-capability name (e.g.
    `tocIgnore`). It is the config key.
  - `htmlName` — the HTML attribute actually stamped (e.g. `m3e-toc-ignore`).
  - `type_` — the attribute's forced classified type, reusing the same
    `AttrTypeOverride` vocabulary as `attrTypes` (`"bool"`/`"int"`/`"float"`/
    `"string"` scalar, or an enum list/map). A `"bool"` synthetic attr renders as a
    presence attribute (`m3e-toc-ignore=""` when `True`).
  - `description` — optional doc-comment prose for the generated setter.

The synthetic attr is injected into the target component's `attributes` list
(`Generate.Normalize.applySyntheticAttrs`) BEFORE any spec/capability/Token path
runs, so it flows through the normal classification chain and
picks up its setter, its phantom capability row, and its `Token` treatment for free.

-}
type alias SyntheticAttr =
    { elmName : String
    , htmlName : String
    , type_ : Cem.AttrTypeOverride
    , description : Maybe String
    }


type alias Config =
    Dict.Dict
        String
        { slots : List SlotSpec
        , extra : List ( String, String )
        , group : List ( String, String )
        , examples : List ExampleRecord
        , docMeta : List ( String, String )
        , requiredAttrs : List String
        , actionMap : List ( String, String )
        , attrTypes : List ( String, Cem.AttrTypeOverride )
        , idWiring : Maybe IdWiring
        , events : List ( String, EventDecoder )
        , staticAttrs : List ( String, String )

        -- Per-attribute property-vs-attribute override (WS1a escape hatch): a map
        -- from CEM attribute name → "attribute" | "property". Default (absent) =
        -- "attribute" for every observed scalar (D1). Only "property" flips a
        -- reflected scalar back to `Html.Attributes.property`.
        , attrForm : List ( String, String )

        -- SYNTHETIC (non-CEM) attributes to inject onto this component, each with a
        -- real phantom capability (issue #38). Default (absent) = `[]`, so the
        -- feature is opt-in and library-agnostic. See `SyntheticAttr`.
        , syntheticAttrs : List SyntheticAttr
        }


{-| A config-declared **event-payload decoder descriptor**, keyed per
component by the DOM event name (e.g. Paginator's `page`). It tells the generator
what typed payload to bake into that event's setter, replacing the default
`target.value`/`checked`/`selected` inference:

  - `EventNone` — no payload; the setter takes a plain `msg` and emits
    `Json.Decode.succeed`. This is the Tree-style "non-serialisable payload"
    case, generated mechanically rather than hand-written.
  - `EventAt path scalar` — extract a scalar at a JSON path, e.g.
    `EventAt [ "detail", "pageIndex" ] EInt` → `Json.Decode.at [ "detail",
    "pageIndex" ] Json.Decode.int`; the setter takes `Int -> msg`. The legacy
    `target.value`/`target.checked` behaviour is just `EventAt [ "target",
    "value" ] EString` / `EventAt [ "target", "checked" ] EBool`.
  - `EventDate path` — a date-carrying value at a JSON path, read back as an ISO
    string via `Json.Encode.encode` (which triggers `Date.prototype.toJSON`).
    The setter takes `String -> msg`.

`events` is library-agnostic mechanism; the specific descriptors (which event on
which component) live in the library's config.

-}
type EventDecoder
    = EventNone
    | EventAt (List String) EventScalar
    | EventDate (List String)
