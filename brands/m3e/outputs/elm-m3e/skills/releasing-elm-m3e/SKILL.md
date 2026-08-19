---
name: releasing-elm-m3e
description: >-
  Releases the elm-m3e package to the Elm registry and deploys the docs site — the
  owner-only, irreversible release runbook. Use when maintaining elm-m3e and preparing a
  release, tagging a version, running elm publish, bumping the version with elm bump,
  cutting a changelog entry, or deploying the docs site. Covers RELEASE-CHECKLIST.md
  (structure/license/tag/publish steps), the three CI jobs that must be green (library /
  docs / harness), the elm bump discipline for API compatibility, the `elm make --docs
  docs.json` publish gate (every exposed value must be documented), and docs-site deploy.
  Elm versions are permanent and publishing cannot be undone, so this is a deliberate
  owner-run runbook, not model-triggered automation. Cross-references the release
  playbook's checklist 03 (03-elm-release). For regenerating the package see
  regenerating-elm-m3e.
disable-model-invocation: true
---

# Releasing elm-m3e

**Publishing to the Elm registry is permanent — a version cannot be unpublished or
overwritten, and tags are immutable.** This skill operationalizes `RELEASE-CHECKLIST.md`;
the owner runs the irreversible steps by hand, in order. Do not automate them.

> The library is deliberately **prerelease** ("breaking changes are embraced"). Only tag
> `1.0.0` when you are ready to freeze the API. Everything below is the runbook for when
> that day comes.

## Preconditions — all three CI jobs green

Do not release on a red or stale CI run. The three jobs in `.github/workflows/ci.yml`:

1. **library** — `elm-format --validate` on the generated output, `elm-test` (kind/token
   unit tests, which compile `../src` against the sibling IR), and `elm-review` with the Cem
   rules + `NoProprietaryDsClasses` (which compiles `../src` through `docs/elm.json`).
2. **docs** — the reference pipeline (`build:reference`, which runs a whole-API `elm make
   --docs` — the package correctness proof — and **fails hard if any exposed value lacks a
   doc comment**) and the full elm-pages production build.
3. **harness** — the Playwright runtime contract harness (the components actually upgrade
   and render in a browser).

Each fetches the sibling public `jackhp95/elm-review-cem` at `../elm-review-cem`.

## The publish gate: `elm make --docs`

elm-m3e publishes as a **single Elm package** (`jackhp95/elm-m3e`) alongside its one runtime
dependency, the shared IR (`jackhp95/elm-html-intermediate-representation`), which is
published on its own. Before tagging, run the whole-API docs compile:

```bash
cd docs && pnpm run build:reference   # whole-API `elm make --docs`; must exit 0
```

This validates that every exposed value has a doc comment (what `elm publish` requires). A
missing doc comment on any generated exposed value fails here. If it fails, fix it upstream
in the generator/config and regenerate (see regenerating-elm-m3e), never by hand-editing
`src/`.

> **Docs-size gate is pending.** The old per-package docs-size assertion lived in the
> now-retired facet-split machinery (`packages.json` + `npm run measure-docs`, deleted with
> the split world). A single-package docs-size gate against the registry byte cap is an open
> release decision (release audit NB4) — until it lands, check the docs.json byte size by
> hand before tagging.

## `elm bump` discipline

Elm computes the version bump from the API diff — you do not choose it. Run `elm bump`
from the package root (the repo root is the package):

```bash
elm bump          # inspects the API diff vs the last published version, writes elm.json
```

- A changed/removed exposed value or type → **MAJOR**. A regen from a `@m3e/web` bump can
  produce this (a renamed phantom capability, a removed setter) — reconcile the changelog
  and let `elm bump` set the number; do not hand-set `version`.
- Added exposed values only → **MINOR**. Doc/impl-only changes → **PATCH**.
- Update `CHANGELOG.md` to match what `elm bump` reports before tagging.
- A breaking change in a shared module (e.g. a `M3e.Kind` or `M3e.Values` rename) bumps the
  whole package. Note that the IR dependency (`elm-html-intermediate-representation`) versions
  independently — an `HtmlIr.*` change bumps that package, and elm-m3e widens its dep range.

## The irreversible steps (from RELEASE-CHECKLIST.md)

elm-m3e releases as a **single Elm package** published from the repo root; its IR dependency
is a separate package with its own release. Publish the IR **first** (elm-m3e's dep range
must resolve), then elm-m3e.

> The retired facet-family split (7 mirror repos, driven by the deleted `packages.json` +
> `scripts/mirror-release.mjs`) is no longer the release path. Publish the single package
> directly.

1. **Confirm structure & license**: `cd docs && pnpm run build:reference` (whole-API compile +
   doc-comment check); hand-check docs.json byte size against the 700 KB registry cap until
   the single-package docs-size gate lands (NB4); root `LICENSE`, root `elm.json` `"license"`,
   and `package.json` all agree on **BSD-3-Clause**.
2. **Publish the IR dependency** `jackhp95/elm-html-intermediate-representation` (its own
   repo/runbook) so elm-m3e's dependency range resolves.
3. **Publish elm-m3e** from the repo root. Publishing is permanent and cannot be undone.
   ```bash
   elm publish
   ```
4. **After publishing**, point the repo homepage at the `package.elm-lang.org` page.

The repo is already public with description/topics/homepage set. Optional hardening
(secret scanning, private vuln reporting, branch protection) is in RELEASE-CHECKLIST §5;
note the `.gitleaks.toml` allowlist already suppresses the false-positive
`M3e.Values.*`/`M3e.Heading.emphasized` "generic-api-key" hits in the examples corpus.

## Docs-site deploy

The docs site is a separate elm-pages build (`docs/`), deployed via the Netlify adapter
(`docs/netlify.toml`); the **docs** CI job runs the full production build on every push.
Build locally with `cd docs && pnpm install && pnpm run build` (output in `docs/dist`).
After publishing the package, the repo homepage moves from the docs site to the
`package.elm-lang.org` page (RELEASE-CHECKLIST §6).

## Cross-reference

- **`RELEASE-CHECKLIST.md`** (repo root) — the authoritative owner-only step list this
  skill operationalizes; read it before each release.
- The release playbook's **checklist 03 (`03-elm-release`)** — the cross-repo Elm-release
  procedure this repo's checklist instantiates.
- regenerating-elm-m3e — for any pre-release regen from a `@m3e/web` bump.

---
_Validated against elm-m3e 1.0.0, 2026-07._
