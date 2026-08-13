# Plan: Prod theme-flash + Dev FOUC fixes (docs app)

Status: in-progress
Owner: gauntlet manager (top-level session)
Date: 2026-08-10

## Goal

Eliminate two rendering glitches in the elm-pages + @m3e/web docs app:

- **Problem A (dev only):** FOUC on page navigation under Vite dev server. HMR delivers the
  Tailwind stylesheet + `@m3e/web/all` chunk *after* elm-pages paints the new route, so
  `:where(:not(:defined))` hides web components → visible blink → 180ms fade-in. Prod eagerly
  preloads the stylesheet + module, so it never flashes.
- **Problem B (prod only):** User's saved theme lives in `localStorage["m3e-theme-state"]` and is
  read via the `readThemeState` port *after* first paint. SSR paints `Theme.init` defaults
  (`scheme="auto" contrast="standard" color="#6750A4"`), then the port fires and Elm replays
  overrides → flash of default theme → snap to saved theme on every navigation.

## Decisions (locked by Jack 2026-08-10)

- **B → inline blocking `<head>` script** (canonical anti-FOUC-theme pattern). The Elm port still
  replays the full state after boot for consistency; the head script only prevents the pre-paint flash.
- **A → fix now** (don't defer as backlog).

## Key files (verified during investigation)

- `docs/app/Theme.elm:43-57` — `Theme.init` SSR defaults
- `docs/app/Theme.elm:210-224` — `ThemeStateLoaded` replay of colorOverrides/cssOverrides
- `docs/app/Theme/Ports.elm:26-33` — `storeThemeState` / `readThemeState` ports
- `docs/index.ts:90-156` — `m3eSettleGuard()` + dynamic `@m3e/web/all` import
- `docs/index.ts:222-341` — `config.load()`, localStorage read, port wiring
- `docs/index.ts:248-254` — `storeThemeState` handler (writes `localStorage["m3e-theme-state"]`)
- `docs/style.css:400-421` — `:where(:not(:defined))` guard + settle fade
- `docs/elm-pages.config.mjs:1-32` — `headTagsTemplate()`, preload config

## Tasks

### T1 — Problem B: inline blocking head script (Work)
Acceptance test: With a non-default theme saved in `localStorage["m3e-theme-state"]`, load a docs
page fresh and navigate between pages in a production build (`npm run build && preview`); the saved
theme is present on **first paint** — no flash of default theme. Captured screenshot/Playwright at
411×761 shows correct theme immediately.

Implementation notes:
- Add a small synchronous `<script>` in `headTagsTemplate()` (`elm-pages.config.mjs`), placed
  **before** the `<script defer src="/elm.*.js">` and the module `index.ts` script.
- Script reads `localStorage["m3e-theme-state"]`, JSON-parses defensively (try/catch; wrong shape → no-op).
- Apply the persisted `scheme` / `contrast` / seed `color` to the `<m3e-theme>` element attributes,
  and replay any `cssOverrides` as inline custom properties on `<html>` (mirror what
  `ThemeStateLoaded` + `setCssOverride` do at runtime — read those to match the exact keys/shape).
- Must be resilient: if `<m3e-theme>` not yet in DOM, fall back to setting a data attribute on
  `<html>` that the settle guard / Elm boot honors, OR use a `MutationObserver`/`DOMContentLoaded`
  hook — but keep it tiny and synchronous where possible. Prefer setting attrs directly if the
  element is already server-rendered in the static HTML (verify via `dist/` output).
- Keep the blob key (`m3e-theme-state`) and shape as the single source of truth — do NOT fork the
  serialization format. If shape is non-trivial, factor a shared TS helper both `index.ts` and the
  inline script use, or inline-stringify the same logic.

### T2 — Problem A: dev FOUC parity with prod (Work)
Acceptance test: Under `npm run dev` (Vite), navigate between several docs pages (e.g. `/guide/`
→ an examples page) repeatedly; no visible blink/FOUC of web components. Behavior matches prod.

Implementation notes (pick the cleanest that works — worker's judgment, log rationale):
- Preferred: make dev load the `@m3e/web/all` chunk + Tailwind stylesheet as eagerly as prod
  (e.g. static top-level import gated by `import.meta.env.DEV`, or a Vite `optimizeDeps`/preload
  tweak) so definitions land before the route paints.
- Alternative: gate the `:where(:not(:defined))` opacity/fade transition off during HMR-driven
  navigation (dev-only), so already-styled elements don't reset. Must NOT affect the prod build.
- Verify the fix does not regress the intended initial-load settle behavior in prod.

### T3 — Verify (Verify, different provider than worker)
- Rebuild prod, run through T1 acceptance with a saved non-default theme; capture evidence.
- Run dev server, run through T2 acceptance; capture evidence.
- Confirm no regression to initial-load FOUC guard in prod (first cold load still fades in cleanly).
- Run `elm-format` on any `.elm` edits; run the docs build to green.

## Constraints

- Follow Jack's coding preferences; run `elm-format` (docs/node_modules/.bin) after any `.elm` edit.
- Do not fork the theme-state serialization format.
- UI verification at 411×761 with captured output — never trust "looks fine".
- Keep the inline head script tiny; it is render-blocking, so it must be minimal.

## Task table (manager state)

| Task | Role | Tier | Status | Agent | Envelope |
|---|---|---|---|---|---|
| T1 theme head script | Work | sonnet/med | queued | — | this doc |
| T2 dev FOUC parity | Work | sonnet/med | queued | — | this doc |
| T3 verify | Verify | sonnet/med | queued | — | this doc |
