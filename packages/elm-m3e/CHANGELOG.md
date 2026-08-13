# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres
to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) (as enforced by the
Elm package registry from the public API).

## [Unreleased]

## [1.0.0]

First public release: a generated, **Make-Impossible-States-Impossible** `M3e.*`
Elm surface over matraic's [`@m3e/web`](https://github.com/matraic/m3e) Material 3
Expressive web components.

> **Note (pre-phantom draft — rewrite before tagging).** The "Added" list below still
> describes the retired **5-form / `M3e.Cem.*` / `M3e.Native`** shape over a `Markup.*`
> runtime. The shipped architecture is **two surfaces** (general `M3e` +
> `M3e.Attributes`/`M3e.Events`/`M3e.Values`, and per-component `M3e.<Component>`) over the
> imported **`HtmlIr.*`** IR (`elm-html-intermediate-representation`). This unreleased entry
> must be rewritten to the real surface at publish time — see the README for current names.

### Added

- **Five addressable API surfaces per component**, generated from the `@m3e/web`
  Custom Elements Manifest plus a declarative `config/slots.json`:
  - **Bottom** — `M3e.Cem.Html.*`: plain `elm/html`, one constructor per tag; no
    opinion beyond correct DOM-property emission.
  - **Middle** — `M3e.Cem.*`: phantom-typed **attributes** (the shared `M3e.Value`
    token vocabulary), ordinary `Html msg` children, returns `Html`.
  - **Top**, three co-equal shapes over the same phantom-typed IR:
    - `M3e.*` — the **double-list** `view [attrs] [content]` (also the lowercase
      barrel `M3e.treeItem`, `M3e.icon`, … in the single `M3e` module).
    - `M3e.Record.*` — required slots/attrs hoisted into a record
      (`view { required } [attrs] [content]`), so mandatory arguments are
      compiler-enforced.
    - `M3e.Build.*` — a single fully-typed constructor over a complete record
      (required plain, optional-singular as `Maybe`, multi as `List`), so
      presence, cardinality, and validity are all caught by the compiler alone.
- **Typed slots.** Slot children are phantom-typed to the kinds Material 3 allows;
  a wrong-kind child in a slot is a compile error. `any` slots accept any element.
- **Typed native-HTML IR** (`M3e.Native`) with HTML-natural
  attribute typing, so native controls compose provably-validly into typed slots.
- **A structural opaque-IR boundary.** `M3e.Node` / `M3e.Element` are opaque lazy
  IR; construction stays lazy so the typed layers can re-slot content before
  anything renders. The IR collapses to `Html` exactly once, at the application
  root, via `M3e.Element.toNode >> M3e.Node.toHtml`. The raw-to-phantom
  constructors live behind an `*.Internal` fence reachable only by generated
  `M3e.*` code and a team's designated `Seam` module.
- **Config-declared semantic seams.** `text` / `link` / `label` producers are
  declared in config and stamped through the generated `M3e.Seam` contracts —
  userland, not privileged library primitives.
- **A codegen-aware `elm-review` layer** (the D6 5-surface translator) that knows
  the CEM/config the library was generated from — per-component required/multi/
  valid-enum facts (`M3e.Review.Facts`) — and can translate a call between any two
  of the five surfaces.
- **First-class accessible-name attributes** (`M3e.Aria.label`, `labelledby`,
  `describedby`) as a universal, non-phantom setter on any component.

### Notes

- The `docs/kit/` **Kit** (`Kit`, `Native`, `Seam`, `Layout`) is
  copy-paste userland, **not** a dependency of the published package.
- Accessible-name *enforcement* (a `RequireAriaLabel` review rule) is planned, not
  yet implemented; accessible names are currently an author responsibility.

[Unreleased]: https://github.com/jackhp95/elm-m3e/compare/1.0.0...HEAD
[1.0.0]: https://github.com/jackhp95/elm-m3e/releases/tag/1.0.0
