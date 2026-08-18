# hooks/pre-push.d/ — sourced pre-push extensions

`hooks/pre-push` runs `node tools/gate-all.mjs`, then sources every executable
`*.sh` file here, in sorted order, after the gate passes. This is the "sourced
extension" mechanism referenced by the audit's Theme 1 remedies
(`docs/reviews/2026-08-17-thermonuclear-workspace-review.md`, findings
1.2–1.4): package-specific pre-push behavior beyond "run the gate" lives here
instead of a competing per-package hook fighting to own `core.hooksPath`.

Each extension is `. sourced` (not executed as a subshell), so it runs in the
hook's own shell — `set -e` is already active, `$PRE_PUSH_REFS` (the captured
`<local-ref> <local-sha> <remote-ref> <remote-sha>` stdin lines) and `$1`
(remote name) are available, and an extension's own `exit` ends the whole
hook.

## Deferred, not ported: elm-m3e's Netlify prebuilt-dist auto-commit

`packages/elm-m3e/hooks/pre-push` (pre-fold, when elm-m3e was its own git
repo) built `docs/dist/` and self-committed + self-pushed it on every push, so
Netlify could serve a prebuilt static site with no Elm build on its end. That
logic is NOT ported here. Two reasons:

1. **It never actually ran in this workspace.** `core.hooksPath` was unset
   before this fix (finding 1.2) — no per-package hook has fired since the
   2026-08-12 fold. Porting it is new behavior, not a restoration of working
   behavior, so it doesn't belong in a leaf scoped to "wire up the enforcement
   that already existed."
2. **The scoping question needs a product decision, not a guess.** The
   original hook fired unconditionally on every push in elm-m3e's *own* repo,
   where every push necessarily touched that repo. Firing unconditionally
   here — a single monorepo hook — would build + auto-commit
   `packages/elm-m3e/docs/dist/` on every push to *any* package, which is
   almost certainly wrong (spurious Netlify deploys for cem-figma-connect-only
   changes) but scoping it correctly (only when the push touches
   `packages/elm-m3e/docs/**`?  only on specific branches?) is a real design
   call, plus the hook's self-push/recursion-guard logic
   (`packages/elm-m3e/hooks/pre-push`) needs re-verifying against monorepo ref
   semantics before it's safe to arm.

If this is wanted, scaffold it as `hooks/pre-push.d/10-elm-m3e-netlify-dist.sh`
adapted from `packages/elm-m3e/hooks/pre-push`'s existing (well-commented)
implementation, with an explicit push-path scope added first.
