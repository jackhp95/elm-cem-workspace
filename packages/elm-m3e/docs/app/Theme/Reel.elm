module Theme.Reel exposing (Config, view)

{-| A horizontal-scrolling reel of theme-demo cards, each an `m3e-card` wrapped
in its own `<m3e-theme>` — the "themes work by inheritance" live demo.

Anatomy of one card (all m3e components; Tailwind is layout-only):

    <m3e-theme color scheme contrast>        ← live-derived palette for this card
      <m3e-card actionable variant=…>        ← the interactive surface + selection state
        <m3e-heading> name (display font)    ← per-preset display font (inline font-family)
        <m3e-heading>A</> <m3e-heading>a</>  ← "Aa" specimen (display + body font)
        <m3e-avatar>×4                        ← role palette strip (primary/secondary/…)
      </m3e-card>
    </m3e-theme>

Colours are derived live from the nested `<m3e-theme>`: the role avatars are
painted DIRECTLY from `--md-sys-color-<role>` tokens by setting each avatar's own
`--m3e-avatar-color` custom property inline, which the nested theme re-declares
for its subtree, and the card's own surface derives from the same nested palette
through the shadow boundary (CSS custom properties inherit into shadow DOM). No
hex is painted by hand. (The Tailwind `m3e-avatar-color-[…]` arbitrary utility is
NOT used — an arbitrary `var(…)` value fails its `[color]` type-check and emits
no rule; and the bridge `--color-<role>` token is `:root`-computed so a nested
theme can't change it. See `cardRoleStrip`.)

`m3e-card` (with `actionable`) is the interactive element: it dispatches a
standard `click` event (`bubbles: true`, `composed: true`) that Elm's
`Html.Events.on "click"` observes. The earlier native `<button>` wrapper was a
workaround written before this was confirmed; this module now uses `M3e.Component.Card.onClick`
directly so the card itself is the click target — no `M3e.Unsafe` needed.

This module is pure and `msg`-generic. Two placements share it:

  - `Route.GettingStarted.Welcome` — the on-page reel section.

  - `Theme.view` (the settings drawer) — replaces the old `presetGallery`.

        Theme.Reel.view
            { presets = Theme.Presets.presets
            , activeId = shared.theme.activePresetId
            , onPick = PickTheme
            }

@docs Config, view

-}

import M3e exposing (Element)
import M3e.Attributes as MA
import M3e.Component.Avatar
import M3e.Component.Card
import M3e.Component.Heading
import M3e.Component.Icon
import M3e.Component.Theme
import M3e.Values as Value
import Theme.Fonts
import Theme.Presets exposing (Preset)
import TypedHtml
import TypedHtml.Aria as Aria
import TypedHtml.Attributes as TA
import TypedHtml.Grouping


{-| Configuration for the reel view — kept as a record so callers can omit
fields they don't need and future fields can be added without touching call
sites. All fields are explicit; nothing is implicit.
-}
type alias Config msg =
    { presets : List Preset
    , activeId : Maybe String
    , onPick : Preset -> msg
    }


{-| The full reel: a `flex overflow-x-auto snap-x snap-mandatory` row of
`card`s, one per preset. `snap-start` on each card keeps swipes feeling
intentional on touch screens. The reel is layout-only Tailwind; the visual
surface of every card is an `m3e-card`.
-}
view : Config msg -> Element (TypedHtml.Grouping.DivIs s) admittedBy msg
view config =
    TypedHtml.div
        [ TA.class "flex gap-3 overflow-x-auto snap-x snap-mandatory px-4 py-3" ]
        (List.map (card config) config.presets)


{-| One theme card. The `m3e-card` (with `actionable`) is the interactive
element — `M3e.Component.Card.onClick` fires on user click and dispatches `onPick`.
`<m3e-theme>` scopes the live-derived palette to this card's preset, and carries
the `snap-start` + sizing layout so the card fills its snap region.
-}
card : Config msg -> Preset -> Element (M3e.Component.Theme.Is s) admittedBy msg
card config preset =
    let
        isActive : Bool
        isActive =
            config.activeId == Just preset.id
    in
    M3e.theme
        [ M3e.Component.Theme.color preset.seedColor
        , M3e.Component.Theme.scheme preset.scheme
        , M3e.Component.Theme.contrast preset.contrast
        , TA.class "block shrink-0 w-32 snap-start"
        ]
        [ presetCard config isActive preset ]


{-| The `m3e-card` surface: `actionable` makes it the click target; `onClick`
delivers the `onPick` message; `aria-pressed` + `aria-label` make it accessible.
Selection state is expressed the M3 way — `elevated` when active, `outlined`
otherwise — plus a `check_circle` badge.
-}
presetCard : Config msg -> Bool -> Preset -> Element (M3e.Component.Card.Is s) admittedBy msg
presetCard config isActive preset =
    M3e.card
        [ M3e.Component.Card.actionable True
        , M3e.Component.Card.onClick (config.onPick preset)
        , M3e.Component.Card.variant
            (if isActive then
                Value.elevated

             else
                Value.outlined
            )
        , Aria.pressed
            (if isActive then
                Aria.true

             else
                Aria.false
            )
        , Aria.label ("Apply " ++ preset.name ++ " theme")
        , MA.class "w-full text-left m3e-card-padding-[0.625rem]"
        ]
        [ M3e.Component.Card.content (cardBody isActive preset) ]


{-| The card's inner content, one row per line. Each row is a `TypedHtml.div`
(so the row list stays a single kind), and every row's own children are a
single m3e component kind — keeping the phantom-row lists homogeneous without
per-child escapes.
-}
cardBody : Bool -> Preset -> Element (TypedHtml.Grouping.DivIs s) admittedBy msg
cardBody isActive preset =
    TypedHtml.div
        [ TA.class "flex flex-col gap-1.5" ]
        (List.concat
            [ if isActive then
                [ selectedBadge ]

              else
                []
            , [ cardName preset
              , cardSpecimen preset
              , cardRoleStrip
              ]
            ]
        )


{-| The "selected" affordance: a filled `check_circle` icon, right-aligned.
Shown only for the active card. Its colour inherits `on-surface` from the
card's own nested theme.
-}
selectedBadge : Element (TypedHtml.Grouping.DivIs s) admittedBy msg
selectedBadge =
    TypedHtml.div
        [ TA.class "flex justify-end -mb-1 text-primary" ]
        [ M3e.icon
            [ M3e.Component.Icon.name "check_circle"
            , M3e.Component.Icon.filled True
            , MA.class "text-base"
            ]
            []
        ]


{-| The theme name as an `m3e-heading` (title/small) in the preset's display
font. `font-family` is a regular CSS property, so inline `style` is reliable
here (only CSS _custom_ properties are unreliable via the style encoder).
-}
cardName : Preset -> Element (TypedHtml.Grouping.DivIs s) admittedBy msg
cardName preset =
    TypedHtml.div
        [ TA.class "min-w-0" ]
        [ M3e.heading
            [ M3e.Component.Heading.variant Value.title
            , M3e.Component.Heading.size Value.small
            , MA.class "truncate"
            , MA.style "font-family" (Theme.Fonts.fontStack preset.displayFont)
            ]
            [ M3e.text preset.name ]
        ]


{-| "Aa" specimen: uppercase A in the display font, lowercase a in the body
font — two `m3e-heading`s side by side so both fonts show at a glance.
-}
cardSpecimen : Preset -> Element (TypedHtml.Grouping.DivIs s) admittedBy msg
cardSpecimen preset =
    TypedHtml.div
        [ TA.class "flex items-baseline gap-1" ]
        [ M3e.heading
            [ M3e.Component.Heading.variant Value.display
            , M3e.Component.Heading.size Value.small
            , MA.style "font-family" (Theme.Fonts.fontStack preset.displayFont)
            ]
            [ M3e.text "A" ]
        , M3e.heading
            [ M3e.Component.Heading.variant Value.title
            , M3e.Component.Heading.size Value.medium
            , MA.style "font-family" (Theme.Fonts.fontStack preset.bodyFont)
            ]
            [ M3e.text "a" ]
        ]


{-| A strip of 4 role-derived swatches, each a blank `m3e-avatar` painted
DIRECTLY from a `--md-sys-color-<role>` token. The nested `<m3e-theme>`
re-declares those tokens for its subtree (it writes the whole
`:host { --md-sys-color-*: … }` block — see `theme.js`), so painting from them
resolves to this card's own live palette — the "themes work by inheritance"
demo.

The avatar's background is its own `--m3e-avatar-color` custom property (its
shadow `.base` reads `background-color: var(--m3e-avatar-color, …)`; the default
is `primaryContainer`). We set that property DIRECTLY via an inline `style`
declaration: `--m3e-avatar-color: var(--md-sys-color-<role>)`. Because the
avatar host lives inside the card's nested `<m3e-theme>`, `--md-sys-color-<role>`
resolves to that card's palette, and the custom property inherits through the
avatar's shadow boundary to `.base`.

Why NOT the `m3e-avatar-color-[…]` utility (the previous approach): the Tailwind
utility is `--m3e-avatar-color: --value([color], --color-*)`, and an arbitrary
`[var(--md-sys-color-…)]` value does NOT satisfy the `[color]` data-type check,
so the utility emits NO rule at all — every dot fell back to the avatar's default
`primaryContainer`, rendering all four identical. The named form
(`m3e-avatar-color-primary`) DOES emit but reads the `:root`-computed bridge
token `--color-primary`, which never re-derives under a nested theme. Setting
`--m3e-avatar-color` from the sys token via `style` sidesteps both traps: the IR
`style` path emits real CSS custom properties (unlike elm/html's kernel, which
drops `--x`).

-}
cardRoleStrip : Element (TypedHtml.Grouping.DivIs s) admittedBy msg
cardRoleStrip =
    TypedHtml.div
        [ TA.class "flex gap-1 mt-0.5" ]
        [ roleAvatar "primary"
        , roleAvatar "secondary"
        , roleAvatar "tertiary"
        , roleAvatar "surface-container-highest"
        ]


{-| One blank role swatch: a small circular `m3e-avatar` whose background is the
given `--md-sys-color-<role>` token, applied by setting the avatar's own
`--m3e-avatar-color` custom property inline. `m3e-avatar-size-*` keeps it a
compact dot; the colour derives from the nearest `<m3e-theme>`.
-}
roleAvatar : String -> Element (M3e.Component.Avatar.Is s) admittedBy msg
roleAvatar role =
    M3e.avatar
        [ MA.class "m3e-avatar-size-[0.875rem]"
        , MA.style "--m3e-avatar-color" ("var(--md-sys-color-" ++ role ++ ")")
        ]
        []
