# Spec C — Register brand marks through `m3e-icon`'s icon registry

Date: 2026-08-05
Repo: `elm-m3e`
Status: approved design, not yet planned

## Problem

The GitHub mark in the app bar reaches the DOM through an `innerHTML` sink. `Shared.elm`
holds a 583-character SVG string literal (`githubMarkSvg`), wraps it in a `<raw-html>`
element (`githubMark`), and injects it via `M3e.Unsafe.fromHtml`:

```elm
githubLink =
    M3e.iconButton [ … ] [ M3e.Unsafe.fromHtml githubMark ]
```

`js/raw-html.js` parses that string into a `<template>` and adopts the nodes. Its own header
comment concedes the shape of the problem — it carries a 12-line SECURITY CONTRACT warning
that the element is a DOM-XSS sink and must only ever receive author-controlled,
build-time-constant HTML, and it names `Shared.githubMark` as one of the two callers it is
trusting.

So one static icon costs: an Elm string literal of raw markup, a bypass of the typed
`Element` layer, a custom element whose job is to run `innerHTML`, and a hand-maintained
trust list.

## CORRECTION (verified during implementation): import `registerIcon` from `@m3e/web/all`

**`@m3e/web` ships two independent copies of `IconRegistry`** — one inlined in
`dist/all.js`, one in `dist/icon.js` (`rg -c 'class IconRegistry'` returns 1 in each).
Separate module scopes mean separate registries, with separate `Map`s.

`docs/index.ts` imports `@m3e/web/all`, so the live `<m3e-icon>` elements read
**all.js's** registry. Registering through `@m3e/web/icon` writes to the *other* instance —
no error, no warning, and the icon silently renders as its unregistered-name text fallback.
This was reproduced in a browser during implementation:

```
registered: false, textFallback: "github"
shadowHTML: <div class="icon" …>github</div>
```

`@m3e/web/all` re-exports the same `registerIcon`, so the fix stays on the library's public
seam. **Every snippet below that says `from "@m3e/web/icon"` should read
`from "@m3e/web/all"`** for any app that loads the `all` bundle.

This has a second consequence, recorded in "Related: `@m3e/icons`" below.

## The seam that already exists

`@m3e/web/icon` publicly exports `registerIcon` — the documented extension point for
exactly this:

```js
/** Registers an SVG icon to the internal icon registry used by `m3e-icon`. */
function registerIcon(name, variant, data) { IconRegistry.addIcon(name, variant, data); }
```

And `m3e-icon`'s render falls back to the font only when a name is unregistered
(`dist/icon.js:229`):

```js
IconRegistry.isIconRegistered(this.name, this.variant)
  ? IconRegistry.renderIcon(this.name, this.variant, this.filled)
  : html`<div class="icon" aria-hidden="true" translate="no">${this.name}</div>`
```

That text-div fallback is what the Material Symbols ligature font turns into a glyph today.
Registering a name **overrides** the font path for that name and leaves every other name
alone.

Crucially, this is **not** another `innerHTML` channel. `addIcon` validates against a
character allowlist (`dist/icon.js:13`) and then builds the node with lit's `svg` template,
so the data is interpolated into an attribute binding, not parsed as markup:

```js
const PATH_DATA_PATTERN = /^[MmLlHhVvCcSsQqTtAaZz0-9.,\s-]+$/;
const VIEW_BOX_PATTERN  = /^-?\d+(\.\d+)?\s+-?\d+(\.\d+)?\s+-?\d+(\.\d+)?\s+-?\d+(\.\d+)?$/;
```

Only path commands, digits, `.`, `,`, `-` and whitespace survive. No `<`, no quotes, no
event handlers — the sink is closed by construction rather than by a comment asking callers
to behave.

Verified locally: the existing GitHub path data and the viewBoxes `0 0 512 512` and
`0 -960 960 960` all pass these patterns unchanged.

## Design

### Source of truth

`config/icons.json` maps a local icon name to an Iconify id:

```json
{ "github": "mdi:github" }
```

Icon data comes from the **offline** per-set packages (`@iconify-json/mdi`,
`@iconify-json/material-symbols`) added as `devDependencies`, not from the Iconify CDN at
runtime. Nothing is fetched in the browser and nothing is fetched during a production build.
Per-set packages, not the full `@iconify/json`, to keep the dev install small.

### Build step

`docs/scripts/icons-gen/icons-to-js.mjs` reads `config/icons.json`, resolves each id in the
corresponding icon-set JSON, and emits a generated side-effect module
(`docs/gen/icons.js`) of `registerIcon` calls:

```js
import { registerIcon } from "@m3e/web/icon";

const github = { viewBox: "0 0 24 24", path: "M12 2A10 10…" };
for (const variant of ["outlined", "rounded", "sharp"]) {
  registerIcon("github", variant, { outlined: github, filled: github });
}
```

Two API details the generator must respect, because their names invite the wrong reading:

- **`variant`** is the Material style — `"outlined" | "rounded" | "sharp"`, defaulting to
  `"outlined"` (`dist/icon.js:166`). `renderIcon` keys on it, so a mark registered only for
  `"outlined"` disappears if any call site asks for `variant="rounded"`. A brand mark has no
  Material style, so register the same data for all three. It is the same bytes and it
  removes a whole class of "why is my icon missing" bug.
- **`fillSet.outlined` / `fillSet.filled`** are the *fill states*, unrelated to `variant`. A
  brand mark has no fill state either, so both point at the same data.

Also: passing a **string** for a fill state makes `addIcon` assume the Material viewBox
`0 -960 960 960` and skip viewBox validation (`trustViewBox`). Brand marks are not on that
grid, so the generator must always emit the **object** form with an explicit `viewBox`.
Emitting the string form would silently mis-scale every non-Material icon.

### Hard constraint: single path only

`addIcon` accepts one path `d` per fill state. Iconify `body` values may contain several
elements (multiple `<path>`, `<circle>`, `<rect>`, or a `<g>`). The generator must extract
the single `<path d="…">` case and **fail the build loudly** on anything else, naming the
icon and its id. Silently keeping the first path would drop geometry and ship a subtly wrong
mark. If a wanted icon is multi-element, that is a real finding to bring back, not something
for the generator to paper over.

The generator should also run both m3e validation patterns itself and fail at build time,
so a bad icon is a build error rather than a runtime `throw` in `addIcon` that blanks the
app bar.

Wire the generated module into `docs/index.ts` as a side-effect import beside the existing
ones, and add the generation to the `gen` script chain alongside `gen:vendor` /
`gen:reference` / `gen:samples`, with a drift check in the same style as the existing
`check:drift`.

### Elm side

```elm
githubLink =
    M3e.iconButton
        [ Aria.label "GitHub repository"
        , M3e.Attributes.href "https://github.com/jackhp95/elm-m3e"
        , M3e.Attributes.target "_blank"
        , M3e.Attributes.rel "noreferrer noopener"
        ]
        [ M3e.icon [ M3e.Icon.name "github" ] [] ]
```

Deletes `githubMark`, `githubMarkSvg`, one `M3e.Unsafe.fromHtml`, and the `Html.node` /
`attribute` imports if nothing else needs them. The GitHub link becomes structurally
identical to the `menu`, `palette` and `settings` buttons beside it.

The inline-SVG `fill="currentColor"` behaviour is preserved: registry-rendered icons are
`<svg><path/></svg>` inside `m3e-icon`, which already inherits the app bar's on-surface
foreground, so the mark still adapts to light/dark.

## `raw-html.js` is narrowed, not deleted

Its other caller, `Doc.rawPreview`, is a legitimate docs feature: it renders the *authored
HTML surface* of each component example as live DOM so the embedded `<m3e-*>` elements
upgrade in place and inherit the page's `<m3e-theme>`. That is the whole point of the "here's
the raw HTML" pane — it cannot be replaced with typed `Element`s without deleting the
feature it exists to show.

What was indefensible was routing a single hard-coded icon through it. With that caller
gone, the file keeps one caller and its SECURITY CONTRACT shrinks to a single honest claim:
build-time example HTML generated from `config/*.rich.json`, never a hand-pasted literal.

Update the contract comment to drop the `Shared.githubMark` mention. Do not delete the file.

## Related: `@m3e/icons`, and why it cannot be used in this app

There is an official companion package, `@m3e/icons` (v1.0.12, `peerDependencies: @m3e/web`).
It ships **3897 Material Symbols × 3 variants** as one side-effect module per icon — 1.7MB
packed for the whole set, tree-shakeable. Each module is exactly this:

```js
import { registerIcon } from '@m3e/web/icon';
registerIcon('palette','outlined',{outlined:'M480-80q…',filled:'M480-80q…'});
```

It would be the obvious source for Material glyphs — except that it imports from
**`@m3e/web/icon`**, which is the registry instance the `all` bundle does not read (see the
CORRECTION above). So in this app, which loads `@m3e/web/all`, **every `@m3e/icons` import
would register into the wrong `IconRegistry` and silently render as text.** Verified:
`grep -o "from '[^']*'" dist/outlined/palette.js` → `from '@m3e/web/icon'`.

Using it would require either dropping `@m3e/web/all` in favour of per-component imports, or
an upstream fix in `@m3e/web` to share one registry. Neither is in scope here. Recorded so
the trap is not rediscovered — and note it is worth reporting upstream to matraic.

Also note Iconify **normalises** Material Symbols onto a `0 0 24 24` viewBox, not the
`0 -960 960 960` grid the raw Google font data uses. `@m3e/icons` ships the 960-grid paths.
Anything computing geometry from these paths must read the declared viewBox rather than
assume a grid.

## Explicitly out of scope

Retiring the **3.9MB** `docs/public/material-symbols-outlined.woff2`. Decided against: the
font stays.

Two things worth recording so the decision is not re-litigated from bad numbers:

- The real count is **65** distinct `<m3e-icon name="…">` values across the corpus (plus 5 in
  the app's own Elm: `menu palette save settings widgets`). An earlier draft of this spec said
  252 — that was wrong, counting `file:name` pairs across several config files and sweeping in
  non-icon `name="…"` attributes such as m3e shape names (`arch`, `boom`, `bun`) and
  form-field names (`address2`…`address5`).
- Registry-rendered icons lose the variable axes. `m3e-icon`'s shadow CSS applies
  `font-variation-settings` (`FILL`, `wght`, `GRAD`, `opsz`) only to `.icon`, the text div;
  the registry branch is styled by `svg { fill: currentColor; … }`. `variant` and `filled`
  survive (registry key, dual fill-set); `weight`, `grade` and `opticalSize` do not. The
  docs use them exactly once — `docs/app/Route/Examples/Shop.elm:377`
  (`M3e.Attributes.opticalSize 48`) — and zero times in the corpus.

## Verification

- `config/icons.json` → `docs/gen/icons.js` generation is deterministic; drift check green.
- A generator unit test for the failure paths: multi-element body, and path data failing
  `PATH_DATA_PATTERN`, both fail the build with the icon name in the message.
- `rg` confirms `githubMarkSvg` and the second `raw-html` caller are gone, and that
  `M3e.Unsafe.fromHtml` has one fewer use.
- `npm run test:browser`: the app bar GitHub link renders a real vector (not the literal
  text "github", which is what a failed registration looks like), and inverts correctly
  between light and dark.
- The Usage previews still render live components — `raw-html` unaffected.
