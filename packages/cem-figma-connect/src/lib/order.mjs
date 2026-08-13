// Shared ordinal (code-unit) comparators — deliberately NOT localeCompare,
// which is ICU/locale-sensitive and would threaten byte-stability
// (determinism is a hard gate in this project). Every sort that feeds a
// committed artifact (correspondence.json, gap-report.md) or a candidate
// list must use these, not localeCompare, so re-runs on any machine/locale
// produce byte-identical output.
//
// Used by matcher.mjs, fusion.mjs, merge.mjs, and gap-report.mjs — this is
// the single comparator to audit rather than four independent copies.

export const byString = (a, b) => (a < b ? -1 : a > b ? 1 : 0);

// byKey(fn) -> comparator sorting items by fn(item) using ordinal compare.
export const byKey = (fn) => (a, b) => byString(fn(a), fn(b));
