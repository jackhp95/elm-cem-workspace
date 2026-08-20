module Docs exposing
    ( docMetaMarker
    , examplesSection
    )

{-| Markdown documentation generation for the produced Elm modules: the
"Omitted Attributes" note plus the generic (config-supplied) usage-example
and doc-metadata markers.

@docs docMetaMarker
@docs examplesSection

-}

import Util exposing (deduplicateBy)


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
