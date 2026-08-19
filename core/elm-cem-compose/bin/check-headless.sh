#!/usr/bin/env bash
# The mechanical form of "headless": this package must not know what a view is,
# and must not know which brand it is editing. Both are one-line greps, and both
# are load-bearing claims in the spec (§10, §15) rather than conventions.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0

if grep -riq "m3e" "$here/src"; then
  echo "check-headless: FAIL — 'm3e' appears in src/; the core must be brand-agnostic:"
  grep -rin "m3e" "$here/src"
  fail=1
fi

for forbidden in '"elm/html"' '"elm/virtual-dom"' '"jackhp95/elm-m3e"'; do
  if grep -q "$forbidden" "$here/elm.json"; then
    echo "check-headless: FAIL — elm.json declares $forbidden; the core renders nothing."
    fail=1
  fi
done

allowed='elm/core|elm-community/list-extra|jackhp95/elm-cem-facts|jackhp95/elm-cem-compose'
if grep -oE '"[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+"' "$here/elm.json" \
  | grep -vE "\"($allowed)\"" \
  | grep -q .; then
  echo "check-headless: FAIL — elm.json names a dependency outside the registry-faithful set:"
  grep -oE '"[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+"' "$here/elm.json" | grep -vE "\"($allowed)\""
  fail=1
fi

if [ "$fail" -ne 0 ]; then
  exit 1
fi

echo "check-headless: OK — no view, no brand, three dependencies."
