# Plan — Compose IA rework (Gauntlet Loop)

**Status:** PLAN ONLY. No product code changed by writing this. Execution is a Gauntlet Loop on
Paseo, dispatched only after the human approves scope (and, for Part 1, the task-B fix).
**Driver:** [`../spikes/2026-08-15-compose-ia-review.md`](../spikes/2026-08-15-compose-ia-review.md)
(the hands-on audit) and [`../spikes/2026-08-15-compose-1.3-diagnosis.md`](../spikes/2026-08-15-compose-1.3-diagnosis.md)
(the §1.3 root-cause).
**Surface under change:** the docs-app consumer route only —
`packages/elm-m3e/docs/app/Route/Components/Compose.elm` and `app/Compose/{Attrs,Render,Codegen,FromHtml}.elm`.
The published headless core `packages/elm-cem-compose/src/Cem/Compose.elm` is **out of scope** for
every part below (see "Core boundary"). If any part is found to need a core change, it STOPS and
escalates — a core change bumps a published package version and is a separate product decision.

---

## 0. Orientation for the executing manager

- **Model discipline (HARD):** builders = `claude/sonnet`; critics/integrator = `claude/claude-opus-4-8`.
  NEVER `claude/opus` (resolves to banned opus-5), never opus-5/fable-5. UX-copy/visual-judgement
  sub-steps (Parts 5–6) are Opus-appropriate per `~/.paseo/orchestration-preferences.json`, but
  keep the *builder* on Sonnet and let the Opus critic own the aesthetic judgement, or dispatch the
  copy sub-step itself to Opus. Name every model by full ID.
- **Commit the ledger before dispatching any loop** (D-009/D-021). Stage explicit paths; never
  `git add -A` while a loop runs.
- **Gates are manager-run where slow.** `node tools/gate-all.mjs` (~350s) and `pnpm run bump` are
  NEVER loop verify-checks (D-015/D-024). Per-part loop checks use the fast, scoped gates below.
- **Generated code is the spec.** `app/Compose/Attrs.elm` is generated
  (`check:compose-attrs` guards it) — never hand-edit it to pass a gate; change the generator/config
  and regenerate. The other `app/Compose/*` and the route are hand-written and fair game.

## 1. Objective gates (the loop's verify-checks)

Each is fast enough to be a loop check and fails loudly on regression. Run from
`packages/elm-m3e/docs` unless noted.

| Gate | Command | What it proves |
|---|---|---|
| **G-compile** | `pnpm --filter elm-m3e run check` covers Elm compile+review+format; for a tight loop use `npx elm make app/Route/Components/Compose.elm --output=/dev/null` | the route compiles |
| **G-review** | `npm run check:review` (elm-review, incl. the elm-pages router guard D-047) | no elm-review violations; router shape intact |
| **G-attrs** | `npm run check:compose-attrs` | generated `Compose/Attrs.elm` not hand-edited |
| **G-browser** | `node scripts/browser-guard.mjs compose.spec.ts` (port 1239; `pretest:browser` frees it; ~40s + build) | the real DOM/shadow-DOM behavior — the acceptance harness |
| **G-core-untouched** | `git diff --quiet -- packages/elm-cem-compose` | the published core was not touched |

**G-browser is the acceptance gate for every part.** Each part adds/extends `compose.spec.ts`
assertions; the part is DONE only when its new assertions pass AND all prior compose tests stay
green (the suite is the regression net). Because `compose.spec.ts` asserts DOM/shadow-DOM truth
(the audit's whole point — the visual layer must match the model), it is the right acceptance
surface for an IA change.

**Screenshots for human review:** each part attaches before/after Playwright screenshots
(`browser_take_screenshot` on `/components/compose` at desktop + mobile widths) to its integrator
report. IA quality is a human judgement; the gates prove correctness/no-regression, the screenshots
let the human approve the look.

## 2. Core boundary (non-negotiable)

`Cem.Compose` is a published package (v1.2.0). Its API — `Msg`, `slotChips`, `attrChips`,
`slotMenuOptions`, `componentOptions`, `AttrChipInfo`, `SlotChipInfo`, etc. — is a published
surface. Every part below is achievable in the consumer route using the data the core **already
exposes** (`AttrChipInfo.isSet/currentValue/kind`, `SlotChipInfo.filled/max/affordances/required`,
`slotMenuOptions`, `componentOptions`). If a builder claims a part needs a new core query, that is
an escalation to the human, not a core edit — it would bump `elm-cem-compose` and belongs in a
separate product step.

---

## 3. Parts (in the audit's priority order)

### Part 1 — §3.3 correctness gate: bind the chip pressed-state to the model (BLOCKS the rest)

**This is the task-B fix.** Gate-blocking for the whole rework: no relabeling matters until the
pressed signal is trustworthy. See `2026-08-15-compose-1.3-diagnosis.md` §4 for the full root-cause
and fix.

- **Change:** remove `M3e.Attributes.toggle True` from the three chip builders in `Compose.elm`
  (`discreteAttrButtonElement`, the `PlainChip _` branch of `attrButtonElement`, `slotButtonElement`),
  keeping `M3e.Attributes.selected info.isSet` / `selected (info.filled > 0)` so the pressed styling
  is purely model-derived. No core change.
- **New G-browser assertions:**
  1. open an attribute chip's menu, dismiss it **without** selecting (Escape / click-away) → chip is
     NOT `[selected]`/pressed and the `.cf-root` snippet is unchanged (the regression the audit found).
  2. after actually selecting a value, the chip IS pressed AND the snippet changed (guard against
     over-correcting to never-pressed).
  3. all existing `compose.spec.ts` stay green (menus still open on these buttons).
- **Escalation guard:** if removing `toggle` breaks `menuTrigger` popover opening, STOP and report —
  do not reach for a core change; the fix is a consumer-side host/markup adjustment.
- **Human sign-off:** required before dispatch (per the brief — even a consumer-route fix is reported
  first). This part is pre-approved to dispatch only once the human okays the diagnosis's proposed fix.

### Part 2 — §3.1 split "change component" from "add child" (highest IA leverage)

The literal "IA is bad" complaint: the change-component menu and the add-child menu are today two
faces of one flat ~300-item dump mixing component types with doc-example titles.

- **2a — Change-component menu = component types only, grouped + filterable.**
  - Remove example items from `componentMenuElement` (drop `exampleMenuItemsForChangeComponent` from
    the type picker; move example-loading to the add-child menu only, or to a distinct "load example"
    affordance — see 2c).
  - Group the `componentOptions` list by the docs' existing left-nav categories so the mental model
    matches the sidebar. The category map already exists for the Components nav — reuse it (find it
    under `app/` / `Doc*`; do not invent a second taxonomy). Render category subheaders in the menu.
  - Add a filter/search box at the top of the root's menu (the root offers every component, ~130+);
    height-cap already exists (`max-h-64 overflow-y-auto`). Nested nodes' menus are already short
    (parent-slot-constrained) — search optional there.
  - Data comes from `Cem.Compose.componentOptions path model` (already type-directed); grouping is a
    pure consumer-side partition of that list against the nav taxonomy. No core change.
- **2b — Add-child menu = three fixed primitives, then clearly-headed examples.**
  - `slotMenuElement`: render `Text` / `Icon` / component options with a visible structural grouping
    (primitives first, then a labeled "Nest a component" group), matching the small-menu discipline
    the attribute value menu already gets right (audit §2).
  - Example items (`exampleMenuItemsForAddChild`) move under a captioned "Load an example" subsection
    and are **qualified by source component** ("Avatar — Usage", "Heading — Label Small (2)") so
    duplicate bare titles become distinguishable (audit §1.2).
- **2c — Investigate the §1.2 "identical menu for two different slots" observation.** The audit saw
  the `unnamed` slot menu on one listItem show the same options as the `overline` menu on another.
  Determine whether this is (i) correct (both slots genuinely afford the same kinds per facts) or
  (ii) a leaked/stale popover. This is a **diagnosis sub-step** (systematic-debugging): confirm
  against `slotMenuOptions` for each slot before changing anything. If it is a real popover-identity
  bug, it may be an m3e-menu wiring issue (id/`for` collision) — fix in the consumer route or
  escalate if it is a web-component limitation (see D-047's documented m3e limits).
- **G-browser:** the type-picker menu contains **no** `.compose-example-item`; category subheaders
  present; the filter narrows the list; the add-child menu shows the three primitives then the
  qualified example subsection; the existing "offers every valid kind" and "only offers what the
  parent slot accepts" tests stay green (adjust selectors for the new grouping, not the assertions'
  intent).

### Part 3 — §3.2 attribute/slot visual separation + "has content" vs "empty" chip states

- Give the `ATTRIBUTES` and `SLOTS` groups real structural separation (background tint or
  left-border color per group), not just caption labels. The two groups are already separated
  containers (`attrGroup`/`slotGroup`); this is a styling pass on those wrappers.
- Empty slot chip vs. filled slot chip become categorically different: `+ name` (add affordance)
  only on `info.filled == 0`; a filled slot shows name + count at heavier weight with no `+`. Data
  is `SlotChipInfo.filled` (already available); `slotCountTrailing` already gates the badge on
  `filled > 0` — extend to gate the leading `add` icon too.
- Depends on Part 1 (pressed style must already be model-bound, or the empty/filled distinction is
  built on the same unreliable signal).
- **G-browser:** an empty slot chip exposes the add affordance; a filled slot chip does not show the
  bare `+` and shows its count; attribute vs slot rows are distinguishable by a stable attribute/class
  the test can assert (add a `data-` marker or class the test keys on).

### Part 4 — §3.4 per-level indentation for nesting depth

- Add a fixed per-level left indent to child cards (in addition to the existing per-card border),
  mirroring the code panel's own indentation. `viewNode`/`childCards` already recurse with `path`;
  depth = `List.length path`, so indent is a pure function of the path already threaded through.
  Optionally add a thin vertical connector line down a slot's children (tree-view convention).
- **G-browser:** build a 3-level tree (the existing "nesting three levels deep" test already does)
  and assert the depth-2 card's computed left offset > the depth-1 card's (via `boundingBox`/computed
  style), so indentation is objectively present, not just visually claimed.

### Part 5 — §3.5 give the live preview a labeled frame

- Wrap `Render.renderNode` output (`screen:282`) in a labeled container ("Live preview" heading +
  subtle border/background) so it reads as an output region, not incidental page copy. Pure markup
  in `screen`.
- **Copy sub-step is Opus-appropriate** (UX copy). Keep the builder on Sonnet for the markup and let
  the Opus critic own heading/label wording, or dispatch the one-line copy to Opus.
- **G-browser:** the preview region has an accessible "Live preview" label/heading and a
  container the test can locate.

### Part 6 — §3.6 one-line root-card explainer

- A single dismissible caption near the root card ("The root card can't be reordered or removed;
  use the sidebar to start over with a different root component"). Persist dismissal in
  `localStorage` so it doesn't nag returning users (a small port/flag; check whether the docs app
  already has a localStorage helper before adding one).
- **Copy is Opus-appropriate.** Same split as Part 5.
- **G-browser:** the caption renders on first load; dismiss hides it; (optional) a reload with the
  persisted flag keeps it hidden.

---

## 4. Sequencing & dependencies

```
Part 1 (correctness gate) ── must land first; blocks 3
        │
        ├── Part 2 (menu split)         ── independent of 3/4, parallelizable after 1
        ├── Part 3 (attr/slot + chip states) ── depends on 1
        ├── Part 4 (indentation)        ── independent
        └── Parts 5,6 (preview frame, explainer) ── polish, last, independent
```

Run as one Gauntlet with parts pipelined where independent (2, 4 can proceed alongside 3 once 1 is
in). Each part = one loop with its scoped G-browser assertions as the verify-check; the manager runs
`node tools/gate-all.mjs` once at the end (not per part) and attaches screenshots for the human's
IA sign-off.

## 5. Risks / watch-items

- **R:** removing `toggle` (Part 1) could regress menu-open behavior on these buttons →
  mitigated by keeping all existing `compose.spec.ts` green as a gate.
- **R:** the nav-category taxonomy (Part 2a) might not cover every component in `componentOptions`
  (e.g. structural primitives with no docs page) → the grouping must have an "Other/Uncategorized"
  bucket and the G-browser test must assert no component silently vanishes from the menu.
- **R:** §1.2's identical-menu observation (Part 2c) could be a web-component popover-identity limit
  rather than a code bug (cf. D-047's m3e host limits) → the diagnosis sub-step decides; if it's a
  limit, document it and adjust IDs, don't fight the framework.
- **R:** copy parts (5,6) drifting into "AI slop" → run the `ste-writing` skill on the caption/labels.
- **Core-bump trap:** any part that "would be so much easier with a new `Cem.Compose` query" — STOP,
  escalate, do not edit the core. The whole rework is designed to need zero core changes.

## 6. Acceptance for the whole rework

- [ ] Part 1 landed; the "open-then-dismiss leaves no pressed chip" regression test green.
- [ ] Type-picker menu free of example titles, grouped, filterable; add-child menu primitives-first
      with qualified examples.
- [ ] Attribute vs slot rows visually distinct; empty vs filled slot chips visually distinct.
- [ ] Nesting indentation objectively present at depth ≥ 2.
- [ ] Preview labeled/framed; root explainer present + dismissible.
- [ ] Full `compose.spec.ts` green; `node tools/gate-all.mjs` GREEN; `packages/elm-cem-compose`
      untouched (`git diff --quiet`).
- [ ] Human IA sign-off on the attached before/after screenshots.
