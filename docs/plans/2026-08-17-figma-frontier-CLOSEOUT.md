# Figma-frontier — session closeout + bridge-session runbook

> Single handoff for the next session. What LANDED this session, what is PREPPED,
> and what remains BRIDGE- / HUMAN-gated. Supersedes the two cancelled prep-agent
> drafts (Jack stopped them mid-run; their scope is folded in here).

## Landed this session (merged to main)

- **Stream 2 — CC→Elm naming reconciliation + compile gate. DONE, gate-all GREEN
  (exit 0, 0 failed).** Commits `b43b38d` (gate v1 + plan) + `6c80a03` (the fix).
  - Producer (elm-cem `Emit.elm`): per-surface module infix
    (`M3e.Component.<N>` / `M3e.Build.<N>`) in `surfacesOf` + the top-level
    `module` field in `encodeComponent`.
  - Seams (m3-kit profile): `textSeam Kit→M3e`, `attrSeam Native→
    TypedHtml.Unsafe.Attributes` + `attrSeamFn customAttribute`; the emitter now
    threads `htmlSeam/attrSeam/attrSeamFn` (were silently dropped).
  - Icon path: ctor/Name from `M3e.Icon`, setters from `M3e.Component.Icon`
    (also fixed a pre-existing `M3e.Icon.filled` phantom).
  - Engine A (`to-elm.mjs`): removed the now-redundant `M3e.→M3e.Component.`
    rewrite (was double-infixing).
  - New gate `tools/check-cc-elm-refs.mjs` (`--strict`, wired blocking into
    `gate-all`): 0/224 snippets reference a non-existent module.
  - **Known gate limitation** (friction logged): it checks MODULE existence, not
    FUNCTION existence — it missed the icon-fn bug (caught by diff review). **v2 =
    a real `elm make` over substituted snippet bodies.** See
    `2026-08-17-stream2-cc-elm-naming-reconciliation.md` F4.
- **Phase 3 design** — `2026-08-17-stream2-phase3-figma-to-elm-link.md`. The
  downstream (HTML→tree→Elm via `Compose.FromHtml`→`Compose.Codegen`) already
  exists and compiles (`M3e.Html.*` surface). Only the `get_design_context`→m3e-*
  HTML adapter is missing. Stream 2 unblocks it (the CC snippets it reuses now
  compile).

## Bridge state (verify-before-use)

- **WS relay** `bun extract/relay/socket.ts` on `:3055` — Design-mode reads work:
  `get_document_info / get_local_components / get_component_properties /
  get_styles / get_variables / export_node_as_image / capture_set`.
- **Verify live before ANY capture** (the relay logged the plugin flapping —
  connect/`Bridge left`). Health: `node -e` on
  `extract/lib/bridge-health.mjs::checkBridge({})` → needs `reachable:true` +
  `editorType:"figma"`, then a real `wsQuery("get_document_info", {}, {channel})`.
  **Keep the plugin's "Start WS Bridge" panel OPEN + foregrounded** — closing/
  backgrounding it drops the socket.
- **Dev Mode NOT required** (Jack's personal account can't enter it). Route
  Phase-3 reads through this Design-mode WS bridge, not the Dev-mode
  `get_design_context` MCP.
- **Figma MCP** (`plugin:figma:figma`) — configured, needs Jack's `/mcp` auth AND
  Dev Mode; superseded by the WS bridge for our reads.

## Stream 1 — visual-gate residuals (BRIDGE-gated). Runbook.

Canonical gate = `packages/cem-figma-connect/src/visual/*` (Plan C:
`plans/plan/C-visual-gate.md`), NOT the ephemeral `plans/gate-tooling/` from the
old handoff (that dir does not exist in this tree — it was an old-machine path).
Pipeline: harness (`src/visual/harness/`) → driver (`drive.mjs`) → figma export
(`figma-export.mjs`, WS bridge) → diff (`diff.mjs`, pixelmatch) → review webapp
(`src/visual/review/server.mjs`) → status (`status.mjs`).

Per-session (bridge live): start relay → connect plugin (Design mode, kit open) →
per residual: figma-export → diff → view result → human-approve in the webapp.

The 4 residuals (method in `plans/next-agent-handoff.md`; each needs a live
capture + human review — do NOT mark done without the captured diff PNG):
1. **m3e-card** — TWO structurally different nodes share ONE example. Convert to a
   MANUAL binding with per-set examples via `manual-correspondence.json`
   `figmaSets[].example` (mechanism date-input/tab/fab-menu-item already use).
   Read `~/.claude/skills/m3e/components/card.md` for the real tags/slots — do not
   guess. This edit is byte-stable and verifiable NOW (`pnpm emit` + `pnpm check`
   + `pnpm test`); only the pixel capture is bridge-gated.
2. **m3e-fab-menu** — node = open menu (3 tertiary segments + stars) + a sibling
   FAB (close icon, bottom-right). Needs the FAB + `m3e-fab-menu-trigger`
   composition, `variant="tertiary"`, corrected content, AND a render-harness
   change to open the SIBLING menu (a naive sibling FAB lands at top — the open
   menu portals; don't repeat).
3. **m3e-date-input docked** (node `51954:18567`) — the modal set is wrapped;
   apply the same render-harness WRAP to the docked set.
4. **m3e-search-view fullscreen** — representative binding, user-approved by
   eyeball; only pixel-match if asked (rebuild the per-set example to
   avatar+Label+supporting ×3, search text "Input text").

## Stream 2 / Phase 3 — remaining (BRIDGE-gated)

Build the `get_design_context`→m3e-HTML adapter (or its WS-bridge equivalent:
walk the frame via `get_document_info`/node reads, invert `correspondence.json`
to m3e-* tags), feed `Compose.FromHtml.parse`, fold with `Compose.Codegen`.
Capture one real frame → composed Elm as evidence. Downstream is testable now
against a scratch Elm build (docs app isn't cold-build-ready — see the Phase-3
doc's build note).

## Stream 3 — Avetta Plan-F (HUMAN/ORG-gated). Readiness.

Plan F (`plans/plan/F-consumer-avetta.md`) already enumerates every gated step
(F1–F8, each with its ⚑ HUMAN checkbox). Current readiness:
- **Precondition (Plan E complete):** the m3-kit breadth pipeline is proven; the
  residual visual-gate worklist (Stream 1 above) is the open tail. F's ADS work
  can start in parallel with S1 since it targets a different file (ADS
  `cbhz1J779WAI7gYkjCQwS0`).
- **`profiles/avetta-ads/` does NOT exist yet** — it is built by F3 (delta profile
  `extends: m3-kit`) AFTER the F2 ADS extraction (needs the WS bridge on ADS).
- **Pre-buildable without a bridge:** `docs/AVETTA.md` (F8, pure doc); the branding
  seed-override machinery (F4) reuses tailwind-m3e-web's culori tooling. Everything
  else (F1 library-resolution experiment, F2 extraction, F5 codeSyntax stamping,
  F6 Ui.* retirement, F7 publish) is ⚑ HUMAN org-write and waits on Jack.
- **Standing rule:** ADS is a shared org workspace — every write needs its own ⚑
  approval; `avetta/ui` VOLT-2003 `figma:check` CI must stay green during F6.

## Decisions (Jack's)

- **Canonical `--file-key`:** recommend `UtwpUdPiOZEuxp8Nq1d5yQ` — it's in
  `profile.json`, all 224 emitted URLs, and the file Jack had open in Figma this
  session. Confirm before any publish. (Publish is OFF, so non-blocking.)
- **`extract/` IP-provenance review:** cem-figma-connect stays private until
  recorded. Does not block the private-monorepo main merge (internal integration
  ≠ public release / Figma publish).

## Remainder queue (next bridge session, Jack present)

1. Verify bridge live (read call). 2. S1: 4 residual captures + human review
(real diff evidence). 3. Phase 3: one real frame → composed Elm, captured.
4. S3: F1/F2 once Jack approves org access. All gated on Jack holding the plugin
panel open (+ org approvals for S3).
