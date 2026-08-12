#!/usr/bin/env bash
#
# Neutrality gate: this package MUST stay design-system / framework neutral. No
# rule logic or user-facing message may assume Material (or any specific library).
#
# It greps every git-tracked file (case-insensitively) for the tokens
# `material`, `m3e`, `md3`, then subtracts a curated allow-list of KNOWN-legitimate
# hits. Anything left over is a NEW, unreviewed mention and fails the build.
#
# Legitimate hits fall into a few buckets, all captured in `.neutrality-allowlist`:
#   - test fixtures + round-trip corpora (they need a concrete example namespace,
#     `M3e.*`) — allow-listed by whole file (`file:` entries);
#   - pedagogical `M3e.*` examples in `src/` doc-comments and default-arg samples —
#     allow-listed line-by-line;
#   - the README's "Material 3 (M3e)" framing and CHANGELOG;
#   - docs/decisions.md's historical cross-references to the elm-m3e extraction;
#   - skills/*.md maintainer docs that teach/config-illustrate the rules using
#     `M3e` as the worked example, or that describe this very gate.
#
# NOT scanned at all (not `.neutrality-allowlist` entries — structurally excluded
# below): generated lockfiles. `package-lock.json`'s base64 integrity hashes are
# not human-authored text, so a `material`/`m3e`/`md3` 3-8 char run inside one is
# pure coincidence — it says nothing about rule neutrality, and the exact hash
# (hence which line "hits") reshuffles on every dependency bump. Allow-listing a
# specific hash would just mean the next `npm install` silently trades that hit
# for a different coincidental one elsewhere in the file.
#
# Run locally from the repo root: `bash .github/neutrality-check.sh`
# (also runs as a CI step, and via `npm run check:neutrality` / `npm run gate`).
# Exit 0 = neutral, exit 1 = new unreviewed mention.

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

ALLOWLIST=".neutrality-allowlist"
PATTERN='\bmaterial\b|m3e|md3'

if [[ ! -f "$ALLOWLIST" ]]; then
    echo "neutrality-check: missing $ALLOWLIST" >&2
    exit 2
fi

# Whole-file allowances: lines beginning `file:<path>` in the allow-list.
ALLOWED_FILES=()
while IFS= read -r f; do
    [[ -n "$f" ]] && ALLOWED_FILES+=("$f")
done < <(grep -E '^file:' "$ALLOWLIST" | sed 's/^file://')

is_allowed_file() {
    local path="$1"
    local f
    for f in "${ALLOWED_FILES[@]}"; do
        # A trailing "/" allows the whole directory subtree; otherwise exact match.
        if [[ "$f" == */ ]]; then
            [[ "$path" == "$f"* ]] && return 0
        else
            [[ "$path" == "$f" ]] && return 0
        fi
    done
    return 1
}

# Line-level allowances are stored as `<path>::<trimmed-content>` entries. We
# compare on path + trimmed content (NOT line number) so reformatting or moving a
# line doesn't spuriously fail the gate.
tmp_hits="$(mktemp)"
trap 'rm -f "$tmp_hits"' EXIT

# Grep the WORKING-TREE content of every tracked file. We deliberately use plain
# `grep` fed by `git ls-files` (not `git grep`, which can read the index rather
# than unstaged edits) so the gate always reflects what's actually on disk.
# -I skips binary, -i case-insensitive, -n gives line numbers. `|| true` so a
# clean tree (grep exit 1) doesn't trip `set -e`.
#
# `:!package-lock.json` (a pathspec exclusion) keeps the generated lockfile out
# of the scan entirely — see the header comment for why. If another generated
# lockfile shows up later (a package manager switch, etc.), add it the same way.
git ls-files -z -- . ':!package-lock.json' | xargs -0 grep -nHI -i -E "$PATTERN" 2>/dev/null > "$tmp_hits" || true

violations=0
while IFS= read -r hit; do
    [[ -z "$hit" ]] && continue
    path="${hit%%:*}"
    rest="${hit#*:}"           # strip path
    content="${rest#*:}"       # strip line number
    # trim leading/trailing whitespace
    trimmed="$(printf '%s' "$content" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

    # Never police the allow-list itself or this script.
    [[ "$path" == "$ALLOWLIST" ]] && continue
    [[ "$path" == ".github/neutrality-check.sh" ]] && continue

    if is_allowed_file "$path"; then
        continue
    fi

    key="${path}::${trimmed}"
    if grep -Fxq "$key" "$ALLOWLIST"; then
        continue
    fi

    if [[ "$violations" -eq 0 ]]; then
        echo "neutrality-check: FAIL — unreviewed design-system mention(s):" >&2
    fi
    echo "  $path: $trimmed" >&2
    violations=$((violations + 1))
done < "$tmp_hits"

if [[ "$violations" -gt 0 ]]; then
    echo "" >&2
    echo "If a hit is legitimate, add it to $ALLOWLIST:" >&2
    echo "  - a whole fixture/example file:  file:<path>" >&2
    echo "  - a single reviewed line:        <path>::<trimmed line content>" >&2
    exit 1
fi

echo "neutrality-check: OK — no unreviewed design-system mentions."
