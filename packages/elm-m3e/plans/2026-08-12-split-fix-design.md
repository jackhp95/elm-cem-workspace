# elm-m3e 3-Package Split — DAG-Fix + Revival Design

**Date:** 2026-08-12
**Author:** opus planner+coordinator (publish-readiness batch, Phase 1)
**Status:** design locked; execution on branches `elm-cem@p1-split-fix-dag`, `elm-m3e@p1-split-fix-dag`
**Companion:** `2026-08-12-publish-readiness.md` (§3/§4 — the blockers this resolves)

---

## 1. Problem statement (verified from source, not from the prior report)

The intended Arch-3P family is a 4-package DAG:

```
elm-m3e-core  ←  elm-m3e-components  ←  elm-m3e-builder
      ↖──────────────────────────────────┘
elm-m3e-icons  (independent; IR-only)
```

It fails registry-check today. Root causes, each verified against the live tree:

### 1a. Circular dependency: components → builder → components
- `M3e.Build.Internal` (the shared *builder forge*, 64 lines, `elm-m3e-builder/src/M3e/Build/Internal.elm`) mints the opaque `Builder(..)` type + `init/withAttribute/withChild/toElement`. It depends only on `HtmlIr.*`.
- **All 130** `elm-m3e-components/src/M3e/Internal/Types/*.elm` files `import M3e.Build.Internal as B` — and every one uses **exactly one symbol: `B.Builder`** (the type, referenced in their `Is`/record type aliases). Verified: `grep -rho 'B\.[A-Za-z]*' elm-m3e-components/src | sort | uniq -c` → `130 B.Builder`, nothing else.
- `elm-m3e-builder` legitimately depends on components (`M3e/Build/Icon.elm` imports `M3e.Component.Icon` + `M3e.Internal.Types.Icon`).
- So: components import a **builder-namespace** module, while builder imports components ⇒ a cycle with no valid topological publish order.

### 1b. The forge is unexposed → cross-package import can't even resolve
`split.js` (line ~210) exposes every module **except** those whose name matches `Internal(\.|$)` or `Review(\.|$)` (special-casing only `*.Review.Facts`). So wherever the forge lands, it is emitted **unexposed**, and a dependent package physically cannot import it across the package boundary. This is the direct source of the "724 / 654 NB1 violations" — the import target is unresolvable. (Contrast: `elm-html-intermediate-representation` *does* expose `HtmlIr.Internal` for exactly this cross-package-forge reason; the `Builder` docstring says it is "exactly like `HtmlIr.Internal`.")

### 1c. `jackhp95/elm-m3e` name collision
Two trees claim the identical package name `jackhp95/elm-m3e`:
- root `elm-m3e/elm.json` (138 modules) — the **Arch-R monolith**, the CI-verified path that ships today;
- nested `elm-m3e/elm-m3e/elm.json` (8 modules) — the **Arch-3P thin core**.
Exactly one may own that registry name, permanently.

### 1d. Mechanical debris
- `split.js` is **dormant**: unwired from every gate, and `packages.json` was deleted 2026-07-22 (`b94bfc2b`, "delete split-world relics"). A prior 7-package `packages.json` survives in history (`b94bfc2b^:packages.json`) but is pre-phantom (flat `M3e.<Component>` names) — a template, not reusable as-is.
- `elm-m3e-components` + `elm-m3e-builder` lack `LICENSE` + `README`.
- Stale gitignored `dist-packages/*` (Jul-21 era) on disk, incl. `elm-m3e-review-facts/elm.json` with `exposed-modules: []` — misleading debris.

---

## 2. Design decisions

### D1 — Relocate the forge to a neutral CORE module, in the codegen emitter
The `Builder` machinery is shared lower-layer infrastructure that **both** components and builder need; it currently lives (misleadingly) in the builder namespace. Move it **down** into the core package as a neutral module.

- **New name: `M3e.Forge.Internal`** (was `M3e.Build.Internal`). "Forge" is the domain vocabulary already used in the module's own docstring ("the builder forge"); it is unambiguously *not* the `M3e.Build.*` builder-surface namespace, satisfying the requirement that **components no longer import the builder namespace**.
- **Last segment stays `Internal`** → the coarse backstop rule `NoInternalImportOutsideAllowed` (which gates only imports whose *last* segment is `Internal`) remains active on it. Its allow-list is `["M3e","TypedHtml","HtmlIr"]` (brand prefixes); every importer (`M3e.Internal.Types.*`, `M3e.Build.*`) is under `M3e`, so **no fence-config change is needed**. The primary fence is structural anyway (public API withholds the opaque constructors); exposing `M3e.Forge.Internal` mirrors `HtmlIr.Internal` exactly.
- **This is a codegen change, not a hand-edit.** The forge module + all its import sites are emitted by `elm-cem/codegen/Generate/Phantom/Emit.elm`, which templates the name as `lib ++ ".Build.Internal"` at 4 sites (module decl L2523; re-export `as Internal` L2646; two `as B` imports L3376/L4003) plus comments. Change the template → regenerate elm-m3e's flat `src/` → the rename propagates to all ~261 references, machine-verified by `regen-drift`/`check:drift`.
- **API-safe for Arch R:** `M3e.Build.Internal` is NOT in any package's `exposed-modules` (verified). Renaming an internal module leaves the 138-module monolith's public API byte-identical.

*Rejected alternative:* keep the name `M3e.Build.Internal` and merely re-route it to core in `packages.json`. This breaks the cycle too, but (a) leaves components importing a `M3e.Build.*`-named module (violates the stated intent), and (b) leaves the flat-src module misleadingly named, relying on split routing to relocate it — fragile. The emitter rename is the durable, honest fix and aligns with "generated code is the source of truth."

*Rejected alternative:* a 5th micro-package `elm-m3e-internal`. Core is already the universal lower dep of both components and builder; a separate package adds a repo + publish hop for one 64-line module. Put it in core.

### D2 — `split.js`: force-expose designated cross-package internal modules
Add an opt-in mechanism so a package may expose a specifically-designated `*.Internal` forge module despite the blanket Internal filter (exactly the carve-out `*.Review.Facts` already gets). Concretely: a per-package `"exposeInternal": ["M3e.Forge.Internal"]` list in `packages.json`; split.js unions those into `exposed-modules` for that package. Core exposes `M3e.Forge.Internal`; the fence rule keeps untrusted userland out.

### D3 — Resolve the name collision by renaming the 3P core → `jackhp95/elm-m3e-core`
- **Canonical `jackhp95/elm-m3e` = the Arch-R root monolith** (gate-verified, ships today).
- **The 3P thin core is renamed `jackhp95/elm-m3e-core`** (the exact name the historical `packages.json` used). Components depend on `jackhp95/elm-m3e-core`; builder depends on core + components.
- Effect: the collision is **eliminated** and Arch-3P becomes a self-consistent, collision-free family (`elm-m3e-core` + `-components` + `-builder` + `-icons`) that can be published **independently of** the monolith-fate decision. This is fully reversible — it is a generated `elm.json` `name` value driven by a `packages.json` config field.
- **Jack's remaining decision is no longer a blocker:** "do you also want to publish the 3P family, or just the `jackhp95/elm-m3e` monolith?" Nothing irreversible is done here; both trees remain in-repo and both are valid, non-colliding packages. Recommendation: publish the Arch-R monolith now (it is the CI-verified, ships-today path); publish the 3P family later if/when the modular story earns its keep. **The monolith-vs-3P master decision remains surfaced to Jack, not guessed.**

### D4 — Split output location & the committed nested trees
- `split.js --out=.` writes `./elm-m3e-core/`, `./elm-m3e-components/`, `./elm-m3e-builder/` (dir = pkg short-name). This regenerates the committed component/builder trees in-place with the corrected DAG, and creates the renamed `elm-m3e-core/`. The obsolete committed `./elm-m3e/` (old-name core) is superseded by `./elm-m3e-core/`.
- **`elm-m3e-icons/` is NOT a split target** — it is hand-authored generator-native (own producer, LICENSE, README, drift-gated via `--nested-pkg=elm-m3e-icons`). Left untouched.
- Delete stale `dist-packages/*`.
- **Flagged for Jack (not silently executed):** removing the now-obsolete committed `./elm-m3e/` core dir and treating `split.js --out=.` output as the canonical generated split. On the branch this is reversible; called out explicitly in the worklog so the reviewer sees it rather than discovering a silent restructure.

### D5 — Registry-faithful verification per package
Each split package must pass `elm make --docs` as a standalone tree with its family deps staged (the same mechanism `check:cem --nested-pkg` uses to resolve unpublished sibling deps into a local ELM_HOME). Evidence captured per package.

---

## 3. Execution plan (task table — manager state)

| # | task | repo/branch | acceptance test | status |
|---|------|-------------|-----------------|--------|
| 1 | Rename forge `Build.Internal`→`Forge.Internal` in emitter | elm-cem@p1 | `Emit.elm` emits new name at all 4 sites; elm-cem's own tests/fixtures green | queued |
| 2 | Regen elm-m3e flat `src/` w/ branch elm-cem | elm-m3e@p1 | `src/M3e/Forge/Internal.elm` exists; 0 refs to `M3e.Build.Internal`; `check:drift`/`regen-drift` green | queued |
| 3 | Confirm Arch-R monolith unchanged | elm-m3e@p1 | root `elm make --docs` green; exposed-modules byte-identical (138) | queued |
| 4 | `split.js` force-expose carve-out | elm-cem@p1 | unit: a designated `*.Internal` module lands in `exposed-modules` | queued |
| 5 | Author `packages.json` (4-pkg, forge→core, core=`elm-m3e-core`) | elm-m3e@p1 | totality/disjointness/DAG gates pass on split run | queued |
| 6 | Run split `--out=.`; stamp LICENSE/README | elm-m3e@p1 | 3 trees emitted; each has LICENSE+README | queued |
| 7 | registry-check each split pkg standalone | elm-m3e@p1 | `elm make --docs` green for core, components, builder (+icons) | queued |
| 8 | Delete stale `dist-packages/*`; flag obsolete `./elm-m3e/` | elm-m3e@p1 | tree clean; decision surfaced in worklog | queued |
| 9 | Full `npm run gate` (Arch-R path) still green | elm-m3e@p1 | `gate` EXIT 0 incl registry-check + Playwright | queued |
| V | Independent clean-state verify of 1–9 | verifier agent | re-runs registry-check from clean tree; verdict approve/fix/trash | queued |

Recomposition guard: task 9 (full monolith gate) + task 7 (each split pkg compiles) together cover both the horizontal cuts and the vertical assembly.

---

## 4. Staged, DO-NOT-RUN outward-facing steps (Jack)
Populated in the worklog after the trees are green: per-package mirror-repo creation + tag + `elm publish`, in topological order, with the name-collision recommendation. **This agent creates no remote repos, pushes nothing, publishes nothing.**

---

## 5. OUTCOME (executed) — deviation from §2 recorded

The DAG-fix (D1/D2) landed exactly as designed: the forge is now `M3e.Forge.Internal`
in core, force-exposed, and the components→builder→components cycle is gone. `split.js`
is revived (`npm run split` / `verify:split`); registry-check green for every package;
LICENSE+README stamped; stale `dist-packages` + committed relics removed; name collision
resolved (monolith keeps `jackhp95/elm-m3e`, 3P family is collision-free).

**One design assumption in §2 was disproven by the compiler and forced a fork:**
D3/§3 assumed a fully-separate `elm-m3e-builder` package. It is **not compilable as a
standalone registry package** — `M3e.Build.*` import components' `M3e.Internal.Types.*`,
which use `exposing (..)` (forbidden on an exposed package module by `elm publish`). No
packages.json routing fixes this; it needs a codegen change (B1: emit explicit exposing +
`@docs` for the 130 internal type modules and expose them — docs noise; or B2: re-export
the builder-needed types through the exposed `M3e.Component.*` surface — cleaner emitter
change). **Surfaced to Jack; not guessed.** The shipped layout (Option A) folds the builder
API into `elm-m3e-components` (4 packages, all registry-check green today).

Full per-phase evidence, staged publish commands, and the fork write-up:
`2026-08-12-publish-readiness-fixes-worklog.md`.
