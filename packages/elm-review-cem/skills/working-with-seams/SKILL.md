---
name: working-with-seams
description: >-
  Explains the seam practice for an app using the jackhp95/elm-review-cem
  seam-discipline rules: what a seam is (a sanctioned type-system hole whose
  every use discards a guarantee), how the gate / fences / autofix fit together,
  and the load-bearing idea that the `Seam` module is a centralized design-system
  maintenance surface — NOT clutter to minimize or a debt ledger to freeze. Use
  when reasoning about a `Seam.*` escape the gate flags, running the ExtractToSeam
  census, reading a consolidated `Seam.elm`, or resisting the reflex to just
  suppress or delete it. Triggers include "clean up Seam.elm", "reduce the seam
  helpers", "the seam is cluttered", "should I add this module to the allow-list",
  "run ExtractToSeam", "why is Seam.* flagged". Routes config wiring to
  configuring-cem-review-rules and per-rule semantics to the module docs.
---

# Working with seams

**The load-bearing idea:** the `Seam` module is a centralized design-system
**maintenance surface** — the one place the friction between what feature code
needs and what the typed design system (M3E) offers is gathered so a maintainer
can resolve it. It is **not** clutter to minimize, and **not** a debt ledger to
freeze.

This skill is the *mental model + doctrine*. For wiring the rules read
**configuring-cem-review-rules**; for exactly what each rule flags read its
module doc. Don't re-derive those here.

## What a seam is

A **seam** is a sanctioned hole in the type system: a function that turns raw
`Html` / `Html.Attribute` into the typed IR (`Element` / `Node` / `Attr`), or
re-brands one phantom row to another (`recast`). Each use **throws away a
guarantee** the typed component layer would otherwise enforce — so a codebase
wants them *contained* to a few blessed modules, not sprinkled through features.

Seams are built on two fenced forges: `HtmlIr.Internal` (the raw→phantom
constructors) and each brand's `*.Unsafe` surface. A **config-blessed coercion**
(`<Lib>.Coerce.*`, from the generator's `_coerce` block) is the *named, stable*
crossing and is deliberately NOT a seam; `recast` and the raw wrappers are.

## The family (route to the module docs for semantics)

| Rule | Role |
|---|---|
| `NoSeamOutsideAllowedModules` | **the gate** — flags any applied `Seam.*` escape used outside the allow-listed modules. Report-only. |
| `ExtractToSeam` | **the autofix** — lifts each flagged escape into the seam module and rewrites the call site. Opt-in; an elm-review *project* rule, so it moves code across files. |
| `NoInternalImportOutsideAllowed` / `NoUnsafeImportOutsideAllowed` | **the fences** — gate `import *.Internal` / `import *.Unsafe` to the allowed holders (the coarse backstop behind the structural fence). |
| `NoRedundantElementForge` / `NoRedundantElementEscape` | backstops against re-forging / re-escaping what the typed producer layer already hands you. |

The gate and `ExtractToSeam` **share `allowedModules`** — one source of truth for
where seams may live.

## Reading a flagged escape: triage, don't silence

A flagged `Seam.*` escape (or one the census lifts into `Seam`) is **friction** —
a spot where a feature reached past the typed DS. Each entry resolves one of
three ways, and choosing which *is the work*:

1. **Develop a new typed pattern.** The escape recurs → build the missing M3E /
   `Layout` / `Text` primitive and retarget the call sites onto it. After a
   census, identical escapes are **deduped** and the generated name **encodes the
   raw pattern** — `flexColGap4P6` literally reads "we're missing a `Layout`
   column with gap-4 / padding-6". That's the signal for *which* primitive to
   build next.
2. **Fix it at the call site.** A one-off, a misuse of an API that already
   exists, or a DS bug that only bites there. Fix in place; the entry disappears.
3. **Extend the DS to allow it.** The escape is a *legitimate* need the design
   system wrongly forbids — change the DS so it becomes a first-class typed call.

The seam **persists as the workbench; its contents are transient and trend
toward zero** as the DS matures.

## The census (running `ExtractToSeam --fix` with `allowedModules = [ "Seam" ]`)

Pointing the autofix's allow-list at the seam module alone sweeps **every**
fixable crossing in the app into `Seam` at once. Treat it as a **deliberate
diagnostic sweep** — run it to see the full scope and prioritize, not a state to
commit and forget. It is **deterministic and regenerable** (re-running reproduces
it byte-for-byte), so it's cheap to run and cheap to throw away. Hundreds of
helpers is a *measure of how hard feature code is fighting the DS*, never a
target.

Expect **punts**: an escape that captures a `let` / `case` / lambda binding or a
top-level value of the violating module (and point-free `Seam.*` references) is
surfaced as a plain error, not auto-lifted — the rule refuses to emit a
possibly-wrong fix. Those are the entries you resolve by hand.

## The reflex to resist

The natural read of a 1000-line `Seam.elm` is *"clutter — revert the lift,
`elm-review suppress` the backlog, keep the seam small."* Keep the honest half,
drop the framing:

- **Honest:** `suppress` keeps each violation at its real call site (with
  context); consolidating into machine-named helpers loses that context. A real
  tradeoff — name it, don't hide it.
- **What that framing misses:** `suppress` only *counts and freezes* debt. The
  seam is a place to **develop the fix** — a consolidated, deduped,
  primitive-naming view that tells a maintainer which typed pattern to build. It
  is a design surface, not a debt counter. Shrinking it *for its own sake*
  optimizes the wrong number; the number falls when the DS gets better, via the
  three paths above.

## Sharp edges of the lift

`ExtractToSeam` does several non-obvious things when it moves an escape across
files — de-qualifying self-references, threading cyclic and constructor
captures, re-qualifying aliases, renaming shadowing parameters. If a lifted
helper looks wrong, or you're extending the tool, see
**[reference/lift-mechanics.md](reference/lift-mechanics.md)**.

## Routing

- **configuring-cem-review-rules** — wiring the rules, the `Cem.fences` preset,
  building the allow-list.
- **authoring-cem-review-rules** — adding or changing a rule in the package.
- Per-rule semantics — the module doc for `NoSeamOutsideAllowedModules`,
  `ExtractToSeam`, `NoInternalImportOutsideAllowed`, etc.
- `docs/decisions.md` §"Seam-discipline rules live here" and `README.md`
  §"Seam discipline" — the package's own framing.

---
_Validated against elm-review-cem 1.0.0, 2026-07._
