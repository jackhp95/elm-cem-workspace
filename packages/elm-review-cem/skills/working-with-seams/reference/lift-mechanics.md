# Lift mechanics — what `ExtractToSeam` does when it moves an escape

`ExtractToSeam` is an elm-review **project** rule: it lifts a flagged escape into
the seam module as a new top-level function and rewrites the call site to call
it. Moving an expression across files means **every reference inside it must
still resolve — and mean the same thing — in its new home.** This catalogs how
each kind of reference is handled and the failure mode if it isn't.

> **The integration build is the only ground truth.** Unit tests
> (`Review.Test`) check the fixed *text*; they do **not** prove the lifted `Seam`
> module compiles. Every mechanic below was a real bug found by running the
> census against the real docs app and compiling the result. When changing the
> rule, verify by building the lifted output, not just by re-running the tests.

## How each reference inside an escape is handled

| Inside the escape | What the lift does | Example |
|---|---|---|
| **Self-reference** — head or nested ref that resolves to the seam module | **De-qualify** (it's now *in* the seam module). The head de-qualifies too. | `Seam.asAttribute (Seam.token …)` → `asAttribute (token …)` |
| **External ref** the seam does not yet import | **Carry the import** (preserving its alias); keep the ref qualified. | `Value.large "card"` → seam gains `import M3e.Values as Value` |
| **Cyclic ref** — into a module that imports the seam (importing it back would cycle) | **Thread as a parameter**; pass the original at the call site. | `Seam.asAttribute (Doc.render "hero")` → `hero docRender = asAttribute (docRender "hero")`, called `Seam.hero Doc.render` |
| **Free variable** — lowercase local (parameter, `msg`, `let` value in scope) | **Thread verbatim** as a parameter. | `Seam.col n` ↔ `col n = asAttribute (class ("col-" ++ n))` |
| **Uppercase local constructor** | **Thread via a lowercased slug** — a constructor can't be a parameter name; pass the constructor at the call site. | `Seam.onClick ToggleSettings` → `seamOnClick toggleSettings = onClick toggleSettings`, called `Seam.seamOnClick ToggleSettings` |
| **Alias mismatch** — a qualified ref whose module the seam already imports under a *different* qualifier (or unaliased) | **Re-qualify to the seam's qualifier**; add no import (Elm forbids importing a module twice). | `TA.name` (feature: `import TypedHtml.Attributes as TA`) → `TypedHtml.Attributes.name` |
| **Shadowing parameter** — a threaded / free / constructor param whose name collides with a seam top-level (or another param) | **Rename** (append `_`) and substitute in the body; the call site still passes the original. | `seamOnClick section` (shadows `Seam.section`) → `seamOnClick section_` |
| **Rebinding import** — an unqualified value imported via `exposing` whose bare name also names a seam top-level | **Re-qualify** so it can't silently rebind to the seam's own definition. | `asAttribute (attribute …)` where `attribute` = `Html.Attributes.attribute` → `asAttribute (Html.Attributes.attribute …)` (else it binds to `Seam.attribute`, wrong type) |

The alias/rebinding rewrites are **alias-agnostic**: the target qualifier is read
from the seam module's own import table keyed by the *resolved* module, not
hardcoded.

## Dedup and convergence

- **Dedup** is by the *normalized rewritten body*: two escapes that rewrite to
  the same body collapse into one lifted function that both call sites reuse.
- **Convergence:** an already-lifted helper is recognized because its body's head
  **resolves** (via the lookup table) to the seam module *and* is one of the
  module's exposed names — so its call sites are never re-extracted and `--fix`
  reaches a fixpoint. (Resolution, not a `Seam.` string match, is what survives
  the head being de-qualified.)

## What gets punted (surfaced as a plain error, never auto-fixed)

The rule refuses to emit a possibly-wrong fix, so it punts an escape that:

- captures a value bound by a `let` / `case` / lambda / record-update **inside**
  the escape;
- captures a value defined at the **top level of the violating module**;
- is a **multi-line** escape that also captures free variables;
- is a **point-free** / bare `Seam.*` reference (`List.map Seam.asElement`).

These are the census entries you resolve by hand (see the three triage paths in
the main skill).

## Reproducing / verifying a lift

Wire `ExtractToSeam` into the target project's review config with
`allowedModules` pointing at the seam module, run
`elm-review --rules ExtractToSeam --fix-all-without-prompt`, then **compile the
result**. A clean compile (0 errors) — not a green `Review.Test` run — is what
proves a lift is correct. Re-running `--fix` a second time must be a no-op
(convergence).
