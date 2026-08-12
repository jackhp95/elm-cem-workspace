*Historical record of the markup-prototype Phase 0 research (2026-07-13). Current architecture = HtmlIr IR + phantom generator; the findings here informed the generator design but the markup/ pipeline they reference was deleted in the elm-phantom pass 1 refactor. The native-attr typing conclusions remain valid and are implemented in data/native-attrs.json.*

# Phase 0 — Schema lock + source spike (FINDINGS)

> Executed 2026-07-13. Answers the Phase 0 question: *which source gives the cleanest
> element→attr→type, and does typed enum output need generator changes?*

## Headline

- **No generator changes needed for typed enums.** `codegen/Attr.elm:classifyText` already
  turns a CEM `type.text` union string like `"'get' | 'post'"` into a real Elm `AEnum`
  union (also `boolean`→`ABool`, `number`→`ANumber`, int-literal-union→`AInt`). The
  full-coverage manifest is just CEM declarations with richer `type.text` strings — the
  **exact path the 16-element v1 already uses**, so it dogfoods through `bin/elm-cem.js`
  unchanged. `native-attrs.json` (String/Bool/Int only, tied to `Html.Attributes.<name>`)
  is a *different, weaker* path and is correctly superseded by the manifest.
- **84% of attributes type automatically** from the WHATWG value column with simple rules
  (150/179 rows), including **38 real enums with keyword sets extracted inline**. The 29
  residual fall back to `AString` safely; several are recoverable with a few more rules.

## Source decision (empirical)

| Source | Gives | Notes / gotchas |
|---|---|---|
| **@webref/elements** 2.7.1 | Element **existence** + `obsolete` flag + IDL interface | **113 live** HTML elements, 29 obsolete (clean list). NO attribute data (`attributes` field absent on all 308 entries). Use as the element spine + exclusion signal. |
| **@mdn/browser-compat-data** 8.0.6 | Per-element→**attr presence** + **deprecated/experimental** flags + `input[type]` **enum keywords** (via `type_*` sub-entries) | 134 elements (116 live / 18 deprecated). Global attrs listed separately (31). **Noise to prune**: non-attr entries like `implicit_noopener`, `text_fragments`, `aspect_ratio_computed_from_attributes`, `data_attributes`. Must de-explode `type_*` → single `type` enum. |
| **WHATWG attributes index** (scrape) | Attribute **value TYPES** + enum keyword sets | 4-col table (Attribute\|Element(s)\|Description\|Value), 179 rows. Value column → Bool/Enum/Int/Float/Url/IdRef/Tokens/String. Enums list keywords inline (`"sync"; "async"; "auto"`). Only covers spec'd content attrs (no globals/ARIA/event handlers). |
| **elm-m3e/config/native-mdn.json** + BCD `mdn_url` | MDN prose descriptions | Reuse existing captured prose; WHATWG Description column is a fallback. |

**Merge model:** existence = webref (∩ BCD for the 3 experimental extras: `fencedframe`,
`geolocation`, `model`); attr membership + deprecation = BCD; value type = WHATWG (keyed by
attr name, element-scoped where an attr's value differs by element, e.g. `type`); prose = MDN.
Cross-source: webref-live ⊆ BCD (no webref-live element missing from BCD) — consistent.

## WHATWG value-column taxonomy → Elm AttrType

| WHATWG value kind | count | → AttrType | Elm emission |
|---|---|---|---|
| Enum (quoted keyword list) | 38 | `AEnum keywords` | real union |
| Boolean attribute | 34 | `ABool` | `Bool` |
| Text / Text* | 24 | `AString` | `String` |
| Valid …integer… | 15 | `AInt`/`ANumber` | `Int` |
| Valid …URL… | 13 | `AString` (URL-flagged) | `String` |
| …space/comma-separated tokens | 12 | `AString` (token-flagged) | `String` |
| Valid floating-point number | 8 | `ANumber` | `Float` |
| ID / hash-name reference | 6 | `AString` (IDREF-flagged) | `String` |
| **Other** (BCP47 lang, MIME, media query, CSS color, target-keyword, referrerpolicy, input-type-keyword, Varies) | 29 | mostly `AString`; a few enum-recoverable | — |

Recoverable "Other": `target`/`formtarget` → navigable-target keywords (`_blank _self _parent _top`);
`referrerpolicy` → the referrer-policy enum; `type` on input → 22-keyword enum from BCD `type_*`
(button, checkbox, color, date, datetime-local, email, file, hidden, image, month, number,
password, radio, range, reset, search, submit, tel, text, time, url, week). `Varies` (max/min/value)
= genuinely per-input-type; leave `AString`.

## Schema lock (target = markup/manifest.json CEM)

Emit `modules[].declarations[]`, one declaration per element:
- `kind: "class"`, `customElement: true`, `tagName: "markup-<tag>"`, `name: "Markup<Pascal>"`.
- `summary` = MDN element prose; `description` = generated (tier/void note).
- `attributes[]`: `{ name, type: { text: <union-string|"boolean"|"number"|"string"> }, description }`.
  Enum → TS-union string `"'a' | 'b'"`; Bool → `"boolean"`; Int/Float → `"number"`; else `"string"`.
- `slots`/`members`/`events`/`cssProperties`/`cssParts`/`cssStates`/`dependencies`: `[]` (per v1).
- Globals: factor into ONE shared declaration/module, NOT per element (Phase 1 decision).
- `config/slots.json` (tiers/slots) and `_native` summaries stay separate, merged by `bin/elm-cem.js`.

## Artifacts (this dir)
`spike-webref.mjs` `spike-webref2.mjs` `spike-bcd.mjs` `spike-whatwg.mjs` `spike-typing.mjs`
`spike-elements.mjs` — rerunnable; the numbers above are their output on the versions pinned in
`package.json`.

## Open product note (not blocking — v1 already commits to it)
Full coverage means ~113 `markup-<tag>` **custom elements** (web-component facets), not typed
*native* `<tag>`s. That is the same shape v1 ships for 16 elements. Phase 4 measures whether the
facet family fits the ≤700,000 B size gate.
