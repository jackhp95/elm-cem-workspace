# DAG rework — Task 0 baseline capture

Companion to `docs/plans/2026-08-21-dag-rework-plan.md`. This records the
"before" snapshot the final tasks diff against (plan Step 0.4), the identity
guard result (Step 0.3), and the gate baseline (Step 0.1).

## Provenance

- **Branch:** `docs/dag-rework-plan`, worktree `plan-dag-rework`.
- **Base SHA at capture:** `e89659d45c1bbe9c89c3918137353232ae96c640`
  (this branch's tip; plan doc + this note only — no emitter change yet at
  capture time).
- **Working tree before Task 1:** clean (`git status --short` empty).

## Step 0.3 — identity guard (D-DAG5) — PASS

```
$ git config user.name && git config user.email
JackHP95
git@jackhpeterson.com
```

## Provisioning note (friction — see below)

A fresh paseo worktree is un-provisioned: no root `node_modules`, no
`@m3e/web` CEM manifest. The first `gate:all` was RED with 42/57 failing
purely from missing toolchain (`run-p`/`run-s`/`vitest`/local `elm`/
`elm-format` all `command not found`, CEM manifest absent). One
`pnpm install` at the workspace root (its postinstall runs `elm-tooling
install` and provisions `@m3e/web`) fixed 40 of 42. **Every plan that gates
on `gate:all` from a fresh worktree must `pnpm install` first.** Logged as a
friction under `~/.claude/frictions/agent/`.

## Step 0.1 — `npm run gate:all` baseline (after provisioning)

```
54/57 passed, 1 skipped, 2 failed
```

- **1 SKIP** — `workspace: check-drift` — CHRONIC (needs the okf consumer's
  `.cache/m3e` = a built `matraic/m3e@v2.7.3` checkout; documented in
  `gate-all.mjs`'s `CHRONIC_SKIPS`). Not a regression.
- **2 FAIL** — `elm-cem-figma-connect: check` and `: test` — a `run-p
  "check:*"` parallel flake: **all 7 `check:*` sub-scripts pass individually
  (exit 0)**, but the `run-p` aggregate exits 1 (likely the Chromium visual
  `check:render` harness under concurrency). **Pre-existing, unrelated to the
  elm-cem emitter / DAG rework** — elm-cem-figma-connect is the Figma token
  pipeline, not the phantom emitter this rework touches.

### Everything the DAG rework actually touches is GREEN at baseline

| gate | status |
|------|--------|
| `elm-cem: check` | PASS (4.2s) |
| `elm-cem: test` | PASS (13.9s) |
| `elm-m3e: check` | PASS (37.6s) |
| `elm-m3e: test` | PASS (67.8s) |
| `elm-m3e-{core,elements,build,components,icons,facts}: check` | PASS |
| `workspace: ab-elm-cem (Face A byte-identity)` | PASS (4.4s) |
| `workspace: ab-elm-m3e-split` | PASS (1.4s) |
| `workspace: verify-split (5-package registry-faithfulness)` | PASS (4.3s) |
| `workspace: check-m3e-5pkg (D-037 split shape)` | PASS |
| `e2e: facts bundle generate + validate` | PASS (both faces schema-valid) |

The 2 cfc reds are the ONLY reds, and no elm-cem/elm-m3e gate is among them —
a clean-enough baseline for a dual-emit generator change.

## Step 0.4 — "before" tier-DAG facts (P1–P5), re-verified against the live tree

Every P-claim in the plan's "Read before Task 0" section was re-checked at
this base and holds:

- **P1** — Builders consume Elements, not Components.
  `Emit.elm:130` emits `compBuildModule` per CEM element; `compBuildModule`
  (`Component.elm:1164-1813`) hard-imports Elements at `Component.elm:1691`
  (`import <Lib>.Element.<X> as Component`), and `internalRef n = "Component." ++ n`
  (`Component.elm:1306-1307`). Materialized: `M3e/Build/NavMenu.elm:20`
  → `import M3e.Element.NavMenu as Component`. `grep 'import M3e.Component'`
  in `elm-m3e-build/src/` → **zero**.
- **P2** — Components (family) consume Elements, not Builders.
  `M3e/Component/NavMenu.elm` imports `M3e.Element.{NavMenu,NavMenuItem,NavMenuItemGroup}`;
  no `import M3e.Build` anywhere in `elm-m3e-components/src/`.
- **P3** — parallelism baked into the package DAG: `elm-m3e-build` and
  `elm-m3e-components` both dep `{core, elements}`, neither deps the other.
- **P4** — Builders CEM-emitted per-element (`Emit.elm:130`, one
  `M3e.Build.<X>` per `M3e.Element.<X>`); Components config-emitted per-family
  (`Emit.elm:140`, `FamilyPackage.files brand families`, 21 families).
- **P5** — the Component façade re-exports the element surface member-PREFIXED
  (`NavMenuIs`, `ItemIs`, `ItemBadgeSlot = Item_.BadgeSlot`, `itemBadge =
  Item_.badge`, …) — including the type-level `Builder` alias and the slot
  placers — but NOT the builder seeds (`build`/`toElement`). **Verified this
  makes the Component façade a member-prefixed SUPERSET of the union of the
  per-element Element surfaces the three NavMenu builders reference** (all of
  `Component.{Is,Builder,AttrCaps,Content,ChildAdmittedBy,SlotCaps,BadgeSlot,
  IconSlot,LabelSlot,SelectedIconSlot,ToggleIconSlot}` and slot-placers
  `Component.{badge,icon,label,selectedIcon,toggleIcon}` have a member-prefixed
  re-export on `M3e.Component.NavMenu`). This is the load-bearing precondition
  for Shape A and it holds — see Task 2 proof.

These become FALSE at Task 10; this note is the diff anchor.
