---
name: authoring-cem-review-rules
description: >-
  Encodes the house style for adding or changing a rule when maintaining the
  jackhp95/elm-review-cem package itself (contributor-facing, not consumer). Use
  when working in the elm-review-cem repo to add a new Cem.* rule, make a rule
  handle multi-namespace facts, extend the Cem.Facts.Fact contract, or write the
  tests a new rule needs. Triggers include "add a rule to elm-review-cem", "add a
  rule flagging deprecated attributes", "extend the facts contract", "handle
  concatenated library facts", and "what tests does a new CEM rule need". Covers the
  five-step rule checklist, namespace-agnostic derivation from facts, the
  advisory posture on unresolved code, the neutral-message style, and the facts
  breaking-change policy. Routes to CONTRIBUTING, docs/decisions.md, and the
  existing rule modules rather than restating generic elm-review knowledge.
disable-model-invocation: true
---

# Authoring CEM review rules (maintainer)

You are contributing a rule (or a facts-contract change) to the `elm-review-cem`
package itself. This skill encodes only the **house style** that generic
elm-review knowledge won't produce. For the mechanics of visitors, fixes, and
`Review.Test`, use your existing elm-review knowledge; for the per-rule
reference, read the existing modules in `src/`.

## Non-negotiables (what makes a rule fit this package)

1. **Namespace-agnostic — derive, never hardcode.** No rule may mention a
   specific library name. Derive the root namespace from the facts: use
   `Cem.Internal.Facts.rootParts facts` (first fact's `module_` → root parts) and
   the per-fact helpers `factNamespaceParts`, `factNamespace`,
   `factComponentSegment`, `isTopLayerModule`. A rule keys off `fact.module_` /
   `fact.component`, not literal `"Lib"`. This is the reason the package is
   reusable at all (docs/decisions.md §"Namespace-agnostic rules").

2. **Facts-driven vs config-driven.** A facts-driven rule that reasons about component
   *usage* takes `List Cem.Facts.Fact` and lives under `Cem.*`. A seam/boundary
   rule that governs *where* code may appear takes explicit **module-name lists**
   (not facts) and keeps its **top-level** name (no `Cem.` prefix) — see
   `NoSeamOutsideAllowedModules`, `NoInternalImportOutsideAllowed`,
   `ExtractToSeam`. Pick the right class up front; it determines the whole shape.

3. **Advisory posture on unresolved code.** If a call site can't be resolved
   statically (dynamic list, `let`-bound value, helper return, `List.map`
   output), the rule stays **silent** rather than false-positive. `RequireSlot`,
   `MissingRequiredAttribute`, and `MissingRequiredSingularSlot` are all advisory
   report-only rules; `ValidSlotKind` encodes this as an explicit
   `Lenient`/`Strict` posture (`Cem.Internal.Facts` treats non-component barrel
   helpers as *unresolvable*, not as violations). Default to silence on
   uncertainty; only a deliberate `Strict`-style opt-in should warn on the
   unresolvable case.

4. **Neutral message style.** Message = one concise sentence naming the concrete
   thing at this call site. Details = a non-empty list explaining *why* and *what
   to do*, sourced from the FACTS ("The component declares `X` as required…"),
   never from a design-system assumption. This is a just-completed, load-bearing
   fix in this repo: the neutrality pass rewrote `"The Material 3 spec … treats
   `X`…"` → `"The component declares `X`…"` and `"typed M3e API"` → `"typed
   component API"` (commit `fix: neutral rule messages`). The
   `.github/neutrality-check.sh` gate enforces this — any new `material`/`m3e`/`md3`
   mention fails CI unless allow-listed. Write messages that would pass with no
   allow-list entry.

5. **A rule handles ALL namespaces in its facts, not just the first.** Consumers
   concatenate libraries' facts (`M3e … ++ TypedHtml …`). Never derive a single
   root with `Facts.rootParts facts` for resolution; store `Facts.namespaces facts`
   (the distinct namespaces) in context and resolve call sites with
   `Facts.callSite context.namespaces …`. Key any component index on
   `Facts.factKey` / look up with `Facts.find site` (namespace-qualified), and when
   you emit a module name or fix, use the matched call site's `site.namespace` (or
   `Facts.factNamespaceParts fact`) — not a global root — so a second library's
   components are checked and rewritten correctly.

## The five-step checklist (CONTRIBUTING, expanded with judgment)

CONTRIBUTING lists five steps; the judgment each hides:

1. **Create `src/Cem/YourRule.elm` exposing `rule : List Fact -> Rule`.** Prefer
   consuming an EXISTING `Fact` field over widening `Fact`. If your rule needs
   data the facts don't carry (e.g. "which attributes are deprecated"), that data
   belongs in `elm-cem` as a new/extended fact field the generator emits — do NOT
   hardcode a list of names in the rule. Extending facts is the correct move; a
   hardcoded name list is the anti-pattern this package exists to avoid.
2. **Doc-comment every exposed value.** `elm make --docs` (the publish gate)
   rejects undocumented exposures. Keep examples neutral (`<root>.*`), or use a
   concrete namespace only if you also add it to `.neutrality-allowlist`.
3. **Add `"Cem.YourRule"` to `exposed-modules` in `elm.json`.**
4. **Wire into `Cem.all`** — unless the rule is opt-in, in which case leave it
   OUT of `all` and document that clearly in the `Cem` facade (like `preferBarrel`
   and `preferComponentSetters`).
5. **Add `tests/YourRuleTest.elm`** following the table-driven pattern, reusing
   the shared fixtures.

## The four required test classes

A rule is not done until its test file covers all four (see
`reference/test-classes.md` for the concrete `Review.Test` shapes):

1. **Positive** — the violation is flagged (exact message + details + `under`,
   pinned with `atExactly` where offsets matter).
2. **Negative** — correct code produces `expectNoErrors`.
3. **False-positive bait** — the unresolvable case (dynamic list, helper return)
   produces `expectNoErrors`, proving the advisory posture. This is the class
   generic elm-review testing usually omits and the one this package most cares
   about.
4. **Inverse / round-trip** — for an autofix, and MANDATORY for the barrel pair:
   applying the fix and its inverse returns the original (`RoundTripTest` proves
   `preferBarrel`⟷`preferComponentModules` compose as inverses). For a lone
   autofix, at minimum assert the fixed output compiles and re-running the rule
   finds nothing (idempotence).

## The facts-contract breaking-change policy

`Cem.Facts.Fact` is the load-bearing contract with `elm-cem`. Adding, removing,
or renaming a field is a coordinated **major** bump on both repos; a purely
additive optional field an older generator can omit is at most a **minor**. Any
`Fact` change touches **all** hand-built fixtures — the existing fixtures default
every field, so a new field must be defaulted across every fixture in `tests/`
(this is why `slotKinds` / `groupConstructors` additions "touch all 21 Fact
fixtures"). Coordinate the generator side before shipping.

## Reference

- **[reference/test-classes.md](reference/test-classes.md)** — the four test
  classes as concrete `Review.Test` snippets, plus the fixture-defaulting note.
- `CONTRIBUTING.md` — the canonical five-step checklist and the fact-contract rule.
- `docs/decisions.md` — the *why* behind namespace-agnosticism, advisory posture,
  and the barrel round-trip invariant.
- Existing modules: `src/Cem/RequireSlot.elm` (advisory), `src/Cem/ValidSlotKind.elm`
  (posture), `src/Cem/Internal/Facts.elm` (derivation helpers, incl. the
  per-namespace `namespaces` / `factKey` / `callSite` primitives).

---
_Validated against elm-review-cem 1.0.0, 2026-07._
