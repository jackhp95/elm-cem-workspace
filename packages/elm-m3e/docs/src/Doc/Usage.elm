module Doc.Usage exposing
    ( Msg(..)
    , Surface(..)
    , UsageExample
    , encodeSurface
    , surfaceFromString
    , tabStrip
    , usageBlocks
    , usageExampleDecoder
    )

import Doc
import Doc.Slider
import Json.Decode as Decode
import Json.Encode as Encode
import M3e exposing (Element)
import M3e.Attributes
import M3e.Component.Heading
import M3e.Events
import M3e.Kind
import M3e.Values as Value
import TypedHtml
import TypedHtml.Attributes as TA
import TypedHtml.Component.Grouping
import TypedHtml.Kind


{-| Which API surface a Usage example is shown in:

  - `Top` — the barrel `M3e.*` form (the Standard surface, always present)
  - `Record` — `M3e.<Comp>.component { … }` (the required-record surface; per-example)
  - `Build` — `M3e.<Comp>.build |> … |> toElement` (the builder-pipe surface; per-example)
  - `Raw` — the raw `<m3e-*>` HTML (always present)

`M3e` and `HTML` are verified for every example, so those two tabs are always
offered. The `record` / `build` surfaces are offered whenever `top` is — when
their own field is non-null they show a real translation, and when it's null they
show an _identical-by-design_ rationale (the example's content carried nothing for
that surface to enforce). Only a composite with no single-component `top` form
drops them entirely.

-}
type Surface
    = Top
    | Record
    | Build
    | Raw


{-| The click message a layer tab emits. The selected surface itself is NOT held
here: it lives in `Shared.Model.activeSurface`, mirrored from localStorage through
`Theme.Ports.readSurface`, so one choice governs every example on the page AND
survives client-side navigation between component pages. A route forwards this
message straight to `Theme.Ports.storeSurface (encodeSurface surface)`; `index.ts`
echoes the write back so `Shared` is the only writer.
-}
type Msg
    = SelectSurface Surface


{-| Wire form of a surface — a plain string, since the four constructor names are
stable keys ("Top", "Record", "Build", "Raw"). Paired with `surfaceFromString`.
-}
encodeSurface : Surface -> Encode.Value
encodeSurface surface =
    Encode.string (surfaceToString surface)


surfaceToString : Surface -> String
surfaceToString surface =
    case surface of
        Top ->
            "Top"

        Record ->
            "Record"

        Build ->
            "Build"

        Raw ->
            "Raw"


{-| Parse the persisted wire string back to a `Surface`. An unknown string is an
`Err` rather than a silent default, so the caller decides what to fall back to
(`Shared` keeps its current value).
-}
surfaceFromString : String -> Result String Surface
surfaceFromString s =
    case s of
        "Top" ->
            Ok Top

        "Record" ->
            Ok Record

        "Build" ->
            Ok Build

        "Raw" ->
            Ok Raw

        _ ->
            Err ("Unknown surface: " ++ s)


{-| A verified Usage example: its live-preview HTML and the derived Elm in each
API surface. Every Elm surface is optional — `top` (M3e) and `record`
(`M3e.<Comp>.component`, required-record form) / `build` (`M3e.<Comp>.build`) are each present only when that
surface compiled to a distinct form for this example (else `Nothing`; the UI hides
the `top` tab, but keeps `record`/`build` as an identical-by-design rationale tab).
`html` is the one guaranteed surface — its live preview always renders. `section`
groups examples under a sub-heading ("" = ungrouped).
-}
type alias UsageExample =
    { title : String
    , section : String
    , html : String
    , top : Maybe String
    , record : Maybe String
    , build : Maybe String
    }


usageExampleDecoder : Decode.Decoder UsageExample
usageExampleDecoder =
    Decode.map6 UsageExample
        (Decode.field "title" Decode.string)
        (Decode.oneOf [ Decode.field "section" Decode.string, Decode.succeed "" ])
        (Decode.field "html" Decode.string)
        (Decode.oneOf [ Decode.field "top" (Decode.nullable Decode.string), Decode.succeed Nothing ])
        (Decode.oneOf [ Decode.field "record" (Decode.nullable Decode.string), Decode.succeed Nothing ])
        (Decode.oneOf [ Decode.field "build" (Decode.nullable Decode.string), Decode.succeed Nothing ])


{-| Render the Usage section as a single spacing-consistent block: a "Usage"
heading over its per-section sub-headings and examples. Empty ⇒ nothing (so it
drops cleanly out of the top-level `space-y-10` rhythm).

Both the "Usage" heading and each named sub-heading carry a stable `id`
(`Doc.slugify` of their own text) rather than the random id `m3e-toc`'s own
generator falls back to for an unidentified heading -- a stable id keeps
`#usage`/`#variants`-style URLs bookmarkable across reloads. `Shared.tocPanel`
mounts a single `m3e-toc` that discovers these headings (and everything
else on the page) at runtime; nothing here needs to enumerate them.

-}
usageBlocks : Surface -> List UsageExample -> List (Element (TypedHtml.Component.Grouping.DivIs s) adm_ Msg)
usageBlocks activeSurface examples =
    case examples of
        [] ->
            []

        _ ->
            [ TypedHtml.div [ TA.class "space-y-6" ]
                (M3e.heading
                    [ M3e.Component.Heading.variant Value.headline
                    , M3e.Component.Heading.size Value.small
                    , M3e.Attributes.level 2
                    , M3e.Attributes.id (Doc.slugify "Usage")
                    ]
                    [ M3e.text "Usage" ]
                    :: List.concatMap (sectionBlock activeSurface)
                        (groupBySection examples)
                )
            ]


{-| One section: an optional sub-heading (skipped for the ungrouped "" section)
followed by each example's live preview paired with its code tabs.
-}
sectionBlock : Surface -> ( String, List UsageExample ) -> List (Element { a | card : M3e.Kind.Brand, sharedFlow : TypedHtml.Kind.Shared, heading : M3e.Kind.Brand, tabs : M3e.Kind.Brand } admittedBy Msg)
sectionBlock activeSurface ( sec, examples ) =
    let
        headingEl : List (Element { s | heading : M3e.Kind.Brand, card : M3e.Kind.Brand, tabs : M3e.Kind.Brand } admittedBy Msg)
        headingEl =
            if sec == "" then
                []

            else
                [ M3e.heading
                    [ M3e.Component.Heading.variant Value.title
                    , M3e.Component.Heading.size Value.large
                    , M3e.Attributes.level 3
                    , M3e.Attributes.id (Doc.slugify sec)
                    ]
                    [ M3e.text sec ]
                ]
    in
    headingEl ++ List.map (exampleBlock activeSurface) examples


{-| A live preview paired with a tab strip that switches its code between the API
surfaces (optionally `M3e`, then the required-record `component` / `build`
surfaces, and always `HTML`). The site-wide `activeSurface` is used when this
example offers it; otherwise it falls back to `defaultSurfaceFor ex` (the
example's own first-offered surface). Grouped as one `space-y-3` block so
title/preview/tabs/code stay tight while sections stay apart.
-}
exampleBlock : Surface -> UsageExample -> Element (TypedHtml.Component.Grouping.DivIs s) adm_ Msg
exampleBlock activeSurface ex =
    let
        offered : List Surface
        offered =
            List.map Tuple.second (surfacesFor ex)

        surface : Surface
        surface =
            if List.member activeSurface offered then
                activeSurface

            else
                defaultSurfaceFor ex
    in
    TypedHtml.div [ TA.class "space-y-3" ]
        [ TypedHtml.p [ TA.class "max-w-2xl" ] [ M3e.text ex.title ]
        , Doc.showcase (Doc.rawPreview ex.html)
        , surfaceTabs surface ex
        , Doc.Slider.slidingPanels
            (activeIndexFor surface ex)
            (List.map (\( _, l ) -> codeFor l ex) (surfacesFor ex))
        ]


{-| The 0-based position of the selected `surface` within `surfacesFor ex` — the panel
`slidingPanels` translates into view. Every panel in `surfacesFor ex` is mounted (one
`codeFor` surface each) so the prior panel can slide out as the new one slides in;
this index just drives the track offset. Clamps to 0 if the surface isn't offered
(unreachable — the selection comes from `defaultSurfaceFor`/a tab click, both drawn
from `surfacesFor`).
-}
activeIndexFor : Surface -> UsageExample -> Int
activeIndexFor surface ex =
    surfacesFor ex
        |> List.map Tuple.second
        |> List.indexedMap Tuple.pair
        |> List.filter (\( _, l ) -> l == surface)
        |> List.head
        |> Maybe.map Tuple.first
        |> Maybe.withDefault 0


{-| The surfaces offered for one example, in fixed order. Each Elm surface
(`M3e`, required-record `component`, `build`) appears only when it compiled for this example
(its field is non-null); `HTML` is the one universal surface and is always offered
last. Order: M3e, component, build, HTML.
-}
surfacesFor : UsageExample -> List ( String, Surface )
surfacesFor ex =
    let
        optional : Maybe String -> String -> Surface -> List ( String, Surface )
        optional field label surface =
            case field of
                Just _ ->
                    [ ( label, surface ) ]

                Nothing ->
                    []

        -- Record/Build are offered whenever the top surface exists. When their
        -- own field is present they show a real translation; when it's null they
        -- show an identical-by-design rationale (see `codeFor`) instead of being
        -- silently hidden. Only a null `top` (a composite with no single-component
        -- form) drops them entirely.
        recordBuild : Maybe String -> String -> Surface -> List ( String, Surface )
        recordBuild field label surface =
            case ( field, ex.top ) of
                ( Nothing, Nothing ) ->
                    []

                _ ->
                    [ ( label, surface ) ]
    in
    optional ex.top "M3e" Top
        ++ recordBuild ex.record "component" Record
        ++ recordBuild ex.build "build" Build
        ++ [ ( "HTML", Raw ) ]


{-| The surface an example opens on when the user hasn't chosen one: the first
surface `surfacesFor` offers (its strictest available Elm surface, or `HTML` when
no Elm surface compiled). `HTML` is always present, so the fallback is total.
-}
defaultSurfaceFor : UsageExample -> Surface
defaultSurfaceFor ex =
    surfacesFor ex |> List.head |> Maybe.map Tuple.second |> Maybe.withDefault Raw


{-| The per-example surface selector: the shared `tabStrip` over exactly the
surfaces this example offers.
-}
surfaceTabs : Surface -> UsageExample -> Element { s | tabs : M3e.Kind.Brand } admittedBy Msg
surfaceTabs current ex =
    tabStrip current (surfacesFor ex)


{-| A generic single-select layer tab strip: one `Tab` per `(label, surface)`, the
one matching `current` marked selected, each click a page-wide `SelectSurface`.
Shared by the Usage examples (offered surfaces = `surfacesFor ex`) and the
per-component API section (offered surfaces = the four API layers), so a click on
either strip moves both. `Tabs` paginates/scrolls horizontally on narrow viewports
natively, so there is no `overflow-x-auto` wrapper — that wrapper forces
`overflow-y: auto` (CSS spec) and trips a spurious vertical scrollbar on the
control's state-surface bleed.
-}
tabStrip : Surface -> List ( String, Surface ) -> Element { s | tabs : M3e.Kind.Brand } admittedBy Msg
tabStrip current entries =
    M3e.tabs []
        (List.map
            (\( lbl, surface ) ->
                M3e.tab
                    [ M3e.Attributes.selected (surface == current)
                    , M3e.Events.onClick (SelectSurface surface)
                    ]
                    [ M3e.text lbl ]
            )
            entries
        )


{-| The code block for the selected surface. The Elm surfaces highlight as Elm;
the raw `<m3e-*>` HTML surface highlights as plain markup.

`Top` is only offered by `surfacesFor` when its field is present, so its `Nothing`
branch is defensive (falls back to HTML). `Record` and `Build` ARE offered with a
null field — when this example's content had nothing for that surface to lift, the
surface is identical to `M3e` by design, so we show a short rationale instead of a
hollow duplicate.

-}
codeFor : Surface -> UsageExample -> Element (TypedHtml.Component.Grouping.DivIs s) admittedBy msg
codeFor surface ex =
    let
        elmOrHtml : Maybe String -> Element (TypedHtml.Component.Grouping.DivIs s) admittedBy msg
        elmOrHtml field =
            case field of
                Just code ->
                    Doc.codeBlock Doc.Elm code

                Nothing ->
                    Doc.codeBlock Doc.Xml ex.html

        recordBuildCode : Maybe String -> String -> Element (TypedHtml.Component.Grouping.DivIs s) admittedBy msg
        recordBuildCode field surfaceName =
            case field of
                Just code ->
                    Doc.codeBlock Doc.Elm code

                Nothing ->
                    identicalSurfaceNote surfaceName
    in
    case surface of
        Top ->
            elmOrHtml ex.top

        Record ->
            recordBuildCode ex.record "component"

        Build ->
            recordBuildCode ex.build "build"

        Raw ->
            Doc.codeBlock Doc.Xml ex.html


{-| Shown on a `Record`/`Build` tab whose surface is identical to `M3e` for this
example: the example's content carried no required slots or attributes for the
record/pipeline surface to enforce, so the translator emitted no distinct form.
We surface that fact rather than hiding the tab (a hidden tab reads as "this
surface doesn't apply", which is the wrong lesson — it applies, it's just a no-op
here).

Wrapped with the same `overflow-x-auto p-4` treatment as `Doc.codeBlock` so that
the paragraph does not overflow on mobile when this panel is the inactive (inert)
panel in a `Doc.Slider.slidingPanels` stack.

-}
identicalSurfaceNote : String -> Element (TypedHtml.Component.Grouping.DivIs s) admittedBy msg
identicalSurfaceNote surface =
    -- The outer `<div>` stays a plain div — this is one arm of the `case` in
    -- `codeFor`, whose other arms are `Doc.codeBlock` (also `DivIs`), and
    -- `overflow-x-auto` is kept here as the visible scroll affordance. The
    -- former surface/foreground pair (`bg-surface-container` + `text-on-surface`
    -- + `rounded-md-corner-medium`) becomes an `m3e-card` (`filled`) in the
    -- default (unpadded) slot, with `p-4` kept as the inner paragraph's own
    -- layout padding so the card isn't double-padded.
    TypedHtml.div [ TA.class "overflow-x-auto" ]
        [ M3e.card
            [ M3e.Attributes.variant Value.filled ]
            [ TypedHtml.p [ TA.class "p-4" ]
                [ M3e.text
                    (surface
                        ++ " is identical to the M3e tab for this example — its content has no required slots or attributes for the "
                        ++ surface
                        ++ " surface to enforce, so it would be a hollow duplicate of M3e. Reach for "
                        ++ surface
                        ++ " on an example whose composition it can hold a guarantee over."
                    )
                ]
            ]
        ]


{-| Group examples by `.section`, preserving first-seen order of both sections and
examples within each section.
-}
groupBySection : List UsageExample -> List ( String, List UsageExample )
groupBySection examples =
    let
        sections : List String
        sections =
            List.foldl
                (\ex acc ->
                    if List.member ex.section acc then
                        acc

                    else
                        acc ++ [ ex.section ]
                )
                []
                examples
    in
    List.map (\sec -> ( sec, List.filter (\ex -> ex.section == sec) examples )) sections
