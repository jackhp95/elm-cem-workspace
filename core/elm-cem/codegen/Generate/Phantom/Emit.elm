module Generate.Phantom.Emit exposing (files, factsBundleFile)

{-| The phantom emitter: a pure projection of `Generate.Phantom.Model.Brand`
into the 2-shape module layout on the `elm-html-intermediate-representation`
substrate. Emits raw source strings (elm-format normalizes downstream) —
every signature references aliases, nothing is ever inlined.

`files` returns `Result (List String) (List Elm.File)`. On a post-resolution
collision that the rename rules could not resolve — two identifiers colliding in
one module's top-level namespace, a duplicate record-field, or an empty exposing
list — generation fails loudly with a message naming the module, the colliding
identifier, the raw CEM sources, and a ready-to-paste `_renames` snippet.

`factsBundleFile` is the M1.c facts-bundle Face C emitter: the SAME `Brand`
projection `files` reads, surfaced as data instead of Elm source text, so a
downstream consumer never re-measures what this module already emitted. Callers
gate it behind their own flag — see `bin/elm-cem.js`'s `--facts-bundle` handling
— so `files`' byte output is never affected by whether Face C is requested.

This module is a thin composer: every emitter is implemented in a sibling
`Generate.Phantom.Emit.*` module (one per the original file's banner-delimited
section — Guard, Shared, AttrsRow, Component, SubstrateReExports, Html,
General, Attributes, Events, Values, Kind, Home, Facts, Unsafe, Action, Aria,
FactsBundle). This file only routes `Brand` into them and assembles the
results.

@docs files, factsBundleFile

-}

import Attr
import Cem
import Char
import Dict
import Docs
import Elm
import Generate.Phantom.Emit.Action exposing (..)
import Generate.Phantom.Emit.Aria exposing (..)
import Generate.Phantom.Emit.AttrsRow exposing (..)
import Generate.Phantom.Emit.Attributes exposing (..)
import Generate.Phantom.Emit.Component exposing (..)
import Generate.Phantom.Emit.Events exposing (..)
import Generate.Phantom.Emit.Facts exposing (..)
import Generate.Phantom.Emit.FactsBundle as FactsBundle
import Generate.Phantom.Emit.General exposing (..)
import Generate.Phantom.Emit.Guard exposing (..)
import Generate.Phantom.Emit.Home exposing (..)
import Generate.Phantom.Emit.Html exposing (..)
import Generate.Phantom.Emit.Kind exposing (..)
import Generate.Phantom.Emit.Shared exposing (..)
import Generate.Phantom.Emit.SubstrateReExports exposing (..)
import Generate.Phantom.Emit.Unsafe exposing (..)
import Generate.Phantom.Emit.Values exposing (..)
import Generate.Phantom.Model as M exposing (Brand, Comp, EnumSpec, KindField, Marker(..), ResolvedSlot, SlotContent(..))
import Json.Encode as Encode
import Naming


{-| Every emitted file for the brand, or a list of collision errors.

Runs the fail-loud guard after building all files: checks that every emitted
module's exposing list is non-empty and duplicate-free, and that every record
row has unique fields. On residual collision, returns `Err` with messages naming
the module, identifier, raw CEM sources, and a ready-to-paste `_renames` snippet.

-}
files : Brand -> Result (List String) (List Elm.File)
files brand =
    let
        own =
            brand.comps |> List.filter (\c -> homeOf c == Nothing)

        homeNames =
            brand.comps
                |> List.filterMap homeOf
                |> List.foldr
                    (\h acc ->
                        if List.member h acc then
                            acc

                        else
                            h :: acc
                    )
                    []
                |> List.sort

        homeGroups =
            homeNames
                |> List.map
                    (\h ->
                        ( h, brand.comps |> List.filter (\c -> homeOf c == Just h) )
                    )

        allFiles =
            [ generalModule brand
            , attributesModule brand
            , eventsModule brand
            , kindModule brand
            ]
                -- K6: omit Values entirely when there are no unions and no tokens.
                -- An empty Values module would emit `exposing ()` which is invalid Elm.
                -- syncExposedModules in bin/elm-cem.js rebuilds elm.json from the
                -- emitted file tree, so omitting the file self-heals exposed-modules.
                ++ (if List.isEmpty brand.unions then
                        []

                    else
                        [ valuesModule brand ]
                   )
                ++ ariaModule brand
                ++ [ factsModule brand ]
                ++ unsafeModule brand
                ++ actionModule brand
                -- R3: the shared pipe-builder mechanics live once per brand.
                -- Only emitted when at least one rich per-component module
                -- exists (native/home-only brands have no `Builder`).
                ++ (if List.isEmpty own then
                        []

                    else
                        [ buildInternalModule brand, buildModule brand own ]
                   )
                -- R2: the loose elm/html-like producer layer (owns `Ir.node`),
                -- emitted only when a rich per-component shape exists.
                ++ htmlModule brand
                -- Per-component modules: the internal-types, component surface, and builder module.
                ++ List.concatMap (\comp -> [ internalTypesModule brand comp, compModule brand comp, compBuildModule brand comp ]) own
                ++ List.map (homeModule brand) homeGroups

        guardErrors =
            runGuard brand
    in
    if List.isEmpty guardErrors then
        Ok allFiles

    else
        Err guardErrors


{-| The M1.c facts-bundle Face C emitter. Delegates to
`Generate.Phantom.Emit.FactsBundle`, which holds the real implementation —
this is a thin re-export so the module's public contract (`files`,
`factsBundleFile`) stays exactly as it was before the decomposition.
-}
factsBundleFile : Brand -> Elm.File
factsBundleFile brand =
    FactsBundle.factsBundleFile brand
