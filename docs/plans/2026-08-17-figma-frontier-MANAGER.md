# Figma-frontier — gauntlet manager state (living plan doc)

> Manager = this long-lived session. This table is the source of truth for what
> is in flight (liveness / duplicate-dispatch guard). Statuses:
> `queued → dispatched → in-verify → done | retried_up | trashed`.
> Done-gate = acceptance criteria met + CAPTURED evidence + git/branch confirms.
> Branch: figma-frontier. NEVER push/merge to main — hand back to Jack.

## Bridge status (verify-before-use gate)

- **WS relay** (`bun extract/relay/socket.ts`, `:3055`) — RUNNING (bg `b42arm8d6`).
- **Plugin bridge** — connected once (channel `cem-2c4c8a`, editorType=figma /
  Design mode, file "Material 3 Design Kit (Community)" = `UtwpUdPiOZEuxp8Nq1d5yQ`)
  then DROPPED. Waiting on a stable connection (bounded poller `babzzn9on`, 15m,
  exits on a successful `get_document_info` read). **Not usable until that read
  succeeds — do not run captures/exports before then.**
- **Figma MCP** (`plugin:figma:figma`, get_design_context) — needs Jack's auth AND
  Dev Mode (Jack's personal account can't enter Dev Mode). WORKAROUND: route
  Phase-3 Figma reads through the WS bridge (Design-mode read commands cover it).
- Design-mode read commands available: get_document_info, get_local_components,
  get_component_properties, get_styles, get_variables, export_node_as_image,
  capture_set.

## Task table

| # | leaf | role | tier | status | agent | evidence / envelope |
|---|---|---|---|---|---|---|
| S2-a | CC→Elm ref gate (v1) + reconciliation plan | work | opus | **done** | self | commit `b43b38d`; gate RED 83/224 captured |
| S2-b | producer fix (Emit.elm surfaces+module) + regen | work | opus | **done (uncommitted)** | self | facts M3e.Component.*; 130/130 modules real |
| S2-c | seam fix (textSeam M3e, attrSeam TypedHtml.customAttribute) + config thread | work | opus | **done (uncommitted)** | self | gate 83→0; --strict green |
| S2-d | rebaseline 16 emitter unit tests | work | sonnet | **in-verify** | `a9657` | must reach 728 pass / 0 fail + diff review |
| S2-e | wire gate --strict into gate-all | work | opus | **done (uncommitted)** | self | gate-all.mjs parses; gate green |
| S2-f | COMMIT S2 green + full gate-all from clean | verify+manage | opus | queued (blocked by S2-d) | self | needs captured `gate-all` exit 0 |
| S2-map | producer/exposure mapping (corroboration) | verify | sonnet | dispatched | `a77e` | read-only Explore; low priority |
| P3 | Phase-3 Figma→Elm wiring design | plan | opus | **done (prep)** | self | `2026-08-17-stream2-phase3-figma-to-elm-link.md` |
| S1-runbook | visual-gate runbook + mechanical-prep spec | plan | sonnet | dispatched | `a68f` | draft → /tmp; integrate + review |
| S1-work | 4 residual captures (card/fab-menu/date-input/search) | work | — | queued (blocked: bridge live + S1-runbook) | — | ⚑ bridge; captured diff evidence |
| S3-readiness | Avetta Plan-F readiness + gated-step enum | plan | sonnet | dispatched | `a679` | draft → /tmp; integrate + review |
| S3-work | ADS extraction + delta profile | work | — | queued (blocked: bridge + Jack org approvals) | — | ⚑ HUMAN-gated |
| DEC | file-key + IP-provenance decisions | manage | opus | surfaced | self | in chat; publish OFF so non-blocking |

## Cross-cutting verification already captured (S2)

- `check-cc-elm-refs --strict` GREEN (0/224 missing)
- cem-figma-connect `check` GREEN (0 drift/orphan, tokens byte-stable, render stable)
- Face B (cem-facts.json) byte-stable; elm-shape golden 25/0
- check-bundle-provenance / check-emit-determinism-cfc / check-drift /
  check-elm-shape-drift — ALL PASS
- ONLY gate-all failure remaining: the 16 emitter tests (→ S2-d).

## Recomposition guard (end-to-end slices)

- S2 vertical slice: emitted `.figma.ts` → module refs all resolve against real
  elm-m3e (the gate IS the e2e assembly test). Hardening: real `elm make` (v2).
- Phase 3 vertical slice (⚑ bridge): one real frame → composed Elm, captured.
- S1 vertical slice (⚑ bridge): each residual component's visual-diff under
  threshold, screenshot captured.

## Decisions (Jack's; publish OFF ⇒ non-blocking to build)

- Canonical `--file-key`: recommend `UtwpUdPiOZEuxp8Nq1d5yQ` (profile + all 224
  emitted URLs + the file Jack has open). Jack confirms before any publish.
- `extract/` IP-provenance review: repo stays private until recorded.
