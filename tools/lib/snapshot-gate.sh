# tools/lib/snapshot-gate.sh — shared portability helper for gates that
# compare against an inert, pre-migration snapshot repo living OUTSIDE this
# workspace (a sibling checkout, not part of this repo's git history).
#
# These snapshots exist on the machine that did the migration and nowhere
# else. A fresh clone of this repo has no siblings, so a gate that hard-errors
# when its snapshot is missing is permanently red off this one machine. This
# helper makes that case a clean, explained SKIP instead — unless
# REQUIRE_SNAPSHOT_GATES=1, which is the switch for a CI that DOES provision
# the snapshots and wants the old hard-fail behavior back.
#
# Usage (source this file, then call before doing any real comparison work):
#   require_snapshot_or_skip "<gate name>" "$SNAPSHOT_DIR" "<ENV_VAR_NAME>"
#
# Returns (via `return 0`) only when $SNAPSHOT_DIR exists, i.e. the gate
# should proceed to run for real. Otherwise it prints SKIP and `exit 0`, or
# under REQUIRE_SNAPSHOT_GATES=1 prints an error and `exit 1` — it never
# returns in that branch, so callers don't need an `if` around it.

require_snapshot_or_skip() {
    local gate_name="$1"
    local snapshot_dir="$2"
    local env_var="$3"

    if [ -d "$snapshot_dir" ]; then
        return 0
    fi

    if [ "${REQUIRE_SNAPSHOT_GATES:-0}" = "1" ]; then
        echo "ERROR: $gate_name: snapshot not found at $snapshot_dir (override with \$$env_var)." >&2
        echo "ERROR: REQUIRE_SNAPSHOT_GATES=1 is set, so a missing snapshot is a hard failure." >&2
        exit 1
    fi

    echo "SKIP: $gate_name — snapshot directory not found at $snapshot_dir"
    echo "SKIP: override the path with \$$env_var, or set \$SNAPSHOT_ROOT to the directory that contains it"
    echo "SKIP: this is an inert pre-migration snapshot checkout, not part of this repository — it is expected to be absent on any machine other than the one that ran the migration"
    echo "SKIP: set REQUIRE_SNAPSHOT_GATES=1 to make an absent snapshot a hard failure instead"
    exit 0
}
