# 06b — .d.ts type-alias inlining coverage against @m3e/web 2.5.14

**Question:** How completely does elm-cem's `.d.ts` alias inliner
(`inlineTypeAliases()` / `collectLiteralAliases()` in
`/Users/jhp/code/jackhp95/elm-cem/bin/elm-cem.js`, lines ~377–504) resolve
@m3e/web's named attribute types? Can CEM + `.d.ts` enumerate the full
attribute value space, and what falls through?

**Method:** the inliner's functions were copied verbatim into
`/private/tmp/claude-501/-Users-jhp-code-avetta/54553aff-0f9d-4fc4-bd24-2adab2414d05/scratchpad/verify/inline-coverage.js`
and run against
`/Users/jhp/code/jackhp95/elm-m3e/docs/node_modules/.pnpm/@m3e+web@2.5.14_@floating-ui+utils@0.2.11_lit@3.3.3_tslib@2.8.1/node_modules/@m3e/web`
(dist/custom-elements.json + 440 `.d.ts` files scanned recursively from
`dist/`, exactly as elm-cem does — dtsDir = dirname of the CEM). Nothing in
the elm-cem repo was modified. Raw output: `coverage-2.5.14.json`,
`coverage-2.5.12.json` (2.5.12 fetched from npm into `m3e-2.5.12/`).

## Algorithm recap (what the inliner actually does)

- Scans **every `.d.ts` under the directory containing the original
  `--flags-from` CEM** (for @m3e/web: `dist/`, recursive).
- Strips comments, then matches `type Name = <body up to first ;>` and keeps
  the alias **only if the body is a pure literal union** — string literals
  and/or numeric literals separated by `|` (optional leading `|`, multiline
  OK). 79 of 113 aliases in the package qualify.
- Rewrites every CEM `type.text` by splitting on `|` and substituting any
  part that exactly names a collected alias; other parts (`undefined`,
  `null`, function types) are kept. **Single pass, no alias-of-alias
  resolution, no `import` following** (moot here: all `.d.ts` are under
  `dist/`, so cross-file aliases are found anyway).

## Numbers (2.5.14; 121 custom elements)

| bucket | count | % of 505 |
|---|---:|---:|
| total attributes | 505 | 100% |
| no `type` in CEM (e.g. `name`/`value` form attrs, `m3e-dialog.open`) → String fallback | 32 | 6.3% |
| primitive / already-literal (`string`, `boolean`, `number`, `string \| null`, `1 \| -1`, `number \| "all"`) | 330 | 65.3% |
| **named/complex (inliner's target population)** | **143** | **28.3%** |
| — resolved to a **pure literal union** by the inliner | **96** | 67.1% of named |
| — resolved **partially** (literal union + residual function member) | 1 | 0.7% of named |
| — unresolved (type.text unchanged) | 46 | 32.2% of named |

- Distinct alias names referenced by attributes: **73**; **72 resolve**
  (98.6%). The single failure is `LinkTarget`.
- Counting attribute rows whose type references an alias name at all
  (110 rows): 97 resolve at least the alias part → **88%**; the 13 failures
  are all `LinkTarget`.
- The 46 "unresolved" rows are dominated by `Date`-typed calendar attributes,
  which reference no alias at all.
- Aliases the earlier dump analysis flagged (`BreadcrumbItemCurrent`,
  `AutocompleteFilterMode`) **do resolve** — both are pure literal unions
  (`dist/src/breadcrumb/BreadcrumbItemCurrent.d.ts:2`,
  `dist/src/autocomplete/AutocompleteFilterMode.d.ts:2`), and compound forms
  (`BreadcrumbItemCurrent | undefined`, `ElevationLevel | null`,
  `HeadingLevel | undefined`, `ShapeName | null`) resolve because
  `resolveAlias` substitutes per `|`-part and keeps the nullish part.

## Unresolved types — complete list (46 rows, 6 distinct shapes)

| type.text | rows | elements.attributes | what it is in the .d.ts | class |
|---|---:|---|---|---|
| `Date \| null` | 23 | m3e-month-view / m3e-year-view / m3e-multi-year-view (`date`, `range-start`, `range-end`, `min`, `max`, …), m3e-date-picker, m3e-date-range-picker, m3e-calendar | global `Date`; attribute is a parsed date string | (a) non-enum, opaque String is correct |
| `LinkTarget` | 13 | `target` on m3e-button, m3e-icon-button, m3e-breadcrumb-item(-button), m3e-card, m3e-assist-chip, m3e-suggestion-chip, m3e-fab, m3e-menu-item ×2, m3e-list-item-button, m3e-list-action, m3e-nav-item | `dist/src/core/shared/mixins/LinkButton.d.ts:6`: `export type LinkTarget = "_self" \| "_blank" \| "_parent" \| "_top" \| (string & {});` | (b)* — see below |
| `Date` | 6 | m3e-month-view / m3e-year-view / m3e-multi-year-view `today`, `active-date` | global `Date` | (a) |
| `string[]` | 2 | m3e-bottom-sheet.detents, m3e-split-pane.detents | array of CSS lengths | (a) |
| `string \| ((count: number) => string)` | 1 | m3e-autocomplete.results-label | function overload | (a) |
| `(value, orientation, dir) => string \| undefined` | 1 | m3e-split-pane.valueFormatter | a function *property* mis-emitted as an attribute by the CEM analyzer | (a) (upstream CEM artifact) |

Partial resolution (1 row): `m3e-autocomplete.filter` —
`AutocompleteFilterMode | ((option, term) => boolean)` becomes
`"contains" | "starts-with" | "ends-with" | "none" | ((option, term) => boolean)`.
The enum half is enumerated; the function member survives into the union text
and it's up to the Elm classifier what to do with the non-literal part.

## Classification verdict

- **(a) genuinely non-enum: 33 of 46 rows** (Date ×29, string[] ×2,
  functions ×2). Opaque String is the right target; no value space lost.
- **(b) enum-ish but rejected by the regex: 13 rows, all one type —
  `LinkTarget`.** The regex rejects it because of the trailing
  `(string & {})` member. But that member means the type is *deliberately
  open* (any frame name is legal), so a closed Elm enum would be **wrong**;
  String fallback is semantically correct. The real cost is only that the four
  canonical values (`_self`/`_blank`/`_parent`/`_top`) aren't surfaced as
  suggestions. So there are **zero true coverage gaps** — no pure literal
  enum is missed by the regex anywhere in the package.
- **(c) alias-of-alias / import chains: 0.** Every `chainResolvesTo` probe
  came back null; @m3e/web has no alias whose body names another alias that
  the single-pass substitution would miss.

**Bottom line:** for @m3e/web 2.5.14 the CEM+.d.ts combo, after inlining,
fully enumerates the value space of every closed enum attribute (96/96 alias
enums + all inline unions). What falls through is exactly the set of types
that *have no finite value space* (dates, arrays, functions, and the
intentionally open `LinkTarget`).

## 2.5.12 → 2.5.14 CEM differences

- **No elements added or removed** (121 tags in both).
- **3 new attributes**, all `active: boolean`, on `m3e-month-view`,
  `m3e-multi-year-view`, `m3e-year-view` (505 vs 502 attrs).
- Alias map, resolved/unresolved sets, and every bucket count are otherwise
  **byte-identical** (unresolved lists diffed: identical). Conclusions drawn
  from the checked-in 2.5.12 dump analysis carry over to 2.5.14 unchanged.
- (Note: the 2.5.13 `tagName` corruption that `reconcileTagNames` fixes —
  StepperNext/FabMenuItem — is a separate pass and orthogonal to inlining.)

## Files

- Script: `/private/tmp/claude-501/-Users-jhp-code-avetta/54553aff-0f9d-4fc4-bd24-2adab2414d05/scratchpad/verify/inline-coverage.js`
- Raw JSON: `coverage-2.5.14.json`, `coverage-2.5.12.json` (same dir)
- 2.5.12 package: `m3e-2.5.12/` (npm tarball, scratchpad only)
