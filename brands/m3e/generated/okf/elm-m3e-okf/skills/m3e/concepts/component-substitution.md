# Component substitution — why the closest match isn't good enough

Two `<m3e-*>` components can look alike and still mean different things. When a real,
correct component exists for an intent, reaching for a visually-similar substitute — or
for a hand-built layout composition — instead of the correct one is a defect, not a
style choice.

## The rule

**The semantically-correct component is always preferred over a substitute, even when
the substitute needs less new code.** "It looks the same" is not "it is the same": two
components can render an identical row of icons and still carry opposite meaning to
assistive tech, motion behavior, and the next person who reads the tag name to
understand intent.

## Worked example: Card vs. Toolbar for playback controls

A media-playback control set (thumbnail, title/artist text, transport buttons) was
built with `M3e.Component.Card` — `M3e.card` with the progress bar in `Card.header`
and the transport row in `Card.content` (this is still the shape of `mediaPlayer` in
`elm-m3e`'s `docs/app/Route/Examples/DetailedView.elm` today — it compiles and renders
correctly, which is exactly why the mistake is easy to miss). It looked right. It used
the wrong component.

The two components' own doc comments say what each is actually for:

- **`Card`**: "A content container for text, images (or other media), and actions **in
  the context of a single subject**." Card's slots (`header`/`content`/`footer`/
  `actions`) exist to lay out a bounded surface *about* something — a subject plus its
  supporting content and the actions that apply to it.
- **`Toolbar`**: "Presents **frequently used actions relevant to the current page**."
  Toolbar has no content slots at all — only a child slot for actions, plus
  `variant`/`shape`/`elevated`/`vertical` for arranging an *action group* as its own
  first-class thing.

A transport row (play/pause/skip/etc.) is not "content about a subject" that a
container happens to hold actions for — it *is* a group of frequently-used actions.
That is Toolbar's actual semantic, not an incidental one Card also technically
supports via its `actions`/`content` slots. Card fitting the markup (a header slot for
the progress bar, a content slot for the row) does not make Card *correct* — it makes
Card *permissive*. Permissive is not the same test as correct.

## The ladder: choosing among M3e components

This extends the ladder in `auditing-m3e-escapes` (M3e > TypedHtml > escape) to a
different axis: not "should this leave the typed tree" but "which correct M3e
component covers this intent, once more than one superficially fits." Resolve in this
order; stop at the first rung that works.

1. **The real, semantically-correct `M3e` component** — the one whose own doc comment
   describes this exact intent. A row of frequently-used actions is a `Toolbar`, not a
   `Card`, even though `Card` has slots that also happen to fit the markup.
2. **A documented, deliberate composition of correct primitives**, when no single
   component covers the intent. Composition is allowed — it is not a fallback in
   disguise — but only when it is reasoned and the reasoning is written down next to
   the code. `DetailedView.elm`'s own `thumbnailIcon` and `playerRow` are the
   precedent: each carries a doc comment naming which components were checked, which
   slot kinds they don't admit, and why the composition is the least-wrong option. A
   composition with no comment is unreviewable — nobody downstream can tell "reasoned"
   from "reached for the first thing that compiled."
3. **A plain layout primitive** (Tailwind layout-only classes, per this repo's
   layout-only convention), only for pure structural grouping that carries no semantic
   weight of its own — arranging already-semantic children, never standing in for a
   missing or wrong component. Every rung-3 choice needs a written reason, exactly like
   rung 3 of the escape ladder.

Two clauses carry this page, mirrored from `auditing-m3e-escapes`:

- **A wrong-but-close component is a defect, not a style preference.** "Card also has
  slots that fit" is not a justification for using Card where Toolbar is correct.
- **Silence is not a justification.** Rungs 2 and 3 both require a comment stating
  which components were checked and why they didn't fit. An uncommented composition is
  presumed to be rung-1 avoidance until proven otherwise.

## Related

_See also: [Choosing components](choosing-components.md) · the `auditing-m3e-escapes`
skill in the elm-m3e package (a parallel ladder for the M3e/TypedHtml/escape axis —
not linked here directly since it lives in a separate, non-co-located package)._
