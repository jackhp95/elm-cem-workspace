---
name: elm-cem-family-lint-discipline
description: Escape discipline + gate-integrity now enforced across all 6 elm-cem brands; the failure mode to watch is a gate that reports green while switched off
metadata: 
  node_type: memory
  type: project
  originSessionId: adeeda52-06d6-40f1-9aeb-16b125e71ab3
  modified: 2026-08-05T05:14:40.640Z
---

As of 2026-08-05 the whole elm-cem family (elm-m3e, elm-typed-html, elm-shoelace,
elm-web-awesome, elm-calcite, elm-fluent-ui) enforces the ladder
**`<Brand>.*` > `TypedHtml.*` > escape**, via rules in `elm-review-cem`:
`NoUnsafeImportOutsideAllowed` (import fence), `NoRedundantAttributeEscape` +
`NoRedundantElementEscape` (use level, name the typed alternative),
`NoRedundantElementForge`. Scaffolded by `elm-cem brand-sync` from
`templates/ReviewConfig.elm`, so a new brand is born with them.

`elm-cem check-gates` asserts no `check:*`/`test:*` can be silently dropped from
`gate` — no `!(…)` glob exclusions, no `--skip-*`, nothing unreachable. Waivable
only via `gate-waivers.json` with a reason string.

**The failure mode that motivated all of this**: `check` was
`run-p "check:!(review)"`, so elm-review never ran; a commit then destroyed
`ReviewConfig.elm` (188 lines, every import) and `npm run gate` still exited 0.
Fifteen real errors sat invisible behind a green gate, including an accessibility
defect in a live docs sample. **A gate that can quietly drop a check is worse than
no gate — it manufactures false confidence.** Check what a gate actually runs
before trusting a green result.

Two rule-design constraints that are easy to get wrong, both learned the hard way:

- A typed setter may only be suggested when the attribute's meaning is
  **element-independent** (`aria-*`, `role`, HTML globals, events). Per-component
  setters have *closed* capability rows, and from an escape call site `content` on
  a `<meta>` is indistinguishable from `content` on a custom element. The
  element-independent roster is generated (`<Brand>.Review.Facts.globalAttributes`,
  from the `_globals` manifest) so it cannot drift from the setters it guards.
- Phantom-row unification is subset-directional: a producer's named fields must be
  a **subset** of the slot's. Adding a field to a producer makes it fit FEWER slots.
  Cross-brand fit is therefore always fixed on the slot side.

Beware `docs/vendor/elm-foundation/` in elm-m3e: a *copy* of elm-typed-html +
HtmlIr sources with **nothing verifying it still matches**. It silently diverged
once; elm-m3e compiled against a setter its own source no longer produced. A
`check:vendor` is the top open item.

Also: `elm-m3e` has **no acid probes** (`tests/acid` absent) while elm-typed-html
has 27 — the "must NOT compile" evidence is missing for the largest brand.

Open decisions and remaining work:
`~/Documents/code/planning/2026-08-05-elm-cem-family-remaining-work.md`.
Related: [[elm-m3e-substrate-reexports]], [[elm-m3e-cross-cem-branding]],
[[subagent-delegation-verify-lessons]].
