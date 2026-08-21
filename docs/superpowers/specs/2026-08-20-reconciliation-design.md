# Reconciliation design — package-explosion (Side A) ⋈ generator-consolidation (Side B)

**Status:** research/design only. No merge, rebase, cherry-pick, `git mv`, or code change was
performed to produce this document. It characterizes two divergent bodies of work against their
common ancestor and specifies a target end-state that carries the intent of both. The executable
task list is the sibling doc `docs/plans/2026-08-20-reconciliation-plan.md`.

**Author context:** written on branch `spec/reconciliation-research`, whose `HEAD` currently equals
`origin/main` (`0efcf693`). All claims below were verified directly against the three refs named,
reading historical file states via `git show <ref>:<path>` (the working tree was never mutated).

---

## 0. Merge-base confirmation

```
git merge-base exec/explosion-task4 origin/main  →  8675f25bbf9cfce640ac2b781ccd20f5ac7fa1e8
```

Confirmed. `8675f25b` ("merge(docs-codegen-maximalist): data-derived Route.Family/Styles/Installation
+ 15 guides to .md + docs-gen skeleton", `JackHP95 <git@jackhpeterson.com>`, 2026-08-20 09:35) is the
common ancestor of both sides.

- **Side A** = `exec/explosion-task4` — **11 commits** ahead of `8675f25b`, all authored
  `JackHP95 <git@jackhpeterson.com>` with clean staggered timestamps (11:01 → 19:49).
- **Side B** = `origin/main` — **54 commits** ahead of `8675f25b`, all authored
  `Test <test@example.com>` (the corrupted identity — see §9).

---

## 1. Executive summary — the headline findings

1. **The reconciliation shape is not symmetric-textual; it is "Side B is the base, Side A's intent is
   re-derived on top."** Side B changed the *thing that produces* the generated packages (it ported the
   `gen-icon-module.js` / `gen-family-package.js` JS generators into the Elm codegen pass). Side A
   changed the *names, locations, and materialization* of those generated packages. Because the
   producer moved, Side A's 719 committed generated files cannot be textually layered onto Side B — they
   must be **regenerated fresh from Side B's Elm generator fed Side A's configuration**. Side A's
   genuine, portable contribution is small and clean: a handful of **config** edits (`slots.json`,
   `packages.json`, `tools/family.json`, `check-m3e-5pkg.mjs`), **one surgical Elm emitter edit**
   (`Component.elm` `internalTypesModule`), and the **act of materializing + workspace-wiring** the
   siblings. All of these re-derive onto Side B because the mechanisms they depend on are intact there.

2. **The generator question — the crux — resolves to COMPATIBLE (config-only), not
   needs-fresh-reimplementation.** The JS→Elm port is a *faithful* port that preserved both the config
   contract (`slots.json` `_iconModule` / `_families.package.{dir,name,namespace,deps}`) **and** the
   output-path arithmetic. Side A's rename lives *entirely* inside that config contract. Feeding Side A's
   `slots.json` to Side B's Elm generator emits the renamed sibling packages at the exact locations Side
   A materialized. This is the single most consequential finding and it is favorable. (§4, verified.)

3. **The real conflict surface is 4 files, and none is a true semantic collision.** Of 719 (A) + 122
   (B) changed files, only **4** are touched by both sides, and each is either non-overlapping-within-file
   or a regenerated artifact: `Component.elm` (different functions), `tools/family.json` (different JSON
   regions), `tools/gate-all-expected-steps.json` (regenerated fixture), `docs/copy-fidelity-notes.md`
   (different sections). (§5.)

4. **Side B's own Brand Facts schema already speaks Side A's naming — and a recorded human decision
   (DECISION 1) tried to walk it back only *because Side A hadn't landed yet*.** Side B's
   `docs/facts-bundle/schema.json` hard-requires the six NEW-naming package keys
   (`core/elements/build/components/icons/facts`). The newest Side B commit (`5d609ba4`) records
   DECISION 1 = option (1a): retarget that schema *backward* to the old 5-package naming, explicitly on
   the premise that "the elm-m3e package rework … **has not landed**" (an unowned concurrent track, §8 of
   that doc). **That unlanded rework is Side A.** Reconciliation falsifies DECISION 1's premise, which
   makes reversing it (→ effectively option 1b, "the six-package shape is now real; produce against it")
   the faithful both-sides outcome. Because DECISION 1 is a *recorded human decision*, reversing it is
   the single biggest Open Question for Jack (§7, §11-OQ1). Evidence strongly favors reversal.

5. **Side B's security hardening (GIT_DIR/GIT_WORK_TREE scrubbing) is conflict-free to keep, and Side A
   introduced no new exposure of that class.** None of Side A's changed scripts spawns a nested `git`
   subprocess; none of the scripts Side B hardened is touched by Side A. (§8.)

6. **Both sides changed the shared Elm generator, so the Face-A generator snapshot bundle must be
   re-baselined once — a known follow-on, not a conflict** (memory `generator-change-d046-rebaseline`).
   (§6, §10.)

7. **The `Test <test@example.com>` authorship is not limited to the tip commit — it pervades the entire
   Side B lineage** at both author and committer level, across two rebase/replay passes. This worktree's
   git config is clean; the corruption lives in whatever process authors Side B. Informative for the Side
   B owner; out of scope to fix here. (§9.)

---

## 2. Side A — package explosion (what changed, why, evidence)

**Branch:** `exec/explosion-task1` → `…task1b` → `…task2` → `…task3` → `…task4` (tip
`38e8d4fc`). 11 commits. `git diff --stat 8675f25b exec/explosion-task4` = **723 files, +93 401 / −1 888**
(the large insertion count is dominated by *committed generated package sources* — the materialized
split output, not hand-authored logic).

**Intent:** split the monolithic `elm-m3e` package into real, concern-separated sibling packages under
a deliberate (Jack-confirmed) naming inversion, and split `elm-typed-html` into its real tier ceiling.
Design record: `docs/superpowers/specs/2026-08-20-package-explosion-design.md`;
plan: `docs/plans/2026-08-20-package-explosion-plan.md` (both on ancestor branch `spec/explosion-research`).

### 2.1 The naming inversion (design §3.1, §5 "rename map — master table")

| Old package name              | New package name                    | Producer               |
|-------------------------------|-------------------------------------|------------------------|
| `jackhp95/elm-m3e-html`       | **`jackhp95/elm-m3e-core`**         | `elm-cem split`        |
| `jackhp95/elm-m3e-components` (tag-grouped) | **`jackhp95/elm-m3e-elements`** | `elm-cem split`        |
| `jackhp95/elm-m3e-builder`    | **`jackhp95/elm-m3e-build`**        | `elm-cem split`        |
| `jackhp95/elm-m3e-facts`      | `jackhp95/elm-m3e-facts` (unchanged)| `elm-cem split`        |
| `jackhp95/elm-m3e-icons`      | `jackhp95/elm-m3e-icons` (unchanged)| `gen-icon-module`      |
| **`jackhp95/elm-m3e-families`** | **`jackhp95/elm-m3e-components`** (family-grouped) | `gen-family-package` |

The **load-bearing inversion**: the *string* `elm-m3e-components` moves from the tag-grouped package
(now `-elements`) to the family-grouped package (formerly `-families`). The design's "anti-footgun rule"
forbids any blanket find-replace of `elm-m3e-components` because the string carries two opposite meanings
across the rename boundary.

**Not yet done on Side A (deferred to an unbuilt Task 5):** the *module namespace* rename
(`M3e.Component.*` → `M3e.Element.*` per-element, `M3e.Family.*` → `M3e.Component.*` families). On
`exec/explosion-task4` the package **names** are inverted but the **namespaces** are still
`M3e.Component.*` / `M3e.Family.*`. Package names and their module namespaces are therefore intentionally
misaligned at Side A's landed state. This matters for the schema coupling (§7).

### 2.2 The mechanisms Side A used (all unchanged infrastructure, consumed as-is)

- **`elm-cem split`** (`pipeline/elm-cem/bin/split.js`) reads
  `brands/m3e/generated/package/elm-m3e/packages.json` (each entry's `name` + `buckets`) and slices the
  flat monolith `src/` into 4 of the 6 siblings: `core`, `elements`, `build`, `facts`. Invoked via the
  `elm-m3e/package.json` `split` script with `--out=..` (emit committed siblings one level up).
  Provenance is authoritatively documented in `tools/family.json` `$comment_elm_m3e_split_siblings`
  (on `exec/explosion-task4`).
- **`gen-icon-module.js`** and **`gen-family-package.js`** produce the other 2 siblings (`icons`,
  `components`/family) from `slots.json` `_iconModule` / `_families`. Their modules never enter the flat
  `src/`.
- Side A **did not modify** any of `split.js`, `gen-icon-module.js`, or `gen-family-package.js` — it only
  consumed them and repointed their config.

### 2.3 Structural result (verified via `git ls-tree exec/explosion-task4`)

`brands/m3e/generated/package/` contains **6 flat sibling packages** — `elm-m3e-{core,elements,build,
facts,icons,components}`, each with a real `package.json` + `elm.json` — plus the retired monolith shell
`elm-m3e/`. `brands/html/generated/package/` contains **3 flat siblings** `elm-typed-html-{facts,core,
elements}` + the `elm-typed-html/` shell.

### 2.4 elm-typed-html — 3 tiers, a home-only brand

Configured in `brands/html/generated/package/elm-typed-html/packages.json` (3 packages: facts/core/
elements). Its `$scopeNote` records that html is a *home-only* brand (`Emit.elm: own=[]`, all 16
`TypedHtml.Component.*` are HOME modules), so **no Build or components tier is derivable — 3 is the real
ceiling.** A key asymmetry vs m3e: the TypedHtml **barrel lives in the `-elements` tier, not `-core`**
(home Component modules fuse types+surface, so the barrel has a hard elements dependency; barrel-in-core
would need a cross-brand home-emitter decoupling that also touches `elm-typed-svg`, out of scope). This
*contradicts* the design doc's earlier aspirational "5-tier ceiling" theory for html — Side A landed 3
and the `$scopeNote` calls 3 the real ceiling. (Doc-vs-landed divergence; noted, not blocking.)

### 2.5 Side A's non-generated logic footprint (the part that must re-derive onto Side B)

Stripping the 700+ generated-source files, Side A's real, portable edits are:
- **Config:** `brands/m3e/generated/package/elm-m3e/packages.json`, `…/elm-m3e/package.json` (scripts),
  `brands/m3e/inputs/cem/config/slots.json` (`_iconModule` + `_families`),
  `brands/html/generated/package/elm-typed-html/packages.json`, `tools/family.json`,
  `tools/check-m3e-5pkg.mjs`, `tools/gate-all-expected-steps.json`, `tools/snapshot-refs.json`.
- **Emitter logic:** `pipeline/elm-cem/codegen/Generate/Phantom/Emit/Component.elm` (the
  `internalTypesModule` barrel-in-core edit, §5.1) and one sibling emit file under
  `…/Phantom/Emit/`.
- **Regenerated artifact:** `tools/snapshots/elm-cem-generator.bundle` (Face-A re-baseline; §6).
- **Docs:** `docs/copy-fidelity-notes.md`, plus the explosion design/plan on `spec/explosion-research`.
- `pipeline/elm-cem/bin/classify.js` (small, unrelated to generators; no git subprocess — §8).

---

## 3. Side B — generator consolidation + schema + hardening (what changed, why, evidence)

**Branch:** `origin/main` (tip `0efcf693`). 54 commits. `git diff --stat 8675f25b origin/main` =
**126 files, +186 837 / −1 397** (insertions dominated by new golden fixtures + regenerated monolith
`src/`). Four coherent tracks:

### 3.1 Generator consolidation — JS generators ported INTO the Elm codegen pass

Commits `40a3478e` (decode `_iconModule`/`_families` into Elm flags), `0caf6a2a` + `245eabe2` (port +
remove `gen-icon-module.js`), `fbbb0c0f` + `02e4081b` (port + remove `gen-family-package.js` and
`post-generate.js`), consolidated in `bb59eb7a` / `30ea5148`.

- On Side B, `pipeline/elm-cem/bin/gen-icon-module.js`, `gen-family-package.js`, and `post-generate.js`
  are **deleted** (`git ls-tree origin/main pipeline/elm-cem/bin/` shows only `split.js` + `regen-drift.js`
  among the relevant scripts). The generation logic now lives in the Elm codegen at
  `pipeline/elm-cem/codegen/Generate/Phantom/Emit/{IconModule,FamilyPackage,Component}.elm` +
  `Generate/Config.elm`.
- A JS shim in `bin/elm-cem.js` injects the two things Elm cannot compute (Elm has no filesystem access):
  the icon catalog (`injectIconCatalog`, reads `_iconModule.catalogFrom` → `_iconModule.names`) and the
  LICENSE text (`injectPackageLicense`).
- **`split.js` is byte-unchanged** between `8675f25b` and `origin/main` (`git diff 8675f25b origin/main --
  pipeline/elm-cem/bin/split.js` → empty). The split mechanism was **not** part of the port.
- The Elm port is a **faithful port**, proven by golden byte-compare fixtures under
  `pipeline/elm-cem/tests/fixtures/golden-{icon-module,family-package}/`, captured from the *pre-port JS
  output* and byte-compared against the *current Elm CLI output* (the "real A/B no-op proof",
  `17f34060`). Documented in-module deviations (dropped README "write-if-absent" guard, dropped
  `componentsFrom` fs-override, later `a6737ebf` compSurface refactor) are all asserted no-ops for bytes.
- Side B also regenerated the monolith `src/` (`df50a29d`: "codegen now emits fuller `category=`
  docmeta") — a **content enrichment** of the monolith source, relevant to §4.3.

### 3.2 Brand Facts schema (schemaVersion 2)

Commits `6a73ae04`, `df442d78`, `37f43bc4`, `29517a85`, `5949bd20`, `e684e08a`, etc. Added a canonical
"Brand Facts" interface (`docs/facts-bundle/schema.json`, spec
`pipeline/elm-cem/specs/2026-08-19-brand-facts-design.md`, phase plans under
`docs/superpowers/plans/2026-08-{19,20}-brand-facts-*`). The schema **references package names** — its
`targets.elm.packages` block hard-requires the six NEW-naming keys and rejects others (see §7). Entirely
Side-B-only files (the whole `docs/facts-bundle/schema.json` apparatus is untouched by Side A). Coupling
to Side A is *semantic* (naming), not textual.

### 3.3 Figma SLOT-property support + Figma write-block hardening

Commits `3836be5a`, `a36a1e40`, `b1e23e14`, `6559dd36`, `006b4455`, `db82f7be`, `dfda8194`, etc. Routes
SLOT-typed Figma properties into their own correspondence dimension across
`pipeline/elm-cem-figma-connect/src/{match,correspond,emit,visual}` + a PreToolUse hook
(`tools/check-figma-write-block.mjs`). Entirely Side-B-only territory; zero interaction with Side A.

### 3.4 Security hardening — GIT_DIR/GIT_WORK_TREE scrubbing (§8)

Commits `c0b41f1f`, `dc9140f8`, `f50b8d77`, `d744ddce`, `ba9dbcf9`. Remediation of the exact
inherited-git-env leak class that caused the earlier real `origin/main` wipe. Conflict-free to keep.

---

## 4. THE GENERATOR QUESTION (the crux) — RESOLVED: compatible, config-only

**Question (Jack's #3):** does `elm-cem split` on Side B's current codegen still produce output
compatible with what Side A materialized, or does the Elm port change enough that Side A's materialized
packages must be regenerated fresh against Side B's generator?

**Answer:** the split mechanism is *unchanged*, and the ported family/icon generators preserved *both*
their config contract and their output-path arithmetic. Side A's rename is expressed *entirely* as
config. Therefore Side A's intent re-derives onto Side B's generator by **adopting Side A's config and
regenerating** — no reimplementation. The reason to regenerate (rather than textually copy Side A's
committed files) is Side B's *content* enrichment (§4.3) and a known elm-format drift trap (§4.4), not
any incompatibility.

### 4.1 The config contract is identical across the JS→Elm port

Both the old JS generators and the new Elm emitter read the package name, dir, namespace, and deps from
the same `slots.json` keys. The only differences between the two sides' `slots.json`
(`brands/m3e/inputs/cem/config/slots.json`) are Side A's rename + relocation:

| field                        | Side A (`exec/explosion-task4`)   | Side B (`origin/main`)     |
|------------------------------|-----------------------------------|----------------------------|
| `_iconModule.package.dir`    | `../elm-m3e-icons`                | `elm-m3e-icons`            |
| `_iconModule.package.name`   | `jackhp95/elm-m3e-icons`         | `jackhp95/elm-m3e-icons`   |
| `_families.namespace`        | `Family`                         | `Family`                   |
| `_families.package.dir`      | `../elm-m3e-components`           | `elm-m3e-families`         |
| `_families.package.name`     | `jackhp95/elm-m3e-components`     | `jackhp95/elm-m3e-families`|

The deltas are exactly: (a) a `../` prefix on each `dir` (which moves the emitted package from *nested
under the monolith* to a *committed sibling*), and (b) the `families → components` rename on the family
package's `name` + `dir`. Both are pure config the generator consumes.

### 4.2 The output-path arithmetic is preserved across the port (verified)

- **Old JS** (`gen-icon-module.js`, ancestor `:502-505`): `const repoRoot = path.dirname(outDir);
  writePackageTree(repoRoot, pkg, …)` → writes to `repoRoot/pkg.dir/…` where `repoRoot` is the dir
  containing the `--output=src` folder, i.e. `elm-m3e/`. So JS writes to `elm-m3e/<pkg.dir>`.
- **New Elm** (`IconModule.elm:388`, on `origin/main`): `modPath = "../" ++ pkg.dir ++ "/src/…"`, written
  relative to `--output=src`; elm-codegen's writer does `path.join(output_dir, file.path)` with no
  traversal guard, so `elm-m3e/src` + `../<pkg.dir>` = `elm-m3e/<pkg.dir>`. The in-module comment
  (`IconModule.elm:366-371`) explicitly states it "exactly like gen-icon-module.js:502-505's
  `repoRoot = path.dirname(outDir)`." `FamilyPackage.elm:650/699/744` is identical.

Both resolve to `elm-m3e/<pkg.dir>`. Feeding Side A's `pkg.dir = "../elm-m3e-icons"` to *either*
generator therefore yields `elm-m3e/../elm-m3e-icons` = the **sibling** `brands/m3e/generated/package/
elm-m3e-icons/` — exactly Side A's materialized location. The extra `../` in Side A's config precisely
accounts for the nested→sibling promotion under *both* implementations.

> **This equivalence is an inference from reading both code paths; it must be confirmed by execution**
> (run Side B's Elm generator with Side A's `slots.json`, diff the emitted tree against Side A's
> materialized siblings). The reconciliation plan makes this an explicit early gate (Plan Task 2), not an
> assumption. Everything downstream depends on it.

### 4.3 Regenerate, don't textually copy — Side B enriched the monolith source

Side B's `df50a29d` regenerated the monolith `src/` to emit "fuller `category=` docmeta." The `core/
elements/build/facts` siblings come from `elm-cem split` slicing that `src/`. Re-running the split on
Side B's monolith therefore yields siblings that differ from Side A's committed siblings **by exactly
that docmeta enrichment** — a feature carried through from Side B, not a conflict. This is a positive
reason to regenerate the siblings on the reconciled base rather than lift Side A's committed files.

### 4.4 The elm-format drift trap (audit hazard — do not mistake for a regression)

The Side B golden fixtures are byte-identical to the *pre-port JS output*, but the *committed generated
tree* (`brands/m3e/generated/package/elm-m3e/elm-m3e-icons/src/M3e/Icon.elm` etc.) was run through
elm-format at some point and never regenerated, so it differs from raw generator output (e.g. 553 581
vs 574 016 bytes for `Icon.elm`; documented at `pipeline/elm-cem/tests/lib/golden.mjs:7-22`). **A fresh
generate-then-diff against the committed tree will show a false "regression" that is really pre-existing
elm-format drift.** The reconciliation must generate, then apply the same elm-format pass, then compare
— never compare raw generator output to the elm-formatted committed tree.

---

## 5. Conflict / adjacency map

**Method:** `comm -12` of the two sides' changed-file sets. **Result:** A-only = 719, B-only = 122,
**touched-by-both = 4.** The 719 A-only are overwhelmingly the materialized generated sources (which the
reconciliation *regenerates*, so they carry no textual-merge risk). The 122 B-only are the generator
port, schema, Figma SLOT work, and hardening (adjacent, mechanically combinable). The entire *true*
conflict surface is the 4 shared files — and none is a genuine semantic collision.

### 5.1 `pipeline/elm-cem/codegen/Generate/Phantom/Emit/Component.elm` — adjacent-within-file

- **Side A** (+44/−4): edits `internalTypesModule` (original line ~845) — changes the emitted
  `M3e.Internal.Types.<C>` module from `exposing (..)` with unexposed types to a **public** `exposing`
  list with `@docs` coverage + per-alias doc comments, so the `core` tier can publicly expose these types
  for the cross-package `elements → core` re-export to resolve (the "barrel-in-core", design §3.2a).
- **Side B** (+359/−111): rewrites `compModule` (original lines ~387-682) + the module header
  imports/types (adds `ComponentSurface`/`ComponentCore`, lines 18-60) — the family/icon emitter port +
  `compSurface` refactor.
- **These edit different functions.** Side B's last hunk ends at original line ~682; Side A's region
  begins at ~845. `aliasDefs` (Side A's dependency inside `internalTypesModule`) is **not mentioned** by
  Side B's diff (verified). → **Not a true conflict.** A textual 3-way merge may even auto-resolve, but
  because this is codegen logic the plan re-applies Side A's `internalTypesModule` edit onto Side B's
  rewritten file *deliberately* and verifies the emitted `Internal.Types` module still carries the
  public exposing list + `@docs` (Plan Task 4).

### 5.2 `tools/family.json` — adjacent (different JSON regions)

- **Side A** (+43/−2, lines ~50-130): adds the 6 m3e + 3 html sibling package entries; adds
  `authorizedAbsentPrefixes` mirror-lag note; changes `authorizedExtraPrefixes` `["elm-m3e-families/"]`
  → `["elm-m3e-components/"]` (the rename surfacing in config).
- **Side B** (+6/−2, lines ~138-304): adds `skills/m3e/concepts/component-substitution.md` to the okf
  allowlist and 3 figma-connect plan/research files to the figma-connect allowlist.
- Non-overlapping regions → mechanically combinable. The reconciled file = Side A's package entries +
  rename **plus** Side B's okf/figma allowlist additions.

### 5.3 `tools/gate-all-expected-steps.json` — regenerated fixture, both-needed

- **Side A**: inserts 9 new sibling-package `check` steps (`elm-typed-html-{core,elements,facts}: check`,
  `elm-m3e-{build,components,core,elements,facts,icons}: check`); keeps `tools/*.test.mjs (11 file(s))`.
- **Side B**: only bumps the final entry `tools/*.test.mjs (11 → 12 file(s))` (new hardening/figma test).
- This file is a *regenerated* gate fixture (`fix(gate-all): regenerate expected-steps fixture`). The
  reconciliation regenerates it once both sides' work is combined; the reconciled fixture carries **both**
  the new sibling steps **and** the `12 file(s)` count (and will be longer still). Not hand-merged.

### 5.4 `docs/copy-fidelity-notes.md` — adjacent (different sections, append-only)

- **Side A** (+13/−0, ~line 179): adds a `PACKAGES-MOVED.md` note (monolith retirement).
- **Side B** (+20/−0, ~lines 328 & 390): adds a Figma-SLOT plan/research note + an okf concept-page note.
- Both append in distinct sections, zero deletions → keep both.

### 5.5 Adjacent-but-important (no textual overlap, semantic coupling only)

- `docs/facts-bundle/schema.json` (Side-B-only) ⟂ Side A's package names — the DECISION 1 coupling (§7).
- `tools/check-m3e-5pkg.mjs` — Side-A-only (Side B left it at ancestor). Side A rewrote its assertions to
  the NEW names; Side B's ancestor copy asserts the OLD names. Reconciliation adopts Side A's version,
  gated on the naming being landed (which it is, being Side A's honored intent).
- `tools/snapshots/elm-cem-generator.bundle` — both sides changed the generator → single re-baseline (§6).

---

## 6. The Face-A generator snapshot bundle

Side A regenerated `tools/snapshots/elm-cem-generator.bundle` (+ `tools/snapshot-refs.json`) — the
Face-A byte-identity baseline (memory `generator-change-d046-rebaseline`). Side B *also* changed the
generator (the JS→Elm port + fuller docmeta). The reconciled generator is neither side's — it is Side B's
Elm generator driven by Side A's config. Therefore the bundle must be **re-baselined once, after** the
reconciled generator + config are in place, so the `workspace: ab-elm-cem (Face A byte-identity)` and
`ab-elm-m3e-split` gates compare against the true reconciled baseline. This is expected follow-on work,
not a conflict.

---

## 7. THE CENTRAL DESIGN TENSION — Brand Facts schema × the naming rename (DECISION 1 premise-flip)

**Question (Jack's #4):** does Side B's Brand Facts schema reference package names in a way that assumes
the OLD naming? **Answer: it references package names, but it assumes the NEW naming — and a recorded
human decision then tried to walk it back to OLD *specifically because Side A hadn't landed*.**

### 7.1 The evidence (verified directly)

- `docs/facts-bundle/schema.json:818-819` (on `origin/main`):
  ```
  "description": "Exactly the six destination-package keys (spec §3.4). Not the retired
                  top/build/record/html construction forms.",
  "required": ["core", "elements", "build", "components", "icons", "facts"],
  "additionalProperties": false
  ```
  These six keys **are Side A's NEW naming.** The per-component `brandFactsElmComponentTargets`
  (schema `:703-745`) likewise allows only `core/elements/build/components/facts/icons`, and illustrates
  `elements.module` as `M3e.Element.ListItem` — i.e. it also assumes Side A's (deferred) **namespace**
  rename.
- The brand-facts design (`pipeline/elm-cem/specs/2026-08-19-brand-facts-design.md` §3.4) enumerates the
  full NEW package table *and* records the module renames `M3e.Component.* → M3e.Element.*` and
  `M3e.Family.* → M3e.Component.*`.
- The newest Side B commit `5d609ba4` ("docs(plans): record DECISION 1 resolution — retarget schema to
  shipped 5-package shape") resolves the tension. From
  `docs/superpowers/plans/2026-08-20-brand-facts-phase2-targets-elm.md`, DECISION 1 states the schema's
  six NEW keys conflict with "committed reality" (5 packages, OLD names, `M3e.Component.*`/`M3e.Family.*`
  namespaces), and picks **option (1a): retarget the schema *backward* to the shipped 5-package OLD
  naming** — with the explicit rationale that "the spec's aspirational six-package `M3e.Element.*` rework
  (§8 'Coordination dependency (not owned here): the elm-m3e package rework') **has not landed**."

### 7.2 Why reconciliation flips DECISION 1's premise

DECISION 1 chose (1a) *because the package rework had not landed on Side B.* **That rework is Side A**,
and it *has* landed on `exec/explosion-task4`. In the reconciled world:

- Side A makes the six NEW-naming package keys real → the schema's *original, pre-DECISION-1* six-package
  form becomes a **true fact of the reconciled library**, not an aspiration.
- DECISION 1's own doc says option **(1b)** is "correct per the schema-as-written" and was rejected
  *only* because it "couples phase 2 to a concurrent, unowned track (§8) of unknown timing." Reconciliation
  *dissolves* that objection — the track is no longer unowned, concurrent, or of-unknown-timing; it is
  landing in the same reconciliation.
- Therefore the faithful both-sides outcome is: **do not apply DECISION 1's (1a) backward retarget;
  keep the schema's six NEW-naming keys (which Side A now satisfies) — i.e. effectively adopt (1b).** This
  honors Side B's *schema design* (which correctly anticipated the six-package shape) and Side A's
  *delivery* of that shape. The two were designed for each other; they merely landed on separate branches.

### 7.3 The residual namespace caveat (a real sequencing sub-question)

Even with Side A landed, one half of the schema's aspiration is *not* yet real: the schema's per-component
`module` values use the **namespace** rename (`M3e.Element.*` per-element, `M3e.Component.*` families),
but Side A **deferred** the namespace rename (unbuilt Task 5) — its modules are still `M3e.Component.*` /
`M3e.Family.*`. So the reconciled state satisfies the schema's package **keys** but not its per-component
**module** strings. Two sub-options (OQ-2, §11):
- **(a)** Pull Side A's deferred namespace rename (Task 5) into reconciliation scope, so the schema is
  fully satisfied as written.
- **(b)** Keep the six NEW package **keys** but have the schema's `module` fields describe the *current*
  `M3e.Component.*` / `M3e.Family.*` namespaces (a *partial* retarget: names new, namespaces current) —
  smaller scope, defers the namespace rename to its own later track.

Both are legitimate; the choice is Jack's because it sets reconciliation scope. Neither requires DECISION
1's full backward walk to OLD *package names*.

> **This is the single decision that reconciliation cannot make on Jack's behalf** — it reverses (or
> re-scopes) a recorded human decision. The plan sequences all schema work behind it (Plan Task 8, GATED).

---

## 8. Security hardening reconciliation (GIT_DIR / GIT_WORK_TREE)

**Question (Jack's #5):** confirm Side A wasn't itself vulnerable to the same class, and that adopting
Side B's fixes conflicts with nothing Side A touched.

- **Side B's fix idiom** (identical across all hardened scripts): clone `process.env`, then
  `delete gitEnv.GIT_DIR; delete gitEnv.GIT_WORK_TREE; delete gitEnv.GIT_INDEX_FILE;` and pass
  `{ env: gitEnv }` to every git call that targets a repo *other than* `REPO_ROOT`. Applied in
  `tools/publish-mirror.mjs:171-174`, `tools/copy-fidelity.mjs:50-53`, `tools/fetch-snapshots.mjs:44-46`
  (`childEnv`), `pipeline/elm-cem-compose/bin/stage-facts-elm-home.mjs:59-62`,
  `pipeline/elm-review-cem/bin/stage-facts-elm-home.mjs:59-62`, and
  `brands/m3e/generated/okf/elm-m3e-okf/scripts/okf-update.mjs` (+ two okf consumer-vendor templates).
- **Side A is NOT vulnerable to this class.** Side A's three changed scripts spawn no nested `git`:
  `pipeline/elm-cem/bin/classify.js` (pure JS, no `child_process`), `tools/check-m3e-5pkg.mjs` (only
  `readFileSync`), `tools/measure-docs-size.mjs` (spawns `sh -c "command -v elm"` and `elm make` — never
  git; and Side A's diff adds no spawn/exec lines).
- **No overlap:** none of Side B's hardened scripts is among Side A's changed files. **Adopting Side B's
  hardening is conflict-free and requires no extension to any Side A script.** Because the reconciliation
  base *is* Side B, the hardening is simply inherited.

---

## 9. The git-identity anomaly

**Finding (broader than the brief anticipated):** the `Test <test@example.com>` identity is **not limited
to the tip commit `0efcf693`** — it pervades **all 54** Side B commits at *both* author and committer
level. Author dates are real and staggered (12:41 → 20:00 on 2026-08-20); committer dates collapse into
**two batches** (`14:55` for the ~generator/facts/figma block, `21:31` for the latest security/docs
commits) — the signature of **two `git rebase`/replay passes**. Because a rebase preserves author
identity by default and the author is *also* `Test`, the corrupted identity was present at **original
commit time**, not merely introduced by the replay.

- `merge/wave1-integration` (a local branch) *also* tips at `Test <test@example.com>`, with the on-the-nose
  message `fix(tests): isolate throwaway-git tests from GIT_DIR so they can't mutate the real repo` — i.e.
  the same lineage doing the security remediation is itself committing under the leaked test identity.
- `merge/overnight-tracks-integration` is clean `JackHP95` — so the corruption is specific to the Side
  B / wave1 lineage, not global.
- **This worktree's resolved git config is clean** (`user.name=JackHP95`, `user.email=git@jackhpeterson.com`
  from `~/.gitconfig`; no `Test` identity anywhere in the resolved config). The corruption is **not here**.

**Interpretation:** the process that authors Side B has had a corrupted git identity continuously —
`user.name=Test` / `user.email=test@example.com` (or `GIT_AUTHOR_*` / `GIT_COMMITTER_*` env of the same
values) — the same env-leak class (a throwaway-git test's environment bleeding into real operations) that
caused the earlier wipe. Until that process fixes its identity/env, every future Side B commit will keep
mis-attributing to `Test`. **Fixing it is out of scope for this reconciliation** (per the brief), but it
is load-bearing context for whoever owns the Side B / wave1 work, and it means: when the reconciliation
executor commits, they must do so from a *clean* worktree (like this one) to avoid re-introducing the
mis-attribution. Flagged informationally (§11-OQ4).

---

## 10. Target end-state design

A single coherent branch that carries **both** intents, built as **Side B base + Side A intent
re-derived**, with all generated artifacts regenerated (never textually lifted):

1. **Base = Side B** (`origin/main`): the Elm-ported generators, Brand Facts schema, Figma SLOT support,
   and GIT_DIR hardening are all inherited as-is. (The reconciliation branch already sits here.)
2. **Naming rename landed** (Side A's honored intent): `slots.json` `_iconModule`/`_families`,
   `packages.json`, `elm-m3e/package.json` scripts, `tools/family.json`, `tools/check-m3e-5pkg.mjs`
   carry Side A's NEW names + `../` sibling dirs.
3. **Generated packages regenerated** from Side B's Elm generator + Side A's config: `elm-m3e-icons` and
   `elm-m3e-components` (family) emitted at sibling locations by the Elm generator; `elm-m3e-{core,
   elements,build,facts}` sliced by the (unchanged) `elm-cem split` from Side B's enriched monolith
   `src/`. All materialized as committed siblings + real pnpm workspace members. The monolith `elm-m3e/`
   shell retained + published-identity retired.
4. **`Component.elm` barrel-in-core edit re-applied** onto Side B's rewritten `Component.elm`
   (`internalTypesModule` public exposing + `@docs`), verified against emitted `Internal.Types`.
5. **elm-typed-html 3-tier split** re-applied (pure Side-A work, no Side B interaction).
6. **The 4 overlap files reconciled**: `family.json` (both regions), `copy-fidelity-notes.md` (both
   sections), `gate-all-expected-steps.json` (regenerated to carry both sets), `Component.elm` (item 4).
7. **Brand Facts schema resolved per Jack's OQ-1/OQ-2** (§7): default recommendation = keep the six
   NEW-naming keys (do not apply DECISION 1's 1a backward walk), with the namespace sub-question (OQ-2)
   deciding whether module strings are new (land Task 5) or current (partial retarget).
8. **Face-A generator bundle re-baselined once** (§6); phantom expectations re-blessed if touched
   (memory `generator-change-d046-rebaseline`).
9. **Full `gate-all` green** on the reconciled branch, including the new sibling-package steps, the
   `12-file` tools test count, `verify-split`, `check-m3e-5pkg` (new names), and both byte-identity gates.

**Is this just "Side A on top of Side B"?** Almost — with one honest qualification that is *not*
manufactured complexity: Side A's **generated files** are *not* layered on; they are **regenerated** from
Side B's generator (because the producer moved and Side B enriched the source). Side A's **config +
one emitter edit + the materialization act** *are* layered on. And the schema (§7) is the one place where
the two sides' *design intents* must be actively reconciled by a human decision rather than mechanically
combined. Everything else is adjacent.

---

## 11. Open questions for Jack

- **OQ-1 (blocking Plan Task 8) — Reverse DECISION 1?** Side B's recorded human decision (1a) walked the
  Brand Facts schema back to OLD 5-package naming *because Side A hadn't landed*. Reconciliation lands
  Side A, falsifying that premise. **Recommendation (evidence-backed, §7):** do **not** apply the 1a
  backward walk — keep the schema's six NEW-naming keys, which Side A now satisfies (effectively option
  1b, which DECISION 1 itself calls "correct per the schema-as-written"). Confirm before touching the
  schema. This reverses a recorded decision, so only Jack can make it.
- **OQ-2 (blocking Plan Task 8, dependent on OQ-1) — namespace scope.** The schema's per-component
  `module` values assume the *namespace* rename (`M3e.Element.*` / `M3e.Component.*`), which Side A
  deferred (unbuilt Task 5). Either (a) pull the namespace rename into reconciliation scope so the schema
  is fully satisfied, or (b) keep the new package **keys** but describe the *current* `M3e.Component.*` /
  `M3e.Family.*` namespaces in the schema (partial retarget). Sets reconciliation scope.
- **OQ-3 (non-blocking) — mirror republish (OQ-6 from Side A).** Both sides carry mirror-lag allowlist
  entries (`authorizedAbsentPrefixes`/`authorizedExtraPrefixes`) pending a republish of the
  `jackhp95/elm-m3e` snapshot with the new sibling shape. When is that republish scheduled? Until then the
  reconciled `tools/family.json` keeps both sides' lag entries. Not blocking, but the entries should be
  removed in a follow-on once the mirror is republished.
- **OQ-4 (informational, not this task's job) — Side B / wave1 corrupted identity.** The process
  authoring Side B commits as `Test <test@example.com>` (§9). It should fix its git identity/env before
  the next push, and the reconciliation executor must commit from a clean worktree. Surface to the Side B
  owner.
- **OQ-5 (non-blocking) — html tier ceiling doc-vs-landed divergence.** The explosion design doc argues a
  5-tier html ceiling; Side A landed 3 (home-only brand, real ceiling). Reconciliation follows the landed
  3-tier reality; confirm the doc's 5-tier theory is formally retired.

---

## Appendix A — verification commands (reproduce this analysis)

```
git merge-base exec/explosion-task4 origin/main                 # → 8675f25b
git log --format='%h %an <%ae>' 8675f25b..exec/explosion-task4  # Side A, 11, JackHP95
git log --format='%h %an <%ae>' 8675f25b..origin/main           # Side B, 54, Test
comm -12 <(git diff --name-only 8675f25b exec/explosion-task4|sort -u) \
         <(git diff --name-only 8675f25b origin/main|sort -u)   # → the 4 overlap files
git diff 8675f25b origin/main -- pipeline/elm-cem/bin/split.js  # → empty (split unchanged)
git show origin/main:docs/facts-bundle/schema.json              # :819 six NEW keys
git show origin/main:brands/m3e/inputs/cem/config/slots.json    # Side B _iconModule/_families
git show exec/explosion-task4:brands/m3e/inputs/cem/config/slots.json  # Side A (renamed + ../)
git show origin/main:pipeline/elm-cem/codegen/Generate/Phantom/Emit/IconModule.elm  # :366-388 path arith
```
