# Contributing to m3e-docs

Thanks for helping out. This repo generates a verified Claude Code **skill** for the
`@m3e/web` component library — the value is that every API claim is checked against the
library's Custom Elements Manifest (CEM), so contributions must keep that guarantee
intact. This doc should let you make a change without reverse-engineering the build; if
it doesn't, that's a bug in this doc — please flag it.

## Prerequisites

- **Node 22** (the version CI runs on). The core pipeline, guards, and tests are
  dependency-free — they run on Node alone.
- `npm install` only if you want to run the optional render-verification step (it
  needs `jsdom`).

## Local checks (run before every PR — CI runs the same set)

```sh
npm test               # test:lib — unit tests for the CEM validator (node --test)
npm run gen:examples   # re-validate compositions against the CEM (writes data/examples.json)
npm run gen:skill      # regenerate skills/m3e/ from data/*.json
npm run check:skill    # guard: every html block in the skill is valid vs the CEM
node scripts/audit-guidance.mjs   # provenance/citation report (non-gating)
```

Or run the whole thing at once: `npm run gate` (`run-s check test` — every
`check:*` except `check:staleness`, plus every `test:*`). `check:staleness` is
excluded from `gate` on purpose: it reports upstream drift, not a problem with
your change — see the README's [Scripts](README.md#scripts) section.

If you changed anything the skill is built from (`data/*.json`, the authored concept
pages, or a `scripts/build-*.mjs`), you **must** rebuild and commit the regenerated
`skills/` and `data/examples.json`. CI fails if the committed artifacts are stale.

> If any command above isn't the real one for this repo, fix this file. Contributors
> should never have to reverse-engineer the check commands from the CI YAML.

## Where content actually lives (don't hand-edit build outputs)

`skills/m3e/**` is **generated**. Edit the source, then rebuild:

- **Component API** comes from the pinned upstream CEM — it is not hand-authored. To
  change it, bump the SHA in `data/sources.json` and regenerate (see the README's
  [Regenerate](README.md#regenerate) section).
- **Scraped concept pages** (color, density, motion, typography, getting-started,
  installation, frameworks-\*) are converted from `matraic/m3e`'s HTML docs by
  `scripts/guidance.mjs`. To correct their prose, add an auditable find/replace to
  `data/concept-patches.json` (never edit `skills/` directly), then re-run the pipeline.
- **Authored concept pages** live in `data/authored-concepts/*.md`.
- **Example markup** is validated from `data/examples_raw.json` (mined) and
  `data/authored_candidates.json` (authored). Invalid markup is rejected by the build —
  that's working as intended.

## Provenance rules (please read before adding prose)

This project cites, and does not redistribute, Google's m3.material.io guidance prose.
When you author or edit a concept page:

- Restate **facts** (token names, measurements, component anatomies, enum values) in
  **original words** and **cite** the canonical m3.material.io URL.
- Never paste sentences verbatim from m3.material.io. Verbatim is only acceptable for
  code / API surfaces or from `matraic/m3e` (MIT), and must stay attributed.
- Tag any claim that is library-specific (not stated by the cited spec) with
  `(m3e behavior)`.

See [`data/provenance-audit.md`](data/provenance-audit.md) and the README's
[Content licensing](README.md#content-licensing) section.

## Making a change

1. Open (or comment on) an issue first for anything non-trivial.
2. Branch from `main`: `git switch -c <type>/<short-desc>`.
3. Make the change at its **source** (not the generated `skills/`), then rebuild and
   run the local checks above.
4. Keep commits focused; write a clear PR description of the *why*.

## Reporting bugs / requesting features

Use the issue templates. For a "the skill made an agent hallucinate a wrong
tag/attribute" bug, include the exact markup and which component card it came from.
