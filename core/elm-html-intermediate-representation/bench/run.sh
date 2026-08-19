#!/usr/bin/env bash
# Merge-cost benchmark. Reporting only, never a gate.
# Usage: ./run.sh            (ELM overrides the compiler, ITERS/ROUNDS the load)
set -euo pipefail
cd "$(dirname "$0")"
ELM=${ELM:-"../node_modules/.bin/elm"}
if [ ! -x "$ELM" ] && ! command -v "$ELM" >/dev/null 2>&1; then
    echo "no elm compiler at '$ELM' — set ELM=/path/to/elm" >&2
    exit 1
fi
"$ELM" make src/Bench.elm --optimize --output=bench.js >/dev/null
node run.mjs
