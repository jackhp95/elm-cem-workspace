# `editor/` — Elm LSP / VS Code project for `src/`

`src/` is a **generated artifact** (emitted by `elm-cem`) and has no `elm.json`
of its own, so an editor opened on it has no buildable project to analyze. This
directory provides that project without polluting `src/`.

- `editor/elm.json` — an `application` `elm.json` whose `source-directories`
  reach `../src`, the local `stub/`, and the committed
  `../docs/vendor/elm-foundation` copy. Point your Elm LSP at this file (or open
  the repo so it is discovered) to type-check `src/` on any machine, without
  sibling checkouts of the foundation repos.
- `editor/stub/Cem/Facts.elm` — an editor-only stub of `Cem.Facts`, the module
  the generated `M3e.Review.Facts` imports. The canonical `Cem.Facts` lives in
  `jackhp95/elm-review-cem`; this stub lets `src/` type-check without that
  checkout.

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
