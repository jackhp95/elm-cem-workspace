# Stream 2 / Phase 3 — Figma → Elm reverse: the `get_design_context` → Compose link

> Prep doc (MCP not yet live). Scopes the ONE missing piece and proves what is
> testable without a bridge. Figma-DEPENDENT parts are marked ⚑ MCP.

## What already exists (verified)

The reverse pipeline downstream of Figma is **built and self-consistent**:

- `packages/elm-cem-compose/src/Cem/Compose.elm` — the opaque tree engine
  (`Node`, path-addressed edits via `Msg`; slot-cardinality invariant enforced
  in `update`).
- `packages/elm-m3e/docs/app/Compose/FromHtml.elm` — `parse : String -> …` turns
  an HTML string into the `Cem.Compose.Msg` sequence that builds the same tree.
  Brand-agnostic (takes `facts`/`attrKinds`); `componentFromTag` is the inverse
  of `Compose.Render.tagFor` (`"m3e-app-bar"` → `"appBar"`). Unrecognized input
  is dropped, not errored (a demo prefill may be lossy).
- `packages/elm-m3e/docs/app/Compose/Codegen.elm` — `codeFor : Node -> String`
  folds the tree to Elm source. **Verified output vocabulary:** it emits the
  `M3e.Html.<component>` double-list surface + `M3e.Attributes.slot` + `M3e.text`
  + `M3e.Html.icon` (Codegen.elm:43/93/119/133). All of these are REAL, exposed
  modules (`M3e.Html` ships in `elm-m3e-html`; `M3e` barrel `text` in
  `elm-m3e-components`), so Codegen's output already compiles.
- `packages/elm-m3e/docs/app/Route/Components/Compose.elm` — the editor route;
  erases the phantom rows once via `M3e.Unsafe.fromHtml` for the live preview.

So a **tree → Elm** and **HTML → tree** both work today. The editor's HTML→tree
path is live (the route ships a prefill).

## The one missing piece (⚑ MCP)

`get_design_context(nodeId)` (Figma MCP, `plugin:figma:figma`) → an m3e-* HTML
string that `Compose.FromHtml.parse` can consume. That adapter is the whole of
Phase 3's new code. Two complementary sources feed it:

1. **Code Connect snippets are the per-component Figma→Elm map (already built,
   now correct).** When a frame node is an instance of a mapped component,
   `get_design_context` surfaces its `CodeConnectSnippet` — the exact Elm this
   repo emits under `generated/m3-kit/elm/*.figma.ts`. Stream 2's naming fix
   (see `2026-08-17-stream2-cc-elm-naming-reconciliation.md`) is what makes those
   snippets COMPILE (`M3e.Component.<Name>.component`, `M3e.text`), so Phase 3
   inherits correct per-instance Elm for free. **Stream 2 directly unblocks
   Phase 3.**
2. **`correspondence.json` is bidirectional.** The same variant-axis → attribute
   and value → token maps the forward emitter uses (Figma variant `Size=Medium`
   → `size M3e.Values.medium`) invert to drive a Figma node → m3e-* tag+attrs.

### Adapter design (`Figma frame → m3e-* HTML`)

```
get_design_context(frameNodeId)              -- ⚑ MCP: frame subtree + per-instance CC
   │
   ▼  walk the frame's node tree
for each node:
   ├─ instance of a mapped component?  ──► emit `<m3e-<tag> attr..>` from its
   │                                        componentProperties + variant axes
   │                                        (invert correspondence.json), OR reuse
   │                                        its CodeConnectSnippet directly.
   └─ layout frame / text / vector?    ──► TypedHtml scaffolding (`<div>`, text)
   │
   ▼  assemble one m3e-* HTML string (the shape FromHtml.parse expects)
Compose.FromHtml.parse html facts attrKinds  -- existing
   │
   ▼
Cem.Compose tree
   │
   ├─ Compose.Codegen.codeFor  ──► Elm (M3e.Html.* surface)   -- existing, compiles
   └─ (alt) elm-shape.mjs      ──► Elm (M3e.Component.* surface, batch/CLI)
```

**Routing note (VISION: "Figma→Elm should route through elm-shape.mjs").** Two
valid targets share the canonical grammar:
- The **interactive editor** path uses `Compose.Codegen` (Elm, in-browser) →
  `M3e.Html.*` surface. Correct for the live Compose editor.
- A **batch/CLI** Figma→Elm path should route through `packages/elm-cem/src/
  elm-shape.mjs` (the Phase-1 canonical JS engine) → `M3e.Component.*` surface,
  matching the Code Connect emitter. `elm-shape.mjs`'s Layer-1 resolvers already
  consume the same Face C facts, so the two never drift.
Decision for Jack when wiring: does Phase 3 land as an editor feature (Codegen)
or a CLI (elm-shape)? The adapter is identical up to the final fold; recommend
the **editor** path first (the Compose route already renders + previews) with the
CLI as a follow-up.

## Testable NOW (no MCP) — the downstream proof

The Figma-independent half is provable today by feeding a representative m3e-*
HTML string (Figma only supplies the string) through the existing pipeline:

```
examples.json html  ──►  Compose.FromHtml.parse  ──►  Compose.Codegen.codeFor  ──►  Elm
```

⚑ Build note: `Compose.*` lives in the elm-pages docs app
(`packages/elm-m3e/docs`), which is not build-ready in a fresh checkout
(`.elm-pages` not codegen'd, no `elm-stuff`). A focused downstream proof should
compile just the `Compose.*` modules against a scratch elm.json whose
source-directories reach `../src`, `../../elm-cem-compose/src`,
`../../elm-cem/facts/src`, and `vendor/elm-foundation` (the docs app's own set)
— OR run inside a built docs app. Deferred to the wiring session; noted so it is
not mistaken for done.

## Acceptance mapping (from the task)

- [ ] ⚑ MCP: a real Figma frame → `get_design_context` → adapter → composed Elm
      view, captured end-to-end. Blocked on the live MCP (verify auth first).
- [x] The M3e.<Name> naming bug addressed at the producer + a compile-check gate
      over emitted Elm — DONE in the sibling reconciliation plan (the CC snippets
      Phase 3 reuses now compile).
- [ ] The downstream HTML→tree→Elm proof (testable now) — scoped above; execute
      in the wiring session (needs the docs-app/scratch Elm build).

## Immediate next steps once MCP is confirmed live

1. Verify auth with a trivial read (`get_design_context` on a known node, or a
   metadata call); do NOT assume it works until a call returns.
2. Build the adapter (frame-walk + correspondence inversion) as a small module;
   unit-test the inversion against `correspondence.json` fixtures (no bridge).
3. Capture one real frame end-to-end; commit the captured example as evidence.
