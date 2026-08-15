module Compose.Codegen exposing (codeFor)

{-| The generated-code snippet: a pure fold from `Cem.Compose.Node` to the Elm
source text that would build the same tree by hand, against the `Html` facet
(spec §8.6). `Cem.Compose.attrsOf`/`slotsOf` are already sorted, so two
structurally-equal trees produce byte-identical text.
-}

import Cem.Compose
import Compose.Attrs as Attrs


{-| The whole snippet for a node, starting at indentation depth 0.
-}
codeFor : Cem.Compose.Node -> String
codeFor node =
    render 0 [] node


{-| One `M3e.Html.<component>` call: its own attrs (plus any slot-placement
attr inherited from the parent), then its children. `extraAttrs` carries the
`M3e.Attributes.slot "..."` line a named-slot parent injects; the root has
none.
-}
render : Int -> List String -> Cem.Compose.Node -> String
render depth extraAttrs node =
    let
        attrLines : List String
        attrLines =
            List.map (\line -> pad (depth + 2) ++ line) extraAttrs
                ++ (Cem.Compose.attrsOf node
                        |> List.filterMap (\( name, value ) -> Attrs.codeLineFor name value)
                        |> List.map (\line -> pad (depth + 2) ++ line)
                   )

        childLines : List String
        childLines =
            Cem.Compose.slotsOf node
                |> List.concatMap (childCode (depth + 2))
    in
    String.join "\n"
        (List.concat
            [ [ pad depth ++ "M3e.Html." ++ Cem.Compose.componentOf node ]
            , bracketed (depth + 1) attrLines
            , bracketed (depth + 1) childLines
            ]
        )


pad : Int -> String
pad n =
    String.repeat (4 * n) " "


{-| `[]` on one line when empty, a comma-separated block otherwise. An item
may itself be a multi-line nested node's rendered text — only its first line
gets the `[` / `,` marker; later lines pass through untouched, since the
recursive `render` call that produced them already indented them correctly.
-}
bracketed : Int -> List String -> List String
bracketed depth items =
    case items of
        [] ->
            [ pad depth ++ "[]" ]

        first :: rest ->
            List.concat
                [ markFirst (pad depth ++ "[ ") first
                , List.concatMap (markFirst (pad depth ++ ", ")) rest
                , [ pad depth ++ "]" ]
                ]


markFirst : String -> String -> List String
markFirst marker item =
    case String.split "\n" item of
        [] ->
            [ marker ]

        firstLine :: rest ->
            (marker ++ String.trimLeft firstLine) :: rest


{-| The facts' name for the default slot is `"unnamed"`, and the default slot
emits no `slot=` attribute — the same special case `Compose.Render` makes.
-}
slotAttrLines : String -> List String
slotAttrLines slotName =
    if slotName == "unnamed" then
        []

    else
        [ "M3e.Attributes.slot " ++ quoted slotName ]


childCode : Int -> ( String, List Cem.Compose.Child ) -> List String
childCode depth ( slotName, children ) =
    List.map (childItem depth slotName) children


{-| `ChildNode` recurses, carrying the slot-placement attr into the child's
own attr list. `ChildText` emits `M3e.text` directly in the default slot, or
a slotted `TypedHtml.span` wrapper in a named one (`M3e.text` has no attrs
of its own to carry a `slot=`). `ChildIcon` emits the icon constructor with
the glyph as a `TypedHtml.Attributes.name` attr (an `m3e-icon` takes its
glyph via `name`, not text content — the same fix as `Compose.Render`;
`M3e.Attributes.name` takes a `Value M3e.Values.Name`, not a `String`, so it
is `TypedHtml.Attributes.name` that matches the `String` glyph here), carrying
the slot attr alongside it, and no children.
-}
childItem : Int -> String -> Cem.Compose.Child -> String
childItem depth slotName child =
    case child of
        Cem.Compose.ChildNode inner ->
            render depth (slotAttrLines slotName) inner

        Cem.Compose.ChildText text ->
            if slotName == "unnamed" then
                pad depth ++ "M3e.text " ++ quoted text

            else
                String.join "\n"
                    (List.concat
                        [ [ pad depth ++ "TypedHtml.span" ]
                        , bracketed (depth + 1) [ pad (depth + 1) ++ "TypedHtml.Attributes.slot " ++ quoted slotName ]
                        , bracketed (depth + 1) [ pad (depth + 1) ++ "TypedHtml.text " ++ quoted text ]
                        ]
                    )

        Cem.Compose.ChildIcon glyph ->
            String.join "\n"
                (List.concat
                    [ [ pad depth ++ "M3e.Html.icon" ]
                    , bracketed (depth + 1)
                        (List.map (\line -> pad (depth + 1) ++ line)
                            (slotAttrLines slotName ++ [ "TypedHtml.Attributes.name " ++ quoted glyph ])
                        )
                    , bracketed (depth + 1) []
                    ]
                )


quoted : String -> String
quoted s =
    "\"" ++ s ++ "\""
