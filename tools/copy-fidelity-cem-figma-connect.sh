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
#
# Env:
#   SOURCE_CFC          path to the source cem-figma-connect checkout
#                       (default: $SNAPSHOT_ROOT/cem-figma-connect)
#   SNAPSHOT_ROOT       parent directory of the inert pre-migration snapshot
#                       checkouts (default: the workspace's parent directory)
#   REQUIRE_SNAPSHOT_GATES=1  make a missing SOURCE_CFC a hard failure
#                       instead of a SKIP
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_ROOT/tools/lib/snapshot-gate.sh"

SNAPSHOT_ROOT="${SNAPSHOT_ROOT:-$REPO_ROOT/..}"
SOURCE_CFC="${SOURCE_CFC:-$SNAPSHOT_ROOT/cem-figma-connect}"
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
test/fixtures/tailwind-m3e-web-0.1.0/
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
# test/fixtures/tailwind-m3e-web-0.1.0/ — (M5) a vendored, commit-pinned copy
#   consumed as raw CSS text by src/tokens/{resolve-palette,derive,audit}.mjs,
#   wholly unrelated to elm-cem's facts bundle. Repointed at the real
#   co-located package (packages/tailwind-m3e-web, now a sibling under
#   packages/) and deleted — the two packages live in the same workspace and
#   move together now, so there is nothing left to pin against. Verified the
#   repoint changes nothing spurious: seed.css/ref/_tone-table.css/
#   ref/palette.css are byte-identical to the old fixture (resolve-palette's
#   computed-palette fixture regenerates with only its provenance header
#   changing), and the two real content changes it surfaces — sys/typescale.css's
#   display-large-tracking sign flip and sys/color.css's on-container tone —
#   are exactly the bugs audit.mjs's own "REQUIRED CODE CHANGES" report was
#   built to catch; the first is now fixed upstream (test + report updated to
#   match), the second is unchanged (resolve-palette.mjs computes its
#   "should-be" tone from ref/palette.css, not sys/color.css, so that finding
#   is untouched by the repoint). Along the way, audit.mjs's REM_DECL_RE
#   regex was fixed to accept a leading `-` — it had never been exercised
#   against a negative CSS value before.
#
# DELIBERATELY NOT in this list — test/fixtures/m3e-web-2.5.14/ was on the
# task's authorized-deletion list, and is still present here. The deletion
# did not survive investigation:
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

# Files present in the workspace copy that are NOT in the source repo —
# deliberate M3.a additions, each with a stated reason.
AUTHORIZED_EXTRA=$(cat <<'EOF'
profiles/m3-kit/facts/cem-facts.json
profiles/m3-kit/facts/elm-api-facts.json
test/fixtures/cem-facts.m3e-web-2.5.14.json
scripts/gen-facts.mjs
EOF
)
# profiles/m3-kit/facts/{cem-facts,elm-api-facts}.json — the real elm-cem
#   facts bundle (Face B + Face C) this profile now reads, generated via
#   `elm-cem --facts-bundle=<dir>` against elm-m3e's own @m3e/web 2.7.3
#   manifest (130 components, 583 attributes — matches the task brief's
#   measured figures exactly).
#   (M3.a round 2 / defect 2): these two are git-tracked (not merely
#   untracked-but-visible), reproducible via `pnpm --filter cem-figma-connect
#   run gen:facts` (scripts/gen-facts.mjs, which calls the workspace producer
#   packages/elm-cem against elm-m3e's own config), and policed by
#   tools/check-bundle-provenance.mjs (regenerates into a temp dir and diffs
#   byte-for-byte against the committed copy — part of gate-all). They stay
#   on THIS allowlist because the source repo (SOURCE_CFC) has no
#   profiles/m3-kit/facts/ directory at all — that comparison is orthogonal
#   to whether the workspace copy itself is tracked, current, or gated; the
#   provenance check is what actually proves the bundle isn't stale/loose
#   state, not this allowlist entry.
# test/fixtures/cem-facts.m3e-web-2.5.14.json — the Face-B conversion of the
#   (still-present) vendored 2.5.14 fixture, described above.
# scripts/gen-facts.mjs — (M3.a round 2 / defect 2) the ONLY writer of the
#   facts bundle above: regenerates profiles/m3-kit/facts/{cem-facts,
#   elm-api-facts}.json from the workspace producer (packages/elm-cem)
#   against elm-m3e's own config, via `pnpm --filter cem-figma-connect run
#   gen:facts`. tools/check-bundle-provenance.mjs calls the same generation
#   logic to police drift.


# M6 deep-clean authorized deletions. Each path's rule and reasoning is in
# docs/facts-bundle/m6-deep-clean.md; they are superseded plans, handoff notes and
# per-repo .claude-memory files that described pre-migration states. Listed
# explicitly rather than by prefix so a NEW unexplained deletion still goes red.
AUTHORIZED_ABSENT_M6=$(cat <<'M6EOF'
.claude-memory/cem-figma-connect-state.md
plans/2026-07-15-comprehensive-figma-capture-plan.md
plans/2026-07-18-qualifier-aware-matcher-plan.md
plans/2026-07-18-representative-example-emission-plan.md
plans/2026-07-19-append-sets-mechanism-design.md
plans/2026-07-19-appendsets-bank-execution.md
plans/2026-07-19-bridge-coverage-gap.md
plans/2026-07-19-icon-emit-design.md
plans/2026-07-19-manual-correspondence-tab-design.md
plans/2026-07-19-progress-set-attrs-design.md
plans/2026-07-20-elm-emit-gap-closure.md
plans/AUTONOMOUS-SESSION-FRICTIONS.md
plans/coverage-remediation-execution-prompt.md
plans/gate-content-remediation.md
plans/gate-remediation-round2.md
plans/gate-tooling/overrides-snapshot.json
plans/gate-tooling/render-all.mjs
plans/gate-tooling/review-launch.mjs
plans/okf-friction-issues-DRAFT.md
plans/okf-self-learning-loop-DESIGN.md
plans/retarget-feedback-round3.md
research/spikes/01-publish-gate/M3eButton.figma.ts
research/spikes/01-publish-gate/figma.config.json
research/spikes/01-publish-gate/package.json
research/spikes/01-publish-gate/pnpm-lock.yaml
research/spikes/02-elm-label/M3eButton.figma.ts
research/spikes/02-elm-label/figma.config.json
research/spikes/02-elm-label/package.json
research/spikes/07-render-harness/NOTES.md
research/spikes/07-render-harness/assets/m3e-all.bundle.js
research/spikes/07-render-harness/assets/roboto-latin-400-normal.woff2
research/spikes/07-render-harness/assets/roboto-latin-500-normal.woff2
research/spikes/07-render-harness/assets/roboto-latin-700-normal.woff2
research/spikes/07-render-harness/btn-57994-2242.png
research/spikes/07-render-harness/btn-57994-2262.png
research/spikes/07-render-harness/btn-57994-2282.png
research/spikes/07-render-harness/btn-57994-2302.png
research/spikes/07-render-harness/btn-57994-2322.png
research/spikes/07-render-harness/entry.js
research/spikes/07-render-harness/figma-button-filled-medium.png
research/spikes/07-render-harness/harness.html
research/spikes/07-render-harness/package.json
research/spikes/07-render-harness/playwright.config.js
research/spikes/07-render-harness/pnpm-lock.yaml
research/spikes/07-render-harness/pnpm-workspace.yaml
research/spikes/07-render-harness/shots/button-filled-run1.png
research/spikes/07-render-harness/shots/button-filled-run2.png
research/spikes/07-render-harness/shots/button-filled-run3.png
research/spikes/07-render-harness/shots/switch-checked-run1.png
research/spikes/07-render-harness/shots/switch-checked-run2.png
research/spikes/07-render-harness/shots/switch-checked-run3.png
research/spikes/07-render-harness/tests/render.spec.js
research/spikes/07-render-harness/tests/static-server.js
research/spikes/inline-coverage.js
M6EOF
)

require_snapshot_or_skip "copy-fidelity-cem-figma-connect" "$SOURCE_CFC" "SOURCE_CFC"

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
printf '%s\n' "$AUTHORIZED_ABSENT_M6" | grep -vE '^\s*$' | sort > "$tmp/authorized-m6.txt"
comm -23 "$tmp/missing-raw.txt" "$tmp/authorized.txt" | sort > "$tmp/missing-after-base.txt"
comm -23 "$tmp/missing-after-base.txt" "$tmp/authorized-m6.txt" > "$tmp/missing-after-exact.txt"

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
