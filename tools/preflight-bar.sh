#!/usr/bin/env bash
# preflight-bar.sh — validate a Gauntlet BAR before dispatching a builder.
#
# WHY THIS EXISTS
#   Across Milestones 0-4 this effort lost ~11 loop rounds. Every one traced to a
#   defective reference bar, not to a builder that could not do the work. Writing
#   the lessons down did not stop the repeats (D-015 was recorded, then violated
#   four rounds later by D-024). So the lessons are mechanized here instead.
#
# WHAT IT CATCHES (8 of the 11 recorded defects)
#   1. VACUOUS      - the bar passes on the pre-work tree, so it cannot tell
#                     "done" from "nothing happened".            (D-010)
#   2. UNSATISFIABLE- the bar fails for a reason no builder action can clear:
#                     it depends on manager-controlled state, or contradicts a
#                     package's own gate.                        (D-008/9/22)
#   3. TOO SLOW     - a check exceeds the loop's verify tolerance, so the loop
#                     reds out no matter what the builder does.  (D-015, D-024)
#   4. NONDETERMINISTIC - a check flips between two runs on an unchanged tree,
#                     usually a build timestamp.                 (D-020)
#
#   It does NOT catch "measures the wrong thing" (D-014) or "blind to the blast
#   radius" (D-011). Those need judgment — but the `bites` mode below is the
#   mechanical half of the first, and it is worth running on every new check.
#
# USAGE
#   bash tools/preflight-bar.sh check <<'EOF'
#   <one shell command per line — the exact bar you intend to dispatch>
#   EOF
#
#   bash tools/preflight-bar.sh bites "<check cmd>" "<command that breaks it>" "<command that restores it>"
#
# READING THE RESULT
#   Part-specific checks SHOULD fail on the pre-work tree (the work is not done).
#   Regression checks SHOULD pass. What you are hunting is:
#     - a part-specific check that PASSES  -> vacuous
#     - a check that fails for a reason you must fix yourself -> unsatisfiable
#     - anything slower than the threshold -> move it to the manager side
#     - anything that flips between runs   -> nondeterministic
set -uo pipefail

SLOW_SECONDS="${SLOW_SECONDS:-120}"
mode="${1:-check}"

if [ "$mode" = "bites" ]; then
    cmd="${2:?usage: preflight-bar.sh bites <check> <break> <restore>}"
    brk="${3:?}"; rst="${4:?}"
    echo "── bites: $cmd"
    eval "$cmd" >/dev/null 2>&1 && before=0 || before=1
    eval "$brk"  >/dev/null 2>&1 || true
    eval "$cmd" >/dev/null 2>&1 && broken=0 || broken=1
    eval "$rst"  >/dev/null 2>&1 || true
    eval "$cmd" >/dev/null 2>&1 && after=0 || after=1
    echo "   clean=$before  broken=$broken  restored=$after"
    if [ "$before" -eq 0 ] && [ "$broken" -ne 0 ] && [ "$after" -eq 0 ]; then
        echo "   OK — the check BITES (green -> red -> green)"; exit 0
    fi
    echo "   PROBLEM — a check that cannot go red proves nothing." >&2
    [ "$before" -ne 0 ] && echo "     it was already red on a clean tree" >&2
    [ "$broken" -eq 0 ] && echo "     it stayed GREEN while broken — measures the wrong thing" >&2
    [ "$after" -ne 0 ] && echo "     it did not recover — your restore is incomplete" >&2
    exit 1
fi

echo "preflight: running each bar check against the CURRENT (pre-work) tree"
echo "preflight: slow threshold = ${SLOW_SECONDS}s"
echo

pass=0; fail=0; slow=0; flip=0; n=0

# Read the whole bar FIRST, before running anything. A `while read` loop that
# evals commands on the way through loses every line after the first command
# that touches stdin — this script silently ran 2 of 3 checks until that was
# caught. Slurp, then iterate; and run each check with stdin closed.
bar_file="$(mktemp)"; trap 'rm -f "$bar_file"' EXIT
cat > "$bar_file"

while IFS= read -r cmd <&3; do
    case "$cmd" in ''|\#*) continue ;; esac
    n=$((n + 1))
    s=$(date +%s); eval "$cmd" >/dev/null 2>&1 </dev/null && r1=0 || r1=1; e=$(date +%s)
    dur=$((e - s))
    eval "$cmd" >/dev/null 2>&1 </dev/null && r2=0 || r2=1

    tags=""
    [ "$r1" -eq 0 ] && { pass=$((pass+1)); tags="$tags PASSES-NOW"; } || { fail=$((fail+1)); tags="$tags fails-now"; }
    [ "$dur" -gt "$SLOW_SECONDS" ] && { slow=$((slow+1)); tags="$tags SLOW(${dur}s)"; }
    [ "$r1" -ne "$r2" ] && { flip=$((flip+1)); tags="$tags NONDETERMINISTIC"; }

    printf '  %-64s %s\n' "${cmd:0:64}" "$tags"
done 3< "$bar_file"

echo
echo "preflight: $n checks — $pass pass now, $fail fail now, $slow slow, $flip nondeterministic"
echo
echo "Now judge, before you dispatch:"
echo "  * Every check tagged PASSES-NOW that is meant to prove THIS part's work"
echo "    is VACUOUS — it would pass if the builder did nothing at all (D-010)."
echo "    At least one check must fail now and be clearable ONLY by the work."
echo "  * Every check tagged fails-now: can a BUILDER clear it? If clearing it"
echo "    needs a commit you forbade, a file you own, or contradicts a package's"
echo "    own gate, it is UNSATISFIABLE (D-008/D-009/D-022) — fix the bar."
echo "  * Every SLOW check belongs on the manager side, not in the loop (D-015/D-024)."
echo "  * Every NONDETERMINISTIC check needs the unstable input normalized or"
echo "    excluded with a stated reason (D-020)."

[ "$slow" -gt 0 ] || [ "$flip" -gt 0 ] && exit 1
exit 0
