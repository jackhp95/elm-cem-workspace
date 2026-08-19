module Theme.Presets exposing (Preset, byId, presets)

import M3e.Values as Value exposing (Value)
import Theme.Icons exposing (IconStyle)


type alias Preset =
    { id : String
    , name : String
    , seedColor : String
    , scheme : Value Value.Scheme
    , contrast : Value Value.Contrast
    , displayFont : String
    , bodyFont : String
    , iconStyle : IconStyle
    , cssOverrides : List ( String, String )
    }


{-| Look up a preset by its `id` string. Returns `Nothing` for unknown ids.
Used by `Shared.elm` to resolve the preset id from the `onPresetRequested` port.
-}
byId : String -> Maybe Preset
byId id =
    presets |> List.filter (\p -> p.id == id) |> List.head


{-| Ported from `2026.jackhpeterson.com`'s `src/lib/themes.ts` (22 presets).
That source has no per-preset `scheme`/`contrast` field (those are separate
Appearance controls there) — this port adds them, defaulting to
`Value.auto`/`Value.standard` unless a preset's name/intent obviously
implies otherwise (documented per-preset below where that happens).
`traits` and `palette` from the source are dropped — out of scope per this
feature's non-goals. `iconStyle` is re-transcribed per-preset from the source's
own `iconStyle` field (outlined | rounded | sharp). The source's `"sunny"`
preset uses `"emoji"`, an exotic icon set deferred by D4 (non-goals); it maps to
`Outlined` here (the sanctioned fallback) rather than vendoring an emoji set.
Each `cssOverrides` entry's key is prefixed `md-sys-color-` to match this
repo's cssVar naming convention (see `Theme.Tokens.ColorToken.cssVar`),
transcribed from the source's `colorOverrides` object.
-}
presets : List Preset
presets =
    [ -- The stock Material Design baseline — first card in the reel. Its every
      -- field mirrors `Theme.init` (the app's out-of-the-box state): the seed is
      -- `#6750A4`, which is ALSO `<m3e-theme>`'s own documented default `color`
      -- (see the theme CEM / `theme.js` — `color` defaults to "#6750A4"), so the
      -- derived palette is the true stock M3 baseline; `auto`/`standard`; Roboto
      -- for both fonts; the default (Outlined) icon style; and no css overrides.
      -- Selecting it returns the app to `Theme.init` (`applyPresetToModel` sets
      -- `seed`/`scheme`/`contrast`/fonts/`iconStyle` from these and clears
      -- overrides), and `Theme.init` sets `activePresetId` so the Default card
      -- reads as active whenever the app is in its stock state.
      { id = "default"
      , name = "Default"
      , seedColor = "#6750A4"
      , scheme = Value.auto
      , contrast = Value.standard
      , displayFont = "Roboto"
      , bodyFont = "Roboto"
      , iconStyle = Theme.Icons.Outlined
      , cssOverrides = []
      }
    , { id = "material"
      , name = "Material"
      , seedColor = "#6750A4"
      , scheme = Value.auto
      , contrast = Value.standard
      , displayFont = "Fraunces"
      , bodyFont = "Manrope"
      , iconStyle = Theme.Icons.Outlined
      , cssOverrides = []
      }
    , { id = "agent"
      , name = "Agent"
      , seedColor = "#1b1bff"
      , scheme = Value.auto
      , contrast = Value.standard
      , displayFont = "JetBrains Mono"
      , bodyFont = "Inter"
      , iconStyle = Theme.Icons.Sharp
      , cssOverrides = []
      }
    , { id = "fieldnote"
      , name = "Fieldnote"
      , seedColor = "#2d3a1f"
      , scheme = Value.auto
      , contrast = Value.standard
      , displayFont = "Fraunces"
      , bodyFont = "Sora"
      , iconStyle = Theme.Icons.Outlined
      , cssOverrides = []
      }
    , { id = "geometric"
      , name = "Geometric"
      , seedColor = "#ff5b3e"
      , scheme = Value.auto
      , contrast = Value.standard
      , displayFont = "Space Grotesk"
      , bodyFont = "DM Sans"
      , iconStyle = Theme.Icons.Sharp
      , cssOverrides = []
      }
    , { id = "harbor"
      , name = "Harbor"
      , seedColor = "#d4a574"
      , scheme = Value.auto
      , contrast = Value.standard
      , displayFont = "Cormorant Garamond"
      , bodyFont = "Inter"
      , iconStyle = Theme.Icons.Rounded
      , cssOverrides = []
      }
    , { id = "editorial"
      , name = "Editorial"
      , seedColor = "#8b6f4e"
      , scheme = Value.auto
      , contrast = Value.standard
      , displayFont = "Playfair Display"
      , bodyFont = "Lora"
      , iconStyle = Theme.Icons.Outlined
      , cssOverrides = []
      }
    , { id = "candy-pop"
      , name = "Candy Pop"
      , seedColor = "#a855f7"
      , scheme = Value.auto
      , contrast = Value.standard
      , displayFont = "Fredoka"
      , bodyFont = "DM Sans"
      , iconStyle = Theme.Icons.Rounded
      , cssOverrides = []
      }
    , { id = "bauhaus"
      , name = "Bauhaus"
      , seedColor = "#1e3a8a"
      , scheme = Value.auto
      , contrast = Value.standard
      , displayFont = "Anton"
      , bodyFont = "Work Sans"
      , iconStyle = Theme.Icons.Sharp
      , cssOverrides = []
      }
    , { id = "moss"
      , name = "Moss"
      , seedColor = "#5a6b4a"
      , scheme = Value.auto
      , contrast = Value.standard
      , displayFont = "Caudex"
      , bodyFont = "Manrope"
      , iconStyle = Theme.Icons.Rounded
      , cssOverrides = []
      }
    , { id = "risograph"
      , name = "Risograph"
      , seedColor = "#8b4513"
      , scheme = Value.auto
      , contrast = Value.standard
      , displayFont = "Syne"
      , bodyFont = "IBM Plex Sans"
      , iconStyle = Theme.Icons.Sharp
      , cssOverrides = []
      }
    , { id = "studio"
      , name = "Studio"
      , seedColor = "#4a3b6b"
      , scheme = Value.auto
      , contrast = Value.standard
      , displayFont = "EB Garamond"
      , bodyFont = "Inter"
      , iconStyle = Theme.Icons.Outlined
      , cssOverrides = []
      }
    , { id = "atlas"
      , name = "Atlas"
      , seedColor = "#ff6b35"
      , scheme = Value.auto
      , contrast = Value.standard
      , displayFont = "Bebas Neue"
      , bodyFont = "Inter"
      , iconStyle = Theme.Icons.Sharp
      , cssOverrides = []
      }
    , { id = "citrus"
      , name = "Citrus"
      , seedColor = "#c65d00"
      , scheme = Value.auto
      , contrast = Value.standard
      , displayFont = "Fraunces"
      , bodyFont = "Poppins"
      , iconStyle = Theme.Icons.Rounded
      , cssOverrides = []
      }
    , { id = "howler"
      , name = "Howler"
      , seedColor = "#f7ef6a"
      , scheme = Value.auto
      , contrast = Value.standard
      , displayFont = "Bungee"
      , bodyFont = "Outfit"
      , iconStyle = Theme.Icons.Sharp
      , cssOverrides = []
      }
    , { id = "gallery"
      , name = "Gallery"
      , seedColor = "#6b5876"
      , scheme = Value.auto
      , contrast = Value.standard
      , displayFont = "Cormorant Garamond"
      , bodyFont = "Hanken Grotesk"
      , iconStyle = Theme.Icons.Outlined
      , cssOverrides = []
      }
    , { id = "handbook"
      , name = "Handbook"
      , seedColor = "#6b6b5a"
      , scheme = Value.auto
      , contrast = Value.standard
      , displayFont = "Libre Caslon Text"
      , bodyFont = "Source Sans 3"
      , iconStyle = Theme.Icons.Outlined
      , cssOverrides = []
      }
    , { id = "broadcast"
      , name = "Broadcast"
      , seedColor = "#1ce783"
      , scheme = Value.auto
      , contrast = Value.standard
      , displayFont = "Archivo Black"
      , bodyFont = "Archivo"
      , iconStyle = Theme.Icons.Rounded
      , cssOverrides = []
      }
    , { id = "dispatch"
      , name = "Dispatch"
      , seedColor = "#ed2939"
      , scheme = Value.auto
      , contrast = Value.standard
      , displayFont = "DM Sans"
      , bodyFont = "DM Sans"
      , iconStyle = Theme.Icons.Sharp
      , cssOverrides = []
      }
    , { id = "console"
      , name = "Console"
      , seedColor = "#ff4d1f"
      , scheme = Value.auto
      , contrast = Value.standard
      , displayFont = "DM Mono"
      , bodyFont = "DM Mono"
      , iconStyle = Theme.Icons.Sharp
      , cssOverrides = []
      }
    , { id = "platform"
      , name = "Platform"
      , seedColor = "#4f46e5"
      , scheme = Value.auto
      , contrast = Value.standard
      , displayFont = "Albert Sans"
      , bodyFont = "Albert Sans"
      , iconStyle = Theme.Icons.Rounded
      , cssOverrides = []
      }
    , -- Source `iconStyle` is "emoji" — an exotic icon set deferred by D4
      -- (non-goals). Mapped to Outlined here rather than vendoring an emoji set.
      { id = "sunny"
      , name = "Sunny"
      , seedColor = "#ff7300"
      , scheme = Value.auto
      , contrast = Value.standard
      , displayFont = "Epilogue"
      , bodyFont = "Epilogue"
      , iconStyle = Theme.Icons.Outlined
      , cssOverrides = []
      }
    , -- "OLED" is named for the OLED-black display aesthetic (source `traits: ["oled"]`
      -- and a `colorOverrides` block forcing surfaces to near-black) — fixed dark scheme
      -- with high contrast fits that intent better than the auto/standard default.
      { id = "oled"
      , name = "OLED"
      , seedColor = "#a0a0b8"
      , scheme = Value.dark
      , contrast = Value.high
      , displayFont = "Space Grotesk"
      , bodyFont = "Inter"
      , iconStyle = Theme.Icons.Outlined
      , cssOverrides =
            [ ( "md-sys-color-surface", "#000000" )
            , ( "md-sys-color-surface-dim", "#000000" )
            , ( "md-sys-color-surface-bright", "#1a1a1a" )
            , ( "md-sys-color-surface-container-lowest", "#000000" )
            , ( "md-sys-color-surface-container-low", "#050505" )
            , ( "md-sys-color-surface-container", "#0a0a0a" )
            , ( "md-sys-color-surface-container-high", "#121212" )
            , ( "md-sys-color-surface-container-highest", "#1a1a1a" )
            , ( "md-sys-color-background", "#000000" )
            ]
      }
    ]
