# Move 2 — verified re-cut artifacts (pre-publish, NOT yet wired)

The published elm-m3e Elm packages must each compile standalone, fit under the
registry's 768,000-byte uncompressed `docs.json` cap, and form an import DAG.
The canonical source is the generator's flat 143-module `M3e.<Component>` tree
(D-031c, verified). These artifacts capture the VERIFIED 3-way cut of that tree.

- `split-packages.json` — the `elm-cem split` bucket config for the 3-way cut:
  `jackhp95/elm-m3e` (primitives + M3e.Build + M3e.Review.Facts),
  `jackhp95/elm-m3e-components-a` (65 components),
  `jackhp95/elm-m3e-components-b` (65 components + the `M3e` general-surface barrel).
- `cut-groups.json` — the byte-balanced component partition (P2/P3).
- `measure-full-surface.mjs` — spike-method harness; full surface = 1,342,855 B (174.9% cap).
- `measure-split-standalone.mjs` — compiles each emitted package standalone
  (its real split src + family deps vendored unexposed) and measures its docs.json.

VERIFIED (2026-08-13, manager claude-opus-4-8), regenerate the flat tree then:
  node .../elm-cem/bin/split.js split --packages=split-packages.json --src=<flat143> --out=<out>
  → totality OK, disjointness OK, DAG-respect OK
  elm-m3e             213,247 B  27.8% cap   (11 exposed, exit 0)
  elm-m3e-components-a 545,535 B  71.0% cap   (65 exposed, exit 0)
  elm-m3e-components-b 584,075 B  76.1% cap   (66 exposed, exit 0)

NOT YET DONE (remaining Move 2 execution; see ledger D-035): adopt the flat tree
as the committed src, migrate the ~7 app files + 131 imports, wire a
standalone-compile + size gate into gate-all, keep Face A A/B at 143 byte-identical.
STOP before publish.
