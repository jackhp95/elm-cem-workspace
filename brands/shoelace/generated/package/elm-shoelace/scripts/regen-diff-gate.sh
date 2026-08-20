#!/usr/bin/env bash
# Regen-diff gate: the committed src/ MUST be byte-identical to a clean
# regeneration from CEM+config at the current generator HEAD — the "zero
# post-codegen tweaks" contract, enforced (mirrors elm-typed-html / elm-m3e).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ELM_CEM_BIN="${ELM_CEM_BIN:-$ROOT/../../../../../pipeline/elm-cem/bin/elm-cem.js}"
ELM_FORMAT="${ELM_FORMAT:-$ROOT/node_modules/.bin/elm-format}"
INPUTS="$ROOT/../../../inputs/cem"

TMP=$(mktemp -d)
node "$ELM_CEM_BIN" \
  "--flags-from=$INPUTS/custom-elements.json" \
  "--config-from=$INPUTS/config/slots.json" \
  "--output=$TMP" >/dev/null
"$ELM_FORMAT" "$TMP" --yes >/dev/null 2>&1

if diff -r "$ROOT/src" "$TMP" >/dev/null 2>&1; then
    echo "regen-diff gate: OK — src/ is byte-identical to a clean regen"
else
    echo "regen-diff gate: FAIL — src/ differs from a clean regen:"
    diff -rq "$ROOT/src" "$TMP" | head -20
    exit 1
fi
