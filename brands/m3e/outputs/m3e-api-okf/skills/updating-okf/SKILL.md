---
name: updating-okf
description: >-
  Keeps the local m3e-okf checkout current with origin/main, and — critically —
  never clobbers local changes: if the checkout has diverged (local commits or
  uncommitted edits), it captures those as a PR instead of overwriting. Use at
  the start of any m3e work, or when the m3e/applying-material-design skills are
  invoked, so the API facts served are the latest. Deterministic in the common
  case (fast-forward if strictly behind); LLM-in-the-loop only when diverged.
---

# Updating m3e-okf

Run the deterministic updater, then act on its `state`.

```
node <m3e-okf>/scripts/okf-update.mjs
```
(It resolves its own repo root; pass `--repo <path>` to target another checkout.)

## Act on the JSON `state`

- **`current`** — HEAD == origin/main, clean. Nothing to do. Proceed.
- **`updated`** — was strictly behind + clean; the script already fast-forwarded.
  Report the new HEAD and proceed with fresh docs.
- **`error`** — report the `error` string; do not retry blindly (network/git issue).
- **`diverged`** — the checkout has local changes NOT on origin/main (local
  commits and/or uncommitted edits). **These are the user's own fixes — never
  reset, clobber, or `--force` them.** Upstream them as a PR:
  1. `git -C <repo> switch -c okf-local-<short-timestamp>` (branch off HEAD).
  2. If there are uncommitted changes, stage + commit them with a message that
     says they were captured from a diverged local checkout.
  3. `git -C <repo> push -u origin <branch>`.
  4. `gh pr create --base main --head <branch>` — title/body explain these are
     locally-made m3e-okf fixes being upstreamed; link any related friction.
  5. If the PR reports conflicts with main, resolve them locally (you're the
     LLM in the loop): merge/rebase main, fix conflicts favoring the union of
     both intents, push. Then main can fast-forward cleanly next run.

## Why this shape
A modified local checkout is *signal*: the user hit a gap and fixed it on their
machine. Overwriting it on update would destroy that fix and re-introduce the
gap. Turning divergence into a PR both preserves the fix and feeds it back to
everyone. The only auto-mutating path is the safe clean fast-forward.

## Wiring (optional)
To run this on every session, add a SessionStart hook that calls
`okf-update.mjs` and surfaces a one-line status; keep the PR step manual
(LLM-driven) so nothing is pushed without the agent's involvement.
