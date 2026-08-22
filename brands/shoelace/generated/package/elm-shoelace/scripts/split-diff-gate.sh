#!/usr/bin/env bash
# split-diff gate: the committed split siblings (elm-shoelace-{core,elements,
# components,build,facts}) MUST be byte-identical to a clean re-split of the
# monolith src/ at the current generator HEAD. This is the sibling analogue of
# regen-diff-gate.sh — it enforces that nobody hand-edits a published sibling
# (they are generated mirrors; edits belong in the CEM/config or the emitter).
# Mirrors m3e's check:split (scripts/check-split.mjs).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ELM_CEM_BIN="${ELM_CEM_BIN:-$ROOT/../../../../../pipeline/elm-cem/bin/elm-cem.js}"
ELM_FORMAT="${ELM_FORMAT:-$ROOT/node_modules/.bin/elm-format}"
PKG_ROOT="$(cd "$ROOT/.." && pwd)"

TMP=$(mktemp -d)
node "$ELM_CEM_BIN" split --packages="$ROOT/packages.json" --src="$ROOT/src" --out="$TMP" >/dev/null

fail=0
for sib in elm-shoelace-core elm-shoelace-elements elm-shoelace-components elm-shoelace-build elm-shoelace-facts; do
  "$ELM_FORMAT" "$TMP/$sib/src" --yes >/dev/null 2>&1 || true
  # Compare src/ and elm.json (README/LICENSE are static banners; package.json is
  # hand-authored workspace metadata the splitter never emits).
  if ! diff -r "$PKG_ROOT/$sib/src" "$TMP/$sib/src" >/dev/null 2>&1; then
    echo "split-diff gate: FAIL — $sib/src differs from a clean re-split:"
    diff -rq "$PKG_ROOT/$sib/src" "$TMP/$sib/src" | head -10
    fail=1
  fi
  if ! diff "$PKG_ROOT/$sib/elm.json" "$TMP/$sib/elm.json" >/dev/null 2>&1; then
    echo "split-diff gate: FAIL — $sib/elm.json differs from a clean re-split:"
    diff "$PKG_ROOT/$sib/elm.json" "$TMP/$sib/elm.json" | head -20
    fail=1
  fi
done

rm -rf "$TMP"
if [ "$fail" -eq 0 ]; then
  echo "split-diff gate: OK — all five siblings are byte-identical to a clean re-split"
else
  exit 1
fi
