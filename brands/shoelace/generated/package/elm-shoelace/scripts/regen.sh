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

# Re-emit the five split siblings (core/elements/components/build/facts) from the
# freshly regenerated flat src/. The monolith is only the generation-staging root;
# the published product is the siblings (see PACKAGES-MOVED.md). Mirrors m3e's
# gen:src → split → format:{families,build} chain.
if [ -f "$ROOT/packages.json" ]; then
  echo "Re-splitting into sibling packages (packages.json)..."
  node "$ELM_CEM_BIN" split --packages="$ROOT/packages.json" --src="$ROOT/src" --out="$ROOT/.."
  echo "Formatting sibling src/ trees..."
  for sib in elm-shoelace-core elm-shoelace-elements elm-shoelace-components elm-shoelace-build elm-shoelace-facts; do
    [ -d "$ROOT/../$sib/src" ] && "$ELM_FORMAT" "$ROOT/../$sib/src" --yes
  done
fi

echo "Done! src/ + split siblings regenerated."
