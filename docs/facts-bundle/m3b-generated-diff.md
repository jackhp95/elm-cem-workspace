# M3.b — `data/components.json` diff: pre-migration vs. Face-B-sourced

This document enumerates every difference between `m3e-okf`'s pre-migration
committed `data/components.json` (source repo commit `8275e26`,
`/Users/jhp/code/jackhp95/m3e-okf`) and the output produced after this part's
rewiring, in which `scripts/extract.mjs` reads elm-cem's facts bundle
**Face B** (`data/cem-facts.json`, generated against the workspace's single
`@m3e/web` **2.7.3** pin) instead of cloning `matraic/m3e`, building its own
Custom Elements Manifest, hand-porting tag reconciliation
(`reconcileTagNames`), and scanning `.d.ts`/TS sources for literal-union
aliases (`buildAliasMap`).

Verified directly: `node scripts/extract.mjs` was run for real against
`data/cem-facts.json` (a checkout of `matraic/m3e@v2.7.3`'s TS source was
used for the one field the bundle cannot carry — `display`, read from
`:host` CSS; see below), and every element in the output was compared
field-by-field (as a set-keyed structural diff, not a raw line diff, since
Face B's declaration order differs from the old build's — see the ordering
section) against the pre-migration baseline.

## Headline result

```
components (dirs):        55        55   — identical set
elements (tags):          116       116  — identical set
verification findings:    97        97   — identical: DEFAULT-UNDOCUMENTED 41,
                                            UNDOCUMENTED 44, DEFAULT-MISMATCH 11,
                                            CEM-TAG-MISMATCH 1
per-element fields that   name, description, default, slots, events,
match exactly:            navigable, hostContract, examples, verification
```

Every attribute/property/slot/event NAME set, every `default`, every
`description`, `summary`, `sourceFile`, `navigable`, and `hostContract` is
byte-identical between the two trees. The only differences fall into four
explained classes, all traced to a specific Face B field.

## 1. Attribute/property `type` string formatting + `typeSource` label (99 attributes, 17 properties)

**What differs:** the literal-union text is the same *value set*, rendered
differently — e.g.

```diff
- "type": "'small' | 'medium' | 'large'", "typeSource": "cem"
+ "type": "\"small\" | \"medium\" | \"large\"", "typeSource": "ts"
```

and, where the alias body isn't declared in the same member order as the
attribute's own inline reference:

```diff
- "type": "'none' | 'contains' | 'starts-with' | 'ends-with' | (...)"
+ "type": "\"contains\" | \"starts-with\" | \"ends-with\" | \"none\" | (...)"
```

**Why:** the pre-migration baseline was built by
`@custom-elements-manifest/analyzer`'s own type-parser plugin, which
resolves an attribute's literal union inline (single-quoted, in the order
the plugin's own expansion produced) and reports it via `parsedType.text` —
`extract.mjs`'s old `typeOf()` read that directly, so `typeSource` stayed
`"cem"` whenever the plugin had already expanded the union, and only fell
back to a separate `.d.ts`/TS-source alias scan (`typeSource: "ts"`) for the
handful of aliases the plugin left opaque.

Face B resolves every literal-union alias itself, from the package's shipped
`.d.ts` tree, and always reports the result via
`faceB.components[].attributes[].type.resolved` with
`type.source: "dts-alias"` — double-quoted, in **`.d.ts` declaration order**,
regardless of whether the plugin could also have expanded it inline. This
file's `typeOf()`/`typeSourceOf()` now project `type.resolved` +
`type.source` (`dts-alias`/`ts-source` → `"ts"`, else `"cem"`) directly —
verified against `faceB.aliases` for the same members (e.g. `ListVariant`,
`AppBarSize`), which confirms the value SET is unchanged in every case; only
the resolver that produced it, and therefore its quoting/ordering/label,
changed. Two attributes (`m3e-heading`'s `level`, `m3e-icon`'s `weight`) keep
an identical numeric-literal type string but flip `typeSource` from `cem` to
`ts` for the same reason — the old plugin happened to expand the alias
inline for these two, so no fallback ever ran, while Face B labels ALL
alias-resolved types `dts-alias` uniformly.

**Verified dead:** `typeSource: "readme"` (the last-resort fallback to a
README's literal union, for an alias neither the bundle nor a TS-source scan
could resolve) fires 0 times in the regenerated output, matching the
pre-migration baseline (`typeSource cem=525, ts=19, readme=0`,
`docs/facts-bundle/coverage-map.json`'s entry for this exception) — the
fallback code path is exercised by no attribute at either version.

## 2. `properties[].type` gains an explicit `| undefined` for optional fields (17 properties)

```diff
- "type": "'text' | 'video' | 'image' | 'avatar' | 'icon'"
+ "type": "\"video\" | \"image\" | \"avatar\" | \"icon\" | \"text\" | undefined"
```

**Why:** these are optional class fields (e.g. `M3eListElement#leadingContentType?:
...`). The old baseline's `type.text` (from the analyzer plugin) omitted the
implicit `undefined` an optional field's type carries; Face B's
`faceB.components[].properties[].type.resolved` resolves the field's actual
TS type annotation literally, including the optional `| undefined`. This is
the same class of resolver difference as §1 (value set for the non-`undefined`
members is unchanged), reported separately because it affects `properties[]`
rather than `attributes[]` and adds one member instead of reordering/requoting
existing ones.

## 3. CSS custom properties: 4 elements gained/renamed properties (upstream library changes between SHA pins)

```
m3e-date-input       total 3  -> 5   (+2: …-focused-color, …-focused-container-color)
m3e-nav-menu-item    total 31 -> 31  (3 renamed: …-ripple-color -> …-container-pressed-color)
m3e-timepicker-input total 25 -> 34  (+9: …-{unselected,selected,invalid}-{hover,focus,pressed}-state-layer-color)
m3e-timepicker       total 68 -> 77  (+9: same 9 properties, rolled up from timepicker-input)
```

**Why:** the pre-migration baseline was generated against `matraic/m3e` SHA
`a2844143f7dcbe3113a5e88b363ab60afe1570f1` (an ad hoc clone, per-repo, no
longer pinned anywhere else in this workspace). This part's whole point is
the one-pin invariant (`tools/check-single-m3e-web-pin.mjs`): every consumer
now reads facts generated against the single shared `@m3e/web` **2.7.3**
pin. Between that SHA and `2.7.3`, upstream added interaction-state CSS
custom properties to `date-input` and `timepicker`(-input), and renamed
`nav-menu-item`'s ripple-color properties to the `container-pressed-color`
naming used elsewhere in the library. `faceB.components[].cssProperties` is
the field that makes these values correct for the version this workspace
actually ships against — carrying forward the stale SHA's property list
would misdocument the pinned library version's real CSS surface.

## 4. Non-differences achieved by a code change, not left as residual diffs

Two more resolver differences were found and normalised away in
`scripts/extract.mjs` rather than accepted as diffs, because both are
faithfully fixable in code:

- **`default: null` vs. an omitted key.** The old baseline omits the
  `default` key entirely when a CEM attribute or property has no default
  (the raw manifest's `default` was `undefined`, and `JSON.stringify` drops
  `undefined` values). Face B always emits `default: null` explicitly
  (`faceB.components[].attributes[].default` and `…properties[].default`).
  `extract.mjs` maps Face B's `null` back to `undefined` before serializing
  for **both** `attributes[]` and `properties[]` (the first pass only
  applied this to `attributes[]`, via `propsOf()` reading `m.default`
  unmapped — leaving 254 undocumented `"default": null` keys on
  `properties[]`; fixed by applying the same `?? undefined` in `propsOf()`)
  — verified: zero `"default": null` diffs remain, on either array.
- **`description: null` vs. an omitted key.** Same shape mismatch, for
  `description`: Face B emits `description: null` wherever a declaration
  carries no JSDoc comment (e.g. `breadcrumb`'s
  `m3e-breadcrumb-item-button` `click` event, `radio-group`'s
  `m3e-radio-group` `aria-invalid` attribute, 7 `calendar-view` events);
  the old baseline omitted the key. `normalizeNewlines()` (the function
  every `description`/`summary` field is piped through) now maps `null` to
  `undefined` in addition to normalising `\r\n` → `\n`, so this is fixed at
  the one shared chokepoint rather than per call site — verified: zero
  `"description": null` diffs remain.
- **`\r\n` vs `\n` in multi-line descriptions.** Face B preserves a
  declaration's JSDoc comment text verbatim, including whatever line
  endings the source file used; the old analyzer normalised to `\n`. One
  description (`m3e-bottom-sheet`'s `dragHandle` attribute) carries CRLF in
  the source. `extract.mjs` normalises `\r\n` → `\n` on every
  description/summary field it reads from the bundle, matching the old
  behaviour exactly.

## `components[].primaryTag` — a regression, fixed at the resolver, not by reordering

The original rule (`elements.find(e => e.tag === 'm3e-' + dir)?.tag || elements[0]?.tag`)
is unchanged, but its `elements[0]` fallback silently depended on whatever
order elements arrived in. The old `@custom-elements-manifest/analyzer` build
happened to put `m3e-chip` first for the `chips` dir; Face B is sorted by
`tag` ascending (§5), which puts `m3e-assist-chip` first instead — so
`chips.primaryTag` regenerated as `m3e-assist-chip` and that wrong value
shipped into `skills/m3e/SKILL.md`'s `chips` row.

Fixed by replacing the order-dependent fallback with `primaryTagOf()`: when
no element's tag is an exact `m3e-<dir>` match, pick the alphabetically-first
**root** element — one whose declared superclass isn't another element
declared in the same dir (so `m3e-assist-chip`, which subclasses
`M3eChipElement`, is excluded in favor of `m3e-chip` and `m3e-chip-set`,
which both extend `LitElement` directly; alphabetically, `chip` < `chip-set`).
This is deterministic regardless of Face B's array order, and was verified
by computing it against all 55 directories and diffing against the
baseline's `primaryTag` for each: **0 mismatches** (`chips` → `m3e-chip`,
`progress-indicator` → `m3e-circular-progress-indicator`,
`search` → `m3e-search-bar` — the three dirs where the exact-match branch
doesn't fire — and all other 52 dirs via the exact match, unaffected by this
change).

## 5. Element order within a multi-element component directory

`faceB.components` is sorted by `tag` (`docs/facts-bundle/schema.json`'s
`faceB` description: "One entry per unique, authoritatively-tagged custom
element, **sorted by `tag`**"). The pre-migration baseline's element order,
for the 26 directories with more than one element (e.g. `breadcrumb`:
baseline `[item-button, item, breadcrumb]`, regenerated
`[breadcrumb, item, item-button]`), came from
`@custom-elements-manifest/analyzer`'s own module-scan order, which is not
alphabetical, not declaration order, and not reproducible from Face B (or
from any other artifact this workspace has) — it was an artifact of that
specific tool's file-traversal order on a build that no longer runs.

This is **not enumerated element-by-element**: it is a single mechanical
reordering (tag-sorted-ascending, per directory) that touches only array
position, never content — every element's tag, attributes, properties,
slots, events, css, and cssParts are otherwise identical (§§1-4 aside) to
its counterpart in the baseline, confirmed by the tag-keyed structural diff
this document is based on. `README.md`'s "N components (M elements)" count
guard (`check:skill`) and every markup-validity check pass unaffected, since
neither depends on array order.

## Regressions

None found. Every difference traces to one of the four explained classes
above, or is a pure reordering with no content change (§5). `check`, `test`,
and a full `gen` re-run (`gen:extract` → `gen:guidance` → `gen:examples` →
`gen:skill` → `gen:okf`) were run against the regenerated
`data/components.json`, and every downstream artifact (`skills/m3e/**`,
`knowledge/**`, `implementations/m3e-web/**`) regenerated clean and fresh
against it — confirming the new components.json is internally consistent
with the rest of the package, not just individually plausible.

## `sources.json`'s `sha` — subsumed by the bundle's provenance stamp

The pre-migration `data/sources.json.sha` (`a2844143f7dcbe3113a5e88b363ab60afe1570f1`)
came from reading `.cache/m3e/.git/HEAD` after a fresh clone — a git SHA with
no version attached. `PROVENANCE.source.sha` in `data/cem-facts.json` is
`null` (the bundle was generated from an installed npm package, not a git
checkout, so elm-cem has no git SHA to report), so `extract.mjs` falls back
to `PROVENANCE.source.version` (`"2.7.3"`), `v`-prefixed to
`"v2.7.3"` — matching `matraic/m3e`'s actual tag convention (confirmed:
`git ls-remote --tags` lists `v2.7.3`, not `2.7.3`) so the
`github.com/matraic/m3e/blob/<ref>/…` links `build-skill.mjs` renders from
this stamp resolve instead of 404ing. `sources.json`'s shape
(`{upstream, sha, license, components: [{name, sha, readme, sourceFiles}]}`)
is unchanged; only every `sha` value moved from the stale per-repo SHA to
the workspace's single shared `@m3e/web` pin.

## The one field that stays a TypeScript-source read, by design

`display` (each element's resting `:host { display }`) is derived from a
`css` template literal in the upstream TypeScript source
(`scripts/extract.mjs`'s `hostDisplayFrom`/`relatedTsFiles`/`displayFor`).
elm-cem never reads element CSS — only the manifest and `.d.ts` trees — so
this has no Face B field to read (`docs/facts-bundle/coverage-audit.md`
§5.3; `docs/facts-bundle/coverage-map.json`'s entry for this exception).
`display` values are unchanged between the two trees for every element:
verified as part of the tag-keyed structural diff (no `top.display` diffs
reported).
