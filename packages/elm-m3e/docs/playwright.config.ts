import { defineConfig, devices } from "@playwright/test";
import { resolveWorktreePort } from "./scripts/worktree-port.mjs";

/**
 * Runtime contract harness for the M3e.* library.
 *
 * Why this exists: the elm-test suite renders the *virtual DOM* (the emitted
 * markup string) via `Test.Html`. But m3e components are custom elements whose
 * truth lives in **DOM properties** and **shadow DOM** — neither of which
 * `Test.Html` can observe. The icon-invisible bug (friction F1) passed the
 * compiler *and* the unit suite and only a real browser caught it. These tests
 * mount the real components (via the docs component pages, which render the
 * actual `Ui.*` modules) in Chromium and assert the runtime contract.
 *
 * Run: `npm run test:browser`. A `pretest:browser` hook kills anything
 * already listening on THIS worktree's port first, so this always rebuilds
 * and serves fresh rather than risking a pass against stale content —
 * load-bearing for the pre-push gate, since Netlify deploys from whatever
 * `main` says passed. Override the target with `BASE_URL=...` (skips the
 * local server and the port-kill hook has nothing to affect).
 *
 * Port is DERIVED, not hardcoded — see scripts/worktree-port.mjs. This repo
 * runs many git worktrees of the same monorepo concurrently (one per agent),
 * and more than one can contain a copy of elm-m3e/docs. A hardcoded port
 * (this used to be :1239) plus `reuseExistingServer` below meant that
 * whichever worktree's `npm run serve` bound the port FIRST silently "won"
 * it — every other worktree's Playwright suite then reused that process and
 * ran assertions against a DIFFERENT worktree's rendered markup, producing
 * broad, non-deterministic, escalating-with-more-agents failures that looked
 * like flaky regressions but weren't. Hashing the worktree's absolute path
 * into the port keeps one worktree's runs on a STABLE port (so
 * `reuseExistingServer` still speeds up solo local iteration) while making
 * two different worktrees collide only in the astronomically unlikely case
 * of a hash collision (escape hatch: WORKTREE_PORT_SALT, see that module).
 */
const port = resolveWorktreePort();
const baseURL = process.env.BASE_URL ?? `http://localhost:${port}`;

export default defineConfig({
  testDir: "./tests-browser",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  // Retries absorb transient timeouts from parallel-load contention. Without
  // this, a single worker transport crash or slow CE-upgrade cascades into a
  // permanent red gate. 2 retries = standard Playwright practice for
  // load-sensitive suites; a test that retries EVERY run is a signal for a
  // deeper fix, not a substitute for one.
  retries: 2,
  // Cap workers so the static server isn't overwhelmed. Playwright defaults to
  // ceil(cpus/2) which on an M-series Mac is 5-6 — enough that all-components
  // (53 simultaneous CE-upgrade pages) starves slower tests of CPU/net budget.
  // 3 workers keeps utilisation high while cutting the contention that causes
  // the timeouts retries recover from.
  workers: 3,
  reporter: [["list"]],
  use: {
    baseURL,
    trace: "retain-on-failure",
    // 45 s per non-navigation action — gives CE-upgrade assertions headroom
    // under 3-worker load (default 30 s is too tight when 3 pages hydrate
    // 50+ custom elements each simultaneously).
    actionTimeout: 45_000,
    // 90 s > per-test timeout (60 s), so the test-level timeout always wins.
    // Without this, the PW default (30 s) would fire first on heavy pages like
    // /guide/reference (5000+ m3e-card upgrades), masking the 60 s per-test
    // budget the tests intend to give those navigations.
    navigationTimeout: 90_000,
  },
  // Per-test timeout: 60 s. Covers tests that do multiple navigations or
  // asserting heavy routes (mobile-shell already self-sets 60 s; this makes
  // that the default so other multi-nav tests don't need bespoke overrides).
  timeout: 60_000,
  projects: [
    { name: "chromium", use: { ...devices["Desktop Chrome"] } },
  ],
  webServer: {
    // In CI: build the site once and serve the pre-rendered production output
    // statically. `elm-pages dev` cold-compiles all 125 routes on first request
    // (too slow for the boot timeout on a 2-core runner) and holds a `/stream`
    // SSE connection open (breaking `networkidle`); the static build serves
    // instantly, is deterministic, and is the artifact we actually ship — the
    // right target for a runtime-contract harness. Its stdout is piped so a
    // boot failure is visible in the CI log instead of a bare timeout.
    // Locally: reuse a dev server already on this worktree's derived port
    // for fast iteration, else start `elm-pages dev`.
    // Build once, serve statically — in CI AND locally. `elm-pages dev`
    // cold-compiles all routes on first request and holds a `/stream` SSE
    // connection open, so it blows the boot timeout and breaks `networkidle`.
    // Measured: the dev-server path times out at 480s locally. The static build
    // is deterministic, serves instantly, and is the artifact we actually ship.
    // `reuseExistingServer` still lets you point at a hand-started server.
    command: `npm run build:site && PORT=${port} npm run serve`,
    // NOT `baseURL` bare: `/` has no prerendered file anymore (it's a
    // Netlify-only 301 to `/getting-started/welcome`, which `netlify.toml`
    // doesn't apply to this raw static server), and `serve-dist.mjs`'s SPA
    // fallback for an unresolved path tries `dist/index.html`, which no
    // longer exists either -- so a readiness GET of `/` gets a 404 forever
    // and this never comes up. Poll `/search-index.json` instead of a content
    // route: it's a build artifact emitted at the dist root regardless of
    // routing (see `docs/scripts/search-index-gen`), so renaming or moving a
    // page can never silently reintroduce the 480s boot-timeout hang this
    // fixed by making the readiness probe depend on a route again.
    url: `${baseURL}/search-index.json`,
    reuseExistingServer: !process.env.CI,
    stdout: "pipe",
    stderr: "pipe",
    // Cold `elm-pages build` on a slow runner can take a few minutes; give it
    // generous headroom (serving itself is instant once built).
    timeout: 480_000,
  },
});
