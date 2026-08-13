---
type: history
title: Web implementation gap
description: Why @material/web entering maintenance mode left the web without a first-party M3 library — and why community efforts like m3e exist.
resource: https://github.com/material-components/material-web/discussions/5642
tags: [history, web, material-web, maintenance-mode, m3e, custom-elements]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://github.com/material-components/material-web/discussions/5642
    retrieved: 2026-07-11
    note: Official maintenance-mode announcement, posted 2024-06-10; confirmed still maintenance mode as of retrieval.
  - url: https://github.com/material-components/material-web
    retrieved: 2026-07-11
    note: The @material/web repository (Material Design Web Components).
---

Material Design has a strong first-party toolkit on Android (Jetpack Compose), but the web
does not have an equivalent, actively developed home for the newest Material system. That
gap — and its cause — is why community implementations like `@m3e/web` exist.

## What happened

`@material/web` (Material Web Components, "MWC") was Google's official custom-element
library for Material on the web. On **10 June 2024**, the maintainers announced in
discussion **#5642** that the project was entering **maintenance mode**. In their words:
new features and components are **no longer planned**; GitHub PRs are **not accepted by
default** (only small ones reviewed case by case); and ongoing support depends on volunteer
time. The stated reason was that engineers were reassigned toward Google's internal Wiz
framework. The library was described as stable and *not* deprecated — but no longer actively
developed. As of this writing it remains in maintenance mode.

## Why it matters for M3 Expressive

The timing compounds the gap. MWC went quiet in **2024**;
[Material 3 Expressive launched in 2025](/history/m3e-launch). So the newest Material system —
its physics-based [motion](/expressive/motion-physics), expanded
[shape](/expressive/shape-morphing), and [emphasized type](/expressive/emphasized-type) —
arrived after the official web library had stopped taking new features. There is no
first-party, maintained web component set that ships M3E.

## Why this cluster exists

That vacuum is what community custom-element libraries fill. `matraic/m3e` (the `@m3e/web`
package) is one such effort: an MIT-licensed set of `<m3e-*>` custom elements implementing
the Material system for the web. This knowledge bundle deliberately keeps two layers
separate — the **technology-neutral design guidance** here in `knowledge/`, and the
**verified, implementation-specific API** under
[/implementations/m3e-web](/implementations/m3e-web) — precisely because the web's Material
story is community-maintained rather than first-party, and a neutral guidance layer outlives
any single implementation. See [platform rollout](/history/platform-rollout).
