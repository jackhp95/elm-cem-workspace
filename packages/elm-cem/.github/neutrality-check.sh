#!/usr/bin/env bash
# Permanent neutrality gate.
#
# elm-cem is design-system agnostic — no Material assumptions leak into the
# generator or its docs. This script greps every tracked working-tree file
# (case-insensitively) for design-system-specific tokens, subtracts a curated
# allowlist of *legitimate* hits (pedagogical examples, test fixtures, ecosystem
# links, downstream-consumer references), and exits non-zero on any NEW hit.
#
# The allowlist is a plain list of repo-relative paths in .neutrality-allowlist
# (one per line; blank lines and #-comments ignored). Adding a Material/m3e/md3
# mention to any file NOT on the list turns this gate red — that's the point: it
# forces a reviewer to either neutralize the mention or consciously allowlist it.
#
# Uses `git ls-files` so it reflects on-disk (index-independent) content of
# tracked files, and skips the allowlist file itself.
#
# Scoped to this package directory (not the git root): elm-cem lives as a
# package inside a monorepo, and the invariant this gate protects is about
# elm-cem's own files, not siblings elsewhere in the workspace. Running
# `git ls-files` from this directory lists only files tracked under here,
# with paths already package-relative — which is also exactly what happens
# if elm-cem is ever extracted back into its own repo, where this directory
# IS the git root.
set -euo pipefail

PACKAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PACKAGE_DIR"

PATTERN='\bmaterial\b|m3e|md3'
ALLOWLIST_FILE=".neutrality-allowlist"

# Read the allowlist into a set of paths (ignore comments / blanks).
allowed=""
if [ -f "$ALLOWLIST_FILE" ]; then
  allowed="$(grep -vE '^\s*(#|$)' "$ALLOWLIST_FILE" || true)"
fi

is_allowed() {
  local f="$1"
  [ "$f" = "$ALLOWLIST_FILE" ] && return 0
  while IFS= read -r a; do
    [ -z "$a" ] && continue
    [ "$f" = "$a" ] && return 0
  done <<EOF
$allowed
EOF
  return 1
}

violations=0
# -I skips binary files; -l lists matching filenames.
while IFS= read -r -d '' f; do
  if grep -lIiE "$PATTERN" "$f" >/dev/null 2>&1; then
    if ! is_allowed "$f"; then
      if [ "$violations" -eq 0 ]; then
        echo "Neutrality gate FAILED — design-system token(s) in non-allowlisted file(s):" >&2
        echo >&2
      fi
      echo "  $f" >&2
      grep -niIE "$PATTERN" "$f" | sed 's/^/      /' >&2
      violations=$((violations + 1))
    fi
  fi
done < <(git ls-files -z)

if [ "$violations" -gt 0 ]; then
  echo >&2
  echo "If a hit is legitimate (e.g. an ecosystem link or a pedagogical example)," >&2
  echo "add the file to $ALLOWLIST_FILE. Otherwise, neutralize the mention." >&2
  exit 1
fi

echo "Neutrality gate OK — no non-allowlisted design-system tokens."
