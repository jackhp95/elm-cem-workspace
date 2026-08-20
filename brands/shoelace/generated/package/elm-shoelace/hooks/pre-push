#!/bin/sh
# pre-push — run this repo's own gate before anything leaves the machine.
#
# Local verification is the primary gate here, not GitHub Actions. The hook runs
# the same `npm run gate` (or `npm test`) a human would run, so a red tree cannot
# reach origin in the first place.
#
# Enable with `npm run hooks:install` (sets core.hooksPath=hooks). `postinstall`
# does it automatically, so a fresh `npm install` is enough.
#
# Escape hatches, in order of preference:
#   git push --no-verify      one-off bypass
#   SKIP_GATE=1 git push      same, but explicit about what is being skipped
#
# Ref deletions skip the gate: there is no tree to verify, and `git push --delete`
# during branch cleanup should not pay for a full test run.
#
# THIS FILE IS GENERATED. The canonical source is tools/hooks/pre-push-base.sh
# in the elm-cem-workspace monorepo (Theme 3 of the 2026-08-17 thermonuclear
# audit: 7 byte-identical hand-duplicated copies, consolidated behind
# tools/gen-hooks.mjs). Do not hand-edit this file — edit the base and run
# `node tools/gen-hooks.mjs` from the workspace root, or `node tools/gen-hooks.mjs --check`
# to verify it hasn't drifted. Standalone-repo consumers (this file ships to
# each package's own jackhp95/<name> mirror via tools/publish-mirror.mjs) get
# no such regeneration — if you're reading this from a mirror repo, it's a
# faithful copy as of the last publish, just no longer live-editable there.

set -e

# --- BODY START (a brand-specific Netlify wrapper reuses this verbatim below) -----
if [ "${SKIP_GATE:-}" = "1" ]; then
  echo "pre-push: SKIP_GATE=1 — gate skipped."
  exit 0
fi

# stdin: <local-ref> <local-sha> <remote-ref> <remote-sha> per ref being pushed.
# Captured once (`refs=$(cat)`, then replayed via heredoc) rather than read
# directly, so a caller that needs the raw ref list again afterward (e.g. a
# wrapper that self-pushes a follow-up commit) can — the here-doc feeds
# `while read` in the CURRENT shell, not a subshell, so the flags set inside
# the loop survive it either way.
refs=$(cat)
only_deletions=1
saw_ref=0
while read -r _local_ref local_sha _remote_ref _remote_sha; do
  [ -z "$local_sha" ] && continue
  saw_ref=1
  case "$local_sha" in
    *[!0]*) only_deletions=0 ;;
  esac
done <<EOF
$refs
EOF

if [ "$saw_ref" = "1" ] && [ "$only_deletions" = "1" ]; then
  echo "pre-push: deletion-only push — gate skipped."
  exit 0
fi

repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root"

if [ ! -f package.json ]; then
  exit 0
fi

if node -e 'process.exit(require("./package.json").scripts?.gate ? 0 : 1)' 2>/dev/null; then
  script=gate
elif node -e 'process.exit(require("./package.json").scripts?.test ? 0 : 1)' 2>/dev/null; then
  script=test
else
  exit 0
fi

echo "pre-push: running \`npm run $script\` ..."
if ! npm run "$script"; then
  echo ""
  echo "pre-push: \`npm run $script\` FAILED — push aborted."
  echo "          Fix it, or bypass deliberately with: git push --no-verify"
  exit 1
fi

echo "pre-push: gate passed."
# --- BODY END ----------------------------------------------------------------
