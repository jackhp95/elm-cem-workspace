#!/usr/bin/env bash
# Copy-fidelity gate for the m3e-okf migration.
#
# m3e-okf was flat-copied from its own repo into packages/m3e-okf. This gate
# proves the copy is FAITHFUL: no git-tracked source file went missing, and no
# build output got committed into the workspace.
#
# It exists because a migration can look completely green while having silently
# dropped a tracked file — a gate that only asks "is everything passing?" cannot
# see a file that was never copied.
#
# COMPARISON SEMANTICS (this is the subtle part):
#   Both sides are compared as GIT-TRACKED SETS, not as directory listings.
#   The workspace side = files git tracks under packages/m3e-okf, PLUS untracked
#   files git would track (i.e. not covered by .gitignore). Locally-cloned
#   upstream source (.cache/m3e/, gitignored by the root .gitignore's `.cache/`
#   entry) is correctly invisible here — its presence on disk after running
#   gen:extract is normal and is NOT pollution. Comparing raw directory
#   contents instead would flag that clone (and node_modules/) as thousands of
#   spurious extras and train the reader to ignore this gate.
#
# Env:
#   SOURCE_M3E_OKF      path to the source m3e-okf checkout
#                       (default: $SNAPSHOT_ROOT/m3e-okf)
#   SNAPSHOT_ROOT       parent directory of the inert pre-migration snapshot
#                       checkouts (default: the workspace's parent directory)
#   REQUIRE_SNAPSHOT_GATES=1  make a missing SOURCE_M3E_OKF a hard failure
#                       instead of a SKIP
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_ROOT/tools/lib/snapshot-gate.sh"

SNAPSHOT_ROOT="${SNAPSHOT_ROOT:-$REPO_ROOT/..}"
SOURCE_M3E_OKF="${SOURCE_M3E_OKF:-$SNAPSHOT_ROOT/m3e-okf}"
PKG_REL="packages/m3e-okf"

# Source-tracked paths that are DELIBERATELY absent from the workspace copy.
# (Currently none — the whole source tree carries over unchanged.)
AUTHORIZED_ABSENT=$(cat <<'EOF'
EOF
)

# Files present in the workspace copy that are NOT in the source repo, because
# they are deliberate M3.b adaptations. Each entry needs a stated reason.
AUTHORIZED_EXTRA=$(cat <<'EOF'
scripts/gen-facts.mjs
data/cem-facts.json
EOF
)
# scripts/gen-facts.mjs — regenerates data/cem-facts.json from the WORKSPACE
#   producer (packages/elm-cem) against elm-m3e's own config, mirroring
#   packages/cem-figma-connect/scripts/gen-facts.mjs. The source repo has no
#   workspace producer to read from — it cloned matraic/m3e and built its own
#   manifest instead (scripts/extract.mjs's old .cache/m3e path).
# data/cem-facts.json — the committed copy of elm-cem's facts bundle Face B
#   that scripts/extract.mjs now reads instead of cloning matraic/m3e and
#   parsing its own Custom Elements Manifest. Policed for freshness by
#   tools/check-bundle-provenance-m3e-okf.mjs, the same way
#   packages/cem-figma-connect/profiles/m3-kit/facts/cem-facts.json is.


# M6 deep-clean authorized deletions. Each path's rule and reasoning is in
# docs/facts-bundle/m6-deep-clean.md; they are superseded plans, handoff notes and
# per-repo .claude-memory files that described pre-migration states. Listed
# explicitly rather than by prefix so a NEW unexplained deletion still goes red.
AUTHORIZED_ABSENT_M6=$(cat <<'M6EOF'
.claude-memory/m3e-disclosure-hook-design.md
M6EOF
)

require_snapshot_or_skip "copy-fidelity-m3e-okf" "$SOURCE_M3E_OKF" "SOURCE_M3E_OKF"

if [ ! -d "$REPO_ROOT/$PKG_REL" ]; then
    echo "ERROR: workspace copy not found at $REPO_ROOT/$PKG_REL" >&2
    exit 1
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

git -C "$SOURCE_M3E_OKF" ls-files | sort > "$tmp/source.txt"

# Workspace side: tracked files + untracked-but-not-ignored files, both relative
# to packages/m3e-okf. `--others --exclude-standard` is exactly "files git would
# add", i.e. it honours every .gitignore in play (including the root's
# `.cache/` and `node_modules/` entries).
#   A path counts as present only if git knows about it AND it exists on disk —
#   `git ls-files` alone reads the INDEX, so a file deleted from the working tree
#   would still look present and this gate would miss it.
{
    git -C "$REPO_ROOT" ls-files "$PKG_REL"
    git -C "$REPO_ROOT" ls-files --others --exclude-standard "$PKG_REL"
} | sort -u | while IFS= read -r p; do
    [ -e "$REPO_ROOT/$p" ] && printf '%s\n' "${p#"$PKG_REL/"}"
done | sort -u > "$tmp/workspace.txt"

printf '%s\n' "$AUTHORIZED_ABSENT" | { grep -vE '^\s*$' || true; } | sort > "$tmp/authorized.txt"

comm -23 "$tmp/source.txt" "$tmp/workspace.txt" | sort > "$tmp/missing-raw.txt"
printf '%s\n' "$AUTHORIZED_ABSENT_M6" | grep -vE '^\s*$' | sort > "$tmp/authorized-m6.txt"
comm -23 "$tmp/missing-raw.txt" "$tmp/authorized.txt" | sort > "$tmp/missing-1.txt"
comm -23 "$tmp/missing-1.txt" "$tmp/authorized-m6.txt" > "$tmp/missing.txt"
printf '%s\n' "$AUTHORIZED_EXTRA" | { grep -vE '^\s*$' || true; } | sort > "$tmp/authorized-extra.txt"
comm -13 "$tmp/source.txt" "$tmp/workspace.txt" | sort > "$tmp/extra-raw.txt"
comm -23 "$tmp/extra-raw.txt" "$tmp/authorized-extra.txt" > "$tmp/extra.txt"

missing_count=$(wc -l < "$tmp/missing.txt" | tr -d ' ')
extra_count=$(wc -l < "$tmp/extra.txt" | tr -d ' ')
source_count=$(wc -l < "$tmp/source.txt" | tr -d ' ')
workspace_count=$(wc -l < "$tmp/workspace.txt" | tr -d ' ')

echo "copy-fidelity: source tracked=$source_count  workspace tracked+addable=$workspace_count"
echo "copy-fidelity: authorized-absent=$(wc -l < "$tmp/authorized.txt" | tr -d ' ')  authorized-extra=$(wc -l < "$tmp/authorized-extra.txt" | tr -d ' ')"

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
