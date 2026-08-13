# M3.c generated-output diff — tailwind-m3e-web

Comparison of `packages/tailwind-m3e-web/generated/{utilities.css,CSS_CUSTOM_PROPERTIES.md}` before
and after M3.c (Face B rewire), per the task's requirement to enumerate every difference and
classify it as a **version-delta** or a **correction** — never accept an unexplained one.

- **Baseline**: `git -C /Users/jhp/code/jackhp95/tailwind-m3e-web show e4f9767:generated/<file>` —
  generated from the installed `@m3e/web` **2.5.11** (package.json declared `^2.5.14`, a genuine
  stale-install skew the coverage audit called out).
- **New**: `pnpm --filter tailwind-m3e-web run generate:utilities` reading
  `packages/tailwind-m3e-web/data/cem-facts.json` (elm-cem Face B), whose provenance stamps
  `@m3e/web` **2.7.3** — the workspace's single pin (`tools/check-single-m3e-web-pin.mjs`).

Regeneration is deterministic: run twice back-to-back, `utilities.css` and
`CSS_CUSTOM_PROPERTIES.md` are byte-identical both times.

## Headline counts

| | baseline (2.5.11) | new (2.7.3) |
|---|---|---|
| `@utility` rules (unique `--m3e-*`/`--md-*` vars) | 2254 | 2347 |
| Component doc sections | 94 | 100 |

Diff: **+98 added, −5 removed** vars (net +93 = 2347 − 2254); **+6** component sections.

No type-inference (`inferType()`) output changed for any of the 2249 vars common to both runs —
`--value(...)` expressions are byte-identical across the overlap. type inference is exercised
by `test/generate-component-utilities.test.mjs`, unchanged code, so this is expected: the audit
already established `inferType()` is not a CEM fact (§4.2) and it keeps reading the same
`name`/`description` pair, just sourced from Face B instead of the raw manifest.

## Removed vars (5) — all version-delta, verified absent from the 2.7.3 manifest

Confirmed by a literal-string grep of
`packages/elm-m3e/docs/node_modules/@m3e/web/dist/custom-elements.json` (the manifest Face B was
generated from): **zero occurrences** of any of the five names below anywhere in that file.

| Var | Component | Classification |
|---|---|---|
| `--m3e-nav-menu-item-open-ripple-color` | `m3e-nav-menu-item` | version-delta — renamed. Upstream restructured the item's interaction-state colors: the single `*-ripple-color` per state (open/selected/unselected) became `*-container-pressed-color`, joining sibling `*-container-{focus,hover}-color` vars that already existed in 2.5.11. See "Added" table below for the replacements. |
| `--m3e-nav-menu-item-selected-ripple-color` | `m3e-nav-menu-item` | version-delta — same rename, see above. |
| `--m3e-nav-menu-item-unselected-ripple-color` | `m3e-nav-menu-item` | version-delta — same rename, see above. |
| `--m3e-ripple-scale-factor` | `m3e-ripple` | version-delta — removed. The 2.7.3 `m3e-ripple` declaration exposes exactly 4 public vars (`--m3e-ripple-color`, `-enter-duration`, `-exit-duration`, `-opacity`); `scale-factor` is gone, no replacement. |
| `--m3e-ripple-shape` | `m3e-ripple` | version-delta — removed, same declaration as above; no replacement. |

`m3e-nav-menu-item`'s total var count is unchanged (32 → 32): this is a clean 3-for-3 swap, not a
net loss.

## Added vars (98) — all version-delta

Grouped by owning component(s) (per Face B's `components[].cssProperties`), with sample
descriptions from the manifest:

| Component(s) | Count | Notes |
|---|---|---|
| `m3e-timepicker-input` | 34 | **Wholly new component.** 0 vars in the 2.5.11 baseline (`grep -c m3e-timepicker /tmp/baseline-vars.txt` → 0). |
| `m3e-timepicker` + `m3e-timepicker-dial` | 25 | Wholly new — same `m3e-timepicker` family. |
| `m3e-timepicker` | 18 | Wholly new — same family (headline/container/actions vars). |
| `m3e-selection-indicator` | 9 | **Wholly new component** — 0 vars in baseline. |
| `m3e-date-input` | 5 | **Wholly new component** — 0 vars in baseline (despite `m3e-date-input` existing as an *element* earlier via a different attribute surface; it had no public CSS custom properties until 2.7.3). |
| `m3e-nav-menu-item` | 3 | Rename target for the 3 removed `*-ripple-color` vars above (`open`/`selected`/`unselected` `-container-pressed-color`). |
| `m3e-nav-bar` + `m3e-nav-rail` | 2 | New horizontal-nav-item leading/trailing space vars. |
| `m3e-state-layer` | 2 | New pressed-state color/opacity vars, joining existing hover/focus pressed-state vars. |

Total: 34+25+18+9+5+3+2+2 = **98**. The `m3e-timepicker*` family alone (77 vars across 3 tags)
accounts for the majority — Material added a whole new Timepicker component between 2.5.11 and
2.7.3, matching this package's `@m3e/web` range (`^2.5.14`, i.e. always meant to float within the
2.x line) and the workspace's `check-single-m3e-web-pin` invariant.

## Component-section correction (not a version-delta): `m3e-fab-menu-item`

The doc gained a `## \`m3e-fab-menu-item\`` section (10 vars: height, font-size, font-weight,
line-height, tracking, shape, leading-space, trailing-space, spacing, icon-size). None of these
10 var **names** are new — all 10 already appear in the 2.5.11 baseline's var list.

This is exactly the bug the coverage audit predicted (§4.2): `bin/generate-component-utilities.mjs`
used to group by the manifest's **raw, unreconciled** `decl.tagName || decl.name` (source line 132),
and the old baseline doc's `## \`m3e-menu-item\`` section — not a `fab-menu-item` section — contains
all 10 of these vars (verified: `awk` over the baseline doc shows `fab-menu-item-height` etc. filed
under the `m3e-menu-item` heading). Face B's `components[].tag` is the reconciled, authoritative
tag, so these 10 vars now file under their real owner, `m3e-fab-menu-item`, and `m3e-menu-item`'s
own section shrinks from 47 rows to 37 (47 − 10 = 37, confirmed) — losing nothing, just correctly
re-homed. **Classification: correction**, not a regression and not a version-delta — the upstream
fact didn't change, the doc's past mislabeling did.

## Summary

Every one of the 103 line-level differences between the baseline and the new generated output
(98 added + 5 removed vars, plus the 10-var `m3e-fab-menu-item`/`m3e-menu-item` re-homing) is
accounted for:

- **103 are version-delta** (98 added + 5 removed — genuinely different `--m3e-*` surface between
  `@m3e/web` 2.5.11 and 2.7.3, each verified against the raw 2.7.3 manifest directly).
- **1 section-level correction** (`m3e-fab-menu-item` vars correctly re-homed from the
  `m3e-menu-item` section they were mislabeled under).
- **Zero regressions.** No var that still exists upstream in 2.7.3 disappeared from the output,
  and no var's inferred Tailwind type/theme-namespace changed for any of the 2249 vars common to
  both runs.
