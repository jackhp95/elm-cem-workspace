---
name: regenerating-m3e-docs
description: >-
  Regenerates the m3e-docs build artifacts — the m3e skill cards, the examples,
  and the OKF knowledge/implementations bundle — from the SHA-pinned upstream
  matraic/m3e source, and performs an upstream-version bump. Use when a maintainer
  needs to run the generation pipeline in the right order, bump the pinned m3e SHA,
  check staleness, review extraction drift in data/report.md, or understand the
  rebuild+diff CI contract. This is a maintainer workflow for the m3e-docs repo; the
  generated trees (skills/m3e/, knowledge/, implementations/) are build outputs and
  MUST NOT be hand-edited.
disable-model-invocation: true
---

# Regenerating m3e-docs

`skills/m3e/`, `knowledge/`, and `implementations/` are **generated build outputs**.
Never hand-edit them — edit the source (`data/**`, or the generator scripts) and
rebuild. CI enforces this by rebuilding and diffing (`git diff --exit-code`).

## Pipeline order

Run from the repo root. Two build chains share `data/`:

```
# 1. Skill chain (CEM-verified <m3e-*> cards + examples)
npm run gen:extract    # upstream source/CEM  -> data/components.json, sources.json, report.md
npm run gen:guidance   # concept/guidance prose -> data/guidance.json
npm run gen:examples   # validated compositions -> data/examples.json
npm run gen:skill      # data/*.json           -> skills/m3e/**
npm run check:skill    # guard: every html block valid vs the CEM

# 2. OKF bundle chain (neutral knowledge + verified implementation layer)
npm run gen:okf             # data/knowledge/** + cards -> knowledge/**, implementations/**
npm run check:okf-validity  # guard: frontmatter, reserved files, citations
npm run check:okf           # guard: rebuild-and-diff freshness + validity
```

`gen:okf` copies the SAME cards `gen:skill` renders into
`implementations/m3e-web/`, so **run the skill chain before the OKF chain**.
`npm run gen` chains all five `gen:*` steps in exactly this order. The npm
aliases are `gen:extract`, `gen:guidance`, `gen:examples`, `gen:skill`,
`check:skill`, `gen:okf`, `check:okf-validity`, `check:okf`, plus `test:lib`
(all `gen:*` write git-tracked files; all `check:*` verify without writing,
except `check:okf` — see the README).

Order rationale: gen:extract → gen:guidance → gen:examples → gen:skill →
check:skill, then gen:okf → check:okf-validity → check:okf.

## SHA-pin / staleness model

The pinned upstream commit lives in `data/sources.json` (`sha`). Generation is
never automatic — it is a deliberate, pinned step. Check drift:

```
npm run check:staleness   # exit 0 = current, 1 = stale, 2 = undetermined (network/gh)
```

Exit **0** means the pin matches `matraic/m3e@main`; **1** prints how many commits
behind and which `packages/web/src|docs` files changed; **2** means it couldn't
reach upstream (needs `gh` auth or network) — treat as "unknown", not "current".

## Upstream-version bump procedure

1. `npm run check:staleness` — confirm it's stale (exit 1) and see what
   upstream touched.
2. Re-fetch upstream `matraic/m3e` at the new SHA, regenerate its Custom Elements
   Manifest, and update `sha` in `data/sources.json` to the new commit.
3. Re-run the **full pipeline** in order (both chains above).
4. **Review `data/report.md`** — the extraction report. Read the "Verification
   findings" counts (DEFAULT-UNDOCUMENTED / UNDOCUMENTED / DEFAULT-MISMATCH /
   EXAMPLE-DRIFT) and the per-component drift list. New or changed drift is the
   signal that upstream moved; confirm the CEM values now on the cards are correct
   (the CEM always wins over the README).
5. If a NEW component shipped, `data/spec-map.json` will be missing its key and
   `build-skill.mjs` fails by design — add the component's Material spec URL (or an
   explicit `null` for a library extension) and rebuild.
6. **Never hand-edit generated cards** to "fix" drift — fix the source data or the
   generator/templates, then rebuild.
7. Run all guards green, then commit the regenerated trees together with the
   source change.

## CI rebuild + diff + guard contract

`.github/workflows/ci.yml` runs on push/PR against committed inputs only (it does
NOT re-fetch upstream). It:

1. Runs the unit tests (`node --test scripts/lib/*.test.mjs`).
2. Rebuilds `build-examples.mjs`, `build-skill.mjs`, `build-okf.mjs`.
3. Asserts freshness with `git diff --exit-code -- data/examples.json skills/
   knowledge/ implementations/` — a stale committed artifact fails the build.
4. Runs `check-skill.mjs` (every html block valid vs the CEM) and
   `validate-okf.mjs` (OKF frontmatter/reserved/citations).
5. Reports `audit-guidance.mjs` (non-gating) and ratchets it at `--max-uncited 1`.

So the local contract before committing: run `npm run gen` (or the individual
`gen:*` steps in order), then confirm `npm run check:skill`,
`check:okf-validity`, and `check:okf` are all green and `git diff` is clean
for the generated trees. `npm run gate` runs this plus everything else.

---

_Grounded in scripts/*.mjs + .github/workflows/ci.yml; last verified 2026-07-11._
