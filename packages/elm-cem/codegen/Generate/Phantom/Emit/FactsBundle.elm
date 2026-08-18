module Generate.Phantom.Emit.FactsBundle exposing (..)


import Attr
import Cem
import Char
import Dict
import Docs
import Elm
import Generate.Phantom.Model as M exposing (Brand, Comp, EnumSpec, KindField, Marker(..), ResolvedSlot, SlotContent(..))
import Json.Encode as Encode
import Naming

import Generate.Phantom.Emit.AttrsRow exposing (..)
import Generate.Phantom.Emit.Shared exposing (..)


-- FACTS BUNDLE FACE C (elm-api-facts.json — M1.c)
--
-- Surfaces the same `Brand` projection `files` already reads into the
-- generated-Elm API projection docs/facts-bundle/schema.json calls Face C.
-- Provenance (versions/commits/config identity) is NOT known here — the CLI
-- wrapper stamps it after reading this file back (see bin/elm-cem.js) — so the
-- object this function emits carries every OTHER required `faceC` field and
-- omits `provenance`.


{-| Canonical join key: lowercase, non-alphanumerics stripped.
-}
factKey : String -> String
factKey s =
    s
        |> String.toLower
        |> String.filter Char.isAlphaNum


factsBundleFile : Brand -> Elm.File
factsBundleFile brand =
    { path = "elm-api-facts.generated.json"
    , contents = Encode.encode 2 (encodeFaceC brand)
    , warnings = []
    }


encodeFaceC : Brand -> Encode.Value
encodeFaceC brand =
    let
        lib =
            brand.lib

        tokenModule =
            if List.isEmpty brand.unions then
                Nothing

            else
                Just (lib ++ ".Values")

        actionModule_ =
            case brand.actions of
                Nothing ->
                    Nothing

                Just _ ->
                    Just (lib ++ ".Action")

        surfaceKeysUsed =
            brand.comps
                |> List.concatMap (\c -> Dict.keys (surfacesOf brand tokenModule actionModule_ c))
                |> dedup
                |> List.sort

        facets =
            [ { key = "top", facet = "Standard", form = "double-list", finalizer = Nothing }
            , { key = "build", facet = "Build", form = "pipeline", finalizer = Just "toElement" }
            , { key = "record", facet = "Record", form = "record-double-list", finalizer = Nothing }
            , { key = "html", facet = "Html", form = "double-list", finalizer = Nothing }
            ]
                |> List.filter (\f -> List.member f.key surfaceKeysUsed)
                |> List.map
                    (\f ->
                        Encode.object
                            [ ( "key", Encode.string f.key )
                            , ( "facet", Encode.string f.facet )
                            , ( "form", Encode.string f.form )
                            , ( "finalizer", nullableString f.finalizer )
                            ]
                    )
    in
    Encode.object
        [ ( "schemaVersion", Encode.int 1 )
        , ( "lib", Encode.string lib )
        , ( "surfaceKeys", Encode.list Encode.string surfaceKeysUsed )
        , ( "defaultSurface", Encode.string "top" )
        , ( "facets", Encode.list identity facets )
        , ( "components"
          , Encode.object
                (brand.comps |> List.map (\c -> ( c.tag, encodeComponent brand tokenModule actionModule_ c )))
          )
        ]


nullableString : Maybe String -> Encode.Value
nullableString =
    Maybe.map Encode.string >> Maybe.withDefault Encode.null


hasElOf : Comp -> Bool
hasElOf comp =
    let
        requiredSlots =
            comp.slots |> List.filter .required

        reqAttrFields =
            comp.requiredAttrs
    in
    not (List.isEmpty requiredSlots) || comp.actionCaps /= Nothing || not (List.isEmpty reqAttrFields)


surfacesOf : Brand -> Maybe String -> Maybe String -> Comp -> Dict.Dict String Encode.Value
surfacesOf brand tokenModule actionModule_ comp =
    let
        -- Per-surface module names, mirroring EXACTLY the source modules the
        -- generator emits: the strict per-component ctor surface lives in
        -- `<Lib>.Component.<Member>` (barrel imports it at ~L4729;
        -- `guardComponentModule` names it) and the phantom builder in
        -- `<Lib>.Build.<Member>` (`guardBuildModule`). The pre-R-025 flat
        -- `<Lib>.<Member>` no longer exists, so Face C MUST carry the infixed
        -- names — otherwise every downstream Elm snippet (Code Connect, docs)
        -- names a module that isn't there. `memberRef` handles home/native
        -- components (module_ = the home module) so this stays a faithful mirror.
        surfaceMemberName =
            (memberRef brand comp).module_

        topSurfaceModule =
            brand.lib ++ ".Component." ++ surfaceMemberName

        buildSurfaceModule =
            brand.lib ++ ".Build." ++ surfaceMemberName

        -- The single `component` ctor IS the top surface. Its form is the loose
        -- double-list when nothing is required, and the required-record form when
        -- a slot/attr/action is mandatory (post view/el unification — there is no
        -- separate `el` function anymore, so no separate `record` surface).
        top =
            ( "top"
            , Encode.object
                [ ( "facet", Encode.string "Standard" )
                , ( "module", Encode.string topSurfaceModule )
                , ( "entry", Encode.string "component" )
                , ( "form"
                  , Encode.string
                        (if hasElOf comp then
                            "record-double-list"

                         else
                            "double-list"
                        )
                  )
                , ( "finalizer", Encode.null )
                ]
            )

        build =
            ( "build"
            , Encode.object
                [ ( "facet", Encode.string "Build" )
                , ( "module", Encode.string buildSurfaceModule )
                , ( "entry", Encode.string "build" )
                , ( "form", Encode.string "pipeline" )
                , ( "finalizer", Encode.string "toElement" )
                ]
            )

        -- No separate `record` surface post view/el unification: the required-
        -- record form is carried by `top` (see `component`'s conditional form).
        record =
            []

        html =
            if homeOf comp == Nothing then
                [ ( "html"
                  , Encode.object
                        [ ( "facet", Encode.string "Html" )
                        , ( "module", Encode.string (brand.lib ++ ".Html") )
                        , ( "entry", Encode.string comp.resolvedCtor )
                        , ( "form", Encode.string "double-list" )
                        , ( "finalizer", Encode.null )
                        ]
                  )
                ]

            else
                []
    in
    Dict.fromList (top :: build :: record ++ html)


attrTypeKind : Attr.AttrType -> String
attrTypeKind t =
    case t of
        Attr.ABool ->
            "bool"

        Attr.ANumber ->
            "float"

        Attr.AInt ->
            "int"

        Attr.AEnum _ ->
            "enum"

        Attr.AEnumNum _ ->
            "enum"

        Attr.AEnumMap _ ->
            "enum"

        Attr.AString ->
            "string"

        Attr.ASkip _ ->
            "opaque"


encodeEnum : Brand -> Maybe String -> EnumSpec -> Encode.Value
encodeEnum brand tokenModule e =
    Encode.object
        [ ( "aliasName"
          , if e.aliasName == "" then
                Encode.null

            else
                Encode.string e.aliasName
          )
        , ( "values"
          , Encode.list
                (\raw ->
                    let
                        elmIdent =
                            tokenIdentResolved brand raw
                    in
                    Encode.object
                        [ ( "elm", Encode.string elmIdent )
                        , ( "key", Encode.string (factKey raw) )
                        , ( "token"
                          , case tokenModule of
                                Just tm ->
                                    Encode.string (tm ++ "." ++ elmIdent)

                                Nothing ->
                                    Encode.null
                          )
                        , ( "raw", Encode.string (tokenValueOf brand raw) )
                        ]
                )
                e.tokens
          )
        ]


encodeComponent : Brand -> Maybe String -> Maybe String -> Comp -> Encode.Value
encodeComponent brand tokenModule actionModule_ comp =
    let
        ref =
            memberRef brand comp

        -- The component's strict per-component surface module (`component` ctor,
        -- setters, slot placers) — `<Lib>.Component.<Member>`, mirroring the
        -- emitted source (guardComponentModule) and `surfacesOf`'s `top`
        -- surface. Consumers (the elm emitter's nested-child + slot rendering)
        -- read this `module` field to spell a component referenced INSIDE a
        -- snippet (a Button in a Dialog, the `icon` slot placer). The pre-R-025
        -- flat `<Lib>.<Member>` no longer exists, so it must carry the infix.
        moduleName =
            brand.lib ++ ".Component." ++ ref.module_

        namedSlots =
            comp.slots |> List.filter (\s -> s.name /= "unnamed")

        singularSlots =
            namedSlots |> List.filter (not << .multi)

        variadicSlots =
            namedSlots |> List.filter .multi

        attrPipeNames =
            attrsFields brand comp |> List.map (\f -> "with" ++ Naming.pascal f)

        compTopLevelNamespace =
            List.concat
                [ [ comp.resolvedCtor ]
                , comp.attrs |> List.map .elmName
                , attrPipeNames
                , comp.events |> List.map (handlerName brand)
                ]

        slotPipeNameOf s =
            let
                plain =
                    "with" ++ Naming.pascal s.name
            in
            if List.member plain compTopLevelNamespace then
                plain ++ "Slot"

            else
                plain

        pipeSetters =
            (attrsFields brand comp |> List.map (\f -> ( f, "with" ++ Naming.pascal f )))
                ++ (singularSlots |> List.map (\s -> ( s.name, slotPipeNameOf s )))
                ++ (variadicSlots |> List.map (\s -> ( s.name, slotPipeNameOf s )))

        slotKindsOf =
            comp.slots
                |> List.filterMap
                    (\s ->
                        let
                            kindString f =
                                case f.marker of
                                    MShared ->
                                        "shared:" ++ Naming.decapitalize (String.dropLeft 6 f.field)

                                    MBrand ->
                                        f.field
                        in
                        case s.content of
                            Permissive ->
                                Nothing

                            SetContent set ->
                                Just ( s.name, set.fields |> List.map kindString )

                            Fields fs ->
                                Just ( s.name, fs |> List.map kindString )
                    )

        group =
            case homeOf comp of
                Nothing ->
                    Encode.null

                Just h ->
                    Encode.object
                        [ ( "module", Encode.string (brand.lib ++ "." ++ h) )
                        , ( "constructor", Encode.string comp.resolvedCtor )
                        ]
    in
    Encode.object
        [ ( "cemTag", Encode.string comp.tag )
        , ( "component", Encode.string comp.ctor )
        , ( "module", Encode.string moduleName )
        , ( "rootNamespace", Encode.string brand.lib )
        , ( "memberPrefix"
          , if ref.prefix == "" then
                Encode.null

            else
                Encode.string ref.prefix
          )
        , ( "tokenModule", nullableString tokenModule )
        , ( "actionModule", nullableString actionModule_ )
        , ( "usesAction", Encode.bool (comp.actionCaps /= Nothing) )
        , ( "actionMap", Encode.object (comp.actionMap |> List.map (\( a, b ) -> ( a, Encode.string b ))) )
        , ( "setters", Encode.object (comp.attrs |> List.map (\a -> ( a.htmlName, Encode.string a.elmName ))) )
        , ( "setterArgTypes", Encode.object (comp.attrs |> List.map (\a -> ( a.elmName, Encode.string (attrTypeKind a.type_) ))) )
        , ( "enums", Encode.object (comp.enums |> List.map (\e -> ( e.elmName, encodeEnum brand tokenModule e ))) )
        , ( "pipeSetters", Encode.object (pipeSetters |> List.map (\( a, b ) -> ( a, Encode.string b ))) )
        , ( "eventHandlers", Encode.object (comp.events |> List.map (\e -> ( e.name, Encode.string (handlerName brand e) ))) )
        , ( "slotSetters", Encode.list Encode.string (namedSlots |> List.map (\s -> Naming.camel s.name)) )
        , ( "slotSetterMap", Encode.object (namedSlots |> List.map (\s -> ( s.name, Encode.string (Naming.camel s.name) ))) )
        , ( "slotUpgrades", Encode.list Encode.string [] )
        , ( "requiredSlots", Encode.list Encode.string (comp.slots |> List.filter .required |> List.map .name) )
        , ( "multiSlots", Encode.list Encode.string (comp.slots |> List.filter .multi |> List.map .name) )
        , ( "slotKinds", Encode.object (slotKindsOf |> List.map (\( n, ks ) -> ( n, Encode.list Encode.string ks ))) )
        , ( "requiredAttrs", Encode.list Encode.string comp.requiredAttrs )
        , ( "group", group )
        , ( "groupConstructors", Encode.list Encode.string [] )
        , ( "surfaces", Encode.object (Dict.toList (surfacesOf brand tokenModule actionModule_ comp)) )
        ]
