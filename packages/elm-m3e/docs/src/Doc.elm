module Doc exposing
    ( Lang(..), anchorPill, codeBlock, elmSignature, markdown, message, pageHeading, pane, preBlock, rawPreview, recapBox, sectionHeadingWithId, sectionLabel, sectionLabelCaps, showcase, userlandNote
    , slugify
    )

{-| Shared documentation-rendering helpers, lifted from the Styles/GettingStarted
routes so per-component Usage pages can reuse them.

This is also the docs app's designated **escape adapter** (see `docs/DESIGN.md` §4):
the doc routes render syntax-highlighted code, Markdown, and small raw-HTML leaves
that have no typed M3e producer, so those raw-`Html`→`Element` crossings are
centralised here as named helpers (`rawPreview`, `markdown`, `codeBlock`,
`elmSignature`, `anchorPill`, `preBlock`, `message`) instead of scattering
`M3e.Unsafe.fromHtml` through feature routes.

Every one of those helpers returns an `Element` with **free** phantom rows,
because `M3e.Unsafe.fromHtml` asserts nothing about what it wraps — so they drop
into any slot, and no caller has to name a kind row to receive one.

@docs Lang, anchorPill, codeBlock, elmSignature, markdown, message, pageHeading, pane, preBlock, rawPreview, recapBox, sectionHeadingWithId, sectionLabel, sectionLabelCaps, showcase, userlandNote
@docs slugify

-}

import Doc.Fold as Fold
import Html exposing (Html, p, text)
import M3e exposing (Element)
import M3e.Attributes
import M3e.Component.AssistChip
import M3e.Component.Card
import M3e.Component.ContentPane
import M3e.Component.Heading
import M3e.Kind
import M3e.Unsafe
import M3e.Unsafe.Attributes
import M3e.Values as Value
import Markdown.Parser
import Markdown.Renderer
import SyntaxHighlight
import TypedHtml
import TypedHtml.Attributes as TA
import TypedHtml.Component.Grouping


{-| A matraic-style "showcase" card: live demo content in an outlined card.

Deliberately NOT an overflow container: making the card `overflow-x-auto` forces
`overflow-y: auto` (CSS spec), and m3e components' ~4px state-layer bleed then
trips a spurious vertical scrollbar. The inner preview (`rawPreview`) wraps its
items instead, so the card stays within `max-w-full` without clipping — a live
example's escaping menu/tooltip is free to overflow the card.

-}
showcase : Element accepts admittedBy msg -> Element (M3e.Component.Card.Is s) freeAdm msg
showcase content =
    M3e.card
        [ M3e.Component.Card.variant Value.outlined, TA.class "max-w-full" ]
        [ M3e.Component.Card.content content ]


{-| Render a raw HTML string as live DOM. The embedded `<m3e-*>` custom elements
upgrade in place (they are registered globally via `@m3e/web/all` in `index.ts`),
inheriting the page's `<m3e-theme>` context — so the preview is live and themed.

Set via the `innerHTML` property (not children), so Elm's virtual DOM leaves the
injected subtree alone. Pre-render emits the empty wrapper; the content populates
on hydration.

-}
rawPreview : String -> Element accepts admittedBy msg
rawPreview html =
    M3e.Unsafe.customElement "raw-html"
        [ M3e.Unsafe.Attributes.customAttribute "content" html

        -- Plain block flow, matching matraic's `.showcase` (which sets no
        -- flex): each component uses its own `display`, so inline components
        -- (buttons/chips) flow and wrap while full-width components (linear
        -- progress, sliders, dividers, text fields) fill the row. No flex
        -- row — that collapses width-less components to min-content. No
        -- overflow clipping either: an escaping menu/tooltip must be free to
        -- leave the card, and `overflow-x-auto` would force a spurious
        -- vertical scrollbar off the ~4px state-layer bleed.
        , TA.class "max-w-full py-2"
        ]
        []


{-| A syntax-highlighted code block. `Elm` for example code, `NoLang` for raw HTML.
-}
type Lang
    = Elm
    | Shell
    | Xml
    | NoLang


{-| -}
codeBlock : Lang -> String -> Element (M3e.Component.Card.Is s) admittedBy msg
codeBlock lang s =
    let
        trimmed : String
        trimmed =
            String.trim s
    in
    -- Auto-derived folding: the fold tree is computed from the raw
    -- string and highlighted per line, so we assemble nested `<details>`
    -- ourselves rather than emitting one flat highlighted block. The
    -- `m3e-card` (`filled`) supplies the surface/radius a deleted
    -- `.doc-code-block` stylesheet class used to fake. Content goes through
    -- the `content` slot so padding comes free from the card's own tokens
    -- (verified in `@m3e/web`'s CSS: `slot[name="content"]` gets a margin
    -- from `CardToken.padding`) instead of a hand-painted `p-4`. Only the
    -- horizontal-scroll concern needs its own div, scoped to the text so the
    -- card's border/corners stay fixed while just the code scrolls.
    M3e.card
        [ M3e.Attributes.variant Value.filled ]
        [ M3e.Component.Card.content
            (TypedHtml.div [ TA.class "overflow-x-auto" ]
                [ M3e.Unsafe.fromHtml (Fold.viewWith (highlightLine lang) trimmed) ]
            )
        ]


{-| Highlight a single code line, keeping the `.elmshN` token classes. Falls
back to plain text if the line doesn't tokenize (never crashes; per-line
highlighting can lose multi-line context, but example code rarely has it).
-}
highlightLine : Lang -> String -> Html msg
highlightLine lang line =
    let
        parsed : Result () SyntaxHighlight.HCode
        parsed =
            (case lang of
                Elm ->
                    SyntaxHighlight.elm line

                Shell ->
                    SyntaxHighlight.noLang line

                Xml ->
                    SyntaxHighlight.xml line

                NoLang ->
                    SyntaxHighlight.noLang line
            )
                |> Result.mapError (always ())
    in
    case parsed of
        Ok highlighted ->
            SyntaxHighlight.toInlineHtml highlighted

        Err _ ->
            text line


{-| Render a Markdown string (component overviews, member docs) as live DOM.
Falls back to the raw text in a paragraph if parsing/rendering fails, so a
malformed doc-comment never blanks the page. The `doc-prose` wrapper carries
the prose spacing/typography from `style.css`.
-}
markdown : String -> Element (TypedHtml.Component.Grouping.DivIs s) admittedBy msg
markdown raw =
    TypedHtml.div [ TA.class "doc-prose" ]
        (List.map M3e.Unsafe.fromHtml (markdownBody raw))


{-| The route content pane: the standard `M3e.contentPane` wrapper every docs
route hands to `View.fromElement` at its root.
-}
pane : List (Element childAccepts (M3e.Component.ContentPane.ChildAdmittedBy childAdm) msg) -> Element (M3e.Component.ContentPane.Is s) freeAdm msg
pane items =
    M3e.contentPane [ TA.class "mx-auto max-w-5xl space-y-12" ] items


{-| A page's `<h1>`: display-small heading.
-}
pageHeading : String -> Element (M3e.Component.Heading.Is s) admittedBy msg
pageHeading s =
    M3e.heading
        [ M3e.Component.Heading.variant Value.display
        , M3e.Component.Heading.size Value.small
        , M3e.Attributes.level 1
        ]
        [ M3e.text s ]


{-| A section's `<h2>`: headline-small heading, carrying an `id` so it has a
stable, bookmarkable anchor. `Shared.tocPanel`'s `m3e-toc` auto-discovers
every heading on the page at render time, but falls back to a random `guid()`
for any heading with no `id` -- pairing with `Doc.slugify` here keeps the
anchor stable across renders:

    Doc.sectionHeadingWithId (Doc.slugify "Container pairings") "Container pairings"

-}
sectionHeadingWithId : String -> String -> Element (M3e.Component.Heading.Is s) admittedBy msg
sectionHeadingWithId id s =
    M3e.heading
        [ M3e.Component.Heading.variant Value.headline
        , M3e.Component.Heading.size Value.small
        , M3e.Attributes.level 2
        , M3e.Attributes.id id
        ]
        [ M3e.text s ]


{-| Derive a stable `id` from a heading's own display text -- lowercase,
non-alphanumeric runs collapsed to a single hyphen, so "Container pairings"
becomes "container-pairings" and "Invalid states don't compile" becomes
"invalid-states-don-t-compile". Used everywhere a `sectionHeadingWithId` id
is needed, so the id is computed from the SAME string the heading displays --
never a second, independently hand-typed literal that could quietly drift
from the visible text.
-}
slugify : String -> String
slugify text =
    text
        |> String.toLower
        |> String.map
            (\c ->
                if Char.isAlphaNum c then
                    c

                else
                    '-'
            )
        |> String.split "-"
        |> List.filter (not << String.isEmpty)
        |> String.join "-"


{-| The chapter recap box: a "Recap" overline over rendered markdown, in a
tinted container.

The container is an `m3e-card` (`filled`) rather than a painted `div`, so the
surface/foreground pairing comes from the component's own tokens. The "Recap"
overline drops its former `text-primary` accent: no m3e component exposes a
colour override for `m3e-heading`, and this docs app's own styling ladder has
no token-backed semantic class to fall back to, so the eyebrow now renders in
the heading's default colour. See `NoProprietaryDsClasses` burn-down notes.

-}
recapBox : String -> Element (M3e.Component.Card.Is s) adm_ msg
recapBox md =
    M3e.card
        [ M3e.Component.Card.variant Value.filled ]
        [ TypedHtml.div [ TA.class "p-4 space-y-2" ]
            [ M3e.heading
                [ M3e.Component.Heading.variant Value.label
                , M3e.Component.Heading.size Value.large
                ]
                [ M3e.text "Recap" ]
            , TypedHtml.div [] [ markdown md ]
            ]
        ]


{-| A sentence-case section label (label-lg, on-surface-variant, via `m3e-heading`).
Use for overline labels that introduce API sections or content groups.
No uppercase — M3 permits uppercase only for very short labels (≤20 chars);
long dynamic labels can exceed that, so this helper always uses sentence case.
-}
sectionLabel : String -> Element (M3e.Component.Heading.Is s) adm_ msg
sectionLabel s =
    M3e.heading
        [ M3e.Component.Heading.variant Value.label
        , M3e.Component.Heading.size Value.large
        ]
        [ M3e.text s ]


{-| Was the all-caps twin of [`sectionLabel`](#sectionLabel): same role, but
uppercase. `uppercase`/`tracking-wide` are Tailwind painting utilities (a
`text-transform`, not a layout concern) with no `m3e-heading` attribute
equivalent, so under the layout-only-styling policy the visual distinction
between "sentence case" and "caps" collapsed — this now renders identically to
`sectionLabel`. Kept as a separate name only so the ≤20 call sites that chose
it explicitly for its former caps styling don't need touching; consider
migrating them to `sectionLabel` directly, or restoring caps via
`String.toUpper` if the visual distinction is worth an a11y/i18n tradeoff
(screen readers get the transformed text, not the original).
-}
sectionLabelCaps : String -> Element (M3e.Component.Heading.Is s) adm_ msg
sectionLabelCaps s =
    sectionLabel s


markdownBody : String -> List (Html msg)
markdownBody raw =
    let
        rendered : Result () (List (Html msg))
        rendered =
            Markdown.Parser.parse raw
                |> Result.mapError (always ())
                |> Result.andThen
                    (\blocks ->
                        Markdown.Renderer.render Markdown.Renderer.defaultHtmlRenderer blocks
                            |> Result.mapError (always ())
                    )
    in
    case rendered of
        Ok html ->
            html

        Err _ ->
            [ p [] [ text (String.trim raw) ] ]


{-| A labelled callout box — an eyebrow label over Markdown body — for asides that
must not read as body prose (e.g. "these modules are yours to write"). The body is
full Markdown, so it can carry links and inline `code`.

An `m3e-card` (`filled`), replacing the hand-painted surface. This drops the
former left accent bar (`border-l-4 border-primary`): `m3e-card` has no accent-bar
affordance, and adding one back would mean inventing a new token-backed CSS class,
which is out of scope here (see `NoProprietaryDsClasses` burn-down notes) — a
defensible tradeoff since the eyebrow label above already marks this as a notice.

-}
callout : String -> String -> Element (M3e.Component.Card.Is s) admittedBy msg
callout label body =
    M3e.card
        [ M3e.Component.Card.variant Value.filled ]
        [ TypedHtml.div [ TA.class "p-4 space-y-2" ]
            [ M3e.heading
                [ M3e.Component.Heading.variant Value.label
                , M3e.Component.Heading.size Value.medium
                ]
                [ M3e.text label ]
            , TypedHtml.div [ TA.class "doc-prose" ]
                (List.map M3e.Unsafe.fromHtml (markdownBody body))
            ]
        ]


{-| The shared "these helpers are our examples, not the library" callout, used
everywhere an example leans on a `Doc.*` helper. One definition, so the framing
can't drift.
-}
userlandNote : Element (M3e.Component.Card.Is s) admittedBy msg
userlandNote =
    callout "These helpers are our examples, not the library"
        """The `Doc.*` helpers in these examples are **this docs app's own module** — not part of `elm-m3e` (they won't resolve from a fresh install). You rarely need anything like them. The library gives you typed components (`M3e.*`) plus `TypedHtml` for standard HTML, and you never import `HtmlIr`: `M3e.Element`, `M3e.Attr`, `M3e.Node`, `M3e.Values.Value` and `M3e.Kind.Supported` / `.Shared` are all re-exported, so every type annotation you need is reachable from the brand. Build layout, text, and links directly from those. The genuine *escapes* ship with the library too, in one greppable, lint-fenced place — `M3e.Unsafe` (`fromHtml`, `fromNode`, `recast`, and `customElement` for a custom tag the types can't express) and `M3e.Unsafe.Attributes`. See [Escapes](/guide/seams)."""


{-| A syntax-highlighted Elm type signature (for API member rows). Rendered as an
inline `<code>` block so it wraps within the list item; falls back to plain text
if it doesn't tokenize as Elm.
-}
elmSignature : String -> Element (TypedHtml.Component.Grouping.DivIs s) admittedBy msg
elmSignature s =
    let
        trimmed : String
        trimmed =
            String.trim s
    in
    case SyntaxHighlight.elm trimmed of
        Ok highlighted ->
            -- Only the highlighter's output is genuinely raw; the wrapper is a
            -- plain `<div>` the typed layer provides, so the escape covers the
            -- leaf rather than the subtree.
            TypedHtml.div []
                [ M3e.Unsafe.fromHtml (SyntaxHighlight.toInlineHtml highlighted) ]

        Err _ ->
            -- Same wrapper as the Ok branch so both arms are a `<div>`; the
            -- fallback just carries plain text instead of highlighted spans.
            TypedHtml.div []
                [ TypedHtml.code [] [ M3e.text trimmed ] ]


{-| A rounded "pill" anchor for the reference index (a same-page `#slug` link
carrying the outline/hover chrome).

This IS `m3e-assist-chip`: a chip that carries a native `href`, which is exactly
this pill's job. It went through a plain `<a>` for a while because the chip's kind
(`{ s | assistChip : Brand }`) could not satisfy this function's old
`{ s | sharedText : Shared }` annotation — `s` is rigid inside the body, so the
compiler could not add the chip's field to whatever the caller had chosen.

The fix was to widen the annotation rather than to force the crossing. An
assist-chip genuinely IS phrasing content; the signature was simply too narrow, and
an escape here would have papered over that rather than fixed it. `Route.Guide`'s
`chapterLink` re-declares the same type and was widened with it.

-}
anchorPill : { href : String, label : String } -> Element { s | assistChip : M3e.Kind.Brand } admittedBy msg
anchorPill link =
    M3e.assistChip
        [ M3e.Component.AssistChip.href link.href ]
        [ M3e.text link.label ]


{-| A horizontally-scrollable `<pre><code>` block for a verbatim signature line.
-}
preBlock : String -> Element (TypedHtml.Component.Grouping.PreIs s) admittedBy msg
preBlock s =
    TypedHtml.pre [ TA.class "overflow-x-auto" ]
        [ TypedHtml.code [] [ M3e.text s ] ]


{-| A minimal `<div><p>…</p></div>` text block, for framework surfaces (e.g. the
error page) that render a plain message with no typed M3e producer at hand.
-}
message : String -> Element (TypedHtml.Component.Grouping.DivIs s) admittedBy msg
message body =
    TypedHtml.div [] [ TypedHtml.p [] [ M3e.text body ] ]
