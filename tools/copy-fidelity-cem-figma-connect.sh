#!/usr/bin/env bash
# Copy-fidelity gate for the cem-figma-connect migration (M3.a).
#
# cem-figma-connect was flat-copied from its own repo (commit 6294992) into
# packages/cem-figma-connect, then rewired to read elm-cem's canonical facts
# bundle instead of re-parsing the raw CEM / re-measuring elm-m3e's generated
# Elm. This gate proves the COPY is faithful modulo an explicit, reasoned
# allowlist of the migration's own authorized deletions/additions — not that
# the rewiring is correct (that's docs/facts-bundle/m3a-generated-diff.md's
# job).
#
# COMPARISON SEMANTICS (same subtlety as tools/copy-fidelity-elm-m3e.sh):
#   Both sides are compared as GIT-TRACKED SETS, not as directory listings.
#   The workspace side = files git tracks under packages/cem-figma-connect,
#   PLUS untracked files git would track (i.e. not covered by .gitignore).
#   Locally-generated build output (node_modules/, render-cache/, profiles/*/
#   captures/, ...) is gitignored and therefore correctly invisible here —
#   comparing raw directory contents would flag legitimate build artifacts.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_CFC="${SOURCE_CFC:-/Users/jhp/code/jackhp95/cem-figma-connect}"
PKG_REL="packages/cem-figma-connect"

# Source-tracked paths DELIBERATELY absent from the workspace copy.
AUTHORIZED_ABSENT=$(cat <<'EOF'
pnpm-lock.yaml
pnpm-workspace.yaml
profiles/m3-kit/elm-facts.json
profiles/m3-kit/emitters/elm-facts.build.mjs
test/elm-facts-build.test.mjs
test/fixtures/elm-facts.button.json
test/fixtures/elm-facts.progress.json
EOF
)
# pnpm-lock.yaml / pnpm-workspace.yaml — per-repo lockfile + nested pnpm
#   workspace, superseded by the root workspace's single lockfile and single
#   pnpm-workspace.yaml (same treatment as elm-m3e).
# profiles/m3-kit/elm-facts.json / emitters/elm-facts.build.mjs — Task 2's
#   authorized deletions: the ~995-line re-measurement script (and its
#   committed, provably-wrong output — fictional per-facet module paths, a
#   backwards `finalizer`) is superseded by reading elm-cem's own Face C
#   (profiles/m3-kit/facts/elm-api-facts.json) directly.
# test/elm-facts-build.test.mjs — the dedicated unit-test suite for the
#   deleted build script's internal parser (parseFacts/parseSetterSignature/
#   measureGroupAliases, exercised only via synthetic Facts.elm-line
#   fixtures never other test's target). Nothing survives to test once its
#   sole subject is gone; elm-cem's own test suite covers Face C's
#   correctness now. Not a "test deleted to green a gate" — it is the test
#   OF the deleted module, with no fixture or replacement to repoint at.
# test/fixtures/elm-facts.button.json / elm-facts.progress.json — hermetic
#   drift-detection pins for the OLD bundle's per-component slices. There is
#   nothing left to hermetically pin against once the OLD bundle no longer
#   exists — Face C IS the committed input now, not a build script's output
#   a test must catch drifting from it.
AUTHORIZED_ABSENT_DIR_PREFIXES=$(cat <<'EOF'
test/fixtures/m3e-web-2.7.0/
EOF
)
# test/fixtures/m3e-web-2.7.0/ — the vendored raw-CEM + `.d.ts` copy Task 2's
#   src/ingest/cem.mjs used to parse directly (and profiles/m3-kit/profile.json
#   pointed `cem.manifestPath`/`cem.dtsDir` at). Superseded by
#   profiles/m3-kit/facts/cem-facts.json (elm-cem's Face B for the SAME
#   @m3e/web version family, now 2.7.3) — cem.mjs no longer parses a raw
#   manifest or scans a `.d.ts` tree at all (dts-inline.mjs's role is gone
#   from that pipeline; the module itself stays, per the "never delete a
#   tracked source file" rule, and is still unit-tested against small inline
#   fixtures in test/cem-ingest.test.mjs).
#
# DELIBERATELY NOT in this list — test/fixtures/m3e-web-2.5.14/ and
# test/fixtures/tailwind-m3e-web-0.1.0/ were BOTH on the task's authorized-
# deletion list, and both are still present here. Neither deletion survived
# investigation:
#   - m3e-web-2.5.14 is read directly (as raw manifest TEXT, not via
#     loadCem/dts-inline) by src/tokens/derive.mjs's DEFAULT_PATHS
#     .customElementsPath — a design-token CSS `var(--md-sys-*, fallback)`
#     regex-scraper wholly outside the CEM-ingestion pipeline this part
#     rewires. matcher.test.mjs/correspond.test.mjs/gap-report.test.mjs (and
#     the toy/evil/b4 synthetic profile fixtures) WERE repointed at a Face-B
#     conversion of this same fixture (test/fixtures/cem-facts.m3e-web-2.5.14.json,
#     built with elm-cem's own bin/facts-bundle.js against the untouched
#     vendored manifest — verified byte-for-byte reproducing the old 121
#     components / 500 attributes / 2 duplicates), but derive.mjs's raw-text
#     regex needs the ACTUAL manifest bytes, not a re-serialized JSON
#     projection — repointing it produced spurious matches (e.g. an
#     unresolved `${CornerValue.extraExtraLarge}` template-literal fragment
#     masquerading as a real fallback color), a REGRESSION, not a
#     correction. Keeping the vendored tree is the correct call here.
#   - tailwind-m3e-web-0.1.0 is consumed the same way (raw CSS text) by
#     src/tokens/{resolve-palette,audit}.mjs, wholly unrelated to elm-cem's
#     facts bundle. packages/elm-m3e/docs/vendor/tailwind-m3e-web is a
#     same-named vendor copy but pinned to a DIFFERENT upstream commit
#     (verified: sys/color.css differs — `:root` vs `html`, on-container
#     tone 10 vs 30) — repointing to it would silently change computed
#     color values, and rewiring tailwind-m3e-web is explicitly a later part
#     per the task brief. Deleting it breaks `pnpm test` with no in-scope
#     replacement, so it stays.

# Files present in the workspace copy that are NOT in the source repo —
# deliberate M3.a additions, each with a stated reason.
AUTHORIZED_EXTRA=$(cat <<'EOF'
profiles/m3-kit/facts/cem-facts.json
profiles/m3-kit/facts/elm-api-facts.json
test/fixtures/cem-facts.m3e-web-2.5.14.json
EOF
)
# profiles/m3-kit/facts/{cem-facts,elm-api-facts}.json — the real elm-cem
#   facts bundle (Face B + Face C) this profile now reads, generated via
#   `elm-cem --facts-bundle=<dir>` against elm-m3e's own @m3e/web 2.7.3
#   manifest (130 components, 583 attributes — matches the task brief's
#   measured figures exactly).
# test/fixtures/cem-facts.m3e-web-2.5.14.json — the Face-B conversion of the
#   (still-present) vendored 2.5.14 fixture, described above.

if [ ! -d "$SOURCE_CFC" ]; then
    echo "ERROR: source cem-figma-connect not found at $SOURCE_CFC" >&2
    exit 1
fi
if [ ! -d "$REPO_ROOT/$PKG_REL" ]; then
    echo "ERROR: workspace copy not found at $REPO_ROOT/$PKG_REL" >&2
    exit 1
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

git -C "$SOURCE_CFC" ls-files | sort > "$tmp/source.txt"

# Workspace side: tracked files + untracked-but-not-ignored files, both
# relative to packages/cem-figma-connect.
#   A path counts as present only if git knows about it AND it exists on disk.
{
    git -C "$REPO_ROOT" ls-files "$PKG_REL"
    git -C "$REPO_ROOT" ls-files --others --exclude-standard "$PKG_REL"
} | sort -u | while IFS= read -r p; do
    [ -e "$REPO_ROOT/$p" ] && printf '%s\n' "${p#"$PKG_REL/"}"
done | sort -u > "$tmp/workspace.txt"

printf '%s\n' "$AUTHORIZED_ABSENT" | grep -vE '^\s*$' | sort > "$tmp/authorized.txt"

comm -23 "$tmp/source.txt" "$tmp/workspace.txt" | sort > "$tmp/missing-raw.txt"
comm -23 "$tmp/missing-raw.txt" "$tmp/authorized.txt" > "$tmp/missing-after-exact.txt"

# Directory-prefix allowlist (the 459-file m3e-web-2.7.0/ tree) — filtered
# line-by-line rather than via comm, since it's a prefix match, not an exact one.
: > "$tmp/missing.txt"
while IFS= read -r p; do
    [ -z "$p" ] && continue
    keep=1
    while IFS= read -r prefix; do
        [ -z "$prefix" ] && continue
        case "$p" in
            "$prefix"*) keep=0 ;;
        esac
    done < <(printf '%s\n' "$AUTHORIZED_ABSENT_DIR_PREFIXES" | grep -vE '^\s*$')
    [ "$keep" -eq 1 ] && printf '%s\n' "$p" >> "$tmp/missing.txt"
done < "$tmp/missing-after-exact.txt"

printf '%s\n' "$AUTHORIZED_EXTRA" | grep -vE '^\s*$' | sort > "$tmp/authorized-extra.txt"
comm -13 "$tmp/source.txt" "$tmp/workspace.txt" | sort > "$tmp/extra-raw.txt"
comm -23 "$tmp/extra-raw.txt" "$tmp/authorized-extra.txt" > "$tmp/extra.txt"

missing_count=$(wc -l < "$tmp/missing.txt" | tr -d ' ')
extra_count=$(wc -l < "$tmp/extra.txt" | tr -d ' ')
source_count=$(wc -l < "$tmp/source.txt" | tr -d ' ')
workspace_count=$(wc -l < "$tmp/workspace.txt" | tr -d ' ')
authorized_dir_count=$(comm -23 "$tmp/missing-after-exact.txt" "$tmp/missing.txt" | wc -l | tr -d ' ')

echo "copy-fidelity: source tracked=$source_count  workspace tracked+addable=$workspace_count"
echo "copy-fidelity: authorized-absent(exact)=$(wc -l < "$tmp/authorized.txt" | tr -d ' ')  authorized-absent(m3e-web-2.7.0/ tree)=$authorized_dir_count"
echo "copy-fidelity: authorized-extra=$(wc -l < "$tmp/authorized-extra.txt" | tr -d ' ')"

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
    echo "(If one of these is a deliberate M3.a addition, add it to an explicit" >&2
    echo " allowlist in this script with a reason — do not silence this gate wholesale.)" >&2
    status=1
fi

if [ "$status" -ne 0 ]; then
    echo "" >&2
    echo "COPY-FIDELITY RED — $missing_count missing, $extra_count extra" >&2
    exit 1
fi

echo "COPY-FIDELITY GREEN — every tracked source file present or authorized-absent, no unauthorized extra file"
