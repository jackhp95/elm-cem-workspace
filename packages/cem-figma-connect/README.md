# cem-figma-connect

**Private until release-ready.**

A general-purpose tool that merges a **Custom Elements Manifest** (CEM + sibling `.d.ts`
files) with a **Figma component library export** into one correspondence model, and from it
generates **Figma Code Connect** bindings (web-component + framework labels), a
**token/codeSyntax bridge**, and a **visual verification gate** — for any project that has a
CEM and a Figma library. Optionally integrates a Tailwind token surface.

First consumer: `@m3e/web` ⋈ Material 3 Design Kit (Community) ⋈ `jackhp95/elm-m3e` ⋈
`jackhp95/tailwind-m3e-web`. Second consumer: Avetta (ADS + `avetta/ui`).

## Status

**Working tool.** The engine is built and running: a CLI (`src/cli.mjs`) with the
subcommands `match / review / confirm / gap / extract / emit / publish / unpublish /
check / capture`, and ~205 generated Code Connect bindings **per label** committed under
[`generated/m3-kit/`](generated/m3-kit/) (`web-components/` and `elm/`). The first consumer
profile ([`profiles/m3-kit/`](profiles/m3-kit/)) is wired end-to-end.

- **New here? Set up and run:** the [Prerequisites](#prerequisites), [Install](#install),
  and [Quickstart](#quickstart) below, then the full pipeline walkthrough in
  [`docs/USAGE.md`](docs/USAGE.md).
- **Current status / where the work is:** [`STATUS.md`](STATUS.md). The dated `HANDOFF-*`
  files are **historical snapshots** — read `STATUS.md` first.
- **Design & rationale:** [`plans/plan/README.md`](plans/plan/README.md) (execution index),
  [`plans/00-mission-and-decisions.md`](plans/00-mission-and-decisions.md), and
  [`plans/01-architecture.md`](plans/01-architecture.md). Every load-bearing claim was
  **verified empirically on 2026-07-10** — see
  [`research/evidence/2026-07-10-verification-ledger.md`](research/evidence/2026-07-10-verification-ledger.md).

> ⚠️ **Unresolved: which Figma file is the canonical publish target.** The plans
> (`plans/plan/README.md`, `plans/00-mission-and-decisions.md` decision D2) name
> `KujuFlfJSwHI6ua1b7RZvL`, but `profiles/m3-kit/profile.json` (and the 2026-07-14 handoff)
> use `UtwpUdPiOZEuxp8Nq1d5yQ`. These disagree and **need an owner decision** — do not
> assume either is authoritative. `publish` takes `--file-key` explicitly, so nothing here
> silently picks one. See [`docs/USAGE.md`](docs/USAGE.md).

## Prerequisites

- **Node `>=22`** (see `engines` in `package.json`) and **pnpm**.

For the **full pipeline** (extraction → visual gate → publish) you also need:

- **[bun](https://bun.sh)** — the extraction WS relay (`extract/relay/socket.ts`) uses
  `Bun.serve`; Node cannot run it. See [`extract/README.md`](extract/README.md).
- **Playwright Chromium** — the visual gate renders headless: `pnpm exec playwright install chromium`.
- **Figma desktop** + the **self-hosted extraction plugin** under `extract/` (imported by
  manifest, in Design mode). See [`extract/README.md`](extract/README.md).
- **For `publish` only:** a **Figma Personal Access Token** with scopes
  **Code Connect: Write** and **File content: Read**, on an **Organization or Enterprise**
  plan (Code Connect publishing is org/enterprise-gated). Provide it via the
  **`FIGMA_ACCESS_TOKEN` environment variable** — the publish runner reads it from the
  environment **only** and refuses to read a token from any file (`requireToken` in
  [`src/publish/runner.mjs`](src/publish/runner.mjs)).

## Install

```bash
pnpm install
```

## Quickstart

The shortest real path to output, no Figma access or token required (it runs against the
checked-in Figma dump in `research/figma-dumps/`):

```bash
pnpm check                              # CI gate: generated/** matches correspondence.json (0 drift, 0 orphan)
node src/cli.mjs emit --profile m3-kit  # regenerate the Code Connect bindings (same as `pnpm emit`)
```

Then inspect the generated bindings:

```bash
ls generated/m3-kit/web-components/     # 205 *.figma.ts + MANIFEST.json (label "Web Components")
ls generated/m3-kit/elm/                # 205 *.figma.ts + MANIFEST.json (label "Elm")
```

`emit` is deterministic (byte-stable): re-running it against the committed dump leaves
`generated/**` unchanged, which is exactly what `pnpm check` enforces. For the complete
extraction → match → review → gap → emit → visual-gate → publish flow, see
[`docs/USAGE.md`](docs/USAGE.md).

## Layout

- `src/` — the CLI (`src/cli.mjs`) and engine (ingest, matcher, emitters, publish, visual gate).
- `extract/` — the generalized Figma extraction path (self-hosted plugin + bun WS relay + `export.mjs`).
- `profiles/m3-kit/` — the first consumer profile (config, correspondence, gap report, generated-output pins).
- `generated/m3-kit/` — the committed Code Connect bindings (`web-components/` + `elm/`).
- `docs/` — usage walkthrough and density/spacing notes.
- `plans/` — mission, architecture, and the executable plan suite (`plans/plan/`).
- `research/evidence/` — verification reports the plans cite.
- `research/figma-dumps/` — checked-in Figma exports (M3 kit components, variables, styles)
  used as deterministic inputs.
