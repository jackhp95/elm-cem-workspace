# Plan: `m3e-okf` knowledge-base entry — component substitution / the escape ladder

**Spec:** `core/cem-figma-connect/research/2026-08-19-structural-fidelity-ideation.md`, lever **C2b** (documentation half only — the "transpose to Figma-write direction" half is explicitly out of scope, since D6 stands: no code-driven Figma authoring, period. This plan is scoped purely to how a human or an agent chooses among **code-side** `M3e` components when authoring Elm, independent of Figma).

## Context

`m3e-okf` (the Material 3 knowledge base) has a thorough forward map (`skills/m3e/concepts/choosing-components.md`: intent → component, across 9 families) and exactly one tie-break rule, for when two components both plausibly fit. It has **no** guidance for the case that actually caused a real mistake on 2026-08-19: a media-playback control set was built using `M3e.Component.Card` when `M3e.Component.Toolbar` was the semantically correct component. Jack's own framing: **"COMPONENT SHOULD ALWAYS BE PREFERRED"** — meaning when a real, correct component exists for the intent, using a different, "close enough" component (or falling back to a plain layout primitive) instead is a defect, not a style choice.

The reasoning already exists, uncodified, in `brands/m3e/outputs/elm-m3e/docs/app/Route/Examples/DetailedView.elm`'s five inline substitution comments, and the *policy shape* already exists (for a different escape axis — M3e vs. plain HTML vs. `Unsafe`) in `brands/m3e/outputs/elm-m3e/skills/auditing-m3e-escapes/SKILL.md`'s escape ladder. This plan transposes that ladder's discipline to the specific, previously-uncovered case of choosing **among M3e components** when more than one is superficially plausible for the same visual intent.

## Goal

A new `m3e-okf` knowledge-base page, in the house style of its existing `anti-patterns/` and `concepts/` docs, that:
1. States the rule: the correct, semantically-matching component is always preferred over a visually-similar substitute or a hand-built layout-primitive composition, even if the substitute requires less new code.
2. Gives the real Card-vs-Toolbar mistake as the worked example (media-playback controls need `Toolbar`'s action-grouping semantics, not `Card`'s content-container semantics — describe the actual functional difference, not just "wrong label").
3. States, as a rung ladder mirroring `auditing-m3e-escapes`'s own rungs and its two load-bearing clauses (*"a defect, not a style preference"*, *"silence is not a justification"*): (a) the real, semantically-correct `M3e` component; (b) a documented, deliberate composition of correct primitives when no single component covers the intent (cite `DetailedView.elm`'s own precedent: `thumbnailIcon`/`playerRow` as *reasoned* composition, with the reason written down); (c) a plain layout primitive (Tailwind layout-only classes, per this repo's existing layout-only convention) **only** for pure structural grouping that carries no semantic weight of its own — never as a stand-in for a missing or wrong component; every rung-(c) choice needs a written reason, exactly like rung 3 of the existing escape ladder.
4. Cross-links from `skills/m3e/concepts/choosing-components.md` (the existing forward map) so it's discoverable from the place someone would already be looking.

## Global Constraints

- Documentation only. No code changes, no Figma calls, no changes to any `M3e.*` module.
- Match `m3e-okf`'s existing frontmatter/structure conventions exactly (`type: anti-pattern` or `type: concept` as appropriate, `sources`, `tags`, `timestamp` — copy the shape from an existing file such as `knowledge/anti-patterns/re-abstracting-design-tokens.md` or `skills/m3e/concepts/choosing-components.md`, don't invent a new frontmatter shape).
- Do not restate `auditing-m3e-escapes`'s existing ladder — link to it and extend it for the new axis (component-choice vs. component-vs-HTML), so the two documents stay a single coherent policy rather than two competing ones.

## Tasks

### Task 1: Draft the KB page

- Read `brands/m3e/outputs/elm-m3e/skills/auditing-m3e-escapes/SKILL.md` in full (the ladder to mirror) and `brands/m3e/outputs/elm-m3e/docs/app/Route/Examples/DetailedView.elm`'s five inline substitution comments (the worked precedent) before drafting anything.
- Read 2-3 existing `m3e-okf` `knowledge/anti-patterns/*.md` files and `skills/m3e/concepts/choosing-components.md` for house style (heading structure, frontmatter, tone, length — these are short, dense pages, not essays).
- Write the new page (pick the right location under `m3e-okf`'s existing directory structure — `knowledge/anti-patterns/` if framed as "don't substitute", `skills/m3e/concepts/` if framed as "how to choose" — read both directories' existing contents and decide which fits better, then say why in the report).
- Include the Card-vs-Toolbar example concretely: what `Toolbar` provides that `Card` doesn't for a playback-controls use case (grep `Toolbar.elm` and `Card.elm`'s own doc comments for their real intended-use descriptions — don't guess).

### Task 2: Cross-link and verify

- Add a link/reference from `skills/m3e/concepts/choosing-components.md` to the new page, in whatever style that file already uses for cross-references to other concept/anti-pattern pages.
- Verify (grep) that no other `m3e-okf` doc's existing prose already contradicts what you've written — if you find one that does, reconcile it (fix the older doc or adjust the new one, whichever is actually correct) rather than leaving two files disagreeing.
- If this repo has a docs-lint/link-check gate for `m3e-okf` (check for one — e.g. a `check:` script in the relevant `package.json`), run it and confirm it passes.

## Acceptance

- New KB page exists, in house style, cross-linked from the existing forward map.
- The Card-vs-Toolbar case is documented with the real functional distinction, not just "use the right one."
- No contradictions introduced with existing `m3e-okf` content.
- Any repo doc-lint/link-check gate for this package passes.
