module Docs exposing
    ( docMetaMarker
    , examplesSection
    , generateViewDocumentation
    )

{-| Markdown documentation generation for the produced Elm modules: the @docs
layout, the component view docstring, the "Omitted Attributes" note, and the
generic (config-supplied) usage-example and doc-metadata markers.

@docs docMetaMarker
@docs examplesSection
@docs generateViewDocumentation

-}

import Cem
import Util exposing (deduplicateBy)


{-| Render a `**Header:**` block of `` - `name`: description `` bullets, or "" when
the list is empty. The single home for the doc sections in this module.
-}
bulletedSection : String -> List { fields | name : String, description : Maybe String } -> String
bulletedSection header items =
    if List.isEmpty items then
        ""

    else
        "\n\n**"
            ++ header
            ++ ":**\n"
            ++ (items
                    |> List.map
                        (\item ->
                            "- `"
                                ++ item.name
                                ++ "`: "
                                ++ Maybe.withDefault "No description" item.description
                        )
                    |> String.join "\n"
               )


{-| Escape a value so it cannot terminate or corrupt an HTML-comment marker:
drop double quotes (markers quote titles) and `-->` sequences.
-}
escapeMarker : String -> String
escapeMarker s =
    s
        |> String.replace "\"" "'"
        |> String.replace "-->" "--&gt;"


{-| Render config-supplied usage examples into a `## Examples` doc-comment section,
grouped by each example's optional `section` (unsectioned ⇒ "Examples"). Every example
is a machine-readable HTML-comment marker (invisible in rendered Markdown and in the
package registry) followed by a fenced Elm code block, so a downstream extractor can
recover its section, title, and code while the block still reads as ordinary docs.
Returns "" when there are no examples. Manifest-agnostic — it only sees the records.

Note: `code` is emitted verbatim between fences; a code string containing a literal
triple-backtick would terminate the block early. Examples are author/generator
controlled (not untrusted input), so this is a documented constraint, not escaped.

-}
examplesSection : List { fields | title : String, code : String, section : Maybe String } -> String
examplesSection examples =
    if List.isEmpty examples then
        ""

    else
        let
            sectionOf ex =
                ex.section |> Maybe.withDefault "Examples"

            orderedSections =
                examples |> List.map sectionOf |> deduplicateBy identity

            renderExample ex =
                "\n\n<!-- elm-cem:example title=\""
                    ++ escapeMarker ex.title
                    ++ "\" -->\n```elm\n"
                    ++ String.trim ex.code
                    ++ "\n```"

            renderSection name =
                "\n\n### "
                    ++ name
                    ++ (examples
                            |> List.filter (\ex -> sectionOf ex == name)
                            |> List.map renderExample
                            |> String.join ""
                       )
        in
        "\n\n## Examples"
            ++ (orderedSections |> List.map renderSection |> String.join "")


{-| Render opaque per-component doc metadata (config-supplied key/value pairs, e.g.
`category`) as a single machine-readable HTML-comment marker. Invisible in rendered
Markdown; a downstream tool parses it back out. Returns "" when empty. elm-cem never
interprets the keys — they are pass-through, keeping the generator manifest-agnostic.

Pairs render as `key=value` joined by `;`; a downstream parser should split on the
first `;` then the first `=`, so values should avoid the `;` delimiter.

-}
docMetaMarker : List ( String, String ) -> String
docMetaMarker pairs =
    if List.isEmpty pairs then
        ""

    else
        "\n\n<!-- elm-cem:docmeta "
            ++ (pairs
                    |> List.map (\( k, v ) -> k ++ "=" ++ escapeMarker v)
                    |> String.join "; "
               )
            ++ " -->"


{-| Generate comprehensive view function documentation
-}
generateViewDocumentation : Cem.Declaration -> String
generateViewDocumentation component =
    let
        tagName =
            component.tagName |> Maybe.withDefault "div"

        nonEmpty =
            Maybe.andThen
                (\s ->
                    if String.isEmpty (String.trim s) then
                        Nothing

                    else
                        Just s
                )

        -- Component summary and description with default slot info
        summaryLine =
            nonEmpty component.summary
                |> Maybe.withDefault (nonEmpty component.description |> Maybe.withDefault ("Create a " ++ tagName ++ " element"))

        -- Find default slot description
        defaultSlotDescription =
            component.slots
                |> List.filter (\slot -> String.isEmpty slot.name)
                |> List.head
                |> Maybe.andThen .description

        nonEmptyDescription =
            nonEmpty component.description

        basicDoc =
            case defaultSlotDescription of
                Just defaultDesc ->
                    nonEmptyDescription
                        |> Maybe.withDefault summaryLine
                        |> (\desc -> desc ++ "\n\n**Content:** " ++ defaultDesc)

                Nothing ->
                    nonEmptyDescription
                        |> Maybe.withDefault summaryLine

        -- Metadata section
        metadataDoc =
            let
                statusLine =
                    component.status |> Maybe.map (\s -> "\n- **Status:** " ++ s) |> Maybe.withDefault ""

                sinceLine =
                    component.since |> Maybe.map (\v -> "\n- **Since:** " ++ v) |> Maybe.withDefault ""

                superclassLine =
                    component.superclass
                        |> Maybe.map
                            (\sc ->
                                "\n- **Extends:** `"
                                    ++ sc.name
                                    ++ "`"
                                    ++ (sc.modulePath
                                            |> Maybe.map (\m -> " from `" ++ m ++ "`")
                                            |> Maybe.withDefault ""
                                       )
                            )
                        |> Maybe.withDefault ""

                dependenciesLine =
                    if List.isEmpty component.dependencies then
                        ""

                    else
                        "\n- **Dependencies:** " ++ (component.dependencies |> String.join ", ")

                documentationLine =
                    component.documentation
                        |> Maybe.map (\url -> "\n- **Documentation:** " ++ url)
                        |> Maybe.withDefault ""
            in
            if String.isEmpty (statusLine ++ sinceLine ++ superclassLine ++ dependenciesLine ++ documentationLine) then
                ""

            else
                "\n\n**Component Info:**" ++ statusLine ++ sinceLine ++ superclassLine ++ dependenciesLine ++ documentationLine

        -- Events and slots. CSS custom properties / shadow parts / states are
        -- intentionally omitted: they're shadow-DOM styling hooks that can't be
        -- set through these attribute bindings, and enumerating them (hundreds of
        -- design tokens for some libraries) bloated docs.json past the registry
        -- limit. Users find them in the upstream docs (linked above).
        eventsDoc =
            bulletedSection "Events" component.events

        slotDoc =
            bulletedSection "Slots" component.slots
    in
    basicDoc ++ metadataDoc ++ eventsDoc ++ slotDoc
