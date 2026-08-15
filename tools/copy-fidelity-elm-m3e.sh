#!/usr/bin/env bash
# Copy-fidelity gate for the elm-m3e migration.
#
# elm-m3e was flat-copied from its own repo into packages/elm-m3e. This gate
# proves the copy is FAITHFUL: no git-tracked source file went missing, and no
# build output got committed into the workspace.
#
# It exists because a migration can look completely green while having silently
# dropped a tracked file — a gate that only asks "is everything passing?" cannot
# see a file that was never copied.
#
# COMPARISON SEMANTICS (this is the subtle part):
#   Both sides are compared as GIT-TRACKED SETS, not as directory listings.
#   The workspace side = files git tracks under packages/elm-m3e, PLUS untracked
#   files git would track (i.e. not covered by .gitignore). Locally-generated
#   build output (docs/elm-stuff/, docs/dist/, node_modules/, elm-stuff/, ...) is
#   gitignored and therefore correctly invisible here — its presence on disk is
#   normal after a build and is NOT pollution. Comparing raw directory contents
#   instead would flag thousands of legitimate build artifacts and train the
#   reader to ignore this gate.
#
# Env:
#   SOURCE_ELM_M3E      path to the source elm-m3e checkout
#                       (default: $SNAPSHOT_ROOT/elm-m3e)
#   SNAPSHOT_ROOT       parent directory of the inert pre-migration snapshot
#                       checkouts (default: the workspace's parent directory)
#   REQUIRE_SNAPSHOT_GATES=1  make a missing SOURCE_ELM_M3E a hard failure
#                       instead of a SKIP
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_ROOT/tools/lib/snapshot-gate.sh"

SNAPSHOT_ROOT="${SNAPSHOT_ROOT:-$REPO_ROOT/..}"
# elm-m3e's reference advanced to latest main (D-041) — .cache/snapshots/elm-m3e
# via tools/fetch-snapshots.mjs; the frozen sibling is no longer it.
SOURCE_ELM_M3E="${SOURCE_ELM_M3E:-$REPO_ROOT/.cache/snapshots/elm-m3e}"
PKG_REL="packages/elm-m3e"

# Source-tracked paths that are DELIBERATELY absent from the workspace copy:
# per-repo lockfiles and the nested pnpm workspace, all superseded by the root
# workspace's single lockfile and single pnpm-workspace.yaml.
AUTHORIZED_ABSENT=$(cat <<'EOF'
package-lock.json
pnpm-lock.yaml
pnpm-workspace.yaml
docs/package-lock.json
docs/pnpm-lock.yaml
docs/pnpm-workspace.yaml
EOF
)

# M6 deep-clean authorized deletions (docs/facts-bundle/m6-deep-clean.md has the
# full reasoning per path). All are stale/superseded narrative docs or agent
# session-memory scratch with zero live references anywhere in the workspace,
# verified individually against both source-code citations and cross-doc
# citations before removal — not a blanket sweep.
AUTHORIZED_ABSENT="$AUTHORIZED_ABSENT
$(cat <<'EOF'
.claude-memory/elm-m3e-cross-cem-branding.md
.claude-memory/elm-m3e-docs-barrel-conversion.md
.claude-memory/elm-m3e-docs-mobile-shell-fab.md
.claude-memory/elm-m3e-family-git-hygiene.md
.claude-memory/elm-m3e-reflection-attr-property.md
.claude-memory/elm-m3e-substrate-reexports.md
.claude-memory/m3e-components-for-styling.md
.claude-memory/release-planning-collection.md
.claude-memory/thermo-nuclear-release-audit.md
CAP-ACCOUNTING.md
TASK1-FINDING.md
docs-playbook/consumer-migration-playbook.md
docs/plans/2026-08-09-theme-reel-design.md
docs/plans/theme-flash-and-dev-fouc.md
plans/2026-08-05-favicon-material-palette.md
plans/2026-08-05-icon-registry-seam.md
plans/2026-08-05-remove-raw-html-element.md
plans/2026-08-05-shared-elm-value-primitives.md
plans/2026-08-05-theme-host-view-restructure.md
plans/2026-08-06-nav-rail-layout.md
plans/2026-08-06-nav-rail-shell-tests.md
plans/2026-08-06-nav-rail-tree-toc.md
plans/2026-08-07-nav-rail-search.md
plans/2026-08-08-welcome-page-url-restructure.md
specs/2026-08-05-remove-raw-html-element-design.md
EOF
)"

# M5 authorized deletion: the whole docs/vendor/tailwind-m3e-web/ tree. It was a
# VENDORED copy of tailwind-m3e-web's CSS output, checked in because the real
# package lived in a separate repo. That package is now co-located at
# packages/tailwind-m3e-web and the two move together, so the vendored copy is a
# duplicate that can only rot. Matched as a prefix rather than file-by-file
# because the whole subtree is authorized, not individual files.
AUTHORIZED_ABSENT_PREFIX="docs/vendor/tailwind-m3e-web/"

# Files present in the workspace copy that are NOT in the source repo, because
# they are deliberate monorepo adaptations. Each entry needs a stated reason.
AUTHORIZED_EXTRA=$(cat <<'EOF'
docs/scripts/fix-native-bins.mjs
docs/scripts/browser-guard.mjs
docs/scripts/check-review-guard.mjs
docs/scripts/gen-compose-attrs.mjs
docs/app/Compose/Attrs.elm
docs/app/Compose/Render.elm
docs/app/Route/Components/Compose.elm
docs/app/Compose/Codegen.elm
docs/tests-browser/compose.spec.ts
docs/app/Compose/FromHtml.elm
docs/tests/FromHtmlTest.elm
EOF
)
# docs/scripts/fix-native-bins.mjs — pnpm 10 wraps every bin entry in an
#   `exec node <path>` shell shim. That is correct for JS bins and BROKEN for the
#   native Mach-O executables this toolchain depends on (elm, elm-format,
#   lamdera). docs/ was an npm-managed subproject with its own lockfile before
#   the migration, so this only became necessary once the root pnpm workspace
#   took over installing it. The script restores direct symlinks post-install.
# docs/scripts/browser-guard.mjs — workspace portability wrapper for
#   `test:browser` (R-023). It runs the Playwright suite when its generated
#   docs inputs + browser binaries are present, and SKIPs-with-reason in a
#   fresh clone that has neither, so `gate-all` is green-with-a-documented-skip
#   off the migration machine instead of a hard failure. Not in the source repo
#   because it is a monorepo-clone concern the standalone repo never had.
# docs/scripts/check-review-guard.mjs — same-shaped guard for `check:review`
#   (D-047, R-023). elm-review over the docs needs the gitignored elm-pages router
#   wiring (`.elm-pages/`, generated by `elm-pages gen`) to see the framework
#   entry modules (Api/ErrorPage/Route.*) as used; without it NoUnused false-fires.
#   The guard generates the router first, then runs elm-review, and SKIPs-with-reason
#   where the router codegen can't run. A monorepo-clone concern the source repo
#   never had (upstream runs check:review only after a full docs build).
# docs/scripts/gen-compose-attrs.mjs — Compose B9: derives the attr kind +
#   dispatch table from M3e.Attributes/M3e.Review.Facts; new to this
#   monorepo's Compose POC, absent from the upstream elm-m3e checkout.
# docs/app/Compose/Attrs.elm — the committed OUTPUT of the generator above
#   (Compose B9, relocated out of app/Route/ in B11 so elm-pages does not
#   misgenerate it as a route); new to this monorepo's Compose POC, absent
#   from the upstream elm-m3e checkout.
# docs/app/Compose/Render.elm — Compose B10: the hand-written renderNode
#   preview fold (relocated out of app/Route/ in B11 for the same reason);
#   new to this monorepo's Compose POC, absent from the upstream elm-m3e
#   checkout.
# docs/app/Route/Components/Compose.elm — Compose B11: the route at
#   /components/compose; new to this monorepo's Compose POC, absent from the
#   upstream elm-m3e checkout.
# docs/app/Compose/Codegen.elm — Compose B13: the hand-written recursive
#   generated-code snippet fold; new to this monorepo's Compose POC, absent
#   from the upstream elm-m3e checkout.
# docs/tests-browser/compose.spec.ts — Compose B14: Playwright browser
#   coverage for the /components/compose route; new to this monorepo's
#   Compose POC, absent from the upstream elm-m3e checkout.
# docs/app/Compose/FromHtml.elm — Compose G-Ex1: brand-agnostic parser from a
#   real example's HTML into a Cem.Compose message sequence; new to this
#   monorepo's Compose POC, absent from the upstream elm-m3e checkout.
# docs/tests/FromHtmlTest.elm — Compose G-Ex1: worker-test for the parser
#   above; new to this monorepo's Compose POC, absent from the upstream
#   elm-m3e checkout.

require_snapshot_or_skip "copy-fidelity-elm-m3e" "$SOURCE_ELM_M3E" "SOURCE_ELM_M3E"

if [ ! -d "$REPO_ROOT/$PKG_REL" ]; then
    echo "ERROR: workspace copy not found at $REPO_ROOT/$PKG_REL" >&2
    exit 1
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# docs/dist/** is BUILT output (vite content-hashed) that the source repo commits
# for deploy but the workspace rebuilds with different hashes — exclude it from
# copy-fidelity on both sides (it is not source; the site build verifies it). D-041.
git -C "$SOURCE_ELM_M3E" ls-files | grep -vE '^docs/(dist|vendor)/' | sort > "$tmp/source.txt"

# Workspace side: tracked files + untracked-but-not-ignored files, both relative
# to packages/elm-m3e. `--others --exclude-standard` is exactly "files git would
# add", i.e. it honours every .gitignore in play.
#   A path counts as present only if git knows about it AND it exists on disk —
#   `git ls-files` alone reads the INDEX, so a file deleted from the working tree
#   would still look present and this gate would miss it.
{
    git -C "$REPO_ROOT" ls-files "$PKG_REL"
    git -C "$REPO_ROOT" ls-files --others --exclude-standard "$PKG_REL"
} | sort -u | while IFS= read -r p; do
    [ -e "$REPO_ROOT/$p" ] && printf '%s\n' "${p#"$PKG_REL/"}"
done | grep -vE '^docs/(dist|vendor)/' | sort -u > "$tmp/workspace.txt"

printf '%s\n' "$AUTHORIZED_ABSENT" | grep -vE '^\s*$' | sort > "$tmp/authorized.txt"

comm -23 "$tmp/source.txt" "$tmp/workspace.txt" | sort > "$tmp/missing-raw.txt"
comm -23 "$tmp/missing-raw.txt" "$tmp/authorized.txt" \
    | grep -v "^${AUTHORIZED_ABSENT_PREFIX}" > "$tmp/missing.txt" || true
printf '%s\n' "$AUTHORIZED_EXTRA" | grep -vE '^\s*$' | sort > "$tmp/authorized-extra.txt"
comm -13 "$tmp/source.txt" "$tmp/workspace.txt" | sort > "$tmp/extra-raw.txt"
comm -23 "$tmp/extra-raw.txt" "$tmp/authorized-extra.txt" > "$tmp/extra.txt"

missing_count=$(wc -l < "$tmp/missing.txt" | tr -d ' ')
extra_count=$(wc -l < "$tmp/extra.txt" | tr -d ' ')
source_count=$(wc -l < "$tmp/source.txt" | tr -d ' ')
workspace_count=$(wc -l < "$tmp/workspace.txt" | tr -d ' ')

echo "copy-fidelity: source tracked=$source_count  workspace tracked+addable=$workspace_count"
echo "copy-fidelity: authorized-absent=$(wc -l < "$tmp/authorized.txt" | tr -d ' ')"

status=0

if [ "$missing_count" -gt 0 ]; then
    echo "" >&2
    echo "MISSING — git-tracked in the source repo but absent from the workspace copy:" >&2
    sed 's/^/  /' "$tmp/missing.txt" >&2
    status=1
fi

if [ "$extra_count" -gt 0 ]; then
    echo "" >&2
    echo "EXTRA — tracked/addable in the workspace but NOT git-tracked in the source repo:" >&2
    sed 's/^/  /' "$tmp/extra.txt" >&2
    echo "" >&2
    echo "(If one of these is a deliberate monorepo adaptation, add it to an explicit" >&2
    echo " allowlist in this script with a reason — do not silence this gate wholesale.)" >&2
    status=1
fi

if [ "$status" -ne 0 ]; then
    echo "" >&2
    echo "COPY-FIDELITY RED — $missing_count missing, $extra_count extra" >&2
    exit 1
fi

echo "COPY-FIDELITY GREEN — every tracked source file present, no untracked file committed"
