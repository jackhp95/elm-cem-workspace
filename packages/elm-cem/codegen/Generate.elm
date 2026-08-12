module Generate exposing (main)

{-| Generate Elm modules from Custom Elements Manifest (phantom pipeline only).

The legacy 5-form pipeline has been retired. Set `_phantom: true` in your config
and migrate config keys as documented in `docs/config-primitives.md`.

@docs main

-}

import Cem
import Elm
import Gen.CodeGen.Generate as Generate
import Generate.Config exposing (decodeConfigResult, extractComponents, extractLibraryInfo)
import Generate.Normalize exposing (applySyntheticAttrs, applyTypeOverrides)
import Generate.Phantom.Emit
import Generate.Phantom.Model
import Generate.SharedAttrs exposing (componentModuleName)
import Generate.Types exposing (LibraryInfo)
import Json.Decode


main : Program Json.Decode.Value () ()
main =
    Generate.withFeedback
        (\flags ->
            case Json.Decode.decodeValue Cem.manifestDecoder flags of
                Ok manifest ->
                    if Generate.Phantom.Model.decodePhantomFlag flags then
                        generatePhantom flags manifest

                    else
                        Err
                            [ { title = "legacy pipeline retired"
                              , description = "The 5-form legacy pipeline has been removed. Set `_phantom: true` in your `_config` block and migrate your config keys as described in docs/config-primitives.md."
                              }
                            ]

                Err e ->
                    Err
                        [ { title = "Error decoding flags"
                          , description = Json.Decode.errorToString e
                          }
                        ]
        )


{-| The phantom pipeline (`_config._phantom = true`): resolve the primitive
config against the CEM and project the 2-shape layout onto the IR substrate.
Config errors (unknown kind/set refs, R1 violations) fail the run loudly.
-}
generatePhantom :
    Json.Decode.Value
    -> Cem.Manifest
    -> Result (List { title : String, description : String }) { info : List String, files : List Elm.File }
generatePhantom flags manifest =
    let
        libraryInfo =
            extractLibraryInfo manifest

        -- Reuse the legacy normalization front-end wholesale: custom-element
        -- filtering, tag merge, attr-type normalization, plus the config-fed
        -- type overrides and synthetic attrs (the migrated phantom config
        -- keeps those keys under their legacy names, so the legacy decoder
        -- still reads them). Then RENAME each declaration to its module name
        -- (`m3e-button` → `Button`) so phantom config keys and kind refs
        -- resolve; raw CEM class names (`M3eButtonElement`) never match.
        -- Rename ONLY library-prefixed class names ("M3eButtonElement" →
        -- "Button"); clean declaration names (native manifests, incl. the R2
        -- split entries like PictureSource whose tag repeats) stay authoritative.
        rename d =
            if String.startsWith libraryInfo.moduleName d.name then
                { d | name = componentModuleName libraryInfo d }

            else
                d

        -- A malformed `_config` FAILS THE RUN. It used to fall back to the raw
        -- manifest declarations, which threw away the whole legacy front-end in
        -- silence: `_exclude` went inert (leaked base classes kept emitting), every
        -- `attrTypes` override stopped applying, and every synthetic attr vanished —
        -- from ONE typo anywhere in the config, with a successful exit code and no
        -- diagnostic. It also made the decoder's own fail-loud branches unreachable
        -- (`optStrict`, the unknown-scalar-kind rejection, the empty-enum rejection):
        -- each of them dutifully returned an `Err` that this arm discarded.
        --
        -- Nothing legitimate needs the fallback. A manifest with NO `_config` decodes
        -- to the empty config (`decodeConfigResult`'s `Ok Nothing` arm), so the
        -- config-free path is already an `Ok`; only a PRESENT-but-broken config reaches
        -- here, and for that "carry on with a silently different brand" is the worst of
        -- the available answers.
        declarationsResult =
            decodeConfigResult flags
                |> Result.map
                    (\legacyConfig ->
                        extractComponents legacyConfig.exclude manifest
                            |> applyTypeOverrides libraryInfo legacyConfig.components
                            |> applySyntheticAttrs libraryInfo legacyConfig.components
                            |> List.map rename
                    )
    in
    case declarationsResult of
        Err configError ->
            Err [ { title = "config decode error", description = configError } ]

        Ok declarations ->
            case Generate.Phantom.Model.resolve libraryInfo.moduleName libraryInfo.eventPrefix flags declarations of
                Ok brand ->
                    case Generate.Phantom.Emit.files brand of
                        Ok emittedFiles ->
                            -- Thread K2/K3 collapse notes through the info channel (stdout).
                            -- Notes are deterministic (stable order from Model.resolve).
                            -- Emitted file bytes are unaffected by notes.
                            Ok { info = brand.collapseNotes, files = emittedFiles }

                        Err collisionErrors ->
                            Err (List.map (\e -> { title = "phantom collision error", description = e }) collisionErrors)

                Err errors ->
                    Err (List.map (\e -> { title = "phantom config error", description = e }) errors)
