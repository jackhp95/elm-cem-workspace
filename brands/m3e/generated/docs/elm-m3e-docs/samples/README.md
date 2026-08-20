# `docs/samples` — the guide's sample code, compiled

The guide pages teach with Elm held in `"""…"""` string literals. A string is not
code. Nothing compiled it and nothing linted it, and in a single day three pages
were found teaching something wrong:

- `/guide/tooling-refactors` showed an *after-autofix* result that was still an
  escape hatch — `M3e.Unsafe.Attributes.fromHtmlAttribute (class "…")` — while
  `TypedHtml.Attributes.class` existed. The page taught the exact defect the
  autofix removes.
- `/guide/motion` showed `M3e.Unsafe.customElement (Html.node "avt-snackbar")`,
  which does not typecheck: `customElement` takes a `String`.
- `/guide/seams` showed a paraphrase of a live helper that had drifted from it.

Wrong sample code is worse than wrong application code: a reader copies it on
purpose. This directory is what stops that.

## Two mechanisms

### 1. Derive, where a compiled counterpart exists

Some pages render a live value *and* show its code — `/guide/seams` renders
`modelViewer` with `Doc.showcase` and printed a hand-copied paraphrase of it
beside. Those two drifted (the live one had gained an `auto-rotate` attribute and
a `gap-4`; the printed one had not). `/guide/composition-text-field` was worse:
its helper's own doc comment said "shown live and printed below", and the printed
version had lost the `id "email-field"` that the surrounding prose says is what
wires the label to the input.

Mark the compiled declaration and the string is generated from its source text:

```elm
-- @sample-source seamsModelViewer         -- the whole declaration
-- @sample-source-body guideSavedButton    -- the body alone, dedented
```

`npm run gen:samples` writes `docs/src/Guide/Samples.elm`, which the route imports
in place of its old literal. Drift stops being something to watch for: there is
only one copy, and it is the one the compiler already checks.

**This applies to 4 pages, not all of them**, and the reason is structural: it
needs the displayed block to be *exactly* one live declaration. Most guide blocks
are not — they stack two or three fragments to contrast them (`-- GOOD` beside
`-- WRONG`, four API layers beside each other), or they show code with no live
counterpart at all (a `Main.elm`, a snackbar wired to a port). Those go through
mechanism 2.

### 2. Extract and verify the rest

Every other Elm code block is lifted into a module here, compiled against the real
`M3e.*` / `TypedHtml.*` sources, and reviewed. `manifest.json` in this directory
records what is expected of each, and why.

| bucket | expectation |
| --- | --- |
| `good/` | must compile, and must be clean under `review/` |
| `bad/` | must **fail** to compile |
| `good/` + `expect-review <Rule>` | must compile **and** be flagged by that rule, and no other |

`bad/` follows `elm-typed-html/verify/`, which solved this first: `good` must
compile, every `bad/*.elm` must not. A page that shows code and says "the compiler
rejects this" is making a claim, and skipping it would leave the claim unchecked.
`expect-review` is the same idea one layer up — `/guide/accessible-by-construction`
says `missingRequiredAttribute` refuses a nameless icon button, and the check is
what makes that true rather than promised.

## Markers

All of them grep as `@sample`. On the `String` declaration a page displays:

```elm
-- @sample expect-compile-error: <reason>
-- @sample expect-review <RuleName>: <reason>
-- @sample skip: <reason>
```

No marker means the default: it must compile and pass review. `skip` is the only
opt-out and `gen:samples` refuses one without a reason. Prefer
`expect-compile-error` over `skip` for deliberately-broken code — the honest thing
to do with a claim is to test it, not to look away from it.

## Layout

```
elm.json                 the samples application (hand-written)
support/Sample/Support.elm   stubs for the app a fragment assumes (hand-written)
review/src/ReviewConfig.elm  the samples' review config (hand-written)
review/src/CodegenReviewConfig.elm   GENERATED — byte copy of review/src/
review/elm.json          GENERATED — dependency pins from review/elm.json
good/**.elm  bad/**.elm  GENERATED — one module per displayed sample
manifest.json            GENERATED — the dispositions, with reasons
```

Nothing generated is hand-edited: `check:drift` regenerates the lot in a scratch
copy and byte-compares, including the *file set* of `good/` and `bad/`, so an
extra or missing module is drift too.

## Running it

```
npm run gen:samples     # from docs/ (or `npm run gen:samples` at the repo root)
npm run check:samples   # what judges the result; runs inside `npm run gate`
npm run test:samples-gen
```

## Known limits

- The `Sample.Support` stubs are deliberately polymorphic, which means a stub can
  never *prove* a kind is admitted — only decline to disprove it. Everything the
  sample itself writes is checked for real. Keep the stub set small; if a sample
  needs a specific type to be meaningful, write that value in the sample.
- `Cem.preferBarrel` and `Cem.preferComponentSetters` are not run here, mirroring
  the docs config's existing `app/Route/Guide/` exemption: the Guide contrasts the
  API's layers on purpose, so a form preference would fire on the pages doing
  their job. See `review/src/ReviewConfig.elm`.
- A sample that is a *syntax* error cannot be a `bad/` probe (elm-review has to be
  able to parse the project). Use `skip` with a reason for those.
