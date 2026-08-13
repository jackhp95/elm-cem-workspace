module Theme.Fonts exposing (curatedFonts, fontStack, googleFontsUrl, specimenSubsetUrls)

{-| Google Fonts helpers for the theme reel and global font application.

Fonts are modeled in `Theme.Presets.Preset` (`displayFont`, `bodyFont`) but
were never applied — no cmd loaded the webfont or pushed a font CSS variable.
This module restores that: it builds the Google Fonts URL(s) to load and the
specimen subset URL for each reel card.

Global font application happens via `Theme.Ports.loadFonts` (injecting a
`<link>` for the Google Fonts stylesheet) + `Theme.Ports.setCssOverride` for
the `--md-ref-typeface-brand` and `--md-ref-typeface-plain` tokens that
`@m3e/web`'s adopted stylesheet reads.

Specimen subsetting (§D6 of the plan): each reel card loads only the glyphs
it displays ("Aa" + the preset name) by adding `&text=` to the Google Fonts
URL. All 22 cards can load simultaneously at negligible payload cost.

@docs curatedFonts, fontStack, googleFontsUrl, specimenSubsetUrls

-}

import Theme.Presets exposing (Preset)


{-| A `font-family` value for one webfont, with a generic fallback for the
brief window before the font swaps in (`display=swap`). Regular CSS
`font-family` value — safe to push into the `--app-font-display` /
`--app-font-body` custom properties (see `Theme.update`) or to set inline on a
reel card's specimen text.

    fontStack "Fraunces" --> "\"Fraunces\", system-ui, sans-serif"

-}
fontStack : String -> String
fontStack name =
    "\"" ++ name ++ "\", system-ui, sans-serif"


{-| The font families offered by the display/body font pickers (the drawer's
Typography section). A curated cross-section of Google Fonts — sans, serif,
mono, and display faces — that also covers every family used by the presets in
`Theme.Presets`, so a picked font always resolves once `loadFonts` fetches it.
-}
curatedFonts : List String
curatedFonts =
    [ "Roboto"
    , "Inter"
    , "Manrope"
    , "DM Sans"
    , "Hanken Grotesk"
    , "Outfit"
    , "Poppins"
    , "Sora"
    , "Source Sans 3"
    , "Space Grotesk"
    , "Work Sans"
    , "Albert Sans"
    , "Archivo"
    , "Newsreader"
    , "Fraunces"
    , "EB Garamond"
    , "Cormorant Garamond"
    , "Libre Caslon Text"
    , "Lora"
    , "Playfair Display"
    , "DM Mono"
    , "JetBrains Mono"
    , "IBM Plex Mono"
    , "Space Mono"
    , "Anton"
    , "Archivo Black"
    , "Bebas Neue"
    , "Bungee"
    , "Epilogue"
    , "Fredoka"
    , "Syne"
    ]


{-| Build a single Google Fonts `<link>` `href` that loads one or two font
families (display + body, deduped if they are the same). Uses `display=swap`
for FOUT-resistant rendering. Returns `Nothing` when the list is empty.

    googleFontsUrl [ "Fraunces", "Manrope" ]
    --> Just "https://fonts.googleapis.com/css2?family=Fraunces&family=Manrope&display=swap"

    googleFontsUrl [ "DM Mono", "DM Mono" ]
    --> Just "https://fonts.googleapis.com/css2?family=DM+Mono&display=swap"

-}
googleFontsUrl : List String -> Maybe String
googleFontsUrl fonts =
    let
        unique : List String
        unique =
            List.foldl
                (\f acc ->
                    if List.member f acc then
                        acc

                    else
                        acc ++ [ f ]
                )
                []
                fonts
    in
    case unique of
        [] ->
            Nothing

        _ ->
            let
                familyParams : String
                familyParams =
                    unique
                        |> List.map (\f -> "family=" ++ encodeFont f)
                        |> String.join "&"
            in
            Just ("https://fonts.googleapis.com/css2?" ++ familyParams ++ "&display=swap")


{-| Build a **subset** Google Fonts URL for one reel card: loads only the
glyphs actually shown ("Aa" + the preset name). The `&text=` parameter
restricts the font download to exactly those characters, keeping the reel's
total font payload tiny even with 22 × 2 fonts loaded concurrently.

Returns `Nothing` when neither font is a Google Font (e.g. a system font).
In practice all 22 presets use Google Fonts, so this always returns `Just`.

-}
specimenSubsetUrl : Preset -> Maybe String
specimenSubsetUrl preset =
    let
        specimenText : String
        specimenText =
            "Aa" ++ preset.name

        unique : List String
        unique =
            if preset.displayFont == preset.bodyFont then
                [ preset.displayFont ]

            else
                [ preset.displayFont, preset.bodyFont ]

        familyParams : String
        familyParams =
            unique
                |> List.map (\f -> "family=" ++ encodeFont f)
                |> String.join "&"
    in
    Just
        ("https://fonts.googleapis.com/css2?"
            ++ familyParams
            ++ "&text="
            ++ encodeText specimenText
            ++ "&display=swap"
        )


{-| Every reel card's specimen-subset URL, deduped. One `<link>` per card loads
only that card's display + body glyphs ("Aa" + the preset name), so all 22 cards
render in their own fonts at negligible total payload (§D6). Duplicate URLs
(presets sharing the same font pair AND name-glyph set — rare, but possible)
collapse to one so the injector never adds the same stylesheet twice.
-}
specimenSubsetUrls : List Preset -> List String
specimenSubsetUrls presets =
    presets
        |> List.filterMap specimenSubsetUrl
        |> dedupe


{-| Order-preserving dedupe (no `comparable` constraint needed for `List String`,
but written generically-shaped so intent is clear).
-}
dedupe : List String -> List String
dedupe =
    List.foldl
        (\x acc ->
            if List.member x acc then
                acc

            else
                acc ++ [ x ]
        )
        []


{-| Encode a font family name for a Google Fonts URL: spaces become `+`.
Other characters in font family names are safe ASCII.
-}
encodeFont : String -> String
encodeFont =
    String.replace " " "+"


{-| Percent-encode characters that need encoding in a Google Fonts `&text=`
value. Only encodes the characters that are NOT safe in a query-string value.
In practice, the specimen text is just ASCII letters + the preset name (also
ASCII), so we only need to handle `+` (which Google Fonts uses for spaces in
family names, not in `&text=`). We use `%20` for spaces in the text value.
-}
encodeText : String -> String
encodeText text =
    text
        |> String.replace " " "%20"
        |> String.replace "&" "%26"
        |> String.replace "=" "%3D"
        |> String.replace "+" "%2B"
