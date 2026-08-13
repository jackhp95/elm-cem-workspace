// @m3e/web custom-element registration + the Tailwind stylesheet are bundled
// through elm-pages' Vite client pipeline (content-hashed; <link>/<script>
// injected automatically) — not hand-linked static assets. These are
// side-effect imports: registering the <m3e-*> elements and pulling in the CSS.
//
// NOTE: @m3e/web/all is intentionally NOT imported here as a static import in
// production. A dynamic import below allows m3eSettleGuard() to install
// whenDefined() listeners BEFORE element definitions run. See the comment on
// m3eSettleGuard for the full rationale.
//
// T2 — dev FOUC parity: in dev, Vite serves assets lazily (no modulepreload),
// so the dynamic @m3e/web/all chunk arrives AFTER elm-pages paints a new route
// on HMR navigation — `:where(:not(:defined))` hides elements → visible blink.
// Prod is fine because Vite emits a <link rel="modulepreload"> that races ahead
// of the route paint.
//
// Fix: eagerly static-import @m3e/web/all in dev mode only. ES static imports
// are hoisted to module evaluation time — before any module body runs — so
// elements are always defined before m3eSettleGuard() even calls whenDefined().
// This means whenDefined() promises resolve synchronously (already defined),
// the settle guard clears on the next microtask, and there is no FOUC.
// Prod is unaffected (import.meta.env.DEV is false → dead-code-eliminated).
// eslint-disable-next-line @typescript-eslint/no-unused-expressions
if (import.meta.env.DEV) await import("@m3e/web/all");
import "./gen/icons.js";
import "../js/avt-snackbar.js";
import "../js/raw-html.js";
import "../js/slide-panels.js";
import "./style.css";

// ─── Material Symbols Rounded + Sharp (for the theme reel's icon-variant switch) ─
//
// style.css self-hosts only "Material Symbols Outlined" (the app default). The
// theme reel (§D4) can switch the whole app's icons to Rounded or Sharp via each
// <m3e-icon>'s `variant` attribute — but m3e-icon selects the font purely by
// font-family, so those two families must actually be loaded or the glyphs fall
// back to the outlined face (or raw ligature text). These aren't bundled in
// public/, so they load from Google Fonts. `display=block` matches the
// self-hosted @font-face so a variant switch never flashes ligature text.
// Injected once at module-eval time (before Elm renders) so a variant switch on
// boot-from-persisted has the font ready. Idempotent via the id guard.
(function loadExtraSymbolFonts() {
  if (document.getElementById("m3e-symbol-fonts-extra")) return;
  const link = document.createElement("link");
  link.id = "m3e-symbol-fonts-extra";
  link.rel = "stylesheet";
  link.href =
    "https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&family=Material+Symbols+Sharp:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=block";
  document.head.appendChild(link);
})();

// ─── Cascade-specificity fix ────────────────────────────────────────────────
//
// ROOT CAUSE: vendor static CSS uses `:root { --md-sys-color-* }` (specificity
// 0,1,0). @m3e/web's <m3e-theme> adopted stylesheet uses `html { --md-sys-color-* }`
// (specificity 0,0,1). Pseudo-class `:root` BEATS type-selector `html`, so the
// static vendor palette silently wins every time — color/contrast attribute
// changes on <m3e-theme> recompute the adopted-sheet values correctly but are
// never visible in getComputedStyle.
//
// The CSS-layer fix (wrapping vendor :root in @layer) is the right approach per
// spec, but Tailwind v4 / LightningCSS strips all @layer annotations from
// non-entry imported files AND normalizes :where(:root) back to :root, making
// any pure-CSS fix impossible without forking the build pipeline.
//
// JS FIX: after every <m3e-theme> `change` event (fired post-_apply()), copy
// the computed --md-sys-color-* values from the adopted stylesheet to inline
// styles on <html>. Inline styles have specificity (1,0,0,0) — always beats
// any selector in any author stylesheet.
//
// LISTENER PLACEMENT: registered at module-evaluation time (before Elm renders
// and before the first Lit update cycle), so the first `change` from <m3e-theme>
// is never missed. `capture: true` so it fires before other listeners in case
// any sibling handler calls stopPropagation.
//
// ─── Override-clobber fix (bug #3 in this family) ──────────────────────────
//
// ROOT CAUSE: `<m3e-theme>` fires a NEW `change` event any time one of its
// reactive attributes (`scheme`, `contrast`, `color`/seed) is set, and Lit
// processes attribute changes asynchronously (its own microtask-batched
// update cycle) — so that `change` event lands strictly AFTER whatever
// synchronous JS ran when the attribute was set. Elm's `ApplyPreset` and
// `ThemeStateLoaded` handlers both set `scheme`/`contrast`/`color` AND call
// `setCssOverride` for `--md-sys-color-*` overrides in the SAME `Cmd.batch` —
// the port call runs synchronously and lands first, but the deferred
// `change` event fires a tick later and this listener's blind copy-from-
// adopted-stylesheet used to stomp every `--md-sys-color-*` property,
// including the one Elm just explicitly overrode. That's why a manual
// Color-accordion override survives *within* a session (no attribute change
// accompanies it) but not across a reload, and why OLED's baked-in override
// never lands at all (`ApplyPreset` always pairs `scheme` with overrides).
//
// FIX: track which `--md-sys-color-*` properties currently have an active
// Elm-driven override (via `overriddenColorProperties`, updated by the
// `setCssOverride` port handler below) and skip those specific properties
// when copying from the adopted stylesheet. `<m3e-theme>`'s own computed
// palette still wins for every non-overridden role; overridden roles are
// now immune to the safety-net/change-listener re-sync race.
const overriddenColorProperties = new Set<string>();

function _applyThemeInlineStyles(): void {
  for (const sheet of document.adoptedStyleSheets) {
    const rule = sheet.cssRules[0] as CSSStyleRule | undefined;
    if (rule?.selectorText === "html") {
      const { style } = rule;
      for (let i = 0; i < style.length; i++) {
        const prop = style.item(i);
        if (prop.startsWith("--md-sys-color-") && !overriddenColorProperties.has(prop)) {
          document.documentElement.style.setProperty(prop, style.getPropertyValue(prop));
        }
      }
      return;
    }
  }
}
document.addEventListener(
  "change",
  (e) => {
    if ((e.target as Element | null)?.tagName === "M3E-THEME") {
      _applyThemeInlineStyles();
    }
  },
  true,
);
// ─────────────────────────────────────────────────────────────────────────────

// ─── FOUC batch-settle guard ─────────────────────────────────────────────────
//
// @m3e/web/all defines 130+ custom elements. With a STATIC import the defines
// run before any module-body code, so a guard set here would find elements
// already defined and resolve the whenDefined promises immediately — no benefit.
//
// Using a DYNAMIC import instead lets us:
//  1. Set html[data-m3e-settling] BEFORE @m3e/web/all registers any elements.
//  2. Register customElements.whenDefined() listeners while tags are still
//     :not(:defined), so each promise fires exactly when its type is registered.
//  3. Remove the attribute only after all types AND their first Lit render
//     (updateComplete) have settled — preventing a flash of unstyled shadow-DOM
//     that would otherwise appear between :defined firing and Lit's first paint.
//
// The dynamic @m3e/web/all chunk is preloaded by the <link rel="modulepreload">
// that Vite emits, so network latency is identical to the static-import approach;
// the only change is the order of execution relative to the guard setup.
//
// style.css adds `html[data-m3e-settling] :where(:not(:defined)) { transition: none }`
// so per-element transitions are suppressed while the batch is unsettled. When
// @m3e/web/all defines all types in one synchronous block all elements start
// their 180ms fade-in at the same frame boundary (atomic reveal).
//
// ORDERING: The theme change-listener above is registered synchronously before
// this guard and before the dynamic import call. <m3e-theme> cannot fire a
// `change` event until it is defined (which requires the dynamic import to have
// resolved), so the listener is categorically registered in time.
// ─────────────────────────────────────────────────────────────────────────────
function m3eSettleGuard(): void {
  // Collect m3e-* tag names present in the pre-rendered HTML. Because @m3e/web/all
  // hasn't run yet (dynamic import below), every tag is currently :not(:defined).
  const tags = [
    ...new Set(
      [...document.querySelectorAll("*")]
        .map((el) => el.localName)
        .filter((name) => name.startsWith("m3e-"))
    ),
  ];
  if (tags.length === 0) return;

  document.documentElement.dataset.m3eSettling = "";

  const settlePromise = Promise.all(
    tags.map(async (tag) => {
      await customElements.whenDefined(tag);
      // Wait for Lit's first render on one instance of this element type so its
      // shadow DOM is ready before it transitions from opacity 0 to 1.
      const el = document.querySelector(tag);
      if (el && "updateComplete" in el) {
        await (el as Element & { updateComplete?: Promise<boolean> }).updateComplete;
      }
    })
  );

  // 8 s fallback: @m3e/web/all defines all types in one synchronous block, so
  // the only real bottleneck is chunk download. Even on slow 3G (~1 Mbps) the
  // Vite-preloaded chunk lands well within 8 s; if it never arrives (404, network
  // failure) we release the page rather than hiding it forever. On timeout,
  // already-defined elements fade in normally via :where(:defined); anything
  // still :not(:defined) stays opacity:0 per the base CSS rule — correct, since
  // raw unstyled custom-element HTML would look broken.
  const timeoutPromise = new Promise<void>((resolve) => setTimeout(resolve, 8000));

  void Promise.race([settlePromise, timeoutPromise]).then(() => {
    delete document.documentElement.dataset.m3eSettling;
  });
}

m3eSettleGuard();

// Fire-and-forget: start loading @m3e/web/all immediately. Vite preloads the
// chunk via <link rel="modulepreload"> so it is already in the browser cache
// by the time this dynamic import runs; it resolves the whenDefined() promises
// registered above as each element type is defined.
void import("@m3e/web/all");

type ElmPagesInit = {
  load: (elmLoaded: Promise<unknown>) => Promise<void>;
  flags: unknown;
};

/**
 * Dev-only feedback widget (mirrors kinfolk's embed). The vendored feedback-fab
 * build is hosted-only — the GitHub-link fallback was removed — so a submit
 * needs a reachable backend on this origin, which only exists while running
 * `elm-pages dev` locally. The whole call site is guarded by
 * `import.meta.env.DEV`, so Vite dead-code-eliminates it from the production
 * Netlify build and public visitors never see a dead button.
 *
 * The widget is a self-contained custom element (its own shadow DOM + M3
 * tokens), so it does NOT need to live inside the app's `<m3e-theme>`. It mounts
 * under `<html>`, NOT `<body>`: elm-pages runs a Browser.application whose vdom
 * owns `<body>` and would wipe a body-level sibling on hydration/morph.
 */
function mountFeedbackFab(): void {
  // Idempotent across dev hot-reloads.
  if (document.querySelector("feedback-fab")) return;

  const fab = document.createElement("feedback-fab");
  fab.setAttribute("repo", "jackhp95/elm-m3e");
  fab.setAttribute("labels", "feedback,needs-triage");
  fab.setAttribute("title-prefix", "[feedback] ");
  // Hosted-mode endpoint: prefer VITE_FEEDBACK_ENDPOINT (injected at build/dev
  // time for flightdeck or other custom backends), otherwise fall back to the
  // real browser origin so submit stays same-origin even behind a cloudflared /
  // `tailscale serve` proxy where the server sees a different Host.
  const endpoint = import.meta.env.VITE_FEEDBACK_ENDPOINT ?? location.origin;
  fab.setAttribute("endpoint", endpoint);
  // Optional: point the widget's dashboard at a flightdeck instance.
  const fd = import.meta.env.VITE_FLIGHTDECK_URL;
  if (fd) fab.setAttribute("flightdeck-url", fd);
  document.documentElement.appendChild(fab);

  // The widget bundles its OWN Elm program. Elm's `_Platform_export` refuses to
  // load a second program onto a page that already exposes `window.Elm` (this
  // docs app), throwing elm/core hints/6 BEFORE the widget can register its
  // custom element (verified: the `<feedback-fab>` stayed `:not(:defined)`).
  // Free `window.Elm` for the duration of the widget bundle's own export, then
  // restore this app's object on load so nothing else regresses. Elm's running
  // app reads window.Elm only at export time, so a temporary swap is safe.
  const w = window as unknown as { Elm?: unknown };
  const savedElm = w.Elm;
  w.Elm = undefined;

  const script = document.createElement("script");
  script.src = "/feedback-fab.js";
  script.addEventListener("load", () => {
    w.Elm = savedElm;
  });
  document.head.appendChild(script);
}

const THEME_STORAGE_KEY = "m3e-theme-state";

const config: ElmPagesInit = {
  load: async function (elmLoaded) {
    const app = (await elmLoaded) as {
      ports?: {
        storeThemeState?: { subscribe: (cb: (v: unknown) => void) => void };
        readThemeState?: { send: (v: unknown) => void };
        setCssOverride?: {
          subscribe: (cb: (v: { property: string; value: string }) => void) => void;
        };
        setFaviconColor?: { subscribe: (cb: (v: string) => void) => void };
        loadFonts?: { subscribe: (cb: (v: string) => void) => void };
        loadSpecimenFonts?: { subscribe: (cb: (v: string[]) => void) => void };
        setIconVariant?: { subscribe: (cb: (v: string) => void) => void };
        requestPreset?: { subscribe: (cb: (v: string) => void) => void };
        onPresetRequested?: { send: (v: string) => void };
        onOpenSearchRequested?: { send: (v: null) => void };
      };
    };
    // elm-pages hard-codes its route-change announcer as aria-live="assertive"
    // (in its pre-render template + AriaLiveAnnouncer.elm, both under
    // node_modules). Assertive interrupts whatever the user is reading on every
    // navigation; a route change is a status update, not an alert — WAI-ARIA
    // says use "polite". Downgrade it once the app has mounted.
    document
      .getElementById("elm-pages-announcer")
      ?.setAttribute("aria-live", "polite");

    // Persist the whole theme-editor state blob so it survives reloads (read
    // back on boot via `readThemeState` below).
    app?.ports?.storeThemeState?.subscribe((state: unknown) => {
      try {
        window.localStorage.setItem(THEME_STORAGE_KEY, JSON.stringify(state));
      } catch (_) {
        /* localStorage unavailable (private mode / SSR) — ignore */
      }
    });

    // One raw `--{property}: {value}` write via inline style on <html> — used
    // for every color-role override and every computed typescale/shape token
    // that Elm cannot express as an `Ir.attribute`.
    //
    // Also maintains `overriddenColorProperties` (see the comment above
    // `_applyThemeInlineStyles`): a "" value means the override was cleared
    // (ResetColorOverride / ResetAll / a preset switch that no longer covers
    // this property), so `<m3e-theme>`'s own computed palette should resume
    // winning for it on the next `change` event.
    app?.ports?.setCssOverride?.subscribe(({ property, value }) => {
      const fullProp = `--${property}`;
      if (value === "") {
        document.documentElement.style.removeProperty(fullProp);
        overriddenColorProperties.delete(fullProp);
      } else {
        document.documentElement.style.setProperty(fullProp, value);
        if (fullProp.startsWith("--md-sys-color-")) {
          overriddenColorProperties.add(fullProp);
        }
      }
    });

    // Favicon live-recolor: the real rewrite mechanism belongs to a separate
    // spec/plan (specs/2026-08-08-tangram-logo-design.md,
    // plans/2026-08-08-tangram-logo.md) — this port fires regardless, but
    // this handler is intentionally a no-op placeholder until that work lands.
    app?.ports?.setFaviconColor?.subscribe((_hex: string) => {
      // Intentional no-op — see comment above.
    });

    // Inject or replace the Google Fonts stylesheet for the active theme's
    // display + body fonts. Finds or creates a <link id="m3e-theme-font">
    // element in <head>. An empty string removes the link entirely.
    app?.ports?.loadFonts?.subscribe((url: string) => {
      if (url === "") {
        document.getElementById("m3e-theme-font")?.remove();
        return;
      }
      let link = document.getElementById("m3e-theme-font") as HTMLLinkElement | null;
      if (!link) {
        link = document.createElement("link");
        link.id = "m3e-theme-font";
        link.rel = "stylesheet";
        document.head.appendChild(link);
      }
      link.href = url;
    });

    // Inject the theme reel's per-card specimen-subset stylesheets (§D6). Unlike
    // loadFonts (one global <link>), the reel needs MANY subset stylesheets loaded
    // at once — one per preset's "Aa"+name glyphs — so every card renders in its
    // own display/body font. Each is added as a <link class="m3e-specimen-font">,
    // deduped by href, and this handler is idempotent: a re-send never duplicates
    // an already-present link (Shared fires it once at boot, but re-sends are safe).
    app?.ports?.loadSpecimenFonts?.subscribe((urls: string[]) => {
      const existing = new Set(
        [...document.querySelectorAll("link.m3e-specimen-font")].map(
          (l) => (l as HTMLLinkElement).href,
        ),
      );
      for (const url of urls) {
        if (!url) continue;
        // Compare against the browser-resolved absolute href to dedupe reliably.
        const probe = document.createElement("a");
        probe.href = url;
        if (existing.has(probe.href)) continue;
        const link = document.createElement("link");
        link.className = "m3e-specimen-font";
        link.rel = "stylesheet";
        link.href = url;
        document.head.appendChild(link);
        existing.add(probe.href);
      }
    });

    // Global icon-variant switch (§D4). m3e-icon picks its Material Symbols font
    // purely from its own `variant` attribute — there is no CSS custom property
    // or <m3e-theme> cascade for it — so switching the whole app's icon style
    // means setting `variant` on every <m3e-icon>. This sweeps all present icons
    // and installs a MutationObserver (once) so icons rendered later (route
    // changes, drawer opens, lazily-defined elements) inherit the current style.
    let currentIconVariant = "outlined";
    let iconObserver: MutationObserver | null = null;
    const applyIconVariant = (root: ParentNode): void => {
      for (const icon of root.querySelectorAll("m3e-icon")) {
        if (icon.getAttribute("variant") !== currentIconVariant) {
          icon.setAttribute("variant", currentIconVariant);
        }
      }
    };
    app?.ports?.setIconVariant?.subscribe((variant: string) => {
      currentIconVariant = variant;
      applyIconVariant(document);
      if (!iconObserver) {
        iconObserver = new MutationObserver((mutations) => {
          for (const m of mutations) {
            for (const node of m.addedNodes) {
              if (node.nodeType !== Node.ELEMENT_NODE) continue;
              const el = node as Element;
              if (el.localName === "m3e-icon") {
                if (el.getAttribute("variant") !== currentIconVariant) {
                  el.setAttribute("variant", currentIconVariant);
                }
              } else {
                applyIconVariant(el);
              }
            }
          }
        });
        iconObserver.observe(document.body, { childList: true, subtree: true });
      }
    });

    // Page → Shared preset bridge. A page (e.g. Welcome.elm) fires
    // `requestPreset presetId` when the user picks a card in the reel.
    // This handler echoes the id back via `onPresetRequested`, where Shared.elm
    // subscribes and resolves the id to a full Preset via Theme.Presets.byId.
    // The round-trip through JS is the sanctioned decoupling mechanism (no
    // page→shared channel exists in elm-pages without an import cycle).
    app?.ports?.requestPreset?.subscribe((id: string) => {
      app?.ports?.onPresetRequested?.send(id);
    });

    // Cmd/Ctrl+K opens search from anywhere. Chrome and Edge bind that
    // shortcut to focusing the address bar, and Browser.Events.onKeyDown
    // cannot call preventDefault (it only decodes event data) -- so this has
    // to be a real DOM listener that calls preventDefault before sending on
    // the port, or our shortcut would fire ALONGSIDE the browser's, not
    // instead of it.
    //
    // `/examples/*` routes render with no docs shell (Shared.view
    // short-circuits to the bare page body), so there is no FAB and no
    // overlay to open there. Shared.subscriptions already refuses to produce
    // OpenSearch on those routes; mirror the same prefix check HERE, before
    // preventDefault, so the browser keeps its own Cmd/Ctrl+K instead of
    // having it swallowed for no visible effect. Keep in sync with
    // `Shared.hasDocsShell`.
    document.addEventListener("keydown", (event) => {
      const isSearchShortcut = (event.metaKey || event.ctrlKey) && event.key.toLowerCase() === "k";
      if (!isSearchShortcut) return;
      if (window.location.pathname.startsWith("/examples/")) return;
      event.preventDefault();
      app?.ports?.onOpenSearchRequested?.send(null);
    });

    if (import.meta.env.DEV) {
      mountFeedbackFab();
    }

    // (The MutationObserver + requestUpdate() shim that lived here was removed.
    //  It was added under commit eb30e90b based on a wrong diagnosis — the
    //  element was always recomputing correctly. The real fix is the inline-style
    //  sync via the `change` event listener registered at module-init above.)

    // Safety-net initial sync: defer past the microtask queue so Lit's first
    // update cycle (which fills the adopted stylesheet) has completed before we
    // read from it. setTimeout(0) runs after ALL pending microtasks drain — the
    // `change` event listener above handles all subsequent updates.
    await new Promise<void>((resolve) => setTimeout(resolve, 0));
    _applyThemeInlineStyles();

    // Boot: send back whatever was persisted (or null if absent/private mode
    // / corrupt). `Theme.Ports.decoder` falls back to defaults on a failed
    // decode, so a null/garbage payload here is handled entirely Elm-side.
    //
    // MUST run after the safety-net `_applyThemeInlineStyles()` call above:
    // that call unconditionally overwrites every `--md-sys-color-*` inline
    // style from the adopted stylesheet's freshly-computed defaults. Sending
    // `readThemeState` earlier let Elm's `ThemeStateLoaded` replay of
    // persisted `colorOverrides` win the JS statement order but then get
    // clobbered by this safety net a tick later — the override was applied
    // and then silently erased before the user ever saw it.
    try {
      const raw = window.localStorage.getItem(THEME_STORAGE_KEY);
      app?.ports?.readThemeState?.send(raw ? JSON.parse(raw) : null);
    } catch (_) {
      app?.ports?.readThemeState?.send(null);
    }
  },
  flags: function () {
    // `width` picks the initial drawer mode (side vs over) before
    // Browser.Events.onResize takes over. The persisted color scheme is no
    // longer a flag — Theme now boots from the `readThemeState` port
    // subscription instead (see `load` above).
    return {
      width: typeof window !== "undefined" ? window.innerWidth : 1024,
    };
  },
};

export default config;
