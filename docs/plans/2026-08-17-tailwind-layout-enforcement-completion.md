# Tailwind layout-only enforcement — completion

Branch `layout-only-styling`. Living plan doc; the task table is the source of truth
for what is in flight.

## Context

`NoProprietaryDsClasses` (`packages/elm-m3e/review/src/NoProprietaryDsClasses.elm`,
726 lines, 70 tests) already enforces layout-only Tailwind across the docs app,
which currently reports **zero violations** with no suppression file. Three gaps
remain, from the status report that preceded this plan.

## Task table

```
[x] L-A  centralization mechanism for Tailwind violations  — work  — sonnet/opus  — done
[x] L-B  m3e-* allow-list correctness (real manifest)       — work  — sonnet/opus  — done
[x] L-D  T7 search-ranking fix, gate to green              — work  — sonnet/opus  — done
```

## L-A — decision record: ONE destination, named `Seam`

**The question:** reuse the Elm-component side's existing seam destination, or give
Tailwind its own parallel one?

**What I found first, which reframes the question:** there is no file to reuse.

- `find packages -name "Seam.elm"` → **nothing**.
- `NoSeamOutsideAllowedModules` is configured with `seamModules = [ "Recast" ]`, and
  `Recast.elm` **does not exist either** — recasts were driven to 0 in `c3fd2cf`, so
  nothing was ever centralized there.
- `ReviewConfig`'s prose claims the docs app centralizes crossings in "designated
  adapters (`Layout`, `Kit`, `Native`, `Doc`, `Shared`)". `Layout`, `Kit` and
  `Native` **do not exist**, and are not even in that rule's allow-list. Only
  `Doc.elm` and `Shared.elm` are real.

So both candidate destinations are *names in config*, not files. The real choice is
which name to standardize on.

**Decision: one shared destination, named `Seam`.** Reasons:

1. It is Jack's stated convention ("seam is the name of the centralized file unless
   otherwise specified").
2. Both kinds of escape have the same *shape and review purpose*: a small, named
   producer that contains a design-system escape so the escape is greppable and
   reviewable in one place. An `Element`-returning producer that internally recasts
   and one that internally applies a styling class are the same artifact to a
   reviewer.
3. Naming the Tailwind destination anything else would create a SECOND name while
   the first is still aspirational — the exact fragmentation this leaf exists to
   prevent.
4. `Recast` is the wrong name for the shared concept anyway: a Tailwind escape is
   not a recast. Renaming an empty, never-instantiated config name costs nothing.

**Consequently** `NoSeamOutsideAllowedModules`'s `seamModules` is renamed
`Recast` → `Seam`, so exactly one destination name exists across both fences.

**Deliberately NOT done: creating an empty `Seam.elm`.** The docs app has zero
styling violations and zero recasts, so the module would have no members. That is
the same argument used in `c3fd2cf` for not creating an empty `Recast` module — an
empty designated module is worse than none, because it invites use rather than
recording a real need. The *mechanism* is proven by the rule's own `Review.Test`
suite (violation outside the module is caught; identical usage inside is not),
which is exactly where a fence's behaviour should be pinned. The module gets
created by whoever first has a genuine, reviewed need.

**Also fixed here, not perpetuated:** `ReviewConfig`'s false prose about
`Layout`/`Kit`/`Native` being real adapters.

## L-B — decision record: manifest over prefix

The rule accepted any `m3e-*` class via `String.startsWith "m3e-"`, so
`m3e-totally-fake-thing` passed and would render nothing — the exact failure class
the rule was originally written to catch for `ds-`/`t-`. `tailwind-m3e-web` now
emits `generated/utilities.json` alongside `generated/utilities.css` at the same
generation moment, and the rule checks membership against it. Mirrors the
`M3e.Review.Facts` pattern already used by the codegen-aware rules.

## L-D — judgment call flagged for Jack

Search capped at 20 matches in raw index order with no relevance ranking, so
"button" returned 20 guide-prose hits and `/components/button` never surfaced — a
user could not reach a component page by typing its name.

**The ranking I chose** (lowest score wins), which Jack has NOT ruled on:

| Score | Rule | Example for "button" |
| --- | --- | --- |
| 0 | matched text IS the query | `button` |
| 1 | STARTS with the query | `Button < Components < elm-m3e` |
| 2 | a WORD in it starts with the query | `Filled Button`, `Icon button` |
| 3 | contains it anywhere | `M3e.Component.ButtonGroup` |

Ties break toward page-level entries (`heading = Nothing`) over headings inside a
page, then original index for stability.

**Why this shape:** page titles here are reverse breadcrumbs
(`Shared.breadcrumbTitle`), so a page *about* a thing starts with that thing's
name — score 1 surfaces the component page without needing a special-case
"boost reference pages" rule. That is a nicer property than URL- or
section-based boosting: it needs no list of privileged routes and stays correct
as pages are added.

**What Jack might want differently:** a URL-based boost (`/components/*` above
`/guide/*`) would be more aggressive and would also rank a component page above a
guide page that happens to have a better textual match. I chose textual relevance
over route privilege because it degrades more gracefully, but it is a defensible
disagreement. Fully reversible — one function, `Shared.filterSearchEntries`.

Result: all 8 `search.spec.ts` cases pass, including the 3 that were failing
(36, 150, 215).
