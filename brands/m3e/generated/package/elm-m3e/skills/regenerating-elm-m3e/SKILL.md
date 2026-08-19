---
name: regenerating-elm-m3e
description: >-
  Regenerates the generated src/ of elm-m3e from the @m3e/web Custom Elements Manifest
  plus config/, and reviews the resulting diff — the maintainer regen contract. Use when
  maintaining elm-m3e and a @m3e/web version bump changed the manifest, a config key
  (config/slots.json, native-mdn.json, examples.*) was edited, someone hand-edited a file
  under src/M3e/ (which must be reverted and regenerated), a regen diff needs reviewing
  (expected vs suspicious), or zero-diff needs verifying after a toolchain/generator
  change. Covers the never-hand-edit rule, the exact elm-cem command, the config/slots.json
  schema and how edits flow through the generator, the regen-on-bump.yml automation, and
  reading a regen diff. This is a maintainer-run workflow, not something to trigger from a
  consumer's feature request. For releasing see releasing-elm-m3e.
disable-model-invocation: true
---

# Regenerating elm-m3e

**Everything under `src/M3e/` is a generated artifact.** The hand-craft lives in the
generator (`elm-cem`), the config (`config/`), and the userland seam (`docs/kit/`) — never
in the per-component modules. The regen contract: **CEM + config in, the layered
`M3e.*` binding out** (`docs/DESIGN.md` §6).

## The one rule: never hand-edit generated files

If you find a bug in a generated module, the fix is upstream — in the config or the
generator — never in `src/M3e/`. A hand-edit is silently overwritten on the next regen and
diverges the library from `@m3e/web`. If someone *has* hand-edited a generated file:

1. Revert the file (`git checkout -- src/M3e/<File>.elm`).
2. Make the real fix in `config/slots.json` (or upstream in `elm-cem`).
3. Regenerate and confirm the intended change appears in the diff.

(The hand-written IR *core* — `HtmlIr.Element`, `HtmlIr.Node`, `HtmlIr.Attribute`,
`HtmlIr.Value`, `HtmlIr.Kind`, and `HtmlIr.Internal` — lives in the published-shape
`elm-html-intermediate-representation` package, not in `src/M3e/`. elm-m3e **imports**
these modules as a dependency; the phantom pipeline (`"_phantom": true` in
`config/slots.json`) makes the generator emit `import HtmlIr.*` rather than injecting or
emitting runtime copies. Per-component modules under `src/M3e/` are deliberately excluded
from `elm-format --validate` because they are generated.)

## The regen command

Run from the repo root (mirrors `regen-on-bump.yml`). The `elm-cem` generator is the
sibling checkout `../elm-cem` — the exact path `package.json`'s
`split` script already uses. Install its deps first (`cd ../elm-cem
&& npm ci`). It needs an `elm` 0.19.1 (this repo's `node_modules/.bin/elm` works).

> **Use the sibling checkout — the in-repo clone is deleted.** An earlier workflow kept a
> gitignored `elm-cem/` clone inside this repo; it was stuck on a pre-phantom commit and
> emitted the retired `M3e/Build/`, `M3e/Aria.elm` etc., producing a large spurious diff.
> That clone has been removed (pass 2, 2026-07-21). The sibling checkout
> `../elm-cem` is the only local regen path — a regen with it is
> byte-for-byte zero-diff against committed `src/` (verified 2026-07-21: 132 files,
> `diff -rq $TMP src` empty).

```bash
# PATH prepend is REQUIRED: the generator shells out to `elm`, which lives in THIS
# repo's node_modules/.bin (not elm-cem's). Without it the regen fails SILENTLY —
# exit 0, zero files, a bare "Compilation failed." line.
PATH="$PWD/node_modules/.bin:$PATH" \
node ${ELM_CEM_BIN:-../elm-cem/bin/elm-cem.js} \
  --flags-from=docs/node_modules/@m3e/web/dist/custom-elements.json \
  --config-from=config/slots.json \
  --config-from=config/native-mdn.json \
  --config-from=config/examples.generated.json \
  --output=src
```

There is no separate `config/runtime.json` (it does not exist). The phantom pipeline is
switched on by **`"_phantom": true` at the top of `config/slots.json`** — that is what
tells the generator to emit brands that **import** the IR core from the shared
`elm-html-intermediate-representation` package (`HtmlIr.Element/Node/Attribute/Value/Kind`,
`HtmlIr.Internal`) rather than emitting or injecting runtime copies. `injectRuntime` is
retired: the IR is imported, never injected.

The CLI flags the generator actually accepts (see `elm-cem --help`): `--flags-from=<CEM>`
(required), `--output=<dir>` (required), and repeatable `--config-from=<json>` (deep-merged
in order). The `--dep-src=<pkg>=<src>` flag is **not** a generator flag — it belongs to this
repo's own gate scripts (`scripts/measure-docs.mjs`, `scripts/isolation-probe.mjs`), where it
maps the unpublished IR package to its local source tree (see the verification section below).

Then **format** (the raw output is not elm-formatted — committing it raw floods the diff
with line-wrap churn that swamps the real API change):

```bash
../elm-cem/node_modules/.bin/elm-format src --yes
```

Then **verify it compiles**. Committed `src/` imports `HtmlIr.*` from the unpublished
`elm-html-intermediate-representation` package, which is **not** in this repo's `elm.json`,
so a bare `elm make src/M3e.elm` fails with `MODULE NOT FOUND: HtmlIr.Attribute`. Compile it
against the IR source tree on the path — either the whole-API docs pipeline, or a one-off
ad-hoc application `elm.json` whose `source-directories` list both `src/` and the sibling IR
`src/`:

```bash
# Whole-API compile + doc-comment proof — from the repo root:
cd docs && pnpm run build:reference   # elm make --docs over the full M3e.* surface
```

## `config/slots.json` — the schema, and how edits flow

Keyed by **PascalCase component name**, plus `_`-prefixed meta-keys (`_exclude`,
`_native`, `_seams`). Full schema: `docs/CONFIG_SCHEMA.md`. What each key changes in the
output:

| Config key | Flows to the generated output as |
|------------|----------------------------------|
| `slots.<name>.kinds` | the slot's phantom kind row (closed set via `"shared:<atom>"` or private `"<kind>"`, `"arbitrary"` open row, or build error if empty) |
| `slots.<name>.multi` | cardinality (advisory `SingularSlot`/multi accumulation) |
| `slots.<name>.required` | required-slot record field on the per-component `requires`/`build` shape / `RequireSlot` fact |
| `required` (action facet) | a required-record field on the per-component `M3e.<Component>` strict shape |
| `requiredAttrs` | required record fields (e.g. `aria-label` → a11y-required) |
| `staticAttrs` | always-on attrs, never surfaced as setters |
| `actionMap` / `events` | Action facets / custom-event decoders |
| `idWiring` | structural `for`/`id` label↔control association |
| `group` | variant-split members folded into one module |
| `attrTypes` | typed-arg overrides (force an attr's Elm type) |
| `_actions` | the `M3e.Action` roster (capability-typed behavioural values) |
| `_native` | native-HTML brand facts (the native brand ships separately as `TypedHtml.*` / `elm-typed-html`; no `M3e.Native` module is emitted here) |
| `_seams` | seam contract types + stampers consumed by the userland `docs/kit/Seam.elm` (Seam is a copyable kit module, **not** a published `M3e.Seam`) |
| `_phantom` | `true` → the phantom pipeline: generated code imports `HtmlIr.*` (this repo's `config/slots.json` has it set) |

**Vocabulary that bites:** the unnamed slot is keyed `"unnamed"` (not `"default"`); the
accepts-anything sugar is the bare string `"arbitrary"` (not `"any"`); `[]` means *no
typed children* and is rare — an unrestricted slot is `"arbitrary"`, never `[]`. A
component **absent from config gets safe permissive defaults** (free child row, no
required, no groups) — so config is grown by evidence, not up front. See CONFIG_SCHEMA.

Editing config → rerun the regen command → the change shows in the `src` diff.

## Verification gates

elm-m3e is a **single Elm package** (repo root), so the whole `M3e.*` surface is
verified by compiling it against the sibling IR checkout and running the review +
docs pipelines. From `package.json`:

- `npm test` — the self-contained `tests/` project (`DomOutputTest`: the DOM-output
  shape pins for the public `M3e.*` contract — tags, slot stamping, child order). Its
  `elm.json` source-directories include `../src` and the `elm-html-intermediate-representation`
  / `elm-typed-html` siblings, so it compiles the library against the real IR.
- `elm-review --config review` (run from `docs/`) — compiles `../src` through
  `docs/elm.json` and applies the codegen-aware `elm-review-cem` rules.
- The docs job's `build:reference` (`cd docs && pnpm run build:reference`) runs a
  whole-API `elm make --docs`, which fails hard if any exposed value lacks a doc
  comment (the `elm publish` requirement).

> **Retired:** the old facet-split gate (`npm run split`/`measure-docs`/`isolation-probe`/`gate`
> over a multi-package `packages.json` family, plus `scripts/mirror-release.mjs`) was
> removed with the split world — the merged architecture ships as the single
> `jackhp95/elm-m3e` package. A single-package docs-size gate (the registry byte cap)
> is a pending release decision (see the release audit's NB4).

## The `regen-on-bump.yml` automation

A `@m3e/web` bump in `docs/package.json`/`docs/pnpm-lock.yaml` triggers `regen-on-bump.yml`:
it detects whether `@m3e/web` actually changed, installs to materialize the new CEM, clones
`elm-cem` from GitHub, runs the regen command, elm-formats, and **commits the regen diff back
onto the PR branch**. CI then re-runs and proves the regenerated output still compiles. The
regen is **deterministic** — a no-op bump produces no commit (the workflow's `git diff
--quiet -- src` guard). You review the auto-committed diff like any code change.

> **Caveat (GitHub lag):** the workflow clones `elm-cem` from GitHub `main`. The local
> sibling checkout `../elm-cem` is already on the phantom pipeline
> (local `main`, commit `7cebfde`), but GitHub `origin/main` of `elm-cem` still lags that
> local commit — the push is human-gated (Stage F). Until Jack pushes, a CI-driven regen
> clones the older GitHub `main` and may not match the committed `src/`. For a trustworthy
> local regen, always use the sibling checkout as shown above.

## Reading a regen diff — expected vs suspicious

**Expected** (accept): new component modules, new attribute setters, new enum tokens in a
`Value` row, doc-comment text changes (from `native-mdn.json` refresh), example-corpus
churn — all tracking real `@m3e/web` changes.

**Suspicious** (investigate before merging):

- A **slot row narrowing from `"arbitrary"` to a closed set, or the reverse**, that you
  did not intend — a manifest change altered inferred kinds; confirm it matches upstream.
- A **required field appearing/disappearing** unexpectedly — check the manifest and config.
- A phantom capability **renamed** (breaks consumer type annotations) — a real breaking
  change; note it for the changelog/`elm bump`.
- **Massive whitespace-only churn** — you forgot the `elm-format` step; re-run it.
- Any change under `src/M3e/` to modules that shouldn't be generated — the IR core
  (`HtmlIr.*`) lives in `elm-html-intermediate-representation`, not in `src/M3e/`; the generator should never
  produce files named `Node.elm`, `Element.elm`, `Html/Attr.elm` etc. under `src/M3e/`.

## Zero-diff verification after a toolchain change

After bumping `elm-cem` or changing the generator with **no** intended output change, prove
it: regenerate (with the sibling `../elm-cem`) + format, then
`git diff --stat src` should be **empty**. A non-empty diff means the toolchain change was
not behavior-preserving — inspect it. This is the same determinism the golden suite in
`elm-cem` gates. (Verified 2026-07-21: a full regen with the sibling checkout is byte-for-byte
identical to committed `src/` — 132 files, empty `diff -rq`.)

## Reference

- `docs/DESIGN.md` §6 (Regeneration) and §1–§4 (what the layers/seams the generator emits).
- `docs/CONFIG_SCHEMA.md` — the authoritative `config/slots.json` schema and vocabulary.
- `.github/workflows/regen-on-bump.yml` — the automation this skill operationalizes.

---
_Validated against elm-m3e 1.0.0, 2026-07._
