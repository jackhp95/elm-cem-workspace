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
[x] W3 M3E-coupling fixes (Theme 2, moves #2 + #5)             — work — sonnet/high — DONE (2.1,2.3,2.4,2.5,2.6-partial; see progress log)
[ ] W4 elm-review-cem shared-module extraction (move #7)       — work — sonnet/high — HELD (overlaps W3's RequireFabLabel/FormField fix, sequence after)
[ ] W5 redundancy cleanup + family.json manifest (Theme 3/#4)  — work — sonnet/high — queued
[ ] W6 trapped generic modules + prefix-guess fixes (#9)       — work — sonnet/high — queued
[ ] W7 package boundary extractions (elm-cem-facts, tokens/*)  — work — sonnet/high — HELD (structural, lower leverage, later wave)
[ ] W8 derived-artifact staleness gaps (#10)                   — work — sonnet/high — HELD (small, folds into W1 easily, later)
[ ] V-per-wave independent verify, different agent each        — verify — sonnet/high — per-wave
[ ] M synthesis + report                                       — manage — this session — ongoing
```

W2/W3/W4 all touch elm-cem or elm-review-cem — sequenced to avoid file collisions. W1,
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

## Frictions clause

Every dispatched agent logs frictions to `~/.claude/frictions/` per its README schema.
Reviewers additionally log *observed* frictions of the agent they review.

---

## W3 progress log (2026-08-18)

Scope: findings 2.1, 2.3, 2.4, 2.5 (functional/structural M3E-coupling leaks in the generic
layers), plus a cheap slice of 2.6 (honest-scoping). Finding 2.2 (ActionsRoster/ActionWrapper)
explicitly excluded — owned by W2, same files (`Model.elm`/`Emit.elm`) it's already restructuring.

**2.1 — `gen-icon-module.js` hardcoded `"m3e-icon"`/"Material Symbols".** Fixed. Added required
`_iconModule.tag`/`_iconModule.iconFamily` config fields (+ optional `attribution`); the
generator now fails loud if either is missing instead of silently emitting M3E's literals for a
non-M3E brand. `packages/elm-m3e/config/slots.json` updated with the exact original strings so
the real `M3e.Icon` output stays byte-identical (verified via `regen-drift --nested-pkg`, full
elm-m3e gate green). New non-M3E test fixtures (`Wc`/`wc-icon`/`Test Icons` in
`elm-cem/tests/gates.test.mjs`, `Nk`/`nk-icon` in `registry-check-nested-pkg.test.mjs`) assert
the tag/prose come from config, not the M3E literal, and that omitting them fails loud.

**2.3 — `eject.js` BRANDS / `family-deps.js` FAMILY_PACKAGES hardcoded to one vendor.** Fixed.
New `elm-cem/family-configs/<brand>.json` (one file per brand; see its README) is the single
source of truth for both the `eject` brand registry and `FAMILY_PACKAGES`' brand-specific tail —
`family-deps.js` loads every `family-configs/*.json` at module load and derives `BRAND_REGISTRY`
+ `FAMILY_PACKAGES` from it; `eject.js`'s `BRANDS` is now `family.BRAND_REGISTRY` (no JS literal).
Adding a second brand is a data change (drop a file), not a code change — `elm-cem eject --help`
picks it up automatically, so `usage()`'s "Brands: m3e" is now genuinely derived, not asserted.
Full elm-cem test suite green (eject.test.mjs, depstamp.test.mjs, gates.test.mjs all pass
unmodified in behavior — same M3E dep set, same ranges, verified via `family.FAMILY_PACKAGES`
introspection).

**2.4 — cem-figma-connect matcher quarantine breach.** Fixed. `DESCRIPTION_UNTRUSTED`,
`FUZZY_ACCEPT_THRESHOLD`, `BOOLEAN_OPTION_POLARITY`, `BOOLEAN_AXIS_SYNONYMS`,
`MULTI_BOOLEAN_AFFINITY` removed from `src/match/matcher.mjs` entirely; moved to
`profiles/m3-kit/matcher.json` (new file, matches the profile mechanism's existing shape). Added
`loadMatcherConfig(profileDir)` to `matcher.mjs` (required, fails loud if missing/incomplete —
no brand-neutral fallback baked in) and threaded `matcherConfig` as a required parameter through
`match()`/`proposeAxis()`/`fuzzyScore()`/`proposeBooleanAxis()`/`proposeMultiAttrAxis()`.
`merge.mjs`'s `loadProfile()` now loads `matcher.json` alongside the profile's other optional
config files (required, not optional) and `buildProposals()`/`runMatch()`/`runGapReport()` thread
it through. Added `matcher.json` to the three synthetic test-fixture profiles
(`toy-profile`, `b4-profile`, `evil-profile`) and every throwaway-profile-copy helper in the test
suite. Full package gate green (757 tests, `check`+`test`).

**2.5 — `RequireFabLabel`/`RequireFormFieldLabel` hardcoded M3E nouns.** Fixed, via a DIFFERENT
mechanism than the audit's literal suggestion — see below. Both rules' `fabNoun`/`formFieldNoun`
constants are gone; `rule` now takes `{ componentNoun : String }` as its first argument (the
caller supplies which `fact.component` value plays that role), matching the exact precedent
`Cem.fences`'s `brandRoots`/`Cem.redundantElementEscape`'s `seamEscapes` already set in this same
package. `Cem.elm`'s `requireFabLabel`/`requireFormFieldLabel` wrappers, both test suites (32 call
sites), and the README updated. Full elm-review-cem gate green (418 tests + neutrality gate, with
new allowlist entries for the doc-comment examples naming M3E's actual noun as a worked example).

*Deviation from the audit's literal prescription, and why:* finding 2.5 says "add a
generator-set `Fact` field... This touches elm-cem's `Cem.Facts` schema... and the generator that
populates it." That's `packages/elm-cem/codegen/Generate/Phantom/{Model,Emit}.elm` — both
explicitly off-limits this pass (W2 owns them). Worse, it's not just a file-lock inconvenience: a
new `Fact` record field is a **breaking change to a compiled Elm record type** — every
already-generated `<Brand>/Review/Facts.elm` (including the real committed
`elm-m3e/src/M3e/Review/Facts.elm`) constructs `Fact` via a literal record expression with no
partial-record escape hatch in Elm, so adding a required field without updating `Emit.elm`'s
literal-construction template in lockstep breaks compilation of every existing generated brand,
not just a hypothetical new one. Confirmed by tracing `requiredAttrs` (the closest existing
precedent field) through `Config.elm` → `Model.elm` → `Emit.elm`: all three files change for any
new fact field, two of which are locked. Rather than ship a half-wired schema change (or break
the lock), I used the caller-supplied-config pattern already established for exactly this class of
problem in the same file (`Cem.fences`, `Cem.redundantElementEscape`). It satisfies the finding's
actual complaint — no M3E noun hardcoded anywhere in elm-review-cem's source, verified by the
neutrality gate — without touching the locked files or risking a cross-leaf compile break.
**Follow-up note for whoever picks up the generator-set-Fact-field version later:** if a real need
for FACT-driven (not caller-driven) recognition emerges — e.g. so `Cem.all` could include these
rules automatically instead of requiring opt-in wiring — the mechanical shape is the `requiredAttrs`
precedent: decode a new config key in `Config.elm`, thread it into the resolved component record
in `Model.elm`, emit it into both the `Fact` type alias (`elm-cem/facts/src/Cem/Facts.elm`) and the
generated literal + JSON encoder in `Emit.elm` (~line 6160 for the literal, ~line 7165 for the
encoder). Every brand needs a regen once that lands.

**2.6 (partial, as invited if cheap after 2.1-2.5):** renamed the elm-cem test fixture
`tests/fixtures/nonm3e.cem.json` → `wc-widgets.cem.json` (named for its actual package,
`wc-widgets` — "nonm3e" made M3E the unmarked default, backwards for a generic forge) across its
3 referencing test files. Added a note to `cem-configs/README.md` distinguishing it from the new
`family-configs/` (which IS now read, unlike `cem-configs/`) and reaffirming that 2.6's larger ask
(a live second-brand CI proof) is out of scope for this leaf, per the plan's own scoping note.

**Gates run, fresh, full output, this pass:** `elm-cem` (`npm run gate` — all `test:*`+`check:*`,
0 failures), `cem-figma-connect` (`npm run gate` — 757 tests + all `check:*`, 0 failures),
`elm-review-cem` (`npm run gate` — 418 tests + neutrality + format + review, 0 failures), and
`elm-m3e`'s own `elm-cem gate` (regen-drift + registry-check + acid probes, real M3E data,
0 failures) to prove 2.1/2.3's changes didn't disturb the real generated brand.

**Not touched, explicitly out of scope this leaf:** 2.2 (ActionsRoster/ActionWrapper — W2's
files), full 2.6 brand-pluggability proof (flagged in the audit itself as a likely separate wave).
