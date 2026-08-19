# Curation log

A running record of what entered the bundle, when, and on what basis. Newest first.

## 2026-07-11 — Phase 5b: OKF v0.1 bundle established

- Seeded the bundle root with `foundations/`, `styles/`, `components/`,
  `expressive/`, `patterns/`, `anti-patterns/`, and `history/`.
- Authored technology-neutral concept files for foundations (accessibility,
  layout, adaptive-layouts, interaction-states, design-tokens, content-design)
  and styles (color, typography, shape, motion, elevation, icons), each carrying
  OKF frontmatter and `sources:` citations to the Material spec.
- Seeded `components/` with representative neutral class files (button, dialog,
  text-field); the full set lands in the 5c authoring campaign.
- Stubbed `expressive/`, `patterns/`, `anti-patterns/`, and `history/` with
  index.md placeholders pending the authoring campaign.
- The tech-specific, CEM-verified layer moved under `implementations/m3e-web/`
  and is generated from the same `data/` source of truth.

## Provenance discipline

Every concept file that makes a design claim cites the canonical Material spec
page it restates in `sources:`. Google prose is paraphrased, not redistributed;
facts, token names, and measurements may be restated in original words. See
`data/provenance-audit.md` for the per-page 5a audit this bundle preserves.
