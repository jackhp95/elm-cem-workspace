# Reconciliation execution plan — package-explosion (Side A) ⋈ generator-consolidation (Side B)

**Design record:** `docs/superpowers/specs/2026-08-20-reconciliation-design.md` (read it first — this
plan assumes its findings). **Templates followed:** `docs/plans/2026-08-20-package-explosion-plan.md`
and `docs/plans/2026-08-19-repo-shape-v2-wave1-plan.md`.

**This plan is NOT executed by its author.** It is handed to a fresh execution agent after Jack reviews
it. **All three open questions are RESOLVED (Jack, 2026-08-20)** — no task is gated:
OQ-1 = reverse DECISION 1 (keep the six NEW-naming keys); OQ-2 = **land the module-namespace rename now**
(added scope — Task 7, highest blast radius); OQ-5 = html stays 3 tiers this pass, 5 is the confirmed
future target pending the (out-of-scope) DAG rework. See design §11.

**Expected model tier (informational):** planning tier already spent; execution/orchestration →
opus at medium, with a sonnet worker for the mechanical regeneration/verification steps.

---

## Reconciliation shape (read before Task 0)

The reconciliation base **is Side B** (`origin/main`); the branch `spec/reconciliation-research` already
sits on it (`HEAD == origin/main == 0efcf693`). Side B is the base because it changed the *producer* (the
JS→Elm generator port) plus schema, Figma SLOT support, and security hardening — infrastructure that
Side A's outputs must be regenerated *from*. **Side A's intent is re-derived on top as config + one
emitter edit + re-running the materialization** — its 719 committed generated files are **regenerated
fresh**, never textually lifted (design §1, §4.3–4.4). The naming rename is Side A's honored, confirmed
intent and *lands*. Jack has also pulled the **module-namespace rename** into scope (OQ-2) — the
explosion plan's deliberately-last, unbuilt "Task 5", highest blast radius — sequenced here onto a green
tree as Task 7. With OQ-1 resolved (reverse DECISION 1), the schema task (Task 9) is a straightforward
confirmation, no longer gated.

### The crux, in one line (design §4)

Side A's rename lives *entirely* in `brands/m3e/inputs/cem/config/slots.json`
(`_iconModule`/`_families.package.{dir,name}`); Side B's Elm generator consumes that config with the
*same* path arithmetic the deleted JS generators used, so **adopting Side A's `slots.json` makes Side B's
generator emit the renamed sibling packages at the exact locations Side A materialized.** Task 3 is the
go/no-go proof of this.

### Anti-footgun rule (inherited from the explosion plan — load-bearing)

**Never blanket find-replace `elm-m3e-components`.** The string means the *tag-grouped* package under the
OLD naming and the *family-grouped* package under the NEW naming. Every edit below names the exact file +
line + role. The rename map (design §2.1): `html→core`, `components(tag)→elements`, `builder→build`,
`families→components(family)`, `icons`/`facts` unchanged.

### Decisions carried in from the design doc

- **D-R1 — base = Side B.** Confirmed by the reconciliation shape above.
- **D-R2 — regenerate, never lift.** All generated package sources are produced by the reconciled
  generator, then elm-format'd, then committed. Do **not** copy Side A's committed `src/` (design §4.3
  docmeta enrichment; §4.4 elm-format drift trap).
- **D-R3 — commit only from a clean worktree.** The Side B lineage authors commits as
  `Test <test@example.com>` (design §9). Before any commit, verify identity (Task 0 Step 0.3).
- **D-R4 — namespaces stay OLD through Task 6, flip in Task 7.** Materialization (Tasks 3–6) runs with the
  *current* namespaces (`M3e.Component.*` / `M3e.Family.*`); the atomic namespace rename lands **last, on a
  green tree** (Task 7), matching the explosion plan's own sequencing for its highest-blast-radius change.
- **D-R5 — namespace rename is a single atomic pass.** Never sequential `Component→Element` then
  `Family→Component` (the second would recapture freshly-written `Element` tokens). Build the full old→new
  map, apply once (design §7.3).

---

## Task 0: Baseline — clean serial gate + identity guard

- [ ] **Step 0.1: Capture the baseline gate on the reconciliation base.** From the repo root, run
      `GATE_ALL_CONCURRENCY=1 node tools/gate-all.mjs` and save the full output to
      `/tmp/reconcile-baseline-gate.log`. This is Side B green as-shipped — the reference for "did I
      break anything." Expect the `tools/*.test.mjs (12 file(s))` step and the security-hardening tests
      to pass. If the base is not green, STOP and surface (do not build reconciliation on a red base).
- [ ] **Step 0.2: Confirm working tree clean.** `git status --short` empty before starting Task 1.
- [ ] **Step 0.3: IDENTITY GUARD (D-R3).** Run `git config user.name && git config user.email`. It
      **must** be `JackHP95` / `git@jackhpeterson.com` (or Jack's canonical identity), **not**
      `Test`/`test@example.com`. Also check `env | grep -iE 'GIT_AUTHOR|GIT_COMMITTER|GIT_DIR|GIT_WORK_TREE'`
      is empty. If any is corrupted, STOP and fix before committing anything (design §9).
- [ ] **Step 0.4: Confirm HEAD == origin/main.** `git rev-parse HEAD origin/main` — both `0efcf693`.
      Confirm branch is `spec/reconciliation-research` (`git branch --show-current`).

---

## Task 1: Land Side A's generator naming config (`slots.json`)

Adopt Side A's `_iconModule`/`_families` config onto the base. This is the *entire* rename for the two
generator-produced packages; verified line numbers are identical on both sides
(`brands/m3e/inputs/cem/config/slots.json`, unchanged region).

- [ ] **1.1** `_iconModule.package.dir` (`:18`): `"elm-m3e-icons"` → `"../elm-m3e-icons"` (the `../`
      promotes nested→sibling under the generator's path arithmetic, design §4.2). `.name` (`:19`) stays
      `"jackhp95/elm-m3e-icons"` (icons unchanged).
- [ ] **1.2** `_families.package.dir` (`:35`): `"elm-m3e-families"` → `"../elm-m3e-components"`.
- [ ] **1.3** `_families.package.name` (`:36`): `"jackhp95/elm-m3e-families"` →
      `"jackhp95/elm-m3e-components"`.
- [ ] **1.4** `_families.package.deps` (`:39` block) and `_iconModule.package.deps` (`:22` block): repoint
      any `jackhp95/elm-m3e-html` dep key → `jackhp95/elm-m3e-core`, and any `jackhp95/elm-m3e-components`
      (tag) → `jackhp95/elm-m3e-elements`, matching Side A's slots.json exactly
      (`git show exec/explosion-task4:brands/m3e/inputs/cem/config/slots.json` lines 22-30, 39-48 are the
      authority — diff against them until identical).
- [ ] **1.5 Verify** the reconciled `slots.json` `_iconModule`+`_families` blocks are byte-identical to
      Side A's: `diff <(git show exec/explosion-task4:brands/m3e/inputs/cem/config/slots.json) <(cat
      brands/m3e/inputs/cem/config/slots.json)` should show **only** differences outside those two blocks
      (if any). Do **not** commit yet — Task 3 proves the generator output first.

---

## Task 2: Re-apply the barrel-in-core emitter edit onto Side B's `Component.elm`

Side A's one surgical Elm edit (design §5.1) must be re-applied onto Side B's *rewritten* `Component.elm`.
The two edits touch different functions (Side A: `internalTypesModule` ~orig-line 845; Side B: `compModule`
~orig-lines 18-682), and `aliasDefs` is untouched by Side B — so this is a clean re-apply, not a merge.

- [ ] **2.1 Read both versions.** `git show exec/explosion-task4:pipeline/elm-cem/codegen/Generate/
      Phantom/Emit/Component.elm` (Side A `internalTypesModule`) and the current base file. Locate
      `internalTypesModule` in the base (search `internalTypesModule brand comp =`).
- [ ] **2.2 Port the edit.** Re-apply Side A's `internalTypesModule` change: derive `exposedNames` +
      `documentedAliasDefs` from `aliasDefs` (via `typeAliasName`), emit the module header as
      `module <lib>.Internal.Types.<C> exposing (<exposedNames>)` with the `@docs` block + per-alias doc
      comments, replacing the base's `exposing (..)` form. Confirm `aliasDefs` is still in scope and
      unchanged in the base (design §5.1 — verified untouched by Side B).
- [ ] **2.3 Compile-check the codegen.** From `pipeline/elm-cem/`, run the codegen's own build/check
      (`pnpm --filter elm-cem run check` or the repo's codegen `elm make`) — must compile.
- [ ] **2.4 Do not commit yet** — Task 3 regenerates and verifies the emitted output.

---

## Task 3: CRUX GATE — regenerate icon + family packages; prove sibling-location + rename

**This is the go/no-go for the whole "compatible" thesis (design §4).** If the emitted trees do not land
at the renamed sibling locations, the path-arithmetic inference (design §4.2) was wrong and the Elm
emitter needs a small fix — escalate per the blocked protocol before proceeding.

- [ ] **3.1 Regenerate m3e from the base's Elm generator + Task 1 config.** From
      `brands/m3e/generated/package/elm-m3e/`, run the `gen:src` script (`package.json` — the one that
      invokes `bin/elm-cem.js … --output=src` with `--config-from` slots.json). This runs Side B's Elm
      generator with Side A's config.
- [ ] **3.2 Assert sibling locations exist.** Confirm the generator emitted:
      `brands/m3e/generated/package/elm-m3e-icons/src/M3e/Icon.elm` and
      `brands/m3e/generated/package/elm-m3e-components/src/M3e/Family/*.elm` (21 family modules), each
      with its own `elm.json`+`README.md`+`LICENSE` — as **siblings** of `elm-m3e/`, NOT nested inside it.
      Confirm `elm-m3e/elm-m3e-icons/` and `elm-m3e/elm-m3e-families/` (the old nested trees) are **not**
      re-created.
- [ ] **3.3 Assert names.** `elm-m3e-components/elm.json` `name` == `"jackhp95/elm-m3e-components"`;
      `elm-m3e-icons/elm.json` `name` == `"jackhp95/elm-m3e-icons"`; family module namespace still
      `M3e.Family.*` at this stage (the namespace rename lands later, on the green tree — Task 7 / D-R4).
- [ ] **3.4 Byte-compare against Side A's INTENT, accounting for the two known deltas (design §4.3–4.4).**
      elm-format the freshly emitted `elm-m3e-icons`/`elm-m3e-components` trees the same way the committed
      trees were, then `diff -r` against Side A's committed siblings
      (`git show exec/explosion-task4:brands/m3e/generated/package/elm-m3e-components/…`). Expected
      differences are **only**: (a) Side B's "fuller `category=` docmeta" content (design §4.3, from
      `df50a29d`), and (b) nothing else. Any *structural* difference (missing modules, wrong exports,
      wrong package name) is a FAIL → escalate. Document the diff in the commit message.
- [ ] **3.5 Commit** Tasks 1–3 together (config + barrel-in-core edit + regenerated icon/family siblings):
      `refactor(reconcile): land Side A naming config onto Side B Elm generator; regen icon+family siblings`.
      Include the Step 3.4 diff summary in the body. **Identity guard (Step 0.3) before committing.**

---

## Task 4: Materialize the split siblings + wire workspace + retire monolith

The `elm-cem split` mechanism is unchanged on the base (design §3.1). Re-apply Side A's split config and
materialize `core/elements/build/facts` from Side B's (enriched) monolith `src/`.

### 4a. Rewrite `packages.json` tier names (line numbers verified on the base — unchanged vs ancestor)

`brands/m3e/generated/package/elm-m3e/packages.json`:
- [ ] **4.1** `:7` — `"name": "jackhp95/elm-m3e-html"` → `"jackhp95/elm-m3e-core"`.
- [ ] **4.2** `:82` — `"name": "jackhp95/elm-m3e-components"` → `"jackhp95/elm-m3e-elements"`.
- [ ] **4.3** `:107` — `"name": "jackhp95/elm-m3e-builder"` → `"jackhp95/elm-m3e-build"`.
- [ ] **4.4** `:92` — dep key `"jackhp95/elm-m3e-html"` (elements pkg deps) → `"…-core"`.
- [ ] **4.5** `:117` — dep key `"jackhp95/elm-m3e-html"` (build pkg deps) → `"…-core"`.
- [ ] **4.6** `:118` — dep key `"jackhp95/elm-m3e-components"` (build pkg deps, tag-grouped) →
      `"…-elements"`. (Anti-footgun: this is the *tag* package, becomes `elements`, NOT `components`.)
- [ ] **4.7 Verify** against Side A: `diff <(git show exec/explosion-task4:brands/m3e/generated/package/
      elm-m3e/packages.json) brands/m3e/generated/package/elm-m3e/packages.json` — identical.

### 4b. Barrel + `Internal.Types` → `core` bucket move (explosion Task 1b)

- [ ] **4.8** In `packages.json`, move the `{exact:"M3e"}` barrel bucket and `M3e.Internal.Types.` bucket
      into the `core` package (mirror Side A's `packages.json` core `buckets`). This pairs with the Task 2
      emitter edit — together they make `core` publicly expose the types that `elements` re-exports.

### 4c. Repoint split output + materialize siblings

- [ ] **4.9** In `elm-m3e/package.json`, confirm the `split` script uses `--out=..` (committed siblings
      one level up) and repoint any `format:`/`check:` script that named `elm-m3e-families` → the
      `../elm-m3e-components` path and the icon path `../elm-m3e-icons` (compare to
      `git show exec/explosion-task4:brands/m3e/generated/package/elm-m3e/package.json`).
- [ ] **4.10** Run `pnpm --filter elm-m3e run split` (or the `split` script) — it slices Side B's monolith
      `src/` into `elm-m3e-{core,elements,build,facts}` siblings. Then `pnpm --filter elm-m3e run
      verify:split` — the DAG/registry-faithfulness gate must pass.
- [ ] **4.11** Un-ignore the committed sibling outputs (mirror Side A's `elm-m3e/.gitignore` edit) so the
      materialized siblings are tracked.
- [ ] **4.12** Make each materialized sibling a real pnpm workspace member (prerequisite: add each to the
      workspace `pnpm-workspace.yaml`/root config exactly as Side A did — compare
      `git show exec/explosion-task4:pnpm-workspace.yaml`).
- [ ] **4.13** elm-format the materialized siblings (D-R2) so they match repo formatting.

### 4d. Retire monolith identity + repoint consumers (explosion Task 3)

- [ ] **4.14** Repoint the relative `source-directories` that reached into the flat monolith `src/` (e.g.
      `brands/m3e/generated/docs/elm-m3e-docs/elm.json` — the docs samples) to the new siblings, matching
      Side A's Task 3 edits (`git show exec/explosion-task4:…` for each).
- [ ] **4.15** Retire the monolith published identity (confirmed on Side A — *explosion* design OQ-5, not
      this doc's OQ-5): stop publishing
      `jackhp95/elm-m3e`; add `PACKAGES-MOVED.md` (Side A authored it — copy from
      `git show exec/explosion-task4:brands/m3e/generated/package/elm-m3e/PACKAGES-MOVED.md`) and pin it
      from the package README/`VISION.md` as Side A did.
- [ ] **4.16 Commit** Task 4: `refactor(reconcile): materialise m3e 5-package split as committed siblings + retire monolith`.

---

## Task 5: `elm-typed-html` — 3-tier split (pure Side-A re-derivation, no Side B interaction)

Side B did not touch elm-typed-html generation, and html uses the unchanged `elm-cem split` (design §2.4).
This task is a straight re-application of Side A's Task 4.

> **OQ-5 resolved (record inline — do NOT build 5 tiers here):** 3 tiers (facts/core/elements) is the
> ceiling **for this reconciliation pass** because html is a home-only brand and no Build/components tier
> is derivable by regeneration today. **5 tiers (facts/core/elements/components/builders) is the confirmed
> REAL future target** — reachable only once the separate **DAG rework** (linear IR → Core → Elements →
> Components → Builders) lands, which is out of scope and not yet built. Attempting 5 now would require
> that rework. Record the 5-tier target in the html `packages.json` `$scopeNote` / migration note so 3 is
> never mistaken as permanent (design §2.4, §11-OQ5).

- [ ] **5.1** Add `brands/html/generated/package/elm-typed-html/packages.json` (3 packages
      `elm-typed-html-{facts,core,elements}`) — copy verbatim from
      `git show exec/explosion-task4:brands/html/generated/package/elm-typed-html/packages.json`,
      including its `$scopeNote` (home-only brand, barrel in `-elements` tier, 3-tier ceiling).
- [ ] **5.2** Regenerate + split html from the base's generator; materialize the 3 siblings; un-ignore;
      wire as pnpm members; elm-format (mirror Task 4c steps for html).
- [ ] **5.3** Verify each of `elm-typed-html-{facts,core,elements}` has a real `package.json`+`elm.json`
      and the barrel resolves from the `-elements` tier.
- [ ] **5.4 Commit** Task 5: `refactor(reconcile): split elm-typed-html into facts/core/elements siblings`.

---

## Task 6: Reconcile the 4 shared files + the shape gate

The true conflict surface (design §5). Handle each explicitly.

- [ ] **6.1 `tools/family.json` — combine both regions.** Apply **Side A's** additions (the 6 m3e + 3
      html sibling entries; `authorizedAbsentPrefixes` mirror-lag note; `authorizedExtraPrefixes`
      `["elm-m3e-families/"]` → `["elm-m3e-components/"]`) **and keep Side B's** additions already in the
      base (okf `component-substitution.md`; the 3 figma-connect plan/research allowlist entries). Verify
      both sets are present: `rg -n 'elm-m3e-components|component-substitution|structural-fidelity-ideation'
      tools/family.json`. (Regions are non-overlapping — design §5.2.)
- [ ] **6.2 `tools/check-m3e-5pkg.mjs` — adopt Side A's NEW-name assertions.** Replace the base's OLD-name
      assertion array (`elm-m3e-{html,components,builder,icons,facts}`) with Side A's
      (`elm-m3e-{core,elements,build,icons,facts}`) — copy from
      `git show exec/explosion-task4:tools/check-m3e-5pkg.mjs` (its `need` array `:8`, header `:1-3`, OK
      message `:19`). This gate now enforces the reconciled shape.
- [ ] **6.3 `docs/copy-fidelity-notes.md` — keep both sections.** Add Side A's `PACKAGES-MOVED.md` note;
      keep Side B's Figma-SLOT + okf concept-page notes already in the base (append-only, distinct
      sections — design §5.4).
- [ ] **6.4 `tools/gate-all-expected-steps.json` — regenerate, do not hand-edit.** After Tasks 4–5 the
      new sibling `check` steps exist and the base already carries `tools/*.test.mjs (12 file(s))`.
      Regenerate the fixture the same way the repo does (the gate-all fixture-regen path) so it carries
      **both** the 9 new sibling steps **and** the `12 file(s)` count (design §5.3).
- [ ] **6.5 Commit** Task 6: `chore(reconcile): reconcile family.json, shape gate, copy-fidelity notes, gate fixture`.

> **MILESTONE — green reconciled tree, NEW package names, OLD namespaces.** After Task 6, run
> `GATE_ALL_CONCURRENCY=1 node tools/gate-all.mjs` and confirm green. This is the exact state Side A
> reached (package rename fully re-derived), now on Side B's base. It is the green tree Task 7's
> highest-blast-radius namespace rename lands on (D-R4).

---

## Task 7: Module-namespace rename (OQ-2 — the explosion plan's deferred "Task 5")

**Real added scope (Jack, OQ-2).** Rename `M3e.Component.*`→`M3e.Element.*`, `M3e.Family.*`→`M3e.Component.*`,
`TypedHtml.Component.*`→`TypedHtml.Element.*` (core/`Build`/icon/facts namespaces stay). This is the
highest-blast-radius change in the reconciliation — every generated module + **~181 non-generated consumer
`.elm` files** + review-rule logic. It lands **last, on the green tree** (Task 6 milestone) so any compile
break is unambiguously the rename's fault. **Model tier (informational):** opus / high (design-bearing +
wide edit).

**D-R5 (load-bearing) — single atomic pass.** Build the full old→new token map and apply it in ONE
traversal. A sequential `Component→Element` then `Family→Component` would re-capture the freshly-written
`Element` tokens and corrupt the result. **Line numbers below are re-verified on the reconciliation base
(origin/main) — the explosion plan's citations (e.g. `Component.elm:646`) are stale because Side B rewrote
`Component.elm`.**

### 7a. Drive the generated side from config + emitters (so regeneration emits new namespaces)

- [ ] **7.1 First concrete action.** Edit `brands/m3e/inputs/cem/config/slots.json` `_families.namespace`
      `"Family"` → `"Component"` (decoded at `Generate/Config.elm:236` `field "namespace"`, consumed by
      `Generate/Phantom/Emit/FamilyPackage.elm` to build `<lib>.<namespace>.<Family>` paths — the mechanism
      survived the JS→Elm port). Then edit the per-element emitter in
      `pipeline/elm-cem/codegen/Generate/Phantom/Emit/Component.elm`: the `"Component"` path segment at
      **`:824`** (`file [ core.lib, "Component", comp.name ]`) and the module line at **`:827`**
      (`"module " ++ core.lib ++ ".Component." ++ comp.name`) → `"Element"`. **Do NOT touch** the
      `Internal.Types` emission (`:278`, `:312` — no `Component` path segment) or any `M3e.Build` emission
      (Build namespace stays). Also grep the emitter for any other `"Component"` path segment (e.g. a
      `Home.elm` file-path builder) and flip those too: `rg -n '"Component"' pipeline/elm-cem/codegen/Generate/`.
- [ ] **7.2 Flip the barrel emitter's imports.** The barrel producer (`Generate/Phantom/Emit/General.elm`
      / the `M3e.elm` barrel emitter) imports `M3e.Component.*` — retarget to `M3e.Element.*`. Locate:
      `rg -n 'Component' pipeline/elm-cem/codegen/Generate/Phantom/Emit/General.elm`. (This pairs with the
      barrel-in-core edit from Task 2/4b — the barrel now lives in `core` and must reference `M3e.Element.*`.)
- [ ] **7.3 Flip the `elements` bucket prefix.** `brands/m3e/generated/package/elm-m3e/packages.json:99`
      `"prefix": "M3e.Component."` → `"M3e.Element."`. Leave `M3e.Build`/`M3e.Build.` (`:122`/`:125`)
      untouched. (The family package's namespace is now `Component`, sourced from slots.json 7.1.)
- [ ] **7.4 GO/NO-GO GATE — regenerate + re-materialize + inspect headers.** Re-run the m3e generator and
      split (`pnpm --filter elm-m3e run gen:src && pnpm --filter elm-m3e run split`), re-materialize +
      elm-format the siblings, and re-run the html gen/split (7.7). **Confirm:** emitted per-element module
      headers say `module M3e.Element.<C>` (e.g. `elm-m3e-elements/src/M3e/Element/Button.elm` →
      `module M3e.Element.Button`); family modules say `module M3e.Component.<F>` under
      `elm-m3e-components/src/M3e/Component/*.elm`. If headers still say `M3e.Component`/`M3e.Family` for
      the wrong tier, STOP — the emitter edit is incomplete (do not proceed to the consumer remap).

### 7b. Consumer migration (the ~181-file atomic remap)

- [ ] **7.5 Ship the migration script** `brands/m3e/generated/package/elm-m3e/scripts/rename-namespaces.mjs`
      — an **atomic single-pass** remap over a target dir's `.elm` files applying the full map at once
      (D-R5). Reference it from the `PACKAGES-MOVED.md` migration note + README so external consumers can
      run it. (`elmq`/`elm-rust-lsp` are viable rename-aware engines if preferred over text remap — but the
      map must still apply atomically.)
- [ ] **7.6 Apply it to in-repo non-generated consumers.** Run the script over the docs app
      (`brands/m3e/generated/docs/elm-m3e-docs/app/**`, `src/**`, `samples/**`) and any other non-generated
      `.elm` consumer. (Scope check: `git grep -lE 'M3e\.Component\.|M3e\.Family\.' -- '*.elm' | grep -vE
      'generated/package/[^/]+/src/'` — ~181 files on the base.)
- [ ] **7.7 html half.** Flip the html emitter's `TypedHtml.Component.*` path segment → `TypedHtml.Element.*`
      (same emitter family), regenerate + re-split the 3 html siblings, and run the migration remap over
      html's non-generated consumers (`brands/html/generated/package/elm-typed-html/verify/**` fixtures).
- [ ] **7.8 Hand-edit the review-rule LOGIC (NOT a text remap).**
      `pipeline/elm-review-cem/src/NoFamilyMemberDrift.elm:26-27` hardcodes
      `componentNamespace = [ "M3e", "Component" ]` / `familyNamespace = [ "M3e", "Family" ]` — flip to
      `[ "M3e", "Element" ]` / `[ "M3e", "Component" ]` by hand. Also update `review/src/ReviewConfig.elm`
      namespace lists and any elm-review-cem test fixtures whose *expectations* hardcode the old namespaces
      (`rg -n 'M3e","(Component|Family)"' pipeline/elm-review-cem/`).

### 7c. Repoint + verify + commit

- [ ] **7.9 Repoint stragglers.** Any docs `source-directories`, `tools/family.json` `authorizedExtra*`, or
      migration notes naming `M3e.Component`/`M3e.Family` module paths → new namespaces.
- [ ] **7.10 Re-grep — every remaining hit is a miss.** `rg -n 'M3e\.Component\.|M3e\.Family\.|TypedHtml\.Component\.'`
      repo-wide (exclude `dist/` and migration-note prose). The only surviving `M3e.Component.` should be
      the *family* modules (intended) and the review rule's *new* `["M3e","Component"]` (intended). No
      `M3e.Family.` or `TypedHtml.Component.` should remain outside a migration note.
- [ ] **7.11 GATE.** `GATE_ALL_CONCURRENCY=1 node tools/gate-all.mjs` green — the whole tree recompiles
      under the new namespaces and the elm-review-cem drift rules pass. **Commit atomically** (this is the
      one release that flips namespaces): `refactor(reconcile): atomic module-namespace rename (Component→Element, Family→Component, TypedHtml.Component→Element)`.

---

## Task 8: Re-baseline the Face-A generator bundle + phantom re-bless

Both sides changed the generator, **and Task 7 changed it again** (namespace emission) — so the bundle
re-baseline must run **after** Task 7 to capture the final emitter output (design §6, memory
`generator-change-d046-rebaseline`).

- [ ] **8.1 Re-baseline the Face-A bundle.** Regenerate `tools/snapshots/elm-cem-generator.bundle`
      (+ `tools/snapshot-refs.json`) against the final reconciled generator+config (post-namespace-rename),
      via the repo's bundle-regen path. The `workspace: ab-elm-cem (Face A byte-identity)` and
      `ab-elm-m3e-split` gates must then pass.
- [ ] **8.2 Re-bless phantom expectations** if the generator changes moved any
      `pipeline/elm-cem/tests/phantom/expected/**` output (both sides + the namespace rename touched
      `Generate/Phantom/Emit/`). Regenerate + verify the phantom golden fixtures — note the phantom
      fixtures' own module namespaces may shift if they exercise `Component`/`Family` paths.
- [ ] **8.3 Commit** Task 8: `chore(reconcile): re-baseline Face-A generator bundle + phantom expectations`.

---

## Task 9: Brand Facts schema — confirm satisfied, record DECISION 1 reversal (OQ-1)

**No longer gated.** OQ-1 resolved = reverse DECISION 1 (keep the six NEW-naming keys). With Task 7 landed,
the schema's `module` strings (`M3e.Element.*` / `M3e.Component.*`) are also real, so the schema
(`docs/facts-bundle/schema.json`) is satisfied *fully* as-written — no edit to the schema's required keys.

- [ ] **9.1 Confirm the schema is unchanged and correct.** Verify `docs/facts-bundle/schema.json:819`
      still requires `["core","elements","build","components","icons","facts"]` and the per-component
      `brandFactsElmComponentTargets` still illustrates `M3e.Element.*` — both now match the reconciled
      reality. **Do NOT apply DECISION 1's (1a) backward walk.**
- [ ] **9.2 Record the reversal.** Update `docs/superpowers/plans/2026-08-20-brand-facts-phase2-targets-elm.md`:
      annotate the "RESOLVED (1a)" block to note that DECISION 1's premise ("the elm-m3e package rework has
      not landed") is **falsified by this reconciliation** — the rework (package rename + namespace rename)
      has now landed, so DECISION 1 is **reversed** and the schema keeps its six NEW keys. This prevents a
      future reader from re-applying the stale walk-back.
- [ ] **9.3 Verify** `elm-cem` schema tests + `validateBrandFacts` pass against the reconciled tree (new
      package keys + new namespaces). If a phase-2 producer run is in scope, confirm it emits
      `targets.elm.packages` with the six NEW keys and `M3e.Element.*`/`M3e.Component.*` module strings.
- [ ] **9.4 Commit** Task 9: `docs(reconcile): confirm Brand Facts schema; record DECISION 1 reversal (OQ-1)`.

---

## Task 10: Full reconciled gate + final verification

- [ ] **10.1 Run the full gate serially:** `GATE_ALL_CONCURRENCY=1 node tools/gate-all.mjs`, save to
      `/tmp/reconcile-final-gate.log`. It must be **green**, exercising: the new sibling-package
      `check` steps (`elm-m3e-{core,elements,build,components,icons,facts}: check`,
      `elm-typed-html-{core,elements,facts}: check`); `verify-split`; `check-m3e-5pkg` (NEW names);
      `ab-elm-cem` + `ab-elm-m3e-split` byte-identity (post-rebaseline); `tools/*.test.mjs (12 file(s))`;
      the elm-review-cem namespace-drift rules **under the new namespaces**; and all Side B
      security-hardening + Figma tests.
- [ ] **10.2 Diff the two gate logs.** `diff /tmp/reconcile-baseline-gate.log /tmp/reconcile-final-gate.log`
      — every new/changed step must be an *addition* (new siblings) or an *expected* change; no
      regression from the Side B baseline.
- [ ] **10.3 Final namespace sweep.** `rg -n 'M3e\.Family\.|TypedHtml\.Component\.'` repo-wide (exclude
      `dist/` + migration notes) returns **nothing** outside migration prose; the only `M3e.Component.`
      hits are the family modules + the review rule's new list (Task 7.10).
- [ ] **10.4 Re-run the identity guard (Step 0.3)** before the final commit.
- [ ] **10.5 Confirm `git status` clean** and the branch contains exactly the reconciliation commits atop
      `origin/main` (`git log --oneline origin/main..HEAD`).
- [ ] **10.6 Final report** to Jack: the Task-3 crux-gate result (did the generator compatibility hold?),
      the Task-7 namespace-rename outcome (files remapped, gate green), the final gate green evidence
      (paste the tail), and the residual OQ-3 (mirror republish) follow-on (now more overdue — the
      namespace rename shifts the mirror further from the published snapshot).

---

## Dependency graph (for sequencing / parallelism)

```
Task 0 ─▶ Task 1 ─▶ Task 2 ─▶ Task 3 (CRUX GATE) ─▶ Task 4 ─┐
                                                            ├─▶ Task 6 ─▶ [GREEN] ─▶ Task 7 (namespace) ─▶ Task 8 (bundle) ─▶ Task 9 (schema) ─▶ Task 10 (final gate)
Task 5 (html, independent after Task 0) ────────────────────┘
```

- Task 5 (html) is independent of Tasks 1–4 (Side B never touched html) and may run in parallel after
  Task 0 — but its namespace half (`TypedHtml.Component.*`→`TypedHtml.Element.*`) is folded into Task 7.7,
  so html must reach the green milestone before Task 7.
- Task 3 is the first hard gate: if it fails, everything downstream pauses pending an emitter fix.
- Task 7 is the second hard gate + highest blast radius: it lands ONLY on the green tree (Task 6 milestone),
  in a single atomic remap pass (D-R5), and gates green before Task 8.
- Task 8 (bundle) MUST follow Task 7 — the bundle must capture the post-rename emitter output.
- Task 9 (schema) is no longer gated (OQ-1/OQ-2 resolved) — a confirmation + decision-reversal record.

## Task count / shape

**11 tasks (0–10)**, ~58 checkboxed steps — up from 10 tasks / ~45 steps, the growth entirely from Task 7
(the namespace rename Jack pulled into scope, OQ-2). Shape: 1 baseline/guard task; 1 crux-proof gate
(Task 3); 4 package-rename+materialization tasks (m3e config+regen, m3e split, html split, overlap-file
reconcile) reaching a **green milestone**; **1 highest-blast-radius atomic namespace rename (Task 7 — the
new work)**; 1 generator-bundle re-baseline (moved after the rename); 1 schema confirmation + DECISION 1
reversal record (Task 9, un-gated); 1 final full-gate verification. The two hard gates are Task 3
(generator compatibility) and Task 7 (namespace rename on a green tree). No task is human-gated anymore —
all three open questions are resolved.
