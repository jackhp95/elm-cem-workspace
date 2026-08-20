module Generate.Phantom.Emit.IconModule exposing (files)

{-| Port of bin/gen-icon-module.js (G2, 2026-08-19 generator-consolidation
research). Emits `<lib>.Icon` (and, when `_iconModule.package` is configured,
a standalone package tree) as `Elm.File`s, from config decoded up-front in
Generate.Config (no filesystem access here — the icon catalog names arrive
pre-merged into `IconModuleConfig.names` by the CLI shell, since Elm's
single-shot `main` cannot read `catalogFrom` itself; see
`bin/elm-cem.js`'s `injectIconCatalog`).

`_iconModule.lib` is required (the JS predecessor's `_brand` fallback is
dropped — no shipped brand config relies on it: `brands/m3e`'s `_iconModule`
always sets `"lib": "M3e"` explicitly, and `Generate.Config`'s decoder
requires `lib`, matching gen-icon-module.js's de facto behavior for every
real config).

@docs files

-}

import Dict exposing (Dict)
import Elm
import Generate.Types exposing (IconModuleConfig, IconPackageConfig)
import Set exposing (Set)


{-| Elm reserved words — any identifier that exactly matches one of these must
be renamed. Sourced from elm/compiler Parse/Keyword.hs (all reserved
keywords), plus two top-level names this module emits itself (`custom`, and —
in the "names" shape — the `icon` renderer) so they must not collide.
-}
elmReserved : Set String
elmReserved =
    Set.fromList
        [ "if"
        , "then"
        , "else"
        , "case"
        , "of"
        , "let"
        , "in"
        , "type"
        , "module"
        , "where"
        , "import"
        , "exposing"
        , "as"
        , "port"
        , "custom"
        , "icon"
        ]


snakeToCamel : String -> String
snakeToCamel snake =
    case String.split "_" snake of
        [] ->
            ""

        first :: rest ->
            first ++ String.concat (List.map upperFirst rest)


upperFirst : String -> String
upperFirst s =
    case String.uncons s of
        Nothing ->
            s

        Just ( c, tail ) ->
            String.cons (Char.toUpper c) tail


{-| Convert a snake\_case ligature name to an Elm identifier. See
gen-icon-module.js:55-79 for the full rules; ported verbatim.
-}
toElmIdentifier : String -> String
toElmIdentifier snake =
    let
        hasLeadingDigit =
            String.uncons snake
                |> Maybe.map (\( c, _ ) -> Char.isDigit c)
                |> Maybe.withDefault False

        camel =
            if hasLeadingDigit then
                "icon" ++ snakeToCamel snake

            else
                snakeToCamel snake
    in
    if Set.member camel elmReserved then
        camel ++ "_"

    else
        camel


{-| Returns `Err collisionMessage` on the first identifier collision
(mirrors gen-icon-module.js's loud `process.exit(1)`, gen-icon-module.js:140-152).
-}
checkCollisions : List String -> Result String (Dict String String)
checkCollisions names =
    List.foldl
        (\snake acc ->
            case acc of
                Err e ->
                    Err e

                Ok seen ->
                    let
                        id_ =
                            toElmIdentifier snake
                    in
                    case Dict.get id_ seen of
                        Just firstSnake ->
                            Err
                                ("elm-cem gen-icon-module: COLLISION — \""
                                    ++ snake
                                    ++ "\" and \""
                                    ++ firstSnake
                                    ++ "\" both map to Elm identifier \""
                                    ++ id_
                                    ++ "\". Fix the identifier mapping in Generate.Phantom.Emit.IconModule before proceeding."
                                )

                        Nothing ->
                            Ok (Dict.insert id_ snake seen)
        )
        (Ok Dict.empty)
        names


{-| Format a function signature: `name : T1 -> T2 -> ... -> TResult` with
each type on its own indented line after the first. Port of
gen-icon-module.js:235-243.
-}
formatSig : String -> List String -> String -> String
formatSig name firstArgTypes returnType =
    let
        allTypes =
            firstArgTypes ++ [ returnType ]

        lines =
            case allTypes of
                [] ->
                    [ name ++ " :" ]

                first :: rest ->
                    (name ++ " :") :: ("    " ++ first) :: List.map (\t -> "    -> " ++ t) rest
    in
    String.join "\n" lines


{-| The element producer itself — identical IR call regardless of shape; the
only difference is where the ligature string comes from. Port of
gen-icon-module.js:248-249.
-}
produce : String -> String -> String
produce tag ligatureExpr =
    "    Ir.fromNode (Ir.node \"" ++ tag ++ "\" (Ir.attribute \"name\" " ++ ligatureExpr ++ " :: attrs) (List.map HtmlIr.Element.toNode kids))"


sigAttrs : String
sigAttrs =
    "List (Attr attrs msg)"


sigChildren : String
sigChildren =
    "List (Element children childAdmittedBy msg)"


sigReturn : String
sigReturn =
    "Element produced admittedBy msg"


{-| Full port of gen-icon-module.js:124-316's `generateIconModule`. Returns
`Err` on the same two loud-failure conditions the JS raised via
`process.exit(1)` (unknown shape, missing tag/iconFamily are enforced by the
decoder/caller already — only the identifier-collision failure remains
reachable here).
-}
generateIconModule : String -> List String -> String -> String -> String -> Maybe String -> Result String String
generateIconModule lib names shape tag iconFamily attribution =
    let
        attributionLines =
            String.split "\n" (Maybe.withDefault ("Source: " ++ iconFamily ++ " ligature names.") attribution)

        namesShape =
            shape == "names"
    in
    checkCollisions names
        |> Result.map
            (\_ ->
                let
                    allIds =
                        List.map toElmIdentifier names

                    exposingList =
                        (if namesShape then
                            [ "Name", "icon", "custom" ] ++ allIds

                         else
                            "custom" :: allIds
                        )
                            |> String.join "\n    , "

                    moduleLine =
                        "module " ++ lib ++ ".Icon exposing\n    ( " ++ exposingList ++ "\n    )"

                    headlineDoc =
                        if namesShape then
                            [ "{-| Type-safe icon names for the full " ++ iconFamily ++ " ligature set."
                            , ""
                            , "Every ligature is a `Name` value, and `icon` renders one as an `" ++ tag ++ "`"
                            , "element with the ligature pre-filled as the `name` attribute, using the IR"
                            , "directly — no components dependency. So"
                            , "`" ++ lib ++ ".Icon.icon " ++ lib ++ ".Icon.menu attrs kids` emits an `" ++ tag ++ "` element"
                            , "with `name=\"menu\"` prepended to `attrs`."
                            , ""
                            , "`Name` is an ordinary opaque value, so an icon can be stored in a model, held"
                            , "in a list, or taken as a function argument."
                            , ""
                            , "Use `custom` for any ligature not enumerated here — teams updating the"
                            , "underlying font or using app-specific icons should reach for `custom`."
                            , ""
                            , "Elm's dead-code elimination prunes every name you do not reference, so"
                            , "importing this module has no size cost beyond what you use."
                            ]

                        else
                            [ "{-| Type-safe icon element helpers for the full " ++ iconFamily ++ " ligature set."
                            , ""
                            , "Each helper produces an `" ++ tag ++ "` element with the icon name pre-filled"
                            , "as the `name` attribute, using the IR directly — no components dependency."
                            , "So `" ++ lib ++ ".Icon.menu attrs kids` emits an `" ++ tag ++ "` element with"
                            , "`name=\"menu\"` prepended to `attrs`."
                            , ""
                            , "Use `custom` for any name not enumerated here — teams updating the underlying"
                            , "font or using app-specific icons should reach for `custom`."
                            , ""
                            , "Elm's dead-code elimination prunes every helper you do not call, so importing"
                            , "this module has no size cost beyond what you use."
                            ]

                    attributionTailLine =
                        case List.reverse attributionLines of
                            [] ->
                                String.fromInt (List.length names) ++ " icons total."

                            last :: _ ->
                                last ++ " " ++ String.fromInt (List.length names) ++ " icons total."

                    attributionLeadLines =
                        case List.reverse attributionLines of
                            [] ->
                                []

                            _ :: rest ->
                                List.reverse rest

                    docsLine =
                        if namesShape then
                            "@docs Name, icon, custom, " ++ String.join ", " allIds

                        else
                            "@docs custom, " ++ String.join ", " allIds

                    moduleDoc =
                        (headlineDoc
                            ++ [ "" ]
                            ++ attributionLeadLines
                            ++ [ attributionTailLine, "", docsLine, "-}" ]
                        )
                            |> String.join "\n"

                    imports =
                        [ "import Html"
                        , "import HtmlIr.Attribute exposing (Attr)"
                        , "import HtmlIr.Element exposing (Element)"
                        , "import HtmlIr.Internal as Ir"
                        , "import HtmlIr.Node"
                        ]
                            |> String.join "\n"

                    preambleDecls =
                        if namesShape then
                            [ [ "{-| An opaque " ++ iconFamily ++ " ligature name."
                              , ""
                              , "Construct one from the enumerated values below, or with `custom`."
                              , "-}"
                              , "type Name"
                              , "    = Name String"
                              ]
                                |> String.join "\n"
                            , [ "{-| Render an icon `Name` as an `" ++ tag ++ "` element."
                              , "-}"
                              , formatSig "icon" [ "Name", sigAttrs, sigChildren ] sigReturn
                              , "icon (Name ligature) attrs kids ="
                              , produce tag "ligature"
                              ]
                                |> String.join "\n"
                            , [ "{-| Use any ligature name not enumerated below — for teams updating the"
                              , "underlying font or using app-specific icons."
                              , "-}"
                              , "custom : String -> Name"
                              , "custom ="
                              , "    Name"
                              ]
                                |> String.join "\n"
                            ]

                        else
                            [ [ "{-| Use any ligature name not enumerated above — for teams updating the"
                              , "underlying font or using app-specific icons."
                              , "-}"
                              , formatSig "custom" [ "String", sigAttrs, sigChildren ] sigReturn
                              , "custom ligature attrs kids ="
                              , produce tag "ligature"
                              ]
                                |> String.join "\n"
                            ]

                    iconDecls =
                        if namesShape then
                            names
                                |> List.map
                                    (\snake ->
                                        let
                                            id_ =
                                                toElmIdentifier snake
                                        in
                                        [ "{-| The `" ++ snake ++ "` Material Symbol icon. -}"
                                        , id_ ++ " : Name"
                                        , id_ ++ " ="
                                        , "    Name \"" ++ snake ++ "\""
                                        ]
                                            |> String.join "\n"
                                    )

                        else
                            names
                                |> List.map
                                    (\snake ->
                                        let
                                            id_ =
                                                toElmIdentifier snake
                                        in
                                        [ "{-| The `" ++ snake ++ "` Material Symbol icon. -}"
                                        , formatSig id_ [ sigAttrs, sigChildren ] sigReturn
                                        , id_ ++ " attrs kids ="
                                        , produce tag ("\"" ++ snake ++ "\"")
                                        ]
                                            |> String.join "\n"
                                    )

                    sections =
                        [ moduleLine, moduleDoc, imports ] ++ preambleDecls ++ iconDecls
                in
                String.join "\n\n\n" sections ++ "\n"
            )


{-| Write the standalone `elm-m3e-icons`-shaped package tree at nested paths
relative to the SAME `--output` root — `Elm.File.path` is unconstrained
(research §3); elm-codegen's writer does `path.join(output_dir, file.path)`
with no traversal guard (research §5 Risk 2), so `"../<pkg.dir>/..."`-shaped
paths land one level above `--output`, exactly like
gen-icon-module.js:502-505's `repoRoot = path.dirname(outDir)`. Port of
gen-icon-module.js:318-416's `writePackageTree`. README/LICENSE
("write-only-if-absent" in the JS) are DELIBERATELY DROPPED here — Elm has no
filesystem access to check "already exists", and (per the same behavior
simplification Task 7 makes for family packages) elm-codegen's writer always
overwrites on every run anyway, so an Elm port emitting them unconditionally
is a strict behavior narrowing with no byte-equality impact on `elm.json`,
the one package-tree file this module's golden test governs.
-}
iconPackageTreeFiles : IconPackageConfig -> String -> String -> Elm.File
iconPackageTreeFiles pkg lib src =
    let
        libParts =
            String.split "." lib

        modPath =
            "../" ++ pkg.dir ++ "/src/" ++ String.join "/" libParts ++ "/Icon.elm"
    in
    { path = modPath, contents = src, warnings = [] }


iconPackageElmJsonFile : IconPackageConfig -> String -> Elm.File
iconPackageElmJsonFile pkg lib =
    let
        depsJson =
            pkg.deps
                |> List.map (\( k, v ) -> "        \"" ++ k ++ "\": \"" ++ v ++ "\"")
                |> String.join ",\n"

        contents =
            "{\n"
                ++ "    \"type\": \"package\",\n"
                ++ "    \"name\": \""
                ++ pkg.name
                ++ "\",\n"
                ++ "    \"summary\": \""
                ++ pkg.summary
                ++ "\",\n"
                ++ "    \"license\": \"BSD-3-Clause\",\n"
                ++ "    \"version\": \""
                ++ pkg.version
                ++ "\",\n"
                ++ "    \"exposed-modules\": [\n        \""
                ++ lib
                ++ ".Icon\"\n    ],\n"
                ++ "    \"elm-version\": \"0.19.0 <= v < 0.20.0\",\n"
                ++ "    \"dependencies\": {\n"
                ++ depsJson
                ++ "\n    },\n"
                ++ "    \"test-dependencies\": {}\n"
                ++ "}\n"
    in
    { path = "../" ++ pkg.dir ++ "/elm.json", contents = contents, warnings = [] }


{-| Emit `<lib>.Icon` plus, when `package` is configured, the standalone
package tree (module + elm.json), as `Elm.File`s. `Nothing` config is a
silent no-op, mirroring gen-icon-module.js's own opt-in behavior when
`_iconModule` is absent.
-}
files : Maybe IconModuleConfig -> Result String (List Elm.File)
files maybeConfig =
    case maybeConfig of
        Nothing ->
            Ok []

        Just cfg ->
            case cfg.names of
                Nothing ->
                    Err "Generate.Phantom.Emit.IconModule: _iconModule.names is empty — the CLI shell must inject the icon catalog into flags before generation (see bin/elm-cem.js's injectIconCatalog)."

                Just names ->
                    generateIconModule cfg.lib names cfg.shape cfg.tag cfg.iconFamily cfg.attribution
                        |> Result.map
                            (\src ->
                                let
                                    libParts =
                                        String.split "." cfg.lib

                                    mainFile =
                                        { path = String.join "/" libParts ++ "/Icon.elm", contents = src, warnings = [] }

                                    packageFiles =
                                        case cfg.package of
                                            Nothing ->
                                                []

                                            Just pkg ->
                                                [ iconPackageTreeFiles pkg cfg.lib src
                                                , iconPackageElmJsonFile pkg cfg.lib
                                                ]
                                in
                                mainFile :: packageFiles
                            )
