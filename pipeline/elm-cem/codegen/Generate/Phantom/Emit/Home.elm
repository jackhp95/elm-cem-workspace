module Generate.Phantom.Emit.Home exposing (..)


import Attr
import Cem
import Char
import Dict
import Docs
import Elm
import Generate.Phantom.Model as M exposing (Brand, Comp, EnumSpec, KindField, Marker(..), ResolvedSlot, SlotContent(..))
import Json.Encode as Encode
import Naming
import Util exposing (deduplicateBy)

import Generate.Phantom.Emit.AttrsRow exposing (..)
import Generate.Phantom.Emit.Shared exposing (..)


-- HOME-GROUPED MODULES (native families: view-only, member-prefixed aliases)




{-| A member's Attrs field list, with the ARIA `role` field folded in
(role-gated members pin `role : <P>Roles`; un-gated get `role : Supported`
only when the brand has ARIA data at all).
-}
memberAttrsRow : Brand -> String -> Comp -> String
memberAttrsRow brand prefix comp =
    let
        base =
            attrsFields brand comp |> List.map (\f -> ( f, "Supported" ))

        withRole =
            case ( brand.aria, comp.roles ) of
                ( Just _, Just _ ) ->
                    ( "role", prefix ++ "Roles" ) :: base

                ( Just _, Nothing ) ->
                    ( "role", "Supported" ) :: base

                _ ->
                    base
    in
    "{ "
        ++ (withRole
                |> List.sortBy Tuple.first
                |> List.map (\( f, t ) -> f ++ " : " ++ t)
                |> String.join "\n    , "
           )
        ++ "\n    }"


homeModule : Brand -> ( String, List Comp ) -> Elm.File
homeModule brand ( home, members ) =
    let
        lib =
            brand.lib

        prefixOf comp =
            (memberRef brand comp).prefix

        anyShared =
            members
                |> List.any
                    (\c ->
                        c.produces.marker
                            == MShared
                            || (c.slots
                                    |> List.any
                                        (\s ->
                                            case s.content of
                                                Fields fs ->
                                                    List.any (\f -> f.marker == MShared) fs

                                                _ ->
                                                    False
                                        )
                               )
                    )

        anyRoles =
            members |> List.any (\c -> c.roles /= Nothing)

        anyBrandMarker =
            members
                |> List.any
                    (\c ->
                        (c.produces.marker == MBrand && not c.transparent)
                            || (c.slots
                                    |> List.any
                                        (\s ->
                                            case s.content of
                                                Fields fs ->
                                                    List.any (\f -> f.marker == MBrand) fs

                                                _ ->
                                                    False
                                        )
                               )
                    )

        reExportResult =
            reExportBlock brand
                (lib ++ ".Attributes")
                (members |> List.map .ctor)
                -- A home module's members share one re-export block, so a companion is
                -- suppressed here only when EVERY member declaring that attribute is
                -- `propertyOnly` for it. A mixed home (one element with a backing
                -- content attribute, one without) keeps the companion: the row is
                -- shared by design, so this is the honest limit of the mechanism.
                (dedup
                    (brand.controlled
                        |> List.filterMap
                            (\c ->
                                let
                                    owners =
                                        members
                                            |> List.filter (\comp -> comp.attrs |> List.any (\a -> a.htmlName == c.htmlName))
                                in
                                if not (List.isEmpty owners) && List.all (\comp -> List.member c.htmlName comp.propertyOnly) owners then
                                    Just c.htmlName

                                else
                                    Nothing
                            )
                    )
                )
                (members |> List.concatMap .attrs |> deduplicateBy .elmName)

        reExportNames =
            reExportResult.names

        reExportDecls =
            reExportResult.lines

        reExportNeedsValues =
            reExportResult.needsValues

        memberAliasNames comp =
            let
                p =
                    prefixOf comp
            in
            List.concat
                [ if comp.transparent then
                    []

                  else
                    [ p ++ "Is" ]
                , [ p ++ "Attrs" ]
                , comp.slots
                    |> List.filterMap
                        (\s ->
                            case ( s.name, s.content ) of
                                ( "unnamed", Fields _ ) ->
                                    Just (p ++ "Content")

                                _ ->
                                    Nothing
                        )
                , [ p ++ "ChildAdmittedBy" ]
                , case comp.admittedBy of
                    Just _ ->
                        [ p ++ "AdmittedBy" ]

                    Nothing ->
                        []
                , case comp.roles of
                    Just _ ->
                        [ p ++ "Roles" ]

                    Nothing ->
                        []
                ]

        exposeGroups =
            [ members |> List.map .ctor
            , members |> List.concatMap memberAliasNames
            , reExportNames
            ]

        memberDecls comp =
            let
                p =
                    prefixOf comp

                contentType =
                    case comp.slots |> List.filter (\s -> s.name == "unnamed") |> List.head |> Maybe.map .content of
                        Just Permissive ->
                            "childAccepts"

                        Just (SetContent set) ->
                            -- Set aliases live in <Lib>.Kind; home modules
                            -- reference them QUALIFIED (they import Kind
                            -- exposing only the markers).
                            lib ++ ".Kind." ++ set.pascal

                        Just (Fields _) ->
                            p ++ "Content"

                        Nothing ->
                            "childAccepts"

                producedType =
                    if comp.transparent then
                        "childAccepts"

                    else
                        "(" ++ p ++ "Is s)"

                returnAdm =
                    case comp.admittedBy of
                        Just _ ->
                            p ++ "AdmittedBy"

                        Nothing ->
                            "admittedBy"

                childrenType =
                    if comp.transparent then
                        "List (Element childAccepts (" ++ p ++ "ChildAdmittedBy childAdm) msg)"

                    else
                        "List (Element " ++ contentType ++ " (" ++ p ++ "ChildAdmittedBy childAdm) msg)"
            in
            List.concat
                [ if comp.transparent then
                    []

                  else
                    [ ""
                    , ""
                    , doc ("The kind row `" ++ comp.tag ++ "` produces.")
                    , "type alias " ++ p ++ "Is s ="
                    , "    { s | " ++ comp.produces.field ++ " : " ++ markerName comp.produces.marker ++ " }"
                    ]
                , [ ""
                  , ""
                  , doc ("`" ++ comp.tag ++ "`'s closed attribute-capability row.")
                  , "type alias " ++ p ++ "Attrs ="
                  , "    " ++ memberAttrsRow brand p comp
                  ]
                , comp.slots
                    |> List.concatMap
                        (\s ->
                            case ( s.name, s.content ) of
                                ( "unnamed", Fields fs ) ->
                                    [ ""
                                    , ""
                                    , doc ("The kinds `" ++ comp.tag ++ "` admits.")
                                    , "type alias " ++ p ++ "Content ="
                                    , "    " ++ kindRowCompact fs
                                    ]

                                _ ->
                                    []
                        )
                , [ ""
                  , ""
                  , doc ("The context demand `" ++ comp.tag ++ "` injects into its children.")
                  , "type alias " ++ p ++ "ChildAdmittedBy childAdm ="
                  , "    { childAdm | " ++ comp.ctor ++ " : Ctx }"
                  ]
                , case comp.admittedBy of
                    Just parents ->
                        [ ""
                        , ""
                        , doc ("The CLOSED parent contexts `" ++ comp.tag ++ "` is valid inside.")
                        , "type alias " ++ p ++ "AdmittedBy ="
                        , "    { " ++ (parents |> List.map (\pp -> pp ++ " : Ctx") |> String.join ", ") ++ " }"
                        ]

                    Nothing ->
                        []
                , case comp.roles of
                    Just roles ->
                        [ ""
                        , ""
                        , doc ("The ARIA roles `" ++ comp.tag ++ "` admits (see `" ++ lib ++ ".Aria`).")
                        , "type alias " ++ p ++ "Roles ="
                        , "    { "
                            ++ (roles |> List.sort |> List.map (\r -> roleName r ++ " : Role") |> String.join "\n    , ")
                            ++ "\n    }"
                        ]

                    Nothing ->
                        []
                , [ ""
                  , ""
                  , doc
                        ("The `"
                            ++ comp.tag
                            ++ "` element."
                            ++ (if comp.transparent then
                                    " Transparent content model: its produced kind row IS its\nchildren's accepts row — it inherits its context's content model."

                                else
                                    ""
                               )
                        )
                  , comp.ctor ++ " :"
                  , "    List (Attr " ++ p ++ "Attrs msg)"
                  , "    -> " ++ childrenType
                  , "    -> Element " ++ producedType ++ " " ++ returnAdm ++ " msg"
                  , comp.ctor ++ " attrs children ="
                  , "    Ir.fromNode (" ++ nodeHead brand ++ " \"" ++ comp.tag ++ "\" attrs (List.map HtmlIr.Element.toNode children))"
                  ]
                ]

        imports =
            List.concat
                [ [ "import HtmlIr.Attribute exposing (Attr)"
                  , "import HtmlIr.Element exposing (Element)"
                  , "import HtmlIr.Internal as Ir"
                  ]
                , [ "import HtmlIr.Kind exposing ("
                        ++ ((if anyShared then
                                [ "Shared", "Supported" ]

                             else
                                [ "Supported" ]
                            )
                                |> String.join ", "
                           )
                        ++ ")"
                  ]
                , if reExportNeedsValues then
                    [ "import HtmlIr.Value exposing (Value)"
                    , "import " ++ lib ++ ".Values"
                    ]

                  else
                    []
                , if needsJsonEncodeImport brand (members |> List.concatMap .attrs) then
                    [ "import Json.Encode" ]

                  else
                    []
                , if List.isEmpty reExportNames then
                    []

                  else
                    [ "import " ++ lib ++ ".Attributes" ]
                , [ "import "
                        ++ lib
                        ++ ".Kind exposing ("
                        ++ (((if anyBrandMarker then
                                [ "Brand", "Ctx" ]

                              else
                                [ "Ctx" ]
                             )
                                ++ (if anyRoles then
                                        [ "Role" ]

                                    else
                                        []
                                   )
                            )
                                |> List.sort
                                |> String.join ", "
                           )
                        ++ ")"
                  ]
                ]
                |> List.sort
    in
    file [ lib, "Component", home ]
        (String.join "\n"
            (List.concat
                [ [ "module " ++ lib ++ ".Component." ++ home ++ " exposing"
                  , exposeBlock exposeGroups
                  , ""
                  , "{-| The `" ++ home ++ "` element home: constructors, per-element rows, and"
                  , "co-located re-exports of the shared attributes its elements admit."
                  , ""
                  , docsBlock exposeGroups
                  , ""
                  , "-}"
                  , ""
                  ]
                , imports
                , members |> List.sortBy .ctor |> List.concatMap memberDecls
                , reExportDecls
                , [ "" ]
                ]
            )
        )



