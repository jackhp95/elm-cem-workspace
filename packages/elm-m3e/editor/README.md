# `editor/` — Elm LSP / VS Code project for `src/`

`src/` is a **generated artifact** (emitted by `elm-cem`) and has no `elm.json`
of its own, so an editor opened on it has no buildable project to analyze. This
directory provides that project without polluting `src/`.

- `editor/elm.json` — an `application` `elm.json` whose `source-directories`
  reach `../src`, the real `../../elm-cem/facts/src` (the in-workspace
  `jackhp95/elm-cem-facts` package), and the committed
  `../docs/vendor/elm-foundation` copy. Point your Elm LSP at this file (or open
  the repo so it is discovered) to type-check `src/` on any machine.

  This used to point at a local `stub/Cem/Facts.elm` — an editor-only stand-in
  for `Cem.Facts` (the module the generated `M3e.Review.Facts` imports), needed
  because `jackhp95/elm-cem-facts` was an unpublished sibling checkout outside
  this repo. Now that elm-m3e lives in the same workspace as `elm-cem` (which
  owns the canonical `Cem.Facts`), the real source is always in reach and the
  stub is gone — the workspace's `check-single-cem-facts` gate requires
  exactly one `Cem/Facts.elm` under `packages/`, and a second copy here would
  violate it.

## Why `editor/` and not `src/`

The stub used to live at `src/Cem/Facts.elm` (+ a `src/elm.json`). That broke
two gates:

1. **`check:cem` (regen-drift)** diffs the whole `src/` tree against a fresh
   `elm-cem` regen. The generator emits neither the stub nor a `src/elm.json`,
   so both showed up as drift.
2. **`check:review`** compiles with `source-directories` that include BOTH
   `../src` and a real `elm-review-cem` checkout — each defining `Cem.Facts`.
   A stub under `src/` made `Cem.Facts` an `AMBIGUOUS IMPORT` on the review path.

Relocating here keeps `src/` a pure generated artifact (regen-drift green) and
leaves the review with exactly one `Cem.Facts` (the real one from
`elm-review-cem`), while editor/standalone type-checking of `src/` still works
via `editor/elm.json`.
