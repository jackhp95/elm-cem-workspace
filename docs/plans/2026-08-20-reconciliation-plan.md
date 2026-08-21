# Reconciliation execution plan — package-explosion (Side A) ⋈ generator-consolidation (Side B)

**Design record:** `docs/superpowers/specs/2026-08-20-reconciliation-design.md` (read it first — this
plan assumes its findings). **Templates followed:** `docs/plans/2026-08-20-package-explosion-plan.md`
and `docs/plans/2026-08-19-repo-shape-v2-wave1-plan.md`.

**This plan is NOT executed by its author.** It is handed to a fresh execution agent after Jack reviews
it. **Two Open Questions (OQ-1, OQ-2) GATE Task 8** — do not start Task 8 until Jack answers them.

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
intent and *lands*; the only genuinely human-owned decision is how Side B's Brand Facts schema responds
to it (Task 8, gated).

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
- **D-R4 — schema is gated.** Task 8 waits on OQ-1/OQ-2.

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
      `M3e.Family.*` (namespace rename is deferred — design §2.1, §7.3).
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
- [ ] **4.15** Retire the monolith published identity (OQ-5 confirmed on Side A): stop publishing
      `jackhp95/elm-m3e`; add `PACKAGES-MOVED.md` (Side A authored it — copy from
      `git show exec/explosion-task4:brands/m3e/generated/package/elm-m3e/PACKAGES-MOVED.md`) and pin it
      from the package README/`VISION.md` as Side A did.
- [ ] **4.16 Commit** Task 4: `refactor(reconcile): materialise m3e 5-package split as committed siblings + retire monolith`.

---

## Task 5: `elm-typed-html` — 3-tier split (pure Side-A re-derivation, no Side B interaction)

Side B did not touch elm-typed-html generation, and html uses the unchanged `elm-cem split` (design §2.4).
This task is a straight re-application of Side A's Task 4.

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

---

## Task 7: Re-baseline the Face-A generator bundle + phantom re-bless

Both sides changed the generator; the reconciled generator is neither side's baseline (design §6, memory
`generator-change-d046-rebaseline`).

- [ ] **7.1 Re-baseline the Face-A bundle.** Regenerate `tools/snapshots/elm-cem-generator.bundle`
      (+ `tools/snapshot-refs.json`) against the reconciled generator+config, via the repo's bundle-regen
      path. The `workspace: ab-elm-cem (Face A byte-identity)` and `ab-elm-m3e-split` gates must then pass.
- [ ] **7.2 Re-bless phantom expectations** if the generator change moved any
      `pipeline/elm-cem/tests/phantom/expected/**` output (both sides touched
      `Generate/Phantom/Emit/`). Regenerate + verify the phantom golden fixtures.
- [ ] **7.3 Commit** Task 7: `chore(reconcile): re-baseline Face-A generator bundle + phantom expectations`.

---

## Task 8: Brand Facts schema reconciliation — **GATED on OQ-1 + OQ-2** (design §7, §11)

**DO NOT START until Jack answers OQ-1 and OQ-2.** Written parametrically so it is executable under
either resolution.

- [ ] **8.0 Confirm the resolution.** Read Jack's answer to OQ-1 (reverse DECISION 1?) and OQ-2 (namespace
      scope). Record the chosen path at the top of the commit message.

**If OQ-1 = "keep the six NEW-naming keys" (recommended, design §7.2):**
- [ ] **8.1** Do **not** apply DECISION 1's (1a) backward retarget. Confirm
      `docs/facts-bundle/schema.json:819` still requires `["core","elements","build","components","icons",
      "facts"]` (it already does on the base). Confirm the phase-2 producer plan
      (`docs/superpowers/plans/2026-08-20-brand-facts-phase2-targets-elm.md`) is updated to note the
      premise flip (Side A landed; effectively option 1b).
- [ ] **8.2 (per OQ-2 sub-answer):**
      - **OQ-2(a) — land the namespace rename:** execute Side A's deferred namespace pass
        (`M3e.Component.*`→`M3e.Element.*` per-element, `M3e.Family.*`→`M3e.Component.*` families) so the
        schema's `module` strings are fully satisfied. **This is substantial, previously-unbuilt work
        (Side A's "Task 5") — scope it as its own sub-plan if chosen; it touches every generated module +
        every consumer reference.** Anti-footgun applies to namespaces too.
      - **OQ-2(b) — partial retarget:** keep the six package **keys** but edit the schema's per-component
        `brandFactsElmComponentTargets` `module` illustrations to the *current* `M3e.Component.*` /
        `M3e.Family.*` namespaces (+ its test fixtures/validator). Smaller; defers the namespace rename.

**If OQ-1 = "apply DECISION 1 (1a), keep schema on OLD 5-package naming":**
- [ ] **8.1-alt** This conflicts with landing Side A's rename (Tasks 1–6). **Surface the contradiction to
      Jack before proceeding** — you cannot both land the NEW package names *and* retarget the schema to
      OLD names describing them. (This branch of the plan should not be reachable if Side A's rename is
      honored; included only for completeness.)

- [ ] **8.3 Verify** `elm-cem` schema tests + `validateBrandFacts` pass under the chosen shape.
- [ ] **8.4 Commit** Task 8: `feat(reconcile): resolve Brand Facts schema per DECISION-1 premise flip (OQ-1/OQ-2)`.

---

## Task 9: Full reconciled gate + final verification

- [ ] **9.1 Run the full gate serially:** `GATE_ALL_CONCURRENCY=1 node tools/gate-all.mjs`, save to
      `/tmp/reconcile-final-gate.log`. It must be **green**, exercising: the new sibling-package
      `check` steps (`elm-m3e-{core,elements,build,components,icons,facts}: check`,
      `elm-typed-html-{core,elements,facts}: check`); `verify-split`; `check-m3e-5pkg` (NEW names);
      `ab-elm-cem` + `ab-elm-m3e-split` byte-identity (post-rebaseline); `tools/*.test.mjs (12 file(s))`;
      and all Side B security-hardening + Figma tests.
- [ ] **9.2 Diff the two gate logs.** `diff /tmp/reconcile-baseline-gate.log /tmp/reconcile-final-gate.log`
      — every new/changed step must be an *addition* (new siblings) or an *expected* change; no
      regression from the Side B baseline.
- [ ] **9.3 Re-run the identity guard (Step 0.3)** before the final commit.
- [ ] **9.4 Confirm `git status` clean** and the branch contains exactly the reconciliation commits atop
      `origin/main` (`git log --oneline origin/main..HEAD`).
- [ ] **9.5 Final report** to Jack: the Task-3 crux-gate result (did the generator compatibility hold?),
      the final gate green evidence (paste the tail), the schema resolution taken, and any residual OQ-3
      (mirror republish) / OQ-5 (html tier doc) follow-ons.

---

## Dependency graph (for sequencing / parallelism)

```
Task 0 ─▶ Task 1 ─▶ Task 2 ─▶ Task 3 (CRUX GATE) ─▶ Task 4 ─┐
                                                            ├─▶ Task 6 ─▶ Task 7 ─▶ Task 9
Task 5 (html, independent after Task 0) ────────────────────┘
Task 8 (schema) — GATED on OQ-1/OQ-2; can run any time after Task 4, before Task 9's final gate
```

- Task 5 (html) is independent of Tasks 1–4 (Side B never touched html) and may run in parallel after
  Task 0.
- Task 3 is the hard gate: if it fails, everything downstream pauses pending an emitter fix.
- Task 8 is human-gated and must land before Task 9's final gate (schema tests run in gate-all).

## Task count / shape

**10 tasks (0–9)**, ~45 checkboxed steps. Shape: 1 baseline/guard task, 1 crux-proof gate (Task 3, the
consequential one), 4 materialization tasks (m3e config+regen, m3e split, html split, overlap-file
reconcile), 1 generator-bundle re-baseline, 1 human-gated schema task, 1 final full-gate verification.
The only non-mechanical task is Task 8 (gated on Jack's two Open Questions).
