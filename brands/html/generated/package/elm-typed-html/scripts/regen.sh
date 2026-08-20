#!/usr/bin/env bash
# regen.sh — regenerate src/ from manifest/native.cem.json + config/config.json
# Run from the elm-typed-html repo root.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ELM_CEM_BIN="${ELM_CEM_BIN:-../../../../../pipeline/elm-cem/bin/elm-cem.js}"
ELM_FORMAT="${ELM_FORMAT:-$REPO_ROOT/node_modules/.bin/elm-format}"

echo "Regenerating src/ from manifest + config..."
node "$ELM_CEM_BIN" \
  "--flags-from=$REPO_ROOT/manifest/native.cem.json" \
  "--config-from=$REPO_ROOT/../../../inputs/config.json" \
  "--output=$REPO_ROOT/src"

echo "Running elm-format..."
"$ELM_FORMAT" "$REPO_ROOT/src" --yes

echo "Done! src/ regenerated."
