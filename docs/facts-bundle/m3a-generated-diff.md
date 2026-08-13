# M3.a — `generated/m3-kit/**` diff: pre-migration vs. Face-C-sourced

This document enumerates every difference between `cem-figma-connect`'s
pre-migration committed `generated/m3-kit/**` (source repo `6294992`,
`/Users/jhp/code/jackhp95/cem-figma-connect`) and the output produced after
this part's rewiring:

- `src/ingest/cem.mjs` now reads elm-cem's facts bundle **Face B**
  (`cem-facts.json`) instead of parsing a vendored raw manifest + scanning
  its `.d.ts` tree itself.
- `profiles/m3-kit/emitters/elm.mjs` now reads elm-cem's facts bundle
  **Face C** (`elm-api-facts.json`) instead of the deleted
  `profiles/m3-kit/emitters/elm-facts.build.mjs` re-measurement script and
  its committed (and, per the audit, WRONG) `profiles/m3-kit/elm-facts.json`.
- `profiles/m3-kit/profile.json`'s `cem.manifestPath` now points at
  `profiles/m3-kit/facts/cem-facts.json` — elm-cem's real Face B for
  elm-m3e's own `@m3e/web` **2.7.3** — instead of a vendored, independently-
  parsed `@m3e/web` **2.7.0** copy (`test/fixtures/m3e-web-2.7.0/`, deleted).

Both trees were generated against the identical
`profiles/m3-kit/correspondence.json` and Figma-export fixture; only the
facts source changed.

## Headline result

```
elm/**                    224 files   224 differ — EXACTLY one line each, same line number (8)
elm/MANIFEST.json           1 file    0 differences (byte-identical)
web-components/**         224 files   0 differences (byte-identical)
web-components/MANIFEST.json 1 file   0 differences (byte-identical)
```

`web-components/**` never reads either facts face — it is untouched, and the
byte-identity confirms the rewiring did not leak into the unrelated emitter.
Every `elm/**` diff is confined to a single header-comment line (line 8 of
every file); every functional line (module names, setter names, token names,
`figma.code` example bodies, imports) is byte-identical between the two
trees.

Verified directly (not by construction): `diff -rq` between the two
`generated/m3-kit` trees, then, for every one of the 224 differing files, a
per-file `diff` confirmed exactly one hunk.

## Why the functional output didn't move — and why that's not the same as "nothing changed"

An audit established — and Face C states directly — that the committed
`elm-facts.json` was **WRONG** in three ways:

1. **the per-facet `src/M3e/<Facet>/<Comp>.elm` path convention is
   fiction.** elm-cem emits ONE component module (`M3e.Button`) that
   carries all facets' entry points, plus brand-wide barrel modules
   (`M3e.Html`, `M3e.Build`) — never a per-facet module tree. Face C's
   `surfaces` map records all four real surfaces per component
   (`top`/`build`/`record`/`html`) with their REAL module/entry. Measured
   directly for `m3e-button`:

   ```
   top:    { facet: "Standard", module: "M3e.Button", entry: "view" }
   build:  { facet: "Build",    module: "M3e.Button", entry: "build" }
   record: { facet: "Record",   module: "M3e.Button", entry: "el" }
   html:   { facet: "Html",     module: "M3e.Html",   entry: "button" }
   ```

2. **consequently, the committed bundle recorded only a `top` surface for
   every one of its 129 components.** Face C carries every surface elm-cem
   actually measured — e.g. `m3e-split-button` has all four
   (`build`/`html`/`record`/`top`); most components have `build`/`html`/`top`
   (no `record`); the real per-component surface set varies and is no longer
   hardcoded to one.

3. **the committed `finalizer: "build"` was backwards.** `build` is the
   pipeline SEED (`M3e.Button.build { content, action }`); `toElement` is
   what CLOSES it — confirmed against Face C directly:
   `m3e-button.surfaces.build.finalizer` is `"toElement"`, and
   `Generate/Phantom/Emit.elm:2358` generates `toElement : Builder … ->
   Element …` as the brand-wide `Build.Internal`-backed closer, with
   `Emit.elm:2536`'s per-component `exposeGroups` listing `["view", "el",
   "build", "toElement"]` as four DISTINCT exposed names — `build` and
   `toElement` are not the same function under two labels.

**None of the 224 currently-emitted `.figma.ts` files exercise any of the
three wrong facts**, because:

- `profiles/m3-kit/profile.json`'s `elm.elmSurface` is `"top"` (the default)
  for every entry in the committed `correspondence.json` — the Build surface
  (where the finalizer bug would fire) and the Html/Record surfaces (where
  the per-facet-path fiction would fire) are never selected.
- For the `top` (Standard) surface specifically, the OLD bundle's
  `module`/`entry` happened to be correct anyway — `M3e.Button`/`view` IS the
  Standard facet's real home module, so the fictional-path bug was invisible
  at that one surface.
- `finalizer` is read only inside `renderExample`'s `"pipeline"` form
  branch; the `top` surface's form is `"double-list"`, so the wrong
  `finalizer: "build"` was dead data for every currently-emitted file.

So the fixes are real and verified directly against the facts bundle (see
`test/elm-emitter.test.mjs`'s `surfaces` assertions, which now check all four
real surfaces including the corrected `build.finalizer`) — they just don't
move `generated/m3-kit/**` today because the current correspondence set never
reaches the surfaces where they'd show up. Byte-identity on the currently
exercised surface is the CORRECT outcome, not a sign the migration achieved
nothing: flip `elm.elmSurface` to `"build"` in a future profile change (or
add a Build-surface entry) and the corrected `module`/`entry`/`finalizer`
become externally observable for the first time — on the OLD bundle that
surface didn't even exist to select.

## The one difference class that DID land: `elm/**`'s header provenance line

Every one of the 224 `elm/*.figma.ts` files differs on exactly one line — the
header comment naming where the emitter's facts came from. Two variants
(component files vs. the icon-table's per-row files):

```diff
- * token names resolved from elm-facts.json (single provenance stamp lives in that file's elmM3eCommit); NOT the golden's stale short names.
+ * token names resolved from the elm-cem facts bundle Face C (profiles/m3-kit/facts/elm-api-facts.json); provenance stamp lives in that file's provenance object; NOT the golden's stale short names.
```

```diff
- * names resolved from elm-facts.json (single provenance stamp lives in that file's elmM3eCommit).
+ * names resolved from the elm-cem facts bundle Face C (profiles/m3-kit/facts/elm-api-facts.json); provenance stamp lives in that file's provenance object.
```

**Why this is a correction, not cosmetic churn:** the old text named a file
(`elm-facts.json`) and a field (`elmM3eCommit`) that no longer exist —
`profiles/m3-kit/elm-facts.json` is deleted (an authorized deletion), and
Face C's provenance stamp lives in a structured `provenance` object
(`{ producer: { elmCem: { version, commit } }, brand: { name, commit,
configFiles }, source: { package, version, sha } }` —
`docs/facts-bundle/schema.json`'s `faceCProvenance`), not a single flat
`elmM3eCommit` string. A header comment naming a deleted file would be
actively misleading to the next reader trying to trace where a token name
came from — leaving it unchanged would have been the actual regression here.

None of the currently-emitted 224 files carry the emitter's separate
`textSeam`-provenance header note (the `${textSeam}.text (userland SEAM...)`
line) — checked directly (`grep -rl "Kit\.text (userland"` over both trees
returns 0 matches on the pre-migration tree) — so that line's wording change
(profile.json's `elm.textSeam`, not a deleted `elm-facts.json` field) is
exercised by `test/elm-emitter.test.mjs` but is not part of this file-count
diff.

## Regressions

None found. Every difference traces to the single explicit provenance-header
correction above, or is a latent, currently-unobservable correction
(surfaces/finalizer/setters-key-convention, detailed below) that the current
correspondence set doesn't exercise. `web-components/**` (unrelated to this
rewiring) is untouched, confirming no unintended blast radius.

## Two further Face-C corrections, verified but not (yet) visible in `generated/**`

Beyond the three headline bugs above:

- **`setters` is now keyed by the raw CEM attribute name, not the Elm setter
  name.** The old bundle's `setters` map used the ELM identifier as its OWN
  key (e.g. `type_: "type_"`, `disabledInteractive: "disabledInteractive"`),
  but every caller (`setterOf(comp, attr, …)`) looks it up by the CEM
  attribute name from `correspondence.json` (`"type"`,
  `"disabled-interactive"`) — for any attribute whose CEM name and Elm name
  differ, the old bundle's own lookup would have silently missed and thrown
  "not a known/verified setter", a latent bug that never fired only because
  no currently-confirmed entry maps `type` or `disabled-interactive`. Face
  C's `setters` map is keyed by the CEM attribute name
  (`docs/facts-bundle/schema.json`'s `faceCComponent.setters`: "CEM
  attribute name → the exposed Elm setter name"), matching what `setterOf`
  actually looks up. Verified directly for `m3e-button`:
  `setters["disabled-interactive"] === "disabledInteractive"` and
  `setters["type"] === "type_"`.
- **Face C measures every real surface, not just `top`.** Beyond fixing the
  fictional module path (bug 1 above), this means `elmSurface: "build"` /
  `"record"` / `"html"` are now genuinely selectable for `m3e-button` (and
  `"build"`/`"html"` for most other components) — on the old bundle,
  selecting one of those surfaces threw `component "…" does not emit at
  surface "…"` unconditionally, because the bundle recorded no such surface
  existing at all.

Both are verified directly in `test/elm-emitter.test.mjs` (the setters-map
and surfaces/finalizer assertions), not just asserted here.

## Determinism

`gen:emit` was run twice via `tools/check-emit-determinism-cfc.mjs` against
the (unchanged) real `m3-kit` profile: 450 files (224 web-components + 224
elm + 2 `MANIFEST.json`), byte-identical across both runs — confirmed by
running the tool for real (`node tools/check-emit-determinism-cfc.mjs` ->
`OK — 450 file(s) byte-identical across two independent gen:emit runs`).
