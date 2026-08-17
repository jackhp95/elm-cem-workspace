module Doc.Fold exposing (Node, buildForest, serialize, viewWith)

{-| Auto-derived code folding for the docs' code blocks.

The render seam (`Doc.codeBlock`) can only hand us a **raw code string** — the
`SyntaxHighlight.HCode`/`Line` internals are opaque, so we cannot fold a
pre-highlighted block. Instead we compute a **fold tree from the raw string**
here (pure, unit-tested) and assemble nested native `<details>` ourselves,
highlighting **per line** with a caller-supplied `String -> Html msg`
(`SyntaxHighlight.<lang> line |> toInlineHtml`, keeping the `.elmshN` token
classes; caller falls back to plain `text` on `Err`).

Two derivations, both purely from indentation/text (no generator markers, so the
result is identical across every surface tab):

  - **Indentation chevron folds** (Phase 1): a line whose next non-blank line is
    more deeply indented is a fold _header_; its body spans following lines until
    indentation returns to `<=` the header indent. Regions nest. Every fold
    renders **open** by default; `defaultCollapseThreshold` is part of the
    fold-tree data model exercised by `serialize`/`FoldTest.elm` and does not
    drive the rendered `open` state.

  - **Repeated-sibling `…` folds** (Phase 2): a run of `>= 3` consecutive
    single-line siblings at equal indent whose leading construct is identical
    (e.g. `M3e.Option.component …` or `<m3e-option …`) collapses into one `…`
    affordance. The detector is deliberately conservative — it groups only when
    the leading `M3e.<name>` / `<tag` head matches exactly, so distinct lines
    (differing slot names, args, etc.) are never mis-collapsed. If real examples
    ever show a false positive, drop `coalesceSiblings` from `buildForest` and
    Phase 1 still stands on its own.

`buildForest`/`Node`/`serialize` are exposed for the unit tests (`tests/FoldTest.elm`).

-}

import Html exposing (Html)
import Html.Attributes exposing (attribute, class)


{-| A node in the fold tree.

  - `Leaf` — a plain code line, kept verbatim (with its leading indentation).
  - `Fold` — an indentation region: a header line + a nested body; `collapsed`
    is a data-model flag exercised by `serialize`/`FoldTest.elm`, not the
    rendered `open` state (folds render open by default).
  - `Siblings` — a `>= 3` run of repeated single-line siblings, rendered as `…`.

-}
type Node
    = Leaf String
    | Fold { header : String, body : List Node, collapsed : Bool }
    | Siblings (List String)


{-| A fold whose body has more than this many raw lines is flagged `collapsed` in
the fold-tree data model. Folds now render open by default, so this threshold no
longer drives the rendered `open` state — it is retained only for the
`serialize`/`FoldTest.elm` debug format.
-}
defaultCollapseThreshold : Int
defaultCollapseThreshold =
    6



-- FOLD-TREE COMPUTATION (pure)


type alias ILine =
    { indent : Int, raw : String, blank : Bool }


toILine : String -> ILine
toILine raw =
    { indent = leadingSpaces raw
    , raw = raw
    , blank = String.trim raw == ""
    }


{-| Build the fold forest from a raw (already whole-block-trimmed) code string.
-}
buildForest : String -> List Node
buildForest src =
    String.lines src
        |> List.map toILine
        |> consume
        |> coalesceSiblings


consume : List ILine -> List Node
consume lines =
    case lines of
        [] ->
            []

        l :: rest ->
            if l.blank then
                Leaf l.raw :: consume rest

            else
                case nextNonBlankIndent rest of
                    Just ni ->
                        if ni > l.indent then
                            let
                                ( bodyLines, after ) =
                                    splitBody l.indent rest
                            in
                            Fold
                                { header = l.raw
                                , body = coalesceSiblings (consume bodyLines)
                                , collapsed = List.length bodyLines > defaultCollapseThreshold
                                }
                                :: consume after

                        else
                            Leaf l.raw :: consume rest

                    Nothing ->
                        Leaf l.raw :: consume rest


{-| The maximal prefix of `lines` belonging to a header at indent `owner`: any
line that is blank or more deeply indented than the header. Stops at the first
non-blank line that returns to `<= owner`.
-}
splitBody : Int -> List ILine -> ( List ILine, List ILine )
splitBody owner lines =
    case lines of
        [] ->
            ( [], [] )

        l :: rest ->
            if l.blank || l.indent > owner then
                let
                    ( body, after ) =
                        splitBody owner rest
                in
                ( l :: body, after )

            else
                ( [], lines )


nextNonBlankIndent : List ILine -> Maybe Int
nextNonBlankIndent lines =
    case lines of
        [] ->
            Nothing

        l :: rest ->
            if l.blank then
                nextNonBlankIndent rest

            else
                Just l.indent


leadingSpaces : String -> Int
leadingSpaces raw =
    String.length raw - String.length (String.trimLeft raw)



-- PHASE 2: repeated-sibling coalescing


{-| Fold consecutive `Leaf` siblings that share a leading construct (>= 3) into a
single `Siblings` run. Applied at every tree level.
-}
coalesceSiblings : List Node -> List Node
coalesceSiblings nodes =
    case nodes of
        [] ->
            []

        (Leaf raw) :: _ ->
            case siblingHead raw of
                Just head ->
                    let
                        ( run, rest ) =
                            spanMatchingLeaves head (leadingSpaces raw) nodes
                    in
                    if List.length run >= 3 then
                        Siblings run :: coalesceSiblings rest

                    else
                        Leaf raw :: coalesceSiblings (List.drop 1 nodes)

                Nothing ->
                    Leaf raw :: coalesceSiblings (List.drop 1 nodes)

        other :: rest ->
            other :: coalesceSiblings rest


{-| Collect the leading `Leaf` nodes whose sibling-head and indent match, and
return them (raw strings) plus the remaining nodes.
-}
spanMatchingLeaves : String -> Int -> List Node -> ( List String, List Node )
spanMatchingLeaves head indent nodes =
    case nodes of
        (Leaf raw) :: rest ->
            if siblingHead raw == Just head && leadingSpaces raw == indent then
                let
                    ( more, after ) =
                        spanMatchingLeaves head indent rest
                in
                ( raw :: more, after )

            else
                ( [], nodes )

        _ ->
            ( [], nodes )


{-| The normalized leading construct of a line, used to match repeated siblings.
Strips a leading list `[`/`,` separator, then captures either an XML/HTML opening
tag (`<m3e-option`) or an Elm value head (`M3e.Option.component`). `Nothing` if the
line has no such construct (closing brackets, punctuation) — those never group.
-}
siblingHead : String -> Maybe String
siblingHead raw =
    let
        afterSep : String
        afterSep =
            case String.uncons (String.trimLeft raw) of
                Just ( c, rest ) ->
                    if c == '[' || c == ',' then
                        String.trimLeft rest

                    else
                        String.trimLeft raw

                Nothing ->
                    ""
    in
    case String.uncons afterSep of
        Just ( '<', rest ) ->
            let
                tag : String
                tag =
                    takeWhile isTagChar rest
            in
            if String.length tag >= 2 && startsWithAlpha tag then
                Just ("<" ++ tag)

            else
                Nothing

        _ ->
            let
                ident : String
                ident =
                    takeWhile isIdentChar afterSep
            in
            if String.length ident >= 2 && startsWithAlpha ident then
                Just ident

            else
                Nothing


isTagChar : Char -> Bool
isTagChar c =
    Char.isAlphaNum c || c == '-' || c == '_'


isIdentChar : Char -> Bool
isIdentChar c =
    Char.isAlphaNum c || c == '.' || c == '_'


startsWithAlpha : String -> Bool
startsWithAlpha s =
    case String.uncons s of
        Just ( c, _ ) ->
            Char.isAlpha c

        Nothing ->
            False


takeWhile : (Char -> Bool) -> String -> String
takeWhile pred s =
    String.foldl
        (\c ( acc, stop ) ->
            if stop || not (pred c) then
                ( acc, True )

            else
                ( acc ++ String.fromChar c, False )
        )
        ( "", False )
        s
        |> Tuple.first



-- RENDER: nested <details> with per-line highlight


{-| Render the fold tree of `src` into nested native `<details>`, highlighting
each line with `hl` (a `String -> Html msg`; the caller supplies the per-line
`SyntaxHighlight.<lang> line |> toInlineHtml`, falling back to plain `text`).
-}
viewWith : (String -> Html msg) -> String -> Html msg
viewWith hl src =
    Html.div [ class "cf-root" ]
        (buildForest src |> List.map (renderNode hl))


renderNode : (String -> Html msg) -> Node -> Html msg
renderNode hl node =
    case node of
        Leaf raw ->
            renderLine hl raw

        Fold f ->
            Html.node "details"
                (class "cf-fold" :: openAttr True)
                [ Html.node "summary" [ class "cf-summary" ] [ hl f.header ]
                , Html.div [ class "cf-body" ] (List.map (renderNode hl) f.body)
                ]

        Siblings raws ->
            let
                indent : String
                indent =
                    String.repeat (List.head raws |> Maybe.map leadingSpaces |> Maybe.withDefault 0) " "
            in
            Html.node "details"
                (class "cf-fold cf-sib" :: openAttr True)
                [ Html.node "summary"
                    [ class "cf-summary cf-ellipsis" ]
                    [ Html.text (indent ++ "…") ]
                , Html.div [ class "cf-body" ] (List.map (renderLine hl) raws)
                ]


renderLine : (String -> Html msg) -> String -> Html msg
renderLine hl raw =
    if String.trim raw == "" then
        -- Preserve blank lines with a non-collapsing height.
        Html.div [ class "cf-leaf" ] [ Html.text "\u{00A0}" ]

    else
        Html.div [ class "cf-leaf" ] [ hl raw ]


openAttr : Bool -> List (Html.Attribute msg)
openAttr isOpen =
    if isOpen then
        [ attribute "open" "" ]

    else
        []



-- TEST SUPPORT


{-| A compact, content-bearing serialization of a fold tree, for unit tests.

  - `Leaf s` -> `L{trimmed}`
  - `Fold` -> `F[..]` (or `F*[..]` when collapsed)
  - `Siblings run` -> `S<count>`

-}
serialize : List Node -> String
serialize nodes =
    nodes |> List.map serializeNode |> String.join ","


serializeNode : Node -> String
serializeNode node =
    case node of
        Leaf raw ->
            "L{" ++ String.trim raw ++ "}"

        Fold f ->
            "F"
                ++ (if f.collapsed then
                        "*"

                    else
                        ""
                   )
                ++ "["
                ++ serialize f.body
                ++ "]"

        Siblings raws ->
            "S" ++ String.fromInt (List.length raws)
