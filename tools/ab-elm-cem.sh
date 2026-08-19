#!/usr/bin/env bash
# A/B harness: run the pristine elm-cem generator and the workspace elm-cem
# generator against elm-m3e's exact config, and diff the emitted trees.
#
# Usage: bash tools/ab-elm-cem.sh
# Env:
#   PRISTINE_ELM_CEM   path to the pristine (pre-migration) elm-cem checkout
#                       (default: $SNAPSHOT_ROOT/elm-cem)
#   SNAPSHOT_ROOT       parent directory of the inert pre-migration snapshot
#                       checkouts (default: the workspace's parent directory)
#   ELM_M3E             elm-m3e config/checkout to generate against
#                       (default: the in-workspace packages/elm-m3e)
#   REQUIRE_SNAPSHOT_GATES=1  make a missing PRISTINE_ELM_CEM a hard failure
#                       instead of a SKIP
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_ROOT/tools/lib/snapshot-gate.sh"

SNAPSHOT_ROOT="${SNAPSHOT_ROOT:-$REPO_ROOT/..}"
# elm-cem's reference advanced to its latest main at the 2026-08-14 re-integration
# (D-041). tools/fetch-snapshots.mjs materializes the pinned SHA into
# .cache/snapshots/elm-cem; the frozen sibling under SNAPSHOT_ROOT is no longer it.
PRISTINE_ELM_CEM="${PRISTINE_ELM_CEM:-$REPO_ROOT/.cache/snapshots/elm-cem}"
WORKSPACE_ELM_CEM="$REPO_ROOT/core/elm-cem"
ELM_M3E="${ELM_M3E:-$REPO_ROOT/brands/m3e/outputs/elm-m3e}"

require_snapshot_or_skip "ab-elm-cem" "$PRISTINE_ELM_CEM" "PRISTINE_ELM_CEM"

if [ ! -d "$WORKSPACE_ELM_CEM" ]; then
    echo "ERROR: workspace elm-cem not found at $WORKSPACE_ELM_CEM" >&2
    exit 1
fi
if [ ! -d "$ELM_M3E" ]; then
    echo "ERROR: elm-m3e not found at $ELM_M3E" >&2
    exit 1
fi

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

OUT_PRISTINE="$WORK_DIR/out-pristine"
OUT_WORKSPACE="$WORK_DIR/out-workspace"
mkdir -p "$OUT_PRISTINE" "$OUT_WORKSPACE"

run_generator() {
    local generator_dir="$1"
    local out_dir="$2"
    local label="$3"

    echo "=== running $label generator ($generator_dir) ==="
    (
        cd "$ELM_M3E"
        PATH="$ELM_M3E/node_modules/.bin:$PATH" node "$generator_dir/bin/elm-cem.js" \
            --flags-from=docs/node_modules/@m3e/web/dist/custom-elements.json \
            --config-from=config/slots.json \
            --config-from=config/native-mdn.json \
            --config-from=config/examples.generated.json \
            --output="$out_dir"
    )
}

if ! run_generator "$PRISTINE_ELM_CEM" "$OUT_PRISTINE" "pristine"; then
    echo "ERROR: pristine generator run failed" >&2
    exit 1
fi

if ! run_generator "$WORKSPACE_ELM_CEM" "$OUT_WORKSPACE" "workspace"; then
    echo "ERROR: workspace generator run failed" >&2
    exit 1
fi

count_files() {
    find "$1" -type f | wc -l | tr -d ' '
}

PRISTINE_COUNT="$(count_files "$OUT_PRISTINE")"
WORKSPACE_COUNT="$(count_files "$OUT_WORKSPACE")"

if [ "$PRISTINE_COUNT" -eq 0 ]; then
    echo "ERROR: pristine output tree is empty" >&2
    exit 1
fi
if [ "$WORKSPACE_COUNT" -eq 0 ]; then
    echo "ERROR: workspace output tree is empty" >&2
    exit 1
fi

echo "pristine file count:  $PRISTINE_COUNT"
echo "workspace file count: $WORKSPACE_COUNT"

if ! DIFF_OUTPUT="$(diff -r "$OUT_PRISTINE" "$OUT_WORKSPACE")"; then
    echo "ERROR: pristine and workspace generator outputs differ:" >&2
    echo "$DIFF_OUTPUT" >&2
    exit 1
fi

echo "A/B PASS: $PRISTINE_COUNT files, byte-identical output"
