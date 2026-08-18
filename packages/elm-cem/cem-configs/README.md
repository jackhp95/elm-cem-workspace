# cem-configs

CEM-**analyzer** configs (`@custom-elements-manifest/analyzer`) for producing Custom
Elements Manifests from other component libraries — Carbon, Ionic, Spectrum, and
material-web. They are **inputs to future bindings**, not part of this repo's build:
nothing in `bin/` or `codegen/` reads them. They are kept here to preserve the research
effort of working out each library's analyzer setup, ready for the day those libraries
get elm-cem bindings.

Do not confuse this with `../family-configs/` (finding 2.3, 2026-08-17 thermonuclear
review): that directory holds the `eject`/family-package **brand registry** —
genuinely read by `bin/eject.js`/`bin/family-deps.js` at load time — and is a
different kind of config from the CEM-analyzer inputs here. This directory's own
honesty gap (finding 2.6: `bin`/`codegen` still don't read a *component-manifest*
config for any brand but M3E) is unchanged by that fix and remains open — proving
brand-pluggability end-to-end (a second brand's CEM through codegen, in CI) is
flagged in the audit as its own future wave, not a mechanical fix.
