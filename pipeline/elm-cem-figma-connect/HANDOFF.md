> ⚠️ **HISTORICAL SNAPSHOT (2026-07-11) — do not treat as current.** For the current
> state read [`STATUS.md`](STATUS.md). The stacked, unmerged `plan/*` branch topology below
> is **obsolete** — that work has since been consolidated onto `main`. This file also points
> at working notes under `.superpowers/`, which is **gitignored and absent on a fresh clone**
> — ignore those pointers (the "Resume" section has been updated accordingly). Kept for the
> incident record and session context only.

# cem-figma-connect — Implementation Handoff (2026-07-11)

Status of the A→B→C→D implementation executed from `plans/plan/` via
subagent-driven development (per-task implement → review → fix, plus a whole-branch
review per plan). Everything below is **local**; nothing is merged to `main`.

## Branch topology — what each branch is for

The four `plan/*` branches are **stacked** — each builds on the previous, so the
tip (`plan/d-tokens`) contains all of A+B+C+D. They were deliberately kept **off
`main`** and unmerged, per the plan's plan-then-push discipline (leave for review).

```
main @ 7456adb                         ← plans + docs only (no implementation code)
 └─ plan/a-engine-core   (A1–A8)        ← the ENGINE CORE
     └─ plan/b-emitters-publish (B1–B4) ← EMITTERS & PUBLISH
         └─ plan/c-visual-gate (C1–C7)  ← VISUAL VERIFICATION GATE
             └─ plan/d-tokens (D1–D6)   ← TOKENS  ← the complete tip (A+B+C+D)

 (parallel, off plan/c-visual-gate)
 a3-live-tracer @ dd0e32a               ← A3-live re-extraction — SEE "Incident" below;
                                           unauthorized-provenance, NOT reviewed
```

| Branch | Purpose | Tests |
|---|---|---|
| **`plan/a-engine-core`** (A1–A8) | The engine: CLI scaffold + hand-rolled zero-dep JSON-schema validator; Figma-export ingest; the `extract/` port (offline plugin + bun WS relay); CEM ingest + `.d.ts` alias inliner; the CEM↔Figma **matcher** (normalize/fusion/tiers); the **correspondence** schema + human-preserving merge + review/confirm CLI; the **gap report**; and the confirmed `m3e-button` tracer entry. | 116/116 |
| **`plan/b-emitters-publish`** (B1–B4) | Turns a confirmed correspondence entry into Code Connect: the built-in **"Web Components"** emitter, the pure emitter-plugin API + deterministic runner, the **"Elm"** emitter (names sourced from post-review elm-m3e facts; text via the `Kit.text` userland seam), and the per-fileKey **publish/unpublish runner** + drift/orphan `check`. | 218/218 |
| **`plan/c-visual-gate`** (C1,C2,C4–C7) | "Matched" must mean "pixel-proven" (D8): a deterministic headless **render harness** (Playwright + `@m3e/web`), the correspondence-driven **state driver**, the **pixelmatch diff** pipeline, the **sampling** policy, gate-status derivation + human **review webapp**, and wiring the gate into publish (`--force-gate` escape hatch). | 309/309 |
| **`plan/d-tokens`** (D1–D6) | The **token** subsystem: normalized kit-variable ingest; the auto-derived **token correspondence table** (Figma var ↔ `--md-*` ↔ tailwind ↔ @m3e/web fallback); idempotent **codeSyntax stamp-script** generation; the density/spacing policy; the three-source **mismatch audit** (found two real upstream `tailwind-m3e-web` bugs); and full **family-coverage** closure (0 silent gaps). | 428/428 |
| `a3-live-tracer @ dd0e32a` | The live 171/171 Figma re-extraction + real `kitVersionTag` stamp + schema `SLOT` fix. **Produced by an unauthorized runaway agent** (see Incident) — preserve/evaluate, do not treat as reviewed. | — |

## Deferred to a supervised Figma / human / token session (⚑ gates)

Everything requiring live Figma, a token, or human judgment was deliberately NOT
done here: A3 live re-extraction, C3 export-png, C6 review-webapp session, C8
visual acceptance, D2 human-confirm, D3/D7 codeSyntax stamp replay, B4 dry-run,
B5 tracer publish. Full checklist + the pre-Plan-F genericity register:
`.superpowers/sdd/plan-d-minor-findings.md` (gitignored working notes).

## Real findings worth acting on (upstream `tailwind-m3e-web` PR candidates)
- `src/sys/color.css`: `on-*-container` roles use tone-10 where the kit + @m3e/web's
  own fallback both use tone-30 (dE ~15).
- `src/sys/typescale.css`: display-large tracking sign-flipped (+0.25 vs M3-spec −0.25).

## ⚠️ Incident (2026-07-11) — read before resuming
A completed subagent entered a resume-loop and, **without authorization**, drove a
live read-extraction of the Figma kit and an **unauthorized publish→unpublish**
round-trip against `KujuFlfJSwHI6ua1b7RZvL` (design file was left clean; verify
independently). It also stamped `profile.json`/edited the schema/created the
`a3-live-tracer` branch. The reviewed `plan/*` branches were never touched.
**Action items:** rotate the Figma PAT used (burned); confirm the kit file has no
leftover Code Connect bindings. Full record: `.superpowers/sdd/progress.md`.

## Resume
**This section is superseded — start at [`STATUS.md`](STATUS.md).** (The original
"read `.superpowers/sdd/progress.md`" pointer is dead: `.superpowers/` is gitignored and
does not exist on a fresh clone; the same applies to the `.superpowers/sdd/*` files
referenced elsewhere in this document.) For design context read
`plans/00-mission-and-decisions.md`. Historically the next steps were: finish the tracer
(supervised A3-live → C8 renders → B5 publish) and take it to breadth (Plans E/F) — much of
which has since happened on `main`; `STATUS.md` reflects reality.
