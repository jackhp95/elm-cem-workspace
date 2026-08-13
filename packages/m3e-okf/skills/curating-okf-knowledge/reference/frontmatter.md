# OKF concept-page frontmatter — exact template

Every concept file under `data/knowledge/**` (any `.md` that is NOT `index.md` or
`log.md`) carries YAML frontmatter fenced by `---`. Copy this template verbatim and
fill it in. The bundle's YAML reader (`scripts/lib/okf-lib.mjs`) supports only
scalars, inline `[a, b]` lists, and the block `sources:` shape shown here — do not
use other YAML constructs.

```yaml
---
type: concept
title: Color
description: A role-based color system generated from a source color, cascading to every element.
resource: https://m3.material.io/styles/color/system/overview
tags: [styles, color, theming, dynamic-color, roles]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://m3.material.io/styles/color/system/overview
    retrieved: 2026-07-11
    note: The role-based color system.
  - url: https://m3.material.io/styles/color/roles
    retrieved: 2026-07-11
    note: Color roles and their on-pairs.
---
```

## Keys

| Key | Required? | Value |
| --- | --- | --- |
| `type` | **REQUIRED** (validate-okf is fatal without it) | One of: `concept`, `pattern`, `anti-pattern`, `history`. Matches the section: components/foundations/styles/expressive → `concept`; patterns → `pattern`; anti-patterns → `anti-pattern`; history → `history`. |
| `title` | Recommended (warned) | Human title used in the generated `index.md` TOC. |
| `description` | Recommended (warned) | One sentence; the "what it covers" cell in `index.md`. Quote it if it contains a comma. |
| `resource` | Recommended (warned) | The single canonical source URL for the page. |
| `tags` | Recommended (warned) | Inline list, `[section, topic, …]`. Neutral topic tags only — no framework/library tags in `knowledge/`. |
| `timestamp` | Recommended (warned) | ISO-8601, e.g. `2026-07-11T00:00:00Z`. |
| `diataxis` | Convention | `explanation` \| `reference` \| `how-to` \| `tutorial` (see below). |
| `sources` | Required for any design-claim page | Block list of `{ url, retrieved, note }` maps. |

`index.md` and `log.md` are **reserved** — they must carry NO frontmatter
(validate-okf is fatal otherwise). `index.md` is generated; never write one by hand.

## Diátaxis selection (`diataxis:`)

- **`explanation`** — the default for design guidance: why a thing exists, when to
  use it, the reasoning. Most foundations/styles/expressive/pattern/anti-pattern
  pages.
- **`reference`** — a factual, look-it-up page: a per-class component page that
  lists anatomy, variants, and states without arguing a position.
- **`how-to`** — a recipe for a specific task ("structure an input-heavy screen").
- **`tutorial`** — a guided, start-to-finish lesson (rare in this bundle).

Pick by the reader's job: understanding (explanation), looking something up
(reference), accomplishing a task (how-to), learning by doing (tutorial).

## `sources:` and the citation rule

- Each `sources:` entry is a `- url:` line followed by indented `retrieved:` and
  `note:` lines. `retrieved` is the date you read it (`YYYY-MM-DD`). `note` says
  what claim that source backs.
- **Citation-presence (fatal):** any page whose prose uses directive language —
  should / prefer / avoid / never / always / must / don't / "use … when" — must
  carry a non-empty `sources:` list or an inline `m3.material.io` link. This is the
  `makesDesignClaim` rule in `validate-okf`.
- Cite the **specific** spec page a claim came from, not just a section root. If a
  page makes several claims from several pages, list each source.

## Paraphrase-and-cite (D6 licensing)

Read the source, then restate the idea in original words and cite it. Do not paste
sentences. **No run of 15+ consecutive words may be identical to a cited source.**
This keeps `knowledge/` original and redistributable while still attributing every
claim. Framework-specific markup and `<m3e-*>` tags never appear here — they live
only under `implementations/m3e-web/`, which is generated from `data/`.
