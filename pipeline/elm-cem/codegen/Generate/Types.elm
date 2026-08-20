module Generate.Types exposing
    ( Config
    , ConfigResult
    , FamiliesConfig
    , FamilyMember
    , FamilyPackageConfig
    , FamilySpec
    , IconModuleConfig
    , IconPackageConfig
    , LibraryInfo
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
    }


{-| The subset of the decoded `_config` the phantom pipeline actually reuses:
`components` (for type overrides + synthetic attrs) and `exclude`
(custom-element curation). The phantom emitter resolves everything else
(slots, actions, categories, brands, namespaces) directly from the raw flags
in `Generate.Phantom.Model` — see `Generate.Config.decodeConfigResult`'s doc
comment for the full list and why the surface stops here.
-}
type alias ConfigResult =
    { components : Config

    -- Declaration NAMES (e.g. "ActionElementBase") to drop from the emitted
    -- component set, from the optional top-level `_exclude` config list. CEM
    -- manifests can leak abstract Lit base classes as custom elements; this
    -- curates them out of the barrel. Default empty.
    , exclude : List String

    -- G1 (generator-consolidation): the `_iconModule`/`_families` config
    -- blocks, decoded so the Elm pass can eventually emit `<Lib>.Icon`/
    -- `<Lib>.Family.*` itself (G2/G3) instead of the JS generators
    -- re-JSON-parsing the same config files a second time. `Nothing` when the
    -- key is absent — both are opt-in, mirroring the JS generators' own
    -- silent no-op when their config block is missing.
    , iconModule : Maybe IconModuleConfig
    , families : Maybe FamiliesConfig
    }


{-| `_iconModule` config (G1): drives `bin/gen-icon-module.js` today, and will
drive `Generate.Phantom.Emit.IconModule` once G2 ports it. `names` is NOT part
of the hand-authored JSON shape — it is injected into flags by the CLI shell
(`bin/elm-cem.js`) from the file `catalogFrom` names, since Elm's single-shot
`main` has no filesystem access to read `catalogFrom` itself (research §3).
Until that CLI-side injection exists (G2), `names` decodes to `Nothing`.
-}
type alias IconModuleConfig =
    { lib : String
    , iconComp : String
    , catalogFrom : String
    , shape : String
    , tag : String
    , iconFamily : String
    , attribution : Maybe String
    , package : Maybe IconPackageConfig
    , names : Maybe (List String)
    }


{-| The standalone-package half of `_iconModule`/`_families` config: mirrors
the JS generators' `package: { dir, name, summary, version, deps }` shape
(`bin/gen-icon-module.js`, `bin/gen-family-package.js`). `licenseText` is NOT
part of the hand-authored JSON shape — like `IconModuleConfig.names`, it is
injected into flags by the CLI shell (`bin/elm-cem.js`'s
`injectPackageLicense`) from the elm-m3e workspace root's `LICENSE` file,
since Elm's single-shot `main` has no filesystem access to read it itself.
-}
type alias IconPackageConfig =
    { dir : String
    , name : String
    , summary : String
    , version : String
    , deps : List ( String, String )
    , licenseText : Maybe String
    }


{-| `_families` config (G1): drives `bin/gen-family-package.js` today, and
will drive `Generate.Phantom.Emit.FamilyPackage` once G3 ports it.
-}
type alias FamiliesConfig =
    { lib : String
    , namespace : String
    , componentsFrom : Maybe String
    , package : IconPackageConfig
    , families : List ( String, FamilySpec )
    }


{-| One family's spec: an optional root re-export name plus its members
(each a component name and where it re-exports from).
-}
type alias FamilySpec =
    { root : Maybe String
    , members : List FamilyMember
    }


type alias FamilyMember =
    { component : String
    , path : String
    }


{-| Alias kept distinct from `IconPackageConfig` at the type level per the
plan's Interfaces block, even though the shape is identical today — `_families`
and `_iconModule` are independent config surfaces and this keeps them free to
diverge later without a breaking rename.
-}
type alias FamilyPackageConfig =
    IconPackageConfig


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


{-| Per component module name: the two `_config` sub-keys the phantom
pipeline reuses via the legacy front-end (`Generate.Normalize.applyTypeOverrides`
/ `applySyntheticAttrs`). Everything else the legacy `_config` shape used to
carry per component (`slots`, `group`, `examples`, `docMeta`, `requiredAttrs`,
`actionMap`, `idWiring`, `events`, `staticAttrs`, `attrForm`) is decoded
independently, directly from the raw flags, by `Generate.Phantom.Model`
(its own `RawComp`) — see `Generate.Config.decodeConfigResult`'s doc comment.
-}
type alias Config =
    Dict.Dict
        String
        { attrTypes : List ( String, Cem.AttrTypeOverride )

        -- SYNTHETIC (non-CEM) attributes to inject onto this component, each with a
        -- real phantom capability (issue #38). Default (absent) = `[]`, so the
        -- feature is opt-in and library-agnostic. See `SyntheticAttr`.
        , syntheticAttrs : List SyntheticAttr
        }
