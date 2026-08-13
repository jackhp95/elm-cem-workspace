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
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_ELM_M3E="${SOURCE_ELM_M3E:-/Users/jhp/code/jackhp95/elm-m3e}"
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
EOF
)
# docs/scripts/fix-native-bins.mjs — pnpm 10 wraps every bin entry in an
#   `exec node <path>` shell shim. That is correct for JS bins and BROKEN for the
#   native Mach-O executables this toolchain depends on (elm, elm-format,
#   lamdera). docs/ was an npm-managed subproject with its own lockfile before
#   the migration, so this only became necessary once the root pnpm workspace
#   took over installing it. The script restores direct symlinks post-install.

if [ ! -d "$SOURCE_ELM_M3E" ]; then
    echo "ERROR: source elm-m3e not found at $SOURCE_ELM_M3E" >&2
    exit 1
fi
if [ ! -d "$REPO_ROOT/$PKG_REL" ]; then
    echo "ERROR: workspace copy not found at $REPO_ROOT/$PKG_REL" >&2
    exit 1
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

git -C "$SOURCE_ELM_M3E" ls-files | sort > "$tmp/source.txt"

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
done | sort -u > "$tmp/workspace.txt"

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
