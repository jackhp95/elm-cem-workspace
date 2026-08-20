module Naming exposing
    ( capitalize, decapitalize
    , camel, pascal, constructor
    , safeField, safeValue
    , tokenIdent
    )

{-| Naming helpers: the single home for turning CEM identifiers (kebab-case
attribute names, quoted union values, etc.) into safe Elm identifiers.

This module is pure and exposed so it can be unit-tested directly.

@docs capitalize, decapitalize
@docs camel, pascal, constructor
@docs safeField, safeValue
@docs tokenIdent

-}


{-| Uppercase the first character.
-}
capitalize : String -> String
capitalize str =
    case String.uncons str of
        Nothing ->
            str

        Just ( first, rest ) ->
            String.cons (Char.toUpper first) rest


{-| Lowercase the first character.
-}
decapitalize : String -> String
decapitalize str =
    case String.uncons str of
        Nothing ->
            str

        Just ( first, rest ) ->
            String.cons (Char.toLower first) rest


{-| Replace symbolic characters with word-equivalents so they survive the
split-into-words step (e.g. `application/x-www-form-urlencoded`, `2x`, `a+b`).
-}
replaceSymbols : String -> String
replaceSymbols raw =
    raw
        |> String.replace "+" " plus "
        |> String.replace "%" " percent "
        |> String.replace "&" " and "
        |> String.replace "=" " equals "
        |> String.replace "?" " question "
        |> String.replace "#" " hash "
        |> String.replace "@" " at "


{-| Split an arbitrary identifier into words on any non-alphanumeric boundary.
Empty words are dropped. e.g. "top-start" -> ["top","start"],
"\_blank" -> ["blank"], "border-box" -> ["border","box"].
-}
splitWords : String -> List String
splitWords raw =
    raw
        |> replaceSymbols
        |> String.toList
        |> List.map
            (\c ->
                if Char.isAlphaNum c then
                    c

                else
                    ' '
            )
        |> String.fromList
        |> String.split " "
        |> List.filter (not << String.isEmpty)


{-| kebab/snake/quoted → camelCase identifier suitable for a function name.
e.g. "arrow-padding" -> "arrowPadding".
-}
camel : String -> String
camel raw =
    raw
        |> splitWords
        |> List.indexedMap
            (\i word ->
                if i == 0 then
                    String.toLower word

                else
                    capitalize word
            )
        |> String.concat
        |> ensureLeadingAlpha "value"


{-| kebab/snake → PascalCase identifier suitable for a module or type name.
e.g. "sl-button" -> "SlButton".
-}
pascal : String -> String
pascal raw =
    raw
        |> splitWords
        |> List.map capitalize
        |> String.concat
        |> ensureLeadingAlpha "V"


{-| A union value → a valid Elm type constructor (PascalCase).
e.g. "primary" -> "Primary", "top-start" -> "TopStart", "\_blank" -> "Blank",
"2x" -> "V2x".
-}
constructor : String -> String
constructor value =
    pascal value


{-| If an identifier is empty or starts with a digit, prefix it so it becomes a
valid Elm identifier. `fallbackPrefix` is "value"/"V" depending on case.
-}
ensureLeadingAlpha : String -> String -> String
ensureLeadingAlpha fallbackPrefix name =
    case String.uncons name of
        Nothing ->
            fallbackPrefix

        Just ( first, _ ) ->
            if Char.isDigit first then
                fallbackPrefix ++ name

            else
                name


elmKeywords : List String
elmKeywords =
    [ "type", "module", "where", "import", "as", "exposing", "port", "let", "in", "if", "then", "else", "case", "of", "infix", "alias", "effect", "command", "subscription" ]


{-| Append `_` to an Elm reserved keyword so it is safe as a **record field**
name. elm-codegen escapes declaration names automatically, but record-field
strings in `Type.record`/`Type.extensible` are emitted verbatim.
-}
safeField : String -> String
safeField name =
    if List.member name elmKeywords then
        name ++ "_"

    else
        name


{-| Identifiers that are illegal or dangerous as a **top-level VALUE
declaration** derived from a tag name. Beyond the reserved keywords (which
elm-codegen already escapes in binder position, but NOT when the same string is
used as a cross-module reference or record-field), the Elm compiler special-cases
any top-level `main` as the program entry point and rejects a package that
exposes a `main` whose type is not `Html`/`Svg`/`Program` (`-- BAD MAIN TYPE`).
So `<main>` → the DOM tag stays `markup-main`/`main` in the emitted
`Html.node "..."`, but the Elm function that builds it is `main_`.
-}
reservedValues : List String
reservedValues =
    "main" :: elmKeywords


{-| Escape an identifier so it is safe as a **top-level VALUE** name (a raw
element constructor, a middle/top setter, a barrel re-export). Appends `_` (the
Elm convention) to reserved keywords and to `main`. Idempotent across the
bottom/middle/top/barrel layers because each derives the name the same way, so
the escaped name still lines up across cross-module references.
-}
safeValue : String -> String
safeValue name =
    if List.member name reservedValues then
        name ++ "_"

    else
        name


{-| Turn an enum token raw string into a safe Elm identifier / record-field name.

Applies the **K1 unconditional rule**: a token whose raw string starts with `_`
(a leading-underscore token such as `"_top"`, `"_blank"`, `"_self"`,
`"_parent"`) is emitted with a **trailing** `_` instead of losing the underscore
silently (`"_top"` → `"top_"`, not `"top"`). This keeps the API stable: a
token's Elm name never flips when an unrelated enum later adds a plain `"top"`.
All other tokens go through the standard `camel` → `safeField` chain.

The raw token string payload passed to `Ir.token` is always the original
(unchanged), so the HTML attribute value round-trips correctly.

-}
tokenIdent : String -> String
tokenIdent raw =
    if String.startsWith "_" raw then
        -- K1: leading underscore → trailing underscore (unconditional).
        -- camel of "_top" would be "top" (strips the underscore); instead we
        -- produce "top_" by camel-casing the tail and appending "_".
        let
            tail =
                String.dropLeft 1 raw
        in
        camel tail ++ "_"

    else
        camel raw |> safeField
