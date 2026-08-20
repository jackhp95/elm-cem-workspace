# Contributing to elm-m3e

Thanks for your interest! This repo is a code-generation monorepo: the shippable
package `jackhp95/elm-m3e` (the repo root) is a **generated artifact**,
the userland Kit (`docs/kit/`) is copy-paste, and an elm-pages docs site
plus a codegen-aware `elm-review` config round it out.

## Generated code — do not hand-edit

The per-component modules under `src/M3e/` are emitted by `elm-cem`
from the `@m3e/web` Custom Elements Manifest plus `config/slots.json`. **Do not
hand-edit them** — change the generator (`elm-cem/`) or the config (`config/`) and
regenerate. The only hand-written sources are the IR core (`M3e/Node.elm`,
`M3e/Element.elm`, `M3e/Content.elm`) and the `docs/kit/` userland.

## The example corpus — do not "clean up" `config/examples.*.json`

The `config/examples.*.json` files (~1.3 MB of tracked JSON) are **not** stray
build output — they are the curated example corpus the docs site and the agent
skills mine for real, compiling `M3e.*` snippets (and the source the compile-time
benchmark in [`docs/DESIGN.md` §Performance](docs/DESIGN.md) compiled across every
surface). They are intentionally committed. Please do not delete or prune them as
"generated artifacts" — regenerate them through the pipeline instead.

## Setup

```bash
npm ci        # installs elm, elm-format, elm-test (root dev deps)
```

### Editor/LSP note

The repo root stays a package `elm.json`, but `src/elm.json` is a nested
application used so Elm LSP / VS Code can analyze `src/` against a buildable
project. Likewise, `tests/elm.json` points at the committed
`docs/vendor/elm-foundation` copy instead of requiring sibling checkouts of the
foundation repos. If you change the docs route graph, re-run `pnpm run gen:pages`
in `docs/` and commit the refreshed `.elm-pages/` output too.

## Verify — the same gates CI runs

CI (`.github/workflows/ci.yml`) has three jobs. To reproduce them locally:

**Library — format, build, test, review**

```bash
# 1. Format-check the HAND-WRITTEN IR core only (generated modules are excluded by design)
node_modules/.bin/elm-format --validate \
  src/M3e/Node.elm src/M3e/Element.elm src/M3e/Content.elm

# 2. The real correctness proof — a green `elm make` over the package
node_modules/.bin/elm make src/M3e.elm --output=/dev/null

# 3. Tests
node_modules/.bin/elm-test --compiler node_modules/.bin/elm

# 4. elm-review — run from docs/ so it picks up docs/elm.json; `elm-pages gen`
#    must run first or the router shows false NoUnused errors
cd docs && pnpm install --frozen-lockfile && pnpm exec elm-pages gen \
  && node_modules/.bin/elm-review --config ../review --compiler node_modules/.bin/elm && cd ..
```

**Docs — reference pipeline + production build**

```bash
cd docs
pnpm install --frozen-lockfile
pnpm run gen:reference     # `elm make --docs` — fails on any exposed value missing a doc comment
pnpm run build             # full elm-pages + Netlify build
```

**Docs — Playwright runtime contract harness**

```bash
cd docs
pnpm exec playwright install --with-deps chromium
pnpm run test:browser      # boots the app and asserts the runtime contract Test.Html can't
```

## Regenerating the library

After changing `config/slots.json` or the generator, regenerate and re-run the
library gates above so `elm.json`'s `exposed-modules` and the emitted tree stay in
sync. Every exposed value must carry a doc comment (the `gen:reference` gate).

## Pull requests

- Branch off `main`; keep changes focused.
- Ensure the library gates (build + test + review) are green.
- Reference the issue you're addressing.

## Reporting

- Bugs / features: [GitHub issues](https://github.com/jackhp95/elm-m3e/issues).
- Security vulnerabilities: **do not** open a public issue — see
  [`SECURITY.md`](SECURITY.md).
