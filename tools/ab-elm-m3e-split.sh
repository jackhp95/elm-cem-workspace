#!/usr/bin/env bash
# A/B harness: run the pristine elm-cem `split` command and the workspace
# elm-cem `split` command against the SAME generated elm-m3e src/ tree and the
# SAME packages.json, and diff the emitted package mirror trees.
#
# This exercises packages/elm-cem/bin/split.js (the facet-family splitter),
# which is what produces the elm-m3e / elm-m3e-components / elm-m3e-builder
# package trees. The three-way core/components/builder split is retained as-is
# — this harness only proves the SPLIT STEP is unchanged after the elm-m3e
# migration, the same way tools/ab-elm-cem.sh proves the GENERATE step is
# unchanged.
#
# The packages.json bucket rules below partition the CURRENT generator's flat
# module set (a fresh run of `elm-cem` emits `M3e.<Component>` directly, not
# the older `M3e.Component.*` / `M3e.Build.*` per-component naming baked into
# elm-m3e's committed elm-m3e-components / elm-m3e-builder trees — those are
# pre-existing stale output, deliberately left alone per M2.a). The buckets
# here follow the real import graph of the fresh output: every per-component
# module (plus M3e.Review.Facts) imports M3e.Build.Internal, which itself
# imports only the shared core modules — so the DAG is
# components -> builder -> core.
#
# Usage: bash tools/ab-elm-m3e-split.sh
# Env:
#   PRISTINE_ELM_CEM  path to the pristine (pre-migration) elm-cem checkout
#                     (default: /Users/jhp/code/jackhp95/elm-cem)
#   ELM_M3E           elm-m3e config/checkout to generate the src/ tree from
#                     (default: the in-workspace packages/elm-m3e)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PRISTINE_ELM_CEM="${PRISTINE_ELM_CEM:-/Users/jhp/code/jackhp95/elm-cem}"
WORKSPACE_ELM_CEM="$REPO_ROOT/packages/elm-cem"
ELM_M3E="${ELM_M3E:-$REPO_ROOT/packages/elm-m3e}"

if [ ! -d "$PRISTINE_ELM_CEM" ]; then
    echo "ERROR: pristine elm-cem not found at $PRISTINE_ELM_CEM" >&2
    exit 1
fi
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

# ── 1. generate ONE merged src/ tree (the shared input to both split runs) ──
GEN_SRC="$WORK_DIR/gen-src"
mkdir -p "$GEN_SRC"

echo "=== generating merged src/ tree (workspace elm-cem, elm-m3e config) ==="
(
    cd "$ELM_M3E"
    PATH="$ELM_M3E/node_modules/.bin:$PATH" node "$WORKSPACE_ELM_CEM/bin/elm-cem.js" \
        --flags-from=docs/node_modules/@m3e/web/dist/custom-elements.json \
        --config-from=config/slots.json \
        --config-from=config/native-mdn.json \
        --config-from=config/examples.generated.json \
        --output="$GEN_SRC"
)

GEN_COUNT="$(find "$GEN_SRC" -name '*.elm' | wc -l | tr -d ' ')"
if [ "$GEN_COUNT" -eq 0 ]; then
    echo "ERROR: generated src/ tree is empty, nothing to split" >&2
    exit 1
fi
echo "generated src/ tree: $GEN_COUNT .elm files"

# ── 2. the packages.json bucket config (core / components / builder) ───────
PACKAGES_JSON="$WORK_DIR/packages.json"
cat > "$PACKAGES_JSON" <<'JSON'
{
  "family": "elm-m3e",
  "devRepo": "jackhp95/elm-m3e",
  "licenseText": "BSD-3-Clause",
  "packages": [
    {
      "name": "jackhp95/elm-m3e",
      "summary": "M3e.* brand primitives (shared vocabulary + escape hatches)",
      "version": "1.0.0",
      "elmVersion": "0.19.0 <= v < 0.20.0",
      "deps": {
        "jackhp95/elm-html-intermediate-representation": "1.0.0 <= v < 2.0.0",
        "jackhp95/elm-cem-facts": "1.0.0 <= v < 2.0.0"
      },
      "buckets": [
        { "exact": "M3e.Action" },
        { "exact": "M3e.Attributes" },
        { "exact": "M3e.Coerce" },
        { "exact": "M3e.Events" },
        { "exact": "M3e.Html" },
        { "exact": "M3e.Kind" },
        { "exact": "M3e.Unsafe" },
        { "exact": "M3e.Unsafe.Attributes" },
        { "exact": "M3e.Values" }
      ]
    },
    {
      "name": "jackhp95/elm-m3e-builder",
      "summary": "M3e.Build annotation-skin shared by every component module",
      "version": "1.0.0",
      "elmVersion": "0.19.0 <= v < 0.20.0",
      "deps": {
        "jackhp95/elm-html-intermediate-representation": "1.0.0 <= v < 2.0.0",
        "jackhp95/elm-m3e": "1.0.0 <= v < 2.0.0"
      },
      "buckets": [
        { "exact": "M3e.Build" },
        { "prefix": "M3e.Build." }
      ]
    },
    {
      "name": "jackhp95/elm-m3e-components",
      "summary": "M3e per-component API + M3e.Review.Facts",
      "version": "1.0.0",
      "elmVersion": "0.19.0 <= v < 0.20.0",
      "deps": {
        "jackhp95/elm-html-intermediate-representation": "1.0.0 <= v < 2.0.0",
        "jackhp95/elm-cem-facts": "1.0.0 <= v < 2.0.0",
        "jackhp95/elm-m3e": "1.0.0 <= v < 2.0.0",
        "jackhp95/elm-m3e-builder": "1.0.0 <= v < 2.0.0"
      },
      "buckets": [
        { "exact": "M3e" },
        { "prefix": "M3e." }
      ]
    }
  ]
}
JSON

OUT_PRISTINE="$WORK_DIR/out-pristine"
OUT_WORKSPACE="$WORK_DIR/out-workspace"

run_split() {
    local generator_dir="$1"
    local out_dir="$2"
    local label="$3"

    echo "=== running $label split ($generator_dir) ==="
    node "$generator_dir/bin/elm-cem.js" split \
        --packages="$PACKAGES_JSON" \
        --src="$GEN_SRC" \
        --out="$out_dir"
}

if ! run_split "$PRISTINE_ELM_CEM" "$OUT_PRISTINE" "pristine"; then
    echo "ERROR: pristine split run failed" >&2
    exit 1
fi

if ! run_split "$WORKSPACE_ELM_CEM" "$OUT_WORKSPACE" "workspace"; then
    echo "ERROR: workspace split run failed" >&2
    exit 1
fi

count_files() {
    find "$1" -type f | wc -l | tr -d ' '
}

PRISTINE_COUNT="$(count_files "$OUT_PRISTINE")"
WORKSPACE_COUNT="$(count_files "$OUT_WORKSPACE")"

if [ "$PRISTINE_COUNT" -eq 0 ]; then
    echo "ERROR: pristine split output tree is empty" >&2
    exit 1
fi
if [ "$WORKSPACE_COUNT" -eq 0 ]; then
    echo "ERROR: workspace split output tree is empty" >&2
    exit 1
fi

echo "pristine split file count:  $PRISTINE_COUNT"
echo "workspace split file count: $WORKSPACE_COUNT"

if ! DIFF_OUTPUT="$(diff -r "$OUT_PRISTINE" "$OUT_WORKSPACE")"; then
    echo "ERROR: pristine and workspace split outputs differ:" >&2
    echo "$DIFF_OUTPUT" >&2
    exit 1
fi

echo "A/B PASS: $PRISTINE_COUNT files, byte-identical split output"
