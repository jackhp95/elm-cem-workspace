# DAG rework — Task 3 (whole-brand cutover) + Task 4 (MATERIALIZE) evidence

Companion to `docs/plans/2026-08-21-dag-rework-plan.md` and
`docs/plans/2026-08-21-dag-rework-task1-2-poc.md`. Records the captured evidence
for Tasks 3 & 4. Proceeds under **D-DAG1 (Shape A)** with Jack's OQ resolutions
carried into the dispatch (OQ-1 confirmed by the Task 2 PoC; OQ-2 emitter-computed;
OQ-3/OQ-4 = **permanent, first-class dual surface** — `M3e.Build.<Element>` AND
`M3e.Build.<Family>` both permanently exported, per-element modules being thin
forwarding re-exports over the one real Components-driven composed implementation).

## The load-bearing design decision Task 3 had to resolve (D-DAG7)

The plan's Step 3.1 says "extend the PoC to all 21 families + all degenerate
families (every element covered)" and Task 5's gate forbids **any**
`M3e.Build.* → M3e.Element.*` import. Every composed builder therefore has to
source its element-tier types + slot placers through a `M3e.Component.<Family>`
façade — including the **60 standalone (degenerate) elements**, which today have
NO `M3e.Component.<Element>` façade (Components ships only the 21 declared-family
modules).

Empirical grounding for the decision (checked against the live tree):

- The ONLY real compiled consumer of `M3e.Build.*` is the **`M3e.Build` barrel**,
  which references `M3e.Build.<Element>.Is` for **every one of the 130 elements**
  (un-prefixed `Is` alias per element) plus re-exports `Builder`/`toElement`.
- The `elm-review-cem` test references to `M3e.Build.Button.*` /
  `M3e.Component.Button.*` are **elm-review `"""…"""` string fixtures** (rule
  INPUT text), NOT real compiled imports — they impose zero module-graph
  constraint.
- Real per-element consumers (e.g. `TranslateToBuild` fixtures) use the
  **un-prefixed** surface: `M3e.Build.Button.build`, `.withVariant`, `.withIcon`,
  `.withSelected`, `.toElement`.

**Resolution (D-DAG7): the "one real Components-driven implementation" is a
family-composed builder per family, and the Components tier grows to cover every
element.** Concretely, for BOTH the 21 declared families and the 60 synthesized
degenerate single-member families:

1. **Components façade** — `M3e.Component.<Family>` exists for every family. The
   21 declared ones already ship; the 60 degenerate ones are **emitter-computed**
   single-member family façades (family name = element name, member label =
   element name), added to the `FamilyPackage` emitter.
2. **Composed builder** — `M3e.Build.<Family>` (member-prefixed) imports its
   `M3e.Component.<Family>` façade, never `M3e.Element.*`. For a degenerate family
   the family IS the element, single member.
3. **Thin per-element re-export** — `M3e.Build.<Element>` forwards the
   member-prefixed composed surface back to the un-prefixed flat surface
   consumers use today (`build`, `Builder`, `withClass`, `Is`, …). This is what
   keeps the barrel and all existing consumers compiling with ZERO edits, and is
   Jack's "permanent, first-class dual surface". A degenerate family's re-export
   is 1:1/trivial (single member, label = element name).

This makes "everything through Components" literally true (the linear DAG
`build → components → elements → core`) and is the mechanical consequence of
Jack's "one real Components-driven implementation", not scope creep.

### Task 3 dual-emit discipline (nothing shipped changes)

Task 3 keeps the shipped `M3e.Build.*` / `M3e.Component.*` / `M3e.Element.*`
byte-identical. The whole composed + degenerate world is emitted under TEMP
namespaces so the shipped 6-package split stays pristine until Task 4 promotes:

- composed families → `M3e.Build2.<Family>`
- degenerate Component façades → `M3e.Component2.<Element>`
- per-element re-exports are NOT emitted in Task 3 (they are the Task 4
  materialize step; Task 3 proves the composed + façade surfaces).

Task 4 then cuts `Build2 → Build`, promotes the degenerate façades into the real
`M3e.Component.*` namespace, emits the thin `M3e.Build.<Element>` re-exports,
removes the per-element `compBuildModule`, and flips packages.json/split.js/
check-m3e-5pkg.mjs.

## Task 3 — whole-brand cutover (dual-namespace) — CAPTURED EVIDENCE

Emitter changes (all in shared codegen — regen-verified against shoelace below):

- `BuildPackage.elm` — extended from the 21-declared-family PoC to the WHOLE
  brand: `resolveAllFamilies` synthesizes 60 degenerate single-member families
  (every `homeOf == Nothing` element not already a declared-family member —
  mirrors `Emit.elm`'s `own` exactly), emits their `M3e.Component2.<Element>`
  façades (via `FamilyPackage.degenerateFacadeModule`), and gives degenerate
  members an EMPTY `exposedPrefix` so `Build2.<Element>` carries the flat
  un-prefixed surface (`build`, `Builder`, `withClass`) byte-set-identical to
  today's per-element `Build.<Element>`. Conditional `Json.Encode` import
  (union of members' `needsJsonEncodeImport`) added — the one thing the static
  PoC import block missed on the whole-brand set (float-property setters).
- `FamilyPackage.elm` — exposes `degenerateFacadeModule`, a 1:1 single-member
  family façade built by reusing `generateFamilyModule` VERBATIM (cannot drift
  from a declared façade).

Regenerated tree (`npm run gen:src`, m3e):

- **81** `M3e.Build2.<Family>` composed modules (21 declared families covering
  70 elements + 60 degenerate).
- **60** `M3e.Component2.<Element>` degenerate façades (the 21 declared
  `M3e.Component.<Family>` façades already ship).
- Shipped `M3e.Build.*` (130) / `M3e.Component.*` (21) / `M3e.Element.*` (130)
  **byte-identical** — `git status` shows 0 non-Build2/Component2 changes.

### Step 3.2 — coverage (every element has a builder through the tree)

Programmatic assertion over all 130 shipped `M3e.Build.<Element>` modules:

```
total build elements: 130
covered (surface reachable through composition tree): 130
problems: 0
```

- 60 degenerate elements: `Build2.<Element>` exposing set == shipped
  `Build.<Element>` exposing set (zero missing, zero extra — flat un-prefixed).
- 70 declared-family members: every shipped un-prefixed name is present in its
  `Build2.<Family>` module as the correctly member-prefixed name
  (`ItemBuilder`, `itemBuild`, …).

### Step 3.2 (compile) — the whole composed tree type-checks

A throwaway consumer app fusing the flat `src` (Build2 + Component2 + Element +
core) + `../elm-m3e-components/src` (declared Component façades) + IR/facts, with
a `Main.elm` importing all 81 `M3e.Build2.*` modules:

```
Success! Compiled 430 modules.
```

All 81 composed builders + 60 degenerate façades type-check sourced through
Components — Shape A proven at whole-brand scale, not just the NavMenu PoC.

- `import M3e.Element` in `Build2/`: **0** (Task 5's gate holds for the composed
  layer).
- `import M3e.Component`/`Component2` in `Build2/`: **81** (all composed modules
  route through Components).
- `import M3e.Element` in `Component2/`: **60** (façades correctly sit between
  Build and Element).

### Step 3.3 — determinism

Two consecutive `gen:src` runs → `Build2/` and `Component2/` byte-identical
(`diff -rq` clean). (The `ab-elm-cem`/`check-drift` workspace gates stay RED for
the SAME reason as the Task-0-equivalent baseline on this worktree tip — the
committed Face-A snapshot bundle predates BuildPackage.elm, so the workspace
generator emits +81/+60 files the pristine snapshot lacks. That is the
"generator changed → Task 8 re-baseline" state, explicitly out of scope, NOT a
determinism failure: the emitter is internally deterministic as shown.)

### Step 3.4 — before/after builder-tree diff (materialization contract)

```
BEFORE  M3e.Build.* (130 modules, per-CEM-element)   import M3e.Element: 130   import M3e.Component: 0
AFTER   M3e.Build2.* (81 composed = 21 fam + 60 degen) import M3e.Element:   0   import M3e.Component/2: 81
        + M3e.Component2.* (60 degenerate façades)
```

Task 4 promotes this contract: `Build2 → Build`, `Component2 → Component`, the 70
declared-family members gain thin `Build.<Element>` re-exports, per-element
`compBuildModule` is removed.
