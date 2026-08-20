# Docs-codegen maximalist — execution record

Date: 2026-08-19 (overnight autonomous)
Branch: `feat/docs-codegen-maximalist` (not pushed, not merged)
Scope basis: `docs/superpowers/specs/2026-08-19-repo-shape-v2-design.md` §5, "maximalist" confirmed.
Package under work: `brands/m3e/generated/docs/elm-m3e-docs/` (extracted from elm-m3e earlier today).

This is the full-fidelity decision/evidence log. Chat summaries are terse; this is the durable record.

---

## Re-verification of the spec's cited paths (all had moved post-extraction)

The §5 research predated today's docs-extraction; every cited path was re-verified against the current
tree before touching anything:

| §5 citation | Current location (verified) |
|---|---|
| `Route.Family.elm:105-128` (hardcoded families) | `brands/m3e/generated/docs/elm-m3e-docs/app/Route/Family.elm` (now 206 lines; a "Family" nav tab landed today via Track B commit `d0ca81fb` — it built the *page* but left the table hardcoded) |
| `Route.Styles/{Typography,Shape,Color}.elm` | same relative path under the extracted docs package |
| `Route.GettingStarted.Installation.elm:87-120` | same relative path |
| token manifest (`tailwind-m3e-web`/`@m3e/web`) | renamed + relocated to `brands/m3e/generated/style/elm-m3e-tailwind/src/sys/{typescale,shape,color}.css` |
| `config/slots.json` `_families.families` | `brands/m3e/inputs/cem/config/slots.json` **and** a byte-identical copy at `brands/m3e/generated/package/elm-m3e/config/slots.json` (the docs scripts read the elm-m3e-package copy, matching `extract-reference.mjs`'s `REPO/config/` convention) |
| 4 guide `.md` under `docs/guides/` (claimed rawFile precedent) | `brands/m3e/generated/docs/elm-m3e-docs/guides/{EnumSafety,Glossary,Seams,TheLayers}.md` — **see the Phase-2 correction below: these are NOT the site's guide prose and are NOT read via rawFile** |

---

## Phase 1 — the three codegen wins (COMPLETE)

Design: each win derives a small `data/*.json` from the real source at build time, read by the route via
`BackendTask.File`. The JSON files are git-tracked and registered in `scripts/check-data-drift.mjs`
(deterministic → drift-gated: editing a source token without regenerating fails `check:drift`). This
follows the `data/reference.json` precedent and makes the anti-drift guarantee enforced, not asserted.

### 1a. `Route.Family` — derive from `slots.json` `_families.families`

- Generator: `scripts/gen-family-data.mjs` → `data/families.json`. Mirrors `gen-family-package.js`'s
  labelling **exactly**: root member's element label = the FAMILY name (`lowerFirst`), every other
  member's = `lowerFirst(path)`, root-first order; page sorted alphabetically by family.
- **Real drift bug caught:** the hardcoded table labelled the Tabs family's `TabPanel` member `panel`, but
  the generated `M3e.Family.Tabs` re-exports it as **`tabPanel`** (verified in the generated module's
  `exposing`/`@docs` list: `M3e.Component.TabPanel as tabPanel`). A reader following the old docs would
  write `M3e.Family.Tabs.panel` and hit a compile error. The derivation produces `tabPanel`, fixing it.
  Every other family/member matched the hardcoded table (21 families, 70 members) — proof the derivation
  is faithful and the Tabs entry was the lone stale one.
- Route change: `Data = List Family`, `data` reads `data/families.json`; hardcoded `families` binding
  removed; module comment updated (it had *admitted* it "mirrors rather than re-derives, so it can only go
  stale" — now it re-derives).

### 1b. `Route.Styles/{Typography,Shape,Color}` — derive from the `--md-sys-*` manifest

- Generator: `scripts/gen-style-tokens.mjs` → `data/style-tokens.json`, parsing
  `elm-m3e-tailwind/src/sys/{typescale,shape,color}.css`.
- **Typography**: the 15-role `metrics` string (`font-size / line-height · weight`) is derived from
  `--md-sys-typescale-*`. The live typed exhibits + Tailwind classes stay structural in Elm (they need
  compile-time producers); only the drift-prone metric literals move to data. Generated metrics match the
  15 hardcoded strings **byte-for-byte** (no active drift today; now drift-proofed).
- **Shape**: the 10-entry corner scale `(utility, label, rem value)` is fully derived from
  `--md-sys-shape-corner-*` (`label` = titleized size). Matches the hardcoded table byte-for-byte.
- **Color**: the swatches reference M3 color roles by their *Tailwind utility name* (`bg-primary`), and the
  color itself is resolved from `--md-sys-color-*` by the browser — so the hand-typed part is the role
  LISTS, not color values. The generator emits the curated 4 accents + 4 surfaces built by rule AND
  validates every role name against the full `--md-sys-color-*` inventory (37 roles) parsed from
  `color.css`; a renamed/removed role fails the build. Generated accents/surfaces match the hardcoded
  lists byte-for-byte.
  - **Deliberate scope call on Color:** the research flagged "8 of 23 roles" as an incompleteness bug. On
    inspection the Color page is an *editorial curation* (a container-pairings section + a representative
    surfaces section), not an exhaustive mirror — and expanding to the full surface ladder is risky because
    utilities like `bg-surface-container-lowest` are not confirmed to exist in the generated
    `utilities.css` (would render unstyled swatches). So Color is manifest-*backed + validated* (drift
    caught) rather than expanded; the full inventory is emitted as `colorRoleInventory` for any future
    expansion. This renders identically while closing the drift risk. (Typography/Shape ARE exhaustive
    mirror-tables and are fully derived.)

### 1c. `Route.GettingStarted.Installation` — derive package identities from metadata

- Generator: `scripts/gen-install-facts.mjs` → `data/install-facts.json`, from `elm-m3e/elm.json`
  (`jackhp95/elm-m3e`), the docs `package.json` (`@m3e/web@2.7.6`), and `elm-m3e-tailwind/package.json`
  (name + `repository.url`).
- **Real drift bug caught:** repo-shape-v2 renamed the Tailwind bridge `tailwind-m3e-web` →
  `elm-m3e-tailwind` today; the install prose (Step 3) still said `tailwind-m3e-web` in the package name
  and vendor paths — stale the moment the rename landed. The page now interpolates `f.tailwindPackage`
  (`elm-m3e-tailwind`), and the `@m3e/web` step is version-pinned (`@2.7.6`), all sourced from metadata.
- **Internal-consistency detail:** the tailwind package's own `repository.url` still points at
  `.../tailwind-m3e-web.git` (its mirror repo keeps the old name until republished). Rather than guess the
  real current GitHub location, the git-clone URL + clone-directory basename are *sourced from that
  metadata field* (`tailwindRepoUrl` / `tailwindRepoDir`) so the clone + subsequent `cp` stay internally
  consistent and a future repo rename propagates from the single source of truth. `tailwindPackage` (npm
  name) and `tailwindRepoDir` (GitHub basename) can legitimately differ; documented in the generator.
- **Deliberate scope call:** the prose's "128 typed components" count is NOT derived. There is no single
  authoritative source (the `src/M3e/Component` tree has 130 modules, the prose says 128, and other pages
  carry their own hand-tuned counts like "29 components with a required record"). Interpolating a derived
  number risks replacing plausible editorial prose with a WRONG figure, so identities derive and counts
  stay prose.

### Anti-drift wiring
- `package.json`: added `gen:family`, `gen:style-tokens`, `gen:install-facts`; inserted into the `gen`
  chain.
- `scripts/check-data-drift.mjs`: added the 3 outputs to `ARTIFACTS`, the 3 generators to `GEN_STEPS`, and
  extended the scratch-regen to copy the `elm-m3e-tailwind` tree (the style/install generators read its
  `sys/*.css` + `package.json`; it was not previously copied). Generators use node builtins only, so no
  node_modules symlink is needed for that tree.

### Phase-1 verification
- All 5 edited routes compile: `elm make ... --output=/dev/null` → `Success!` (after fixing two
  `NoMissingTypeAnnotationInLetIn` review errors on the new `let` bindings).
- All 3 generators are deterministic: re-running each produces byte-identical output (diff clean).
- Generated tables verified byte-identical to the prior hardcoded tables EXCEPT the intended Tabs/TabPanel
  fix.
- `node tools/gate-all.mjs` (serial): <PENDING — result recorded at commit>.

---

## Phase 2 — guide-markdown migration (see correction; in progress)

**Spec-premise correction (important):** §5 rec #2 says "the infra already exists — `docs/guides/` already
holds 4 markdown files … read via `BackendTask.File.rawFile`, same pattern." Verified FALSE:
- The 4 `guides/*.md` (`EnumSafety`, `Glossary`, `Seams`, `TheLayers`) are **developer-facing architecture
  docs**, linked from `DESIGN.md` / `decisions.md`. Their content DIFFERS from the site's guide-chapter
  prose (e.g. `guides/Seams.md` ≠ `app/Route/Guide/Seams.elm`'s strings).
- **No route reads any `.md` via `rawFile`** — `rg 'rawFile'` across the package = 0 hits; the only
  `BackendTask.File` usage is `jsonFile` for reference/roundtrip data.
- So there is no rawFile precedent to "follow"; Phase 2 must BUILD the mechanism, and must NOT collide with
  the dev-doc `guides/*.md` (migrated prose goes under a new `content/guides/`).

**Chapter classification (verified, `app/Route/Guide/*.elm`):** the spec's "9 pure-prose" list is
inaccurate. Truth:
- **Pure-prose (6)** — no `Doc.showcase`: `CheatSheet`, `Glossary`, `Motion`, `Theming`,
  `ToolingRefactors`, `Troubleshooting`.
- **Mixed (9)** — prose interleaved with live `Doc.showcase`: `Accessibility`,
  `AccessibleByConstruction`, `CompositionTextField`, `FirstComponent`, `GeneratedAndInspectable`,
  `InvalidStates`, `Seams`, `Strictness`, `TheLayers`.
- **Data-driven (3, not candidates)**: `HowWeProveIt`, `Reference`, `Roundtrip` (load JSON).

**Migration mechanism (faithful, render-identical):** move only PROSE strings (rendered via
`Doc.markdown`/`Doc.recapBox`/`Doc.message`, or a chapter's own prose helper like Troubleshooting's
`entry`) to a per-chapter `content/guides/<Chapter>.md` with `@@@ <name>` section delimiters; leave CODE
strings (`Doc.codeBlock` args — several are `@sample`-annotated and extracted by samples-gen for
compilation testing) and all structure/showcases in Elm. New `Doc.sections : String -> Dict String String`
(+ `Doc.section`) splits the file. The route reads the `.md` via `BackendTask.File.rawFile`, maps
`Doc.sections`, and a `let` block re-binds the prose names from that dict via `Doc.section "<name>" d` — so
the `view` body is entirely unchanged. Prose content is copied byte-identically.

**What landed (ALL 15 prose-bearing chapters, not just the 6 pure-prose):**
- Pure-prose (6): CheatSheet, Glossary, Motion, Theming, ToolingRefactors, Troubleshooting.
- Mixed (9): Accessibility, AccessibleByConstruction, CompositionTextField, FirstComponent,
  GeneratedAndInspectable, InvalidStates, Seams, Strictness, TheLayers. (The same mechanism works — the
  live `Doc.showcase`/`Doc.codeBlock` bindings are separate top-level defs, untouched; only prose moves.)
- The 3 data-driven chapters (HowWeProveIt, Reference, Roundtrip) are correctly left alone.

**Verification (evidence):**
- All 15 chapters + `Doc.elm` compile clean (`elm make` → Success); `elm-format` applied.
- Round-trip byte-identity: every extracted `.md` section equals its original Elm literal (checked in JS
  by re-parsing the `.md` with the same split logic and comparing to the literal — all identical).
- **Rendered-HTML identity: PROVEN.** Captured the Phase-1 (HEAD) `dist/guide/<x>/index.html` for 10
  chapters (both pure + mixed), rebuilt with `build:site`, and diffed. Every one is byte-identical to the
  inline-string version EXCEPT (a) the shared content-hashed Elm bundle filename (`elm.<hash>.js`, which
  changes on any route edit and appears identically in every page's `<head>`), and (b) the
  `__ELM_PAGES_BYTES_DATA__` hydration payload (which legitimately grew because the page `Data` went from
  `{}` to the sections dict). With those two expected changes normalised out: **10 identical, 0 differing**
  — and the sanity check confirms the prose IS embedded in the pre-rendered HTML, so the diff is
  meaningful. Zero prose changed.
- Completeness: verified every prose sink (`Doc.markdown`/`recapBox`/`message`/`entry` bareword arg) across
  all 15 chapters is now a migrated `Doc.section` let-binding (the lone flag was a false positive —
  Troubleshooting's `entry` helper has a *parameter* named `prose`).

**Note on the spec's "4 existing `.md`":** those `guides/*.md` remain untouched (they are dev-docs). The
migrated site prose lives in the NEW `content/guides/` dir — no collision.

---

## Phase 3 — generic `docs-gen` package (design doc + tested skeleton; deliberately partial)

Delivered as a **design doc + working, parity-tested skeleton, clearly marked incomplete** — the honest
scope for the biggest/most-open-ended phase (per the task's own guidance). Lives at `pipeline/docs-gen/`
(peer of `elm-cem-compose`).

**Shape chosen:** follows the JS `elm-cem-figma-connect` template (agnostic core + brand config), NOT the
Elm `elm-cem-compose` template — because the docs generators are already `.mjs` emitting JSON for
elm-pages `BackendTask`s, so the unit of reuse is a data-derivation function, not an Elm module. Full
rationale + the three-part contract diagram in `pipeline/docs-gen/DESIGN.md`.

**What's real + tested (the seam is genuine, not vapor):**
- `deriveFamilies(familiesConfig)` — the family-table derivation, lifted from Phase 1, faithful to
  `gen-family-package.js`.
- `deriveTypescale` / `deriveShapeCorners` / `deriveColorRoleInventory` + a generic `customProps` CSS
  parser — lifted from Phase 1's token derivation.
- `splitSections`/`joinSections` — the `@@@`-delimited guide-md format shared with Phase 2's `Doc.sections`.
- **5 parity tests** run the core against the REAL m3e inputs and assert byte-equality with the committed
  `data/families.json` and `data/style-tokens.json` — proving a brand's `gen-*` script could delegate to
  docs-gen with zero output change. `cd pipeline/docs-gen && npm test` → 5 pass, no deps.

**What's deliberately NOT built (documented in DESIGN.md §5):** the route-generation layer (the bulk — emitting
the per-component reference/gallery/family Elm pages from a facts bundle), lifting `extract-reference` +
`examples-gen`, a facts-bundle-typed input, workspace/gate integration, and a brand actually consuming it.
The Phase-1 generators are deliberately NOT refactored to depend on docs-gen (would couple gate-green code
to a not-yet-integrated package; the parity tests show the delegation would be byte-identical when adopted).

**Non-destabilizing:** the package is excluded from the workspace/gate graph (`pnpm-workspace.yaml`
`!pipeline/docs-gen`, matching the existing IR exclusion), verified via `pnpm ls -r`. The final full gate is
therefore unaffected by it.

---

## Gate status (honest, for all three phases)

**Final authoritative run (after all 3 phases committed, machine idle): `GATE-ALL GREEN` — fully green,
zero failures, including the browser suite.** This confirms the earlier `/guide/reference` timeouts were
purely environmental (they did not recur on an unloaded machine). The narrative below is retained because
the timeouts DO recur under load and future runs on slower hosts will hit them.

`node tools/gate-all.mjs` (serial) is green; the only intermittent reds are two pre-existing, environmental
browser-test failures that are NOT caused by this work:
- `mobile-shell.spec.ts:27` and `shell-breakpoints.spec.ts:162`, both navigating to `/guide/reference`.
- Root cause (proven): `/guide/reference` is the heaviest page (5000+ `m3e-card` custom elements). On this
  machine it loads in **94.0s** (measured with a 180s Playwright probe; the app-bar renders — the page
  WORKS), exceeding the tests' hardcoded 60s budget. Failure mode varies run-to-run (goto-timeout vs
  toBeVisible) — the signature of a perf/hydration limit, not a code defect. The reshape's gate passed
  green on a faster machine where this page loaded in <60s.
- **Not mine:** the diff touches only the 5 Phase-1 routes + generators + the 15 guide chapters + Doc.elm;
  nothing touches `/guide/reference`, the mobile shell, the nav bar, or CSS/layout. `/guide/reference`'s
  built output is byte-identical with or without this work.
- Per-phase verification used instead of a fully-green gate (unattainable on this machine): Phase 1 —
  full gate ran, only the 2 timeouts red; Phase 2 — `elm-review` clean + `build:site` renders all routes +
  proven HTML render-identity; Phase 3 — excluded from the gate.
- **Recommendation for Jack:** either run the gate on a faster host, or bump those two tests' 60s budget
  (the page is correct, just slow to hydrate) — a pre-existing docs-infra decision, out of this task's scope.
