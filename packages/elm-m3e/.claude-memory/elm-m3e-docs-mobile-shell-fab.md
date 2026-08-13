---
name: elm-m3e-docs-mobile-shell-fab
description: elm-m3e docs site — mobile URL-bar shell + dev-only feedback-fab + roundtrip regen; SHIPPED to main
metadata: 
  node_type: memory
  type: project
  originSessionId: 89d89891-6c7f-497f-9aec-2c747c3d6fac
---

elm-m3e docs site (elm-pages, Netlify auto-deploy on push to main, origin `jackhp95/elm-m3e`). **SHIPPED 2026-07-28** — merged + pushed to main (HEAD `c9cefba`), Netlify redeploying (local `build:ci` == Netlify's build was green). Two commits:

1. **`09617bb` feat:** non-scrolling `dvh` app-shell → stable mobile URL bar (kinfolk/flightdeck parity). `style.css`: `html`+`body` `overflow:hidden`, body `height:100dvh`; `Shared.elm`: shell grid `h-screen`→`h-dvh`, `/examples/*` branch becomes its own `h-dvh overflow-y-auto` scroller. Scrolling delegated to the m3e-drawer-container's built-in content scroll (verified no clip). **Dev-only feedback-fab**: vendored `docs/public/feedback-fab.js`, injected from `index.ts` under `<html>` (NOT body — elm-pages Browser.application owns body), gated on `import.meta.env.DEV` (Vite strips from prod). `window.Elm` temporarily freed around the widget's load to dodge **elm/core hints/6** (widget bundles its own Elm → 2-program collision; same fix eddie needed). FOUC was ALREADY handled (`:where(:not(:defined)){opacity:0}`+fade). Verified via `docs/tests-browser/mobile-shell.spec.ts` @ 411×761.
2. **`c9cefba` docs:** regenerated `docs/data/roundtrip-report.json` — the PROPER fix for a pre-existing deploy break.

**Roundtrip build break (was pre-existing since `4c37b37`, now FIXED):** committed report was Layer 1 only ({total,converted,clean,usedEscapeHatch}); `Route/Roundtrip.elm` + `Route/Guide/HowWeProveIt.elm` decode 4 `roundtrip*` per-surface aggregates written ONLY by a **Layer 2** run → decode hard-fail at `json.perSurface.top` → `elm-pages build` red → Netlify failing, live site stale. Fix = `node docs/scripts/verify-roundtrip.mjs --render` (Layer 2 = SSR the harness route + DOM-diff each converted cell vs raw corpus; **no elm-review-cem needed**, works here). Real data now (top: 291 strict / 301 functional matched of 333). Decoders kept **strict** (fail-loud) — a tolerant-decoder crutch was used only to bootstrap Layer 2's internal `build:ci`, then reverted.

**Gotchas (still true):**
- Local `pnpm run build:assets` **DEGRADES** `config/examples.surfaces.json` + `docs/data/examples.json` → the elm-review-cem `TranslateToRecord`/`TranslateToBuild` rules produce **0 transforms** in this env, wiping every `{build,record}` surface to `{}`. NEVER commit regenerated surfaces from here. Deployable build = `build:ci` (uses the COMMITTED corpus; only regenerates gitignored `data/reference.json`). `verify-roundtrip.mjs --render` is DIFFERENT — it works (renders committed cells, no rule execution).
- Playwright browser was missing → `npx playwright install chromium`. Dev-fab spec gated on `EXPECT_FAB=1`, run against `elm-pages dev` (prod dist strips the fab). Prod ships an unreferenced 751KB `public/feedback-fab.js` (dev-only asset; harmless, matches kinfolk).

See [[ui-changes-need-playwright]], [[feedback-fab-hosted-rollout]], [[keep-vendored-widget-latest]], [[elm-m3e-cross-cem-branding]].
