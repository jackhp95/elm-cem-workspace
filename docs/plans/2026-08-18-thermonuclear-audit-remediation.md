# Thermonuclear audit remediation — gauntlet plan

Manager: top-level orchestrator session. Source: `docs/reviews/2026-08-17-thermonuclear-workspace-review.md`
(7-reviewer synthesis, file:line evidence throughout). This plan adopts the audit's own
"Consolidated top 10 moves" as the leaf decomposition — it's already well-cut, don't re-derive.

## Goal + acceptance criteria

Close the audit's BLOCKER-severity gaps and work down its ranked move list as far as this pass
reaches. Each leaf's acceptance test is drawn from the audit's own evidence (the finding IS the
failing test; the fix makes it pass). Full gate green after each leaf, independently verified
before merge, same bar as every other leaf this session.

## Waves (dependency-aware — same-package leaves sequenced, different-package leaves parallel)

```
[ ] W1 enforcement wiring (Theme 1, move #1, BLOCKER)          — work — sonnet/high — queued
[ ] W2 elm-cem core: Emit.elm split + resolveWith + dead code  — work — sonnet/high — queued
    (Theme 4 move #3 + Theme 5 move #6, BLOCKER latent bug in Config.elm's divergent decoder)
[ ] W3 M3E-coupling fixes (Theme 2, moves #2 + #5)             — work — sonnet/high — queued
[ ] W4 elm-review-cem shared-module extraction (move #7)       — work — sonnet/high — HELD (overlaps W3's RequireFabLabel/FormField fix, sequence after)
[ ] W5 redundancy cleanup + family.json manifest (Theme 3/#4)  — work — sonnet/high — queued
[x] W6 trapped generic modules + prefix-guess fixes (#9)       — work — sonnet/high — DONE
[ ] W7 package boundary extractions (elm-cem-facts, tokens/*)  — work — sonnet/high — HELD (structural, lower leverage, later wave)
[ ] W8 derived-artifact staleness gaps (#10)                   — work — sonnet/high — HELD (small, folds into W1 easily, later)
[ ] V-per-wave independent verify, different agent each        — verify — sonnet/high — per-wave
[ ] M synthesis + report                                       — manage — this session — ongoing
```

W2/W3/W4 all touch elm-cem or elm-review-cem — sequenced to avoid file collisions (W4 held until
W3's fact-field fix for FAB/FormField nouns lands, since both touch the same rule files). W1,
W5, W6 are root-tooling / other-package scoped — safe fully parallel with everything.

## Notes carried from the audit, not to be lost in translation

- **Two BLOCKER bugs, not just style debt:** Theme 1's whole enforcement gap (gates exist, never
  run — already cost a 5-day mirror fork once) and Theme 5's divergent `_actions` decoder
  (`Config.elm` requires `doc`, `Model.elm` defaults it — a manifest omitting `doc` aborts the
  build even though the decoder whose output is actually used would've accepted it). Both get
  real priority, not just line-item treatment.
- **Move #2 (prove/retract brand-pluggability)** is the biggest, most novel piece — running a
  real second CEM brand (Carbon or Spectrum, configs already exist unused) end-to-end through
  codegen in CI. This is closer to a mini-project than a mechanical fix. Scoping it honestly: W3
  fixes the *known* M3E leaks (2.1-2.5) mechanically; actually proving brand-pluggability via a
  live second-brand CI run is flagged as a possible separate/later wave if time doesn't reach it
  this pass — say so plainly rather than silently skipping it.
- Every fix should cite the audit's finding number (e.g. "fixes 1.5") in its commit message, so
  the audit doc and the fix history stay cross-referenceable.

## W6 progress log (2026-08-18)

All 6 required trapped-generic-modules items done, plus 2 of 4 "other structural
findings" stretch items. Branch: `audit/w6-trapped-generic-modules`. Not merged/pushed.

1. **`okf-lib.mjs` promoted** — `m3e-okf/scripts/lib/okf-lib.mjs` + its test moved to
   `tools/lib/okf-lib.mjs`/`okf-lib.test.mjs` (zero-dep, matches the existing
   `tools/lib/regen.mjs` convention). 4 import sites + `test:lib` script updated. 33/33
   tests green.
2. **`generate-component-utilities.mjs` promoted** — the generic transform (type
   inference, extraction, 3 emitters) moved verbatim to
   `tools/lib/component-css-utilities.mjs`; `tailwind-m3e-web/bin/` keeps only the
   package-specific paths + CLI entry and re-exports the same names (so
   `cem-figma-connect`'s existing cross-package import of this file keeps working
   unchanged). Regenerated output is byte-identical to what's committed; 44/44 package
   tests green.
3. **`calibrate-tones.mjs` — new package, not `tools/lib/`** — the HCT→OKLCH sampling
   math needs `@material/material-color-utilities` + `culori`, and every existing
   `tools/lib/*.mjs` is deliberately zero-dependency, so it got its own workspace
   package, `packages/tonal-palette-oklch` (`lForToneAtHue`/`averageLPerTone`,
   parameterized by hue/chroma/tone — no M3-brand constants). `calibrate-tones.mjs`
   keeps the M3-spec chroma buckets, the 12×12 grid, and the `--_m3e-tone-*` output
   naming, now as a `workspace:*` dependent. Regenerated `_tone-table.css` is
   byte-identical; 4/4 new package tests + 44/44 tailwind-m3e-web tests green.
4. **`validate-markup.mjs` prefix-guess fixed, differently than the audit's literal
   suggestion** — the audit's own reference fix
   (`NoProprietaryDsClasses.elm`, commit `1464985`) swaps a `startsWith("m3e-")` CSS
   *utility-class* guess for `tailwind-m3e-web/generated/utilities.json`. That manifest
   doesn't apply here: `validate-markup.mjs`'s two guesses (lines 76, 112) test HTML
   *tag names* for "is this a custom element", a different namespace entirely (the
   manifest has entries like `m3e-card-padding`, never bare tags like `m3e-card`).
   Real fix: a tag is a custom element per the WHATWG Custom Elements spec iff it
   contains a hyphen — brand-agnostic by construction, no manifest needed. Old
   behavior was worse than cosmetic: a second brand's real, `GT`-documented components
   (e.g. `<carbon-button>`) were never looked up against ground truth at all and
   permanently misreported as "non-standard tag". Added a regression test proving a
   non-m3e custom element now gets checked correctly. 18/18 tests green (17 old + 1
   new).
5. **`fetch-mdn-native-summaries.mjs` — NOT moved upstream; the premise didn't hold** —
   investigated before moving anything: `elm-cem/codegen/Generate/Config.elm`'s
   `nativeAttrTable`/`native` fields are decoded but have **zero downstream readers**
   (verified by grep across `codegen/`), and `docs/facts-bundle/m6-deep-clean.md`
   (2026-08-13, four days before this audit) independently documents `_native` as
   superseded pre-phantom-refactor config vocabulary. No `M3e.Native` module exists
   anywhere in current generated output. So there is no "generator's real
   `nativeAttrTable`" for the script's `ATTR_OWNER` table to dedupe against, and moving
   dead tooling into `elm-html-intermediate-representation`/`elm-typed-html` would add
   cruft to packages this same audit calls exemplary, for zero second-brand benefit.
   Fixed the actually-wrong thing instead: the script's comments claimed to mirror a
   live generator table that doesn't exist (a false-provenance bug, same class as the
   `m6-deep-clean.md` `CONTRIBUTING.md` fix). Left the file in place, un-moved, with
   honest comments and a pointer to W2 (whoever resolves the `_native` dead-config-surface
   cleanup should revisit whether this script moves upstream or gets deleted).
6. **`m3e-okf` package.json name fixed** — was `"m3e-docs"`. Checked for real
   dependents first (not just cosmetic): `tools/bump.mjs`'s `pkgName: "m3e-docs"` drives
   a real `pnpm --filter` call, updated alongside the package.json, plus one prose
   reference in `check-bundle-provenance-m3e-okf.mjs` and one in
   `gen-facts.mjs`'s usage comment. `pnpm --filter m3e-okf` now resolves.

Stretch (`extract.mjs` Markdown parser, `match --check`) not attempted — time budget
went to the 6 required items. Two stretch items done: the `iconGetEnumRows` dedupe in
`cem-figma-connect/src/emit/html-label.mjs` (3 byte-identical blocks → 1 helper, 757/757
package tests green); `spectrum.config.mjs` given the same `exclude` block as
`material-web.config.mjs` (config is currently unconsumed by any script — verified via
`cem-configs/README.md` — so zero risk). The `emitEntry` `PROP_SHAPE_HANDLERS`
dispatch-table redesign (the bigger half of stretch item 8) was not attempted — real
but riskier work, left for a future pass.

Verification: ran each touched package's real `test`/`check`/`gate` script fresh —
`m3e-okf` (34/34), `tailwind-m3e-web` (44/44 + `check:privates`), `tonal-palette-oklch`
(4/4, new), `cem-figma-connect` (`check` all-green + 757/757 `test`). Every regenerated
artifact (`utilities.css`/`.json`, `CSS_CUSTOM_PROPERTIES.md`, `_tone-table.css`) is
byte-identical to what was committed before this pass — confirmed via `git diff
--stat` showing zero changes to `generated/`.

**Independent review (2026-08-18):** merge-ready — all functional claims held up,
including the two deviations from the audit's literal wording on items 4 and 5, which
the reviewer independently re-derived as principled fixes rather than shortcuts. One
low-severity, no-functional-impact ding: `m3e-okf/README.md`'s file-map table and
`skills/curating-okf-knowledge/reference/frontmatter.md` still cited the pre-move path
`scripts/lib/okf-lib.mjs` after item 1 moved the file to `tools/lib/okf-lib.mjs`.
Fixed as a follow-up commit — both docs now point at the real path (README also notes
the promotion, citing Theme 6 #1).

While in there, checked whether item 6's rename (`m3e-docs` → `m3e-okf` in
`package.json`) had the same doc-lag problem — it did, just not flagged by the
reviewer: `README.md`/`CONTRIBUTING.md` titles and two `SKILL.md` prose lines
(`curating-okf-knowledge`, `regenerating-m3e-docs`) still said "m3e-docs". Fixed those
too, same follow-up commit. Deliberately left two related things alone rather than
silently expanding scope further: `build-skill.mjs`'s hardcoded "the m3e-docs repo
that generated this skill" string, baked into ~40 generated `skills/m3e/components/
*.md` + `implementations/m3e-web/components/*.md` cards (fixing it means
regenerating all of them — bigger than a doc-consistency follow-up); and the
`regenerating-m3e-docs` skill's own directory/`name:` identity (a structural rename
with unknown cross-reference blast radius, not a stale-reference fix). Both flagged
here for a future pass rather than fixed or ignored.

Re-ran `m3e-okf`'s gate fresh (34/34) after the doc fixes; no code touched, so no
other package needed re-verification. Friction logged (doc-refs-missed-on-file-move)
covering both the original ding and the item-6 discovery, since the root cause
(grepping code-only when relocating/renaming) recurred across two different items in
the same pass.

## Frictions clause

Every dispatched agent logs frictions to `~/.claude/frictions/` per its README schema.
Reviewers additionally log *observed* frictions of the agent they review.
