# elm-cem-workspace — Vision

> The north star for this repo. It states what we are building and why, how the pieces fit,
> and where we are on the way there. For granular, live status read `GAUNTLET-LEDGER.md`; for the
> Phase-0 design read `docs/superpowers/specs/2026-08-12-elm-cem-workspace-spine-design.md`.
>
> This supersedes the original 2026-07-10 brief (now at
> `packages/cem-figma-connect/plans/BRIEF.md`), which predates the elm-cem-centered reframe and
> the delivery of Phase 0. Where they differ, this document wins.

## What this is

**A forge that turns a component library's machine-readable manifest into everything a team needs
to build with it — and keeps all of it in sync as the library changes.**

Give it a component library's **Custom Elements Manifest** (CEM) — plus a little config, its docs,
and a Figma file — and it produces: typed **Elm** packages, **Figma Code Connect** bindings,
**Tailwind** utilities, and agent **skills**. When the library adds a component or changes an
attribute, one command regenerates all of it.

`elm-cem` is the engine. `elm-m3e` (over Google's `@m3e/web`) is the flagship brand. The workspace
is the coherent home for the whole family — but nothing here is m3e-specific by design: new brands
and new outputs plug in.

## Why it exists

Three problems, one root cause — the relationships between a design system's manifest, its Figma
representation, and its code are not written down as anything a machine can act on:

1. **Figma-generated code throws away the component relationship.** A developer copies CSS/HTML and
   hand-converts it; the result looks right but is structurally disconnected from the design system.
2. **The library keeps moving.** `@m3e/web` adds components and changes internals continually.
   Hand-maintained bindings rot the moment they're written.
3. **The tooling had drifted apart.** The family was five repos, each with its own CEM parser, its
   own version pin, and vendored copies of the others — so a single library bump was an eight-step
   manual fan-out that silently went stale.

The fix is to express those relationships **once, as data**, and generate everything else from it.
Humans answer a few high-level correspondence questions ("the Buttons page is `m3e-button`"; "Figma
calls this token X, the code calls it Y — same thing"); the pipeline does the thousands of
mechanical translations and surfaces only the genuine discrepancies.

## The mission (one sentence)

**Merge the CEM ⋈ Figma ⋈ Tailwind into one correspondence model, and auto-generate from it —
bidirectionally and sustainably — Figma Code Connect for web components, Elm, and Tailwind (plus
hybrid outputs), so design and code mesh seamlessly.**

## What "done" looks like

**The round-trip is real, both directions:**

- **Figma → code.** Select a component in Figma Dev Mode and get the exact Elm (or web-component, or
  Tailwind) to use. Hand a whole frame to an agent and get a composed Elm view back.
- **Code → Figma.** Write Elm and see it mirrored in Figma, built from the real design-system
  components — not redrawn by hand.
- **A live Compose editor** sits in the middle: a type-directed builder that parses HTML (and, in
  time, a Figma frame) into a component tree and emits Elm, showing a live preview and the generated
  code side by side.

**And it stays true over time:**

- A library version bump is **one gated command**. Nothing is hardcoded; nothing drifts.
- A consuming project (e.g. `avetta/ui`) wires it up once — install the packages and the Figma
  library, run one `figma connect publish` — and the round-trip works from then on.

## How it works

```
                     @m3e/web  (upstream library + its CEM)          one version pin
                              │
                        ┌─────▼─────┐
                        │  elm-cem   │   the single producer: reads CEM + .d.ts + config
                        └─────┬─────┘
        emits ┌───────────────┼───────────────────────────────┐
        Elm source     cem-facts.json                 elm-api-facts.json
        (M3e.*)        (tags/attrs/enums/slots)        (module/setter/token surface)
              │               │                                 │
              ▼               ▼                                 ▼
          elm-m3e        m3e-okf · tailwind-m3e-web · cem-figma-connect (matcher + Elm emitter)
        (brand pkgs)     (skill/OKF · utilities · Figma Code Connect + token bridge + visual gate)
                                          │
                                   elm-cem-compose  (the interactive html↔elm editor)
```

- **One producer, one source of truth.** `elm-cem` reads the CEM once and emits a canonical **facts
  bundle**. Every downstream consumer reads the bundle; none re-parses the CEM.
- **The monorepo is the management layer.** It co-locates the family so workspace dependencies
  replace vendored copies, and a **bump orchestrator** drives regeneration and every gate across
  both ecosystems — the JS (pnpm) graph and the Elm (`elm.json`) registry graph — in dependency
  order.
- **cem-figma-connect** joins the CEM with a Figma export into a **correspondence model**, then emits
  **Code Connect** bindings (web-component and Elm labels; Tailwind planned), a **token/codeSyntax
  bridge** that makes Figma's own output speak the design system's token names, and a **visual-diff
  gate** so a binding ships only when its render matches Figma.
- **Everything is data-driven from the CEM.** The library adds a component and the pipeline picks it
  up; the correspondence model records only the human judgments.

## The family

| Package / repo | Role |
|---|---|
| **`elm-cem`** | The engine. CEM → Elm codegen + the facts bundle. Library-agnostic; all opinion lives in per-brand config. |
| **`elm-m3e`** | The flagship brand: the typed `M3e.*` Elm API over `@m3e/web`, published as a concern-separated package set. |
| **`elm-cem-compose`** | The type-directed Compose editor and its HTML→tree parser. |
| **`cem-figma-connect`** | The general CEM ⋈ Figma → Code Connect engine (+ token bridge + visual gate). m3e is its first profile; it works for any CEM+Figma project. |
| **`m3e-okf`** | CEM → a verified agent skill + Open Knowledge Format bundle. |
| **`tailwind-m3e-web`** | CEM → the `--md-*` Tailwind utility surface + density utilities. |
| **`elm-cem-facts` · `elm-typed-html` / IR · `elm-review-cem`** | Shared substrate: fact types, the HTML intermediate representation, and the facts-driven lint rules. |
| **`matraic/m3e`** (upstream, not ours) | Source of `@m3e/web`. Intended eventual home for the CEM ⋈ Figma Code Connect work (Phase 5). |

## Principles

- **Nothing hardcoded.** Every module, setter, token, and binding is measured or generated from the
  CEM. A name that can't be verified is surfaced as a concern, never guessed.
- **Generated code is the specification.** Never hand-edit an emitted or golden file to make a gate
  pass — change the config or the emitter and regenerate. Prove a generator change is a no-op by A/B
  generation, not by regenerate-and-diff.
- **Single source of truth.** One CEM parse, one facts bundle, one version pin — consumed by all.
- **Deep seams only.** In Elm every published package pays a permanent version-cascade tax; split a
  package only where independent evolution or optional bulk earns it, never to paper over a
  dependency-graph artifact.
- **Sustainable by construction.** A library bump is one gated command; drift is detected by CI, not
  accumulated by hand.
- **Brand- and output-pluggable.** New brands (e.g. `gren-m3e`) and new output modalities drop into a
  structure organized around the general pipeline, not around any one brand.

## Roadmap & status

The vision is sequenced foundation-first. Status is high-level here; the ledger has the detail.

| Phase | What | Status |
|---|---|---|
| **0** | **Sustainability spine** — one producer, one facts bundle, the monorepo, one gated `bump` + drift gate | ✅ **Done** (gate-all green; all packages consolidated) |
| **1** | One canonical html↔elm engine | ◐ Largely realized via the Compose HTML→tree path; original de-duplication to confirm |
| **2** | Tailwind Code Connect label + hybrid (Elm+Tailwind) outputs | ☐ Not started |
| **3** | Figma → Elm reverse direction (whole frame → composed Elm) | ◐ Editor + HTML parsing built; the `get_design_context` → Compose link remains |
| **4** | Token model hardening (ref/system/component tiers, density, "required code change" surfacing) | ☐ Not started |
| **5** | Publish + upstream to `matraic/m3e` | ◐ Packages at the pre-publish boundary (concern-separated split); nothing published yet |
| **+** | **Compose editor** — the interactive front end for the html↔elm direction | ◐ Functional; an IA/UX rework and a state-feedback correctness check remain (see the 2026-08-15 IA spike) |

## The two end-user experiences

- **The consuming developer** answers only high-level correspondence questions, then gets the
  round-trip: Figma component → exact Elm; a Figma frame → a composed Elm view; Elm → mirrored in
  Figma; or builds directly in the Compose editor. They never hand-author a binding.
- **The maintainer** runs one gated `bump` when `@m3e/web` releases: re-pin once, regenerate the
  bundle, fan out to every consumer, run the union of gates (including the visual-diff gate), and get
  a report of what changed and what needs a human — instead of eight manual, drift-prone steps.
