#!/usr/bin/env bash
# regen.sh — regenerate src/ from the vendored Shoelace CEM + config.
#
# Inputs live in brands/shoelace/inputs/cem/ (custom-elements.json + config/),
# NOT inside this package — the brand's only authored artifacts are that CEM
# snapshot and the tiny phantom config; everything under src/ is emitted here.
#
# Run via `pnpm --filter elm-shoelace run gen` so elm-tooling's elm 0.19.1 is on
# PATH for elm-cem's internal codegen step.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ELM_CEM_BIN="${ELM_CEM_BIN:-$ROOT/../../../../../pipeline/elm-cem/bin/elm-cem.js}"
ELM_FORMAT="${ELM_FORMAT:-$ROOT/node_modules/.bin/elm-format}"
INPUTS="$ROOT/../../../inputs/cem"

echo "Regenerating src/ from CEM + config..."
node "$ELM_CEM_BIN" \
  "--flags-from=$INPUTS/custom-elements.json" \
  "--config-from=$INPUTS/config/slots.json" \
  "--output=$ROOT/src"

echo "Running elm-format..."
"$ELM_FORMAT" "$ROOT/src" --yes

echo "Done! src/ regenerated."
