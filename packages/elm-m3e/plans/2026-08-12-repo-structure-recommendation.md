# elm-m3e family — repo/package structure recommendation

**Date:** 2026-08-12
**Author:** liaison (design input for the in-flight repo restructuring)
**Status:** OPINION / spec-in-mind — not a directive. Flag anything below that contradicts context I don't have.

---

## The question

The same generated code can be published as **one monolith** (`jackhp95/elm-m3e`), as a **granular family** (`-core` / `-components` / `-review-facts` / `-icons` …), or **both**. Which package boundaries should actually become published-package boundaries?

## Two principles I'd decide by

### 1. In Elm, every published package is a semver unit with a *cascade tax*.
Elm's compiler enforces per-package semver and computes the bump from the API diff. A breaking change in a *low* package forces a coordinated **major bump + republish of every dependent, in dependency order**. That tax is paid *every time the shared base changes*, forever. So: **split only where the modularity buys something worth that recurring tax.** More packages is not more modular — it's more coordination.

### 2. A package boundary should be a *deep seam*, not a leaky one.
A good module/package boundary is deep: a **narrow public interface** hiding a lot, with **independent value**. The tell for a *bad* boundary is the opposite — a wide interface, or one that only works by **exposing internals across it**.

This is the decisive lens here, because the split-fix that broke the `components → M3e.Build.Internal` cycle did it by **force-exposing** `M3e.Forge.Internal` from `-core` so `-components` can reach into it (like `HtmlIr.Internal`). **A boundary you have to force-expose internals across is a leaky seam — exactly the kind you should NOT promote to a package boundary.** Keep it *internal* to a single package instead.

## Applying the test to each candidate boundary

| Boundary | Split as its own package? | Why |
|---|---|---|
| **`elm-m3e-icons`** | **Yes** ✅ | 4083 fns, optional, evolves on Material Symbols' cadence (not the library's). Narrow interface (name → element), huge behind it. A textbook deep seam + genuine opt-in bulk. |
| **IR** (`elm-html-intermediate-representation`) | **Yes** ✅ (already) | The cross-brand substrate — genuinely shared by m3e, typed-html, other brands. Deep. |
| **`elm-cem-facts`** (`Cem.Fact`/`Facet`) | **Yes** ✅ | Neutral vocabulary shared by *generated facts* and the *rules*, with no elm-review dep. A real shared-types seam. |
| **`elm-review-cem`** (the rules) | **Yes** ✅ | Dev tooling, not runtime. Different consumer, different lifecycle. |
| **`elm-m3e-review-facts`** (`M3e.Review.Facts`) | **Yes, small** ✅ (mild) | Review-**only** data. Keeping it a tiny package that only a consumer's `review/elm.json` depends on keeps review data out of the *runtime* dep graph. (Constraint: it MUST stay consumer-importable — a `review/` config imports it — so it can't just be unexposed in the monolith.) |
| **`-core` / `-components` / `-builder`** | **No** ❌ | This is the leaky-seam case. Nobody consumes `-core` without `-components` (you use the substrate *through* the components); `-builder` can't even stand alone (blocked by the `exposing (..)` codegen constraint); and `-core` only "works" by force-exposing `M3e.Forge.Internal`. This split is a **technical artifact of the DAG-break, not consumer-facing modularity** — and it adds 2–3 packages to the cascade tax for ~zero consumer benefit. Keep core/components/builder **inside one package**, with `Forge.Internal` as an internal module. |

## Recommended published surface

- **`jackhp95/elm-m3e`** — the **monolith library** (core + components + builder, one dependency). The primary artifact; what ~95% of consumers want; registry-faithful today.
- **`jackhp95/elm-m3e-icons`** — standalone.
- **`jackhp95/elm-m3e-review-facts`** — tiny, review-only.
- **`jackhp95/elm-review-cem`** — the rules.
- **`jackhp95/elm-cem-facts`**, **`jackhp95/elm-html-intermediate-representation`** — shared types + substrate.

i.e. **publish the monolith as the library; keep separate only the four things that genuinely earn it; do not fragment core/components/builder.** If you want the granular family for its own sake, publish it *in addition to* the monolith (monolith = the default door; family = for pickers) rather than *instead of* — but I'd only carry both if you actually intend to support both consumption styles long-term.

## What would flip this

Tell me if any of these is true — they'd change the answer:
- You want **other libraries to depend on `elm-m3e-core`'s phantom machinery without components** (a real standalone-core consumer). Then `-core` earns a boundary — but fix the seam so it isn't force-exposing internals.
- There's a **cross-brand core-sharing** plan I'm not seeing (though the cross-brand substrate looks like IR, and `-core` is M3e-specific).
- Registry/docs-size or compile-time concerns that actually bite at the monolith's 138 modules.
- The split is a **deliberate product stance** (you *want* to teach consumers the layered model) — then it's a values call, not a mechanics one, and that's yours.

## For the restructuring agent (the one principle to carry)

**Split only where independent evolution or optional bulk justifies Elm's version-cascade tax; keep DAG-break artifacts (`Forge.Internal`) *internal* rather than promoting a force-exposed boundary to a package.** Watch-items: (1) `M3e.Review.Facts` must remain importable by consumers' `review/` configs; (2) the `M3e.Forge.Internal` force-expose is a smell to *contain*, not proliferate; (3) whatever the shape, keep exactly one package claiming `jackhp95/elm-m3e` (the earlier root/nested collision).

## Live blocker found (2026-08-12): the `Cem.Facts` duplicate-expose

Verified against real manifests: **both `jackhp95/elm-review-cem` (`elm.json` exposes `Cem.Facts`) and `jackhp95/elm-cem-facts` (`facts/elm.json` exposes `Cem.Facts`) publish a module named `Cem.Facts`.** Elm forbids two dependencies exposing the same module name. `elm-review-cem` *vendors* `Cem.Facts` (declares no `jackhp95` dep). Consequence for a modular publish: a consumer's `review/elm.json` needs the rules (`elm-review-cem`) **and** the generated facts (`elm-m3e-review-facts`, which per the publish runbook depends on `elm-cem-facts`) → the consumer transitively pulls **two** packages exposing `Cem.Facts` → **module-name clash; won't compile** (plus a `Fact`-type-identity mismatch: the rules expect `elm-review-cem`'s `Fact`, the facts produce `elm-cem-facts`'s `Fact`).

**Resolve before publishing the facts/review packages.** Two coherent end-states — pick ONE, never ship both a vendored and a published `Cem.Facts`:
- **(A) Fewer packages (fits the thesis):** don't publish `jackhp95/elm-cem-facts` as a consumer package — treat it as a build-time source that `elm-cem` uses and `elm-review-cem` vendors; make `elm-m3e-review-facts` compile against **`elm-review-cem`'s** `Cem.Facts`, so consumers ever only see one `Cem.Facts`.
- **(B) One real source:** make `elm-cem-facts` the single `Cem.Facts` and have `elm-review-cem` **depend on it instead of vendoring**, so there's exactly one in the graph. More packages, no duplication.

This is the sharpest instance of the leaky-seam problem extra package boundaries create here.
