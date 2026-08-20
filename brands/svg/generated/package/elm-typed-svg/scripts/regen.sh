#!/usr/bin/env bash
# regen.sh — regenerate src/ from manifest/svg.cem.json + ../../../inputs/config.json
# Run from anywhere; paths resolve against this package root.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ELM_CEM_BIN="${ELM_CEM_BIN:-$REPO_ROOT/../../../../../pipeline/elm-cem/bin/elm-cem.js}"
ELM_FORMAT="${ELM_FORMAT:-$REPO_ROOT/node_modules/.bin/elm-format}"

echo "Regenerating src/ from manifest + config..."
node "$ELM_CEM_BIN" \
  "--flags-from=$REPO_ROOT/manifest/svg.cem.json" \
  "--config-from=$REPO_ROOT/../../../inputs/config.json" \
  "--output=$REPO_ROOT/src"

echo "Running elm-format..."
"$ELM_FORMAT" "$REPO_ROOT/src" --yes

echo "Done! src/ regenerated."
