---
name: elm-m3e-family-git-hygiene
description: elm-m3e + cem/toolchain family repos are main-only (local+remote) as of 2026-07-30; old pre-Jul-21 history lives in the 8 -archive repos; elm-m3e remote intentionally keeps a WIP branch
metadata: 
  node_type: memory
  type: project
  originSessionId: b92683be-7be0-40fd-a7e8-be7668669acf
---

2026-07-30 branch-hygiene pass on the elm-m3e family. In-scope (Jack's own, non-archived): elm-m3e, elm-cem, elm-html-intermediate-representation, elm-typed-html, elm-review-cem, m3e-docs (→ `jackhp95/m3e-okf`), tailwind-m3e-web, elm-material, cem-figma-connect, elm-cem-template, elm-cem-decoder, + remote-only elm-cem-facts / gren-m3e / tailwind-material / goodash-tailwind-v4. **All now main-only local+remote, mains in sync.**

- **Deleted 15 stale local branches** (`cleanup`, `m3e-api-fixes`, `docs-selfcontained`, `collision-policy`, `cleanup-retired-machinery`, `archive/pre-adopt-jul21`, `ir-authoring`, `planning-sync`, `wip/teaching-docs`) across elm-m3e/elm-cem/iir/elm-typed-html. Verified each tip is an ancestor of its `<repo>-archive` repo before deleting → zero loss.
- **The 8 `-archive` repos are the deliberate home of the pre-Jul-21 "unrelated-history adoption" line** (the HtmlIr/TypedHtml origin swap). Old m3e/cem branch work lives there (elm-m3e-archive, elm-cem-archive, elm-html-intermediate-representation-archive, elm-typed-html-archive, elm-review-cem-archive, m3e-docs-archive, elm-cem-m3e, elm-cem-decoder-as-archive), long stale. If old work is ever needed, that's where it is.
- **elm-m3e remote intentionally carries branch `fix-sse-revendor-feedback-fab`** (Jack's live WIP — feedback-fab SSE-safe re-vendor, 1 commit). The elm-m3e working dir is checked out on it (+ a detached `elm-m3e-docsize` worktree). **Do NOT prune it as stale.**
- **elm-review-cem** remote main = intentional squashed 1.0 baseline (commit 19d1e8a says so); dropped `TranslateTo{Html,Raw,Standard}` was a deliberate narrowing to two translators (Build+Record). Old pre-release local line (`d310e36`) is in elm-review-cem-archive; local was reset to origin/main.
- **m3e-okf** disclosure-hook impl (`hooks/m3e-disclosure.mjs` + settings) had been stranded as an unpushed local commit → rescued via rebase onto origin/main + push (`be60352`).
- Out of scope (not Jack's): `matraic-m3e` → `matraic/m3e` upstream (+ its `a11y`/`pr-perf` PR worktrees under `matraic-m3e-wt/`), the `jackhp95/m3e` fork, `m3e-mirror`.

**Why:** these counts/branches look alarming (branches show huge diffs + "N commits not on main") because of the unrelated-history swap, not because they hold unique unmerged work — the content is all in the archives.

**How to apply:** on any future "clean up branches" pass over this family, (1) treat the `-archive` repos as the safety net / source of truth for old history, (2) never delete `elm-m3e/fix-sse-revendor-feedback-fab` without checking it's merged/abandoned first, (3) verify preservation with `git merge-base --is-ancestor <tip> <archive-ref>` before deleting rather than trusting `main..branch` commit counts. Related: [[elm-cem-repo-separation]].
