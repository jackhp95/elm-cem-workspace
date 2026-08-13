# Provenance / licensing audit — concept pages

Per-page provenance and copyright audit of `skills/m3e/concepts/*.md`, run as part of
Phase 5a release hygiene. The binding constraint (Decision **D6**):

1. **Never republish m3.material.io prose verbatim.** m3.material.io *guidance prose*
   has no open-content license — treat it as all-rights-reserved Google content.
   Paraphrase in original words and cite the source URL.
2. **Verbatim is OK** only from Apache-2.0 repos (code, token names, API surfaces) or
   from **MIT `matraic/m3e`** content (attributed).
3. **Facts are not copyrightable** — token names, component anatomies, measurements,
   enum values, and API surfaces may be restated in original prose with a citation.

## Method & a load-bearing caveat

The concept pages fall into two provenance classes:

- **Scraped** (footer `_Source: docs/… · matraic/m3e @ c89173f_`): converted by
  `scripts/guidance.mjs` from **matraic/m3e's own HTML docs** (MIT, attributed). The
  prose is written in M3E's voice ("M3E applies…", "M3E provides the Theme
  component…") — i.e. it is matraic's authored library documentation, which is MIT and
  attributable, **not** copied Google marketing copy. The residual D6 risk is any
  sentence where *matraic themselves* lifted Google's canonical definitional prose.
- **Authored** (footer `_Authored for this skill…_`): original synthesis written for
  this repo, citing m3.material.io by URL for the facts. No Google prose is reproduced;
  library-specific claims carry a `(m3e behavior)` tag.

**Caveat on verification depth:** m3.material.io is a client-rendered JS SPA. Direct
fetches (`WebFetch`) of the cited pages returned only the `<title>` and **no body
prose**, so I could not do a literal string-diff against Google's live text. Verdicts
below are therefore judged from prose *style* (marketing-flavored, full-sentence doc
copy = risk; factual token/measurement tables and library-voice description = safe) and
from the raw matraic HTML in `.cache/m3e/docs/` that was the actual conversion input.
Where I could not be certain, I marked the row and noted the specific concern.

## Audit table

| Page | Cited source(s) | Verdict | Notes |
| --- | --- | --- | --- |
| `color.md` | m3.material.io color/design-tokens; matraic `docs/styles/color.html` (MIT) | **rewritten** | Body is matraic library-voice prose (MIT, attributed) + token facts. One recurring sentence — the design-tokens definition "named, platform-agnostic variables that represent visual design decisions … in a reusable, consistent format" — reads near-verbatim to Google's canonical design-tokens definition. Rewritten in original words (facts + citation kept) via `concept-patches.json`. |
| `density.md` | m3.material.io layout/density, design-tokens; matraic `docs/styles/density.html` (MIT) | **rewritten** | Same near-verbatim Google design-tokens sentence as `color.md` → rewritten identically. The opening "Density refers to the spatial compactness of UI elements…" is matraic's own gloss (library voice follows immediately) and states uncopyrightable facts; left as-is. The 48dp×48dp touch-target figure is an uncopyrightable measurement. |
| `motion.md` | m3.material.io motion/easing, motion-physics, design-tokens; matraic `docs/styles/motion.html` (MIT) | **rewritten** | Same near-verbatim Google design-tokens sentence → rewritten. The physics-motion component list was already detached from the M3 spec citation and tagged `(m3e behavior)` in a prior patch (kept). |
| `typography.md` | m3.material.io typography/overview, design-tokens; matraic `docs/styles/typography.html` (MIT) | **clean** | Matraic library-voice prose + token names + the 15-role scale (uncopyrightable facts). Does **not** contain the Google design-tokens definition sentence. The "30-style" claim was previously re-expressed and attributed to M3 Expressive / m3e via an existing patch. |
| `getting-started.md` | matraic `docs/getting-started/overview.html` (MIT) | **clean** | Pure M3E product/marketing copy authored by matraic (ESM-first, tree-shaking, CSP, etc.). MIT, attributed. No Google prose. |
| `installation.md` | matraic `docs/getting-started/installation.html` (MIT) | **clean** | Install instructions, import-map example, editor-integration steps — all matraic's own library docs (MIT) + factual package/CDN names. No Google prose. |
| `frameworks-react.md` | matraic `docs/frameworks/react.html` (MIT) | **clean** | Library binding docs in M3E's voice. No Google prose. |
| `frameworks-vue.md` | matraic `docs/frameworks/vue.html` (MIT) | **clean** | Two sentences + a link to vuejs.org. Uncopyrightable factual statement. |
| `frameworks-angular.md` | matraic `docs/frameworks/angular.html` (MIT) | **clean** | Library integration note + `CUSTOM_ELEMENTS_SCHEMA` code (Apache/framework API surface). No Google prose. |
| `choosing-components.md` | Synthesized from m3e component descriptions + M3 principles (footer states this) | **clean** | Original selection guidance authored for this skill; component names are API facts linked to verified cards. No verbatim Google prose. |
| `accessibility.md` | m3.material.io designing/usability/assistive-technology (cited by URL) | **clean** | Authored-for-skill original prose; facts (48×48dp, on-* pairing, focus ring) are uncopyrightable and cited; library claims tagged `(m3e behavior)`. |
| `content-design.md` | m3.material.io content-design/alt-text/ux-writing/global-writing (cited by URL) | **clean** | Authored original prose restating Google's content-design *principles* (alt-text purpose, sentence case, active voice) in original words with per-claim citations. Principles/facts are not copyrightable; no sentence is lifted. |
| `design-tokens.md` | m3.material.io design-tokens/how-to-use-tokens (cited by URL) | **clean** | Authored original page. Restates the ref→sys→component tier model (facts) in original wording; does **not** reuse Google's definitional sentence. Library specifics tagged `(m3e behavior)`. |
| `elevation.md` | m3.material.io elevation/applying-elevation/tokens (cited by URL) | **clean** | Authored original prose + a level→surface table of uncopyrightable facts; citations kept; library claims tagged. |
| `icons.md` | m3.material.io icons/applying/designing (cited by URL) | **clean** | Authored original prose + an axis→attribute table (facts); citations + `(m3e behavior)` tags. |
| `interaction-states.md` | m3.material.io interaction/states + state-layers + applying-states (cited by URL) | **clean** | Authored original prose restating the state model (facts: enabled/hover/focus/pressed/dragged/disabled) with citations; token names are API surface; library claims tagged. |
| `layout.md` | m3.material.io layout/breakpoints/canonical-examples/scaffold (cited by URL) | **clean** | Authored original prose; size-class names and canonical-layout names are facts, cited; component/mode specifics tagged `(m3e behavior)`. |
| `shape.md` | m3.material.io shape/corner-radius-scale/principles/shape-morph (cited by URL) | **clean** | Authored original prose; corner-radius scale steps are uncopyrightable facts, cited; `shape` attribute + `m3e-shape` tagged `(m3e behavior)`. |
| `forms.md` | Authored for this skill (no m3.material.io claim) | **clean** | Original prose describing form-associated custom-element wiring; all markup CEM-validated. No Google prose. |

## Outcome

- **Rewritten (3):** `color.md`, `density.md`, `motion.md` — all for the single
  recurring near-verbatim Google design-tokens definition sentence. Rewrites preserve
  every fact and keep the citation; they are recorded as auditable find/replace patches
  in `data/concept-patches.json` (the build fails if a `find` string ever stops
  matching, forcing a human re-verify on upstream drift).
- **Clean (16):** all remaining concept pages — either matraic MIT library-voice prose
  (attributed) or original authored synthesis citing m3.material.io for uncopyrightable
  facts.
- **needs-manual-review (0):** none. The rewritten pages resolve the only identified
  D6 exposure. See the verification caveat above: verdicts rest on prose-style judgment
  and the raw matraic HTML input because m3.material.io's SPA prose could not be fetched
  for a literal diff. If a future reviewer can render the live m3.material.io pages, a
  string-level re-check of the "clean" scraped pages (color/density/motion/typography
  definitional sentences) would upgrade this from *conservative judgment* to *verified*.
