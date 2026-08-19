# Durable m3e-convention enforcement — audit + design

Research + design pass for three recurring agent failure modes: (1) Tailwind
used for typography, (2) `m3e-okf` not consulted before m3e work, (3)
elm-review not reliably run before "done". Lens: `[[deterministic-over-
nondeterministic]]` — machine gates over stronger prompts.

**UPDATE 2026-08-18: D1/D2/D3(new)/D4 all resolved and implemented** — see
"Decision points for Jack — RESOLVED" below. The paragraph immediately below
describes the state as of the ORIGINAL audit pass, before sign-off; kept for
history.

One artifact was implemented in the original pass (safe repo code, tested, no
config changes): `tools/check-layout-only-classes.mjs` + its test. Everything
that touched `.claude/settings.json`, CI, or global config was PROPOSED ONLY
at that point, awaiting Jack's sign-off — now implemented, see below.

## Audit findings — the brief's premise was substantially wrong

The framing "docs exist but nothing enforces them" does not survive contact
with the repo. **Deterministic enforcement of the Tailwind rule already
exists, is AST-level, tested, and wired into both CI and a pre-push hook.**
The real failure is *when* it fires, not *whether* it exists.

What actually exists (all verified by reading the code, not the docs):

- **`NoProprietaryDsClasses`** (`packages/elm-m3e/review/src/NoProprietaryDsClasses.elm`,
  ~730 lines, 83 passing rule tests): the full layout-only classifier.
  Typography is explicitly covered — `font-`, `leading-`, `tracking-`, and
  every `text-*` that is not alignment/wrapping is `Styling` → reported.
  `m3e-*` classes are checked against the real generated manifest
  (`packages/tailwind-m3e-web/generated/utilities.json`, 2361 names), not a
  prefix guess (`DeadM3eUtility`). Escape hatch: the `Seam` module fence.
  Documented specimen exemptions: `Route/Styles/` (type-scale pages must
  apply `text-body-lg` to *show* it) and `Theme/Sections/{Shape,Typography}.elm`
  (`ReviewConfig.elm:327-362`).
- **`packages/elm-review-cem`** additionally ships a generic
  `NoNonLayoutTailwindClasses`, plus the facts-driven guarantee layer
  (`Cem.all`: slot-kind validity, required content/attributes, cardinality,
  enum tokens) and `NoMissingComponentApiNames` — i.e. component-API
  correctness against the CEM facts bundle IS deterministically checked.
- **Wiring:** `check:review` (docs) → `elm-m3e check` → `tools/gate-all.mjs`
  → runs on every push/PR via `.github/workflows/ci.yml` AND locally via the
  workspace pre-push hook (`hooks/pre-push`, `core.hooksPath` confirmed set
  in this checkout via `tools/hooks-install.mjs`).
- **Review scope** (docs/elm.json source-directories): `docs/app`, `docs/src`,
  `packages/elm-m3e/src`, `packages/elm-cem-compose/src`, elm-cem facts,
  vendored foundation. `elm-typed-html` and the IR package run their own
  `check:review`. Coverage is good.
- **Current tree is clean:** a full scan of all 481 reviewed `.elm` files
  finds zero violations. The 2026-08-19 live catch never landed in git.
- **No repo-level `.claude/settings.json` or hooks** — confirmed. All Claude
  Code hooks are personal-global and unrelated to these conventions.
- **The `m3e` skill** is a symlink `~/.claude/skills/m3e →
  ~/code/jackhp95/m3e-okf/skills/m3e` (the standalone okf checkout, kept
  current by the `updating-okf` skill). Opt-in by description-matching only.

## The three real gaps (what the audit actually surfaced)

1. **Agent-time gap.** Nothing fires at Edit/Write time. The gate fires at
   pre-push (gate-all, 15-20 min — separately flagged as unacceptable) and
   CI. An agent writes `text-sm`, self-reports "done", and the violation is
   only caught minutes-to-days later, or by Jack reading a transcript.
2. **Worktree false-green gap.** Mutating subagents work in
   `.claude/worktrees/*` per policy. Verified live in this very worktree: no
   `node_modules`, no `docs/.elm-pages` → `check-review-guard.mjs` **SKIPs
   with exit 0**. An agent that dutifully runs `check:review` there reads a
   green exit and honestly believes elm-review passed. It never ran.
3. **Silent-skip gap in CI.** The guard's `REQUIRE_CLONE_GATES=1` hard-fail
   mode exists but is set nowhere — not in `ci.yml`, not in gate-all. If docs
   codegen ever breaks in CI, elm-review silently stops running and CI stays
   green.

## Root-cause classification per violation class

| # | Violation class | Root cause | NOT the cause |
| --- | --- | --- | --- |
| 1 | Tailwind for typography | **(c)** check exists + wired, but failure surfaces only at push/CI, and silently not-at-all in agent worktrees (gap 2) | (a) — the AST rule is complete and typography-aware |
| 2 | m3e-okf not consulted | **(a)** for the *behavior* (no deterministic "did you look it up" check can exist) — but the *consequence* is mostly mitigated downstream: wrong tags/attrs/slots/enums are caught by the facts rules + phantom-typed slots (compile error) + the utility manifest. Residual risk is design-level misuse, which class #1's checks catch | "skill needs to be forced" — forcing invocation is brittle; catching wrong output is deterministic |
| 3 | elm-review not run before "done" | **(b)+(c)** — wired to push/CI, not to agent done-time; and skip-not-fail semantics (gap 2/3) convert "I ran it" into false green | (a) — `check:review` exists and is reachable from root gate |

## Recommendations (ranked, with cost)

### R1 — IMPLEMENTED: fast agent-time mirror of the layout-only rule

`tools/check-layout-only-classes.mjs` + `tools/check-layout-only-classes.test.mjs`.

- **Runtime:** 0.25 s for all 481 reviewed files (`--all`); ~60 ms single-file
  (`--hook`). Zero dependencies, zero install, zero network — runs in a bare
  agent worktree, which is the whole point.
- **Drift discipline:** the taxonomy is NOT duplicated. The four
  layout/styling lists are parsed at runtime from
  `NoProprietaryDsClasses.elm` itself; the m3e utility names come from the
  same committed `utilities.json` the rule uses; the specimen exemptions are
  parsed from `ReviewConfig.elm`'s `materialDiscipline` binding. Only the
  ~15-line classifier scaffolding (branch order, `ds-`/`t-`, `[--m3e-`
  bridge, `inset-shadow-` shadowing) is mirrored, one function per Elm
  counterpart.
- **False-positive posture:** string/comment-aware tokenizer (class calls
  quoted inside markdown strings or doc comments do NOT match — pinned by
  test); Seam-module fence mirrored; specimen exemptions mirrored; unknown
  tokens allowed (same permissive tail as the rule). The `--all` run over the
  real tree is a regression pin in the test — currently zero violations, so
  any false positive the mirror ever develops fails the test suite, not an
  agent's edit.
- **Deliberate subset:** literal `class`/`…withClass`/`classList` arguments
  only. Computed classes (`class (a ++ b)`) stay the AST rule's job. The
  elm-review rule remains authoritative; this is the tripwire.
- **Already wired into the gate with zero config:** gate-all auto-discovers
  `tools/*.test.mjs`, so the test (including the `--all` pin) runs in CI and
  pre-push from now on.

### R2 — PROPOSED (needs sign-off): repo-level Claude Code PostToolUse hook

This is what actually closes gap 1 — the check fires the moment any agent
(orchestrator or subagent, any session) writes a violating `.elm` file, and
exit 2 feeds the explanation back as blocking feedback the agent must act on.

Exact content for a NEW `.claude/settings.json` at the workspace root:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "node \"$CLAUDE_PROJECT_DIR/tools/check-layout-only-classes.mjs\" --hook"
          }
        ]
      }
    ]
  }
}
```

- **Cost:** ~60 ms per Edit/Write of an `.elm` file; instant no-op exit for
  everything else (non-Elm paths, exempt dirs). No LLM tokens except when a
  violation message is injected.
- **Failure posture:** hook-mode internal errors never block an edit (warn +
  exit 0) — the script can only block on a genuine classification.
- **Why sign-off:** a repo `.claude/settings.json` affects EVERY future
  session and every teammate/agent in this repo, and Claude Code will prompt
  to trust repo hooks on first use. Decision point D1 below.

### R3 — PROPOSED (needs sign-off): make the CI elm-review skip loud

One line in `.github/workflows/ci.yml`'s gate-all step:

```yaml
      - name: gate-all
        run: node tools/gate-all.mjs
        env:
          REQUIRE_CLONE_GATES: "1"
```

- **Cost:** zero when the docs pipeline provisions correctly (it should — CI
  runs `pnpm install --frozen-lockfile`, which is everything
  `check-review-guard.mjs` needs to run `elm-pages gen`).
- **Risk / why sign-off:** if any clone-gated check is CURRENTLY silently
  skipping in CI, this flips CI red — which is exactly the discovery it
  exists to make, but Jack should choose the moment. Check first whether the
  other R-023-pattern guards (`check:nav`, `check:drift`, browser-guard)
  also honor the flag and whether CI provisions their inputs. Decision D2.

### R4 — PROPOSED: m3e-okf context injection (not skill-forcing)

Do NOT try to block edits until the `m3e` skill has been invoked: hooks can't
reliably introspect session skill state, and a blocking gate with a fuzzy
predicate violates the near-zero-false-positive bar. Instead, inject the
pointer deterministically — a UserPromptSubmit- or PostToolUse-style
`additionalContext` hook that fires when an Edit/Write touches
`packages/elm-m3e/**/*.elm` or writes `m3e-` strings, emitting:

```json
{ "hookSpecificOutput": { "hookEventName": "PostToolUse",
  "additionalContext": "m3e ground truth lives in packages/m3e-okf (component API: skills/m3e/components/<name>.md; type roles: knowledge/styles/typography.md; anti-patterns: knowledge/anti-patterns/). Verify tags/attributes/slots there — do not reconstruct from generic Material Design memory." } }
```

(as a small `tools/hook-m3e-context.mjs`, same shape as the layout hook).

- **Cost:** ~10 ms + ~80 injected tokens per matching edit. Cheap, but it IS
  recurring prompt-side cost, and it may be unnecessary: the deterministic
  downstream net (facts rules + compile errors + utility manifest + R1/R2)
  already catches *wrong* m3e usage; the injection only helps the agent get
  there without a retry loop. Recommend trying R1+R2 first and adding this
  only if the transcript evidence shows agents still flailing. Decision D3.

### R5 — PROPOSED (tiny): loud worktree skip banner

`check-review-guard.mjs` already prints a SKIP reason, but exit 0 is what an
agent's Bash tool sees. Two-line change: when `process.cwd()` contains
`/.claude/worktrees/`, print the skip to **stderr** with a leading
`⚠ ELM-REVIEW DID NOT RUN` banner (still exit 0 so gate-all's skip
accounting is untouched). Cost: zero. Low risk — could be implemented in a
follow-up without sign-off, kept as proposal only because it edits a
gate-adjacent script this pass didn't want to touch untested.

### Explicitly NOT recommended

- **A new elm-review rule** — it already exists and is better than anything
  proposed in the brief.
- **An LLM review pass for these violation classes** — every one of them is
  a string/AST property; a 60 ms script catches it.
- **Husky / `setup-pre-commit`** — the workspace already has a coherent
  single-hook scheme (`core.hooksPath` → `hooks/pre-push`); introducing a
  second hook manager would recreate the exact fragmentation D-008 fixed.
  Pre-*commit* placement is also wrong for a 15-20 min gate-all; the
  in-flight gate-all parallelization work is the right fix for that latency,
  and R1/R2 give the instant feedback layer.

## Decision points for Jack — RESOLVED 2026-08-18

- **D1 (R2): APPROVED, IMPLEMENTED.** Repo-level `.claude/settings.json` now
  exists at the workspace root with a `PostToolUse` hook, matcher
  `Edit|Write`, running `tools/check-layout-only-classes.mjs --hook`. Exact
  content and rationale in "D1 implementation" below.
- **D2 (R3): APPROVED, IMPLEMENTED — with a correction to the original plan's
  assumption.** `.github/workflows/ci.yml`'s (sole) `gate-all` job step now
  sets `REQUIRE_CLONE_GATES: "1"`. The plan's original R3 assumed `pnpm
  install --frozen-lockfile` alone was "everything check-review-guard.mjs
  needs" and, by extension, everything the other R-023-pattern guards need
  too. Measured locally: that's true for `check-review-guard.mjs` (it
  self-provisions `.elm-pages/` via its own internal `elm-pages gen` call) but
  FALSE for `check-nav.mjs` / `check-data-drift.mjs` / `browser-guard.mjs` —
  all three need `docs/data/reference.json`, produced only by a separate
  `pnpm gen` pipeline that a bare `pnpm install` does not run. Confirmed by
  actually flipping `REQUIRE_CLONE_GATES=1` in this worktree after a full
  install: `elm-m3e: check` and `elm-m3e: test` hard-FAILED for exactly that
  reason. Fix: two additional CI steps before `gate-all` (see "D2
  implementation" below) — a ~25s `pnpm gen` for the docs package, and a
  Playwright Chromium install for `browser-guard.mjs`'s real E2E run. With
  both in place, `check-review`, `check-nav`, `check-drift`, and
  `test:browser` all run for real and pass.
- **D3 (R4): APPROVED AS A NEW HOOK, NOT JUST INJECTION-ON-DEMAND** — see the
  brand-new "m3e-skill-nudge hook" section below. Jack overrode the R4
  recommendation to wait for flailing evidence: this fires proactively,
  the same PostToolUse turn as D1's layout hook, whenever an Edit/Write
  touches m3e patterns — on top of (not instead of) the deterministic
  downstream catches R4 already praised (facts rules, compile errors, the
  utility manifest, D1's own hook).
- **D4: APPROVED AS RECOMMENDED (no change).** Agent-worktree provisioning
  stays non-standard. Worktrees remain cheap; D1's hook covers edit-time
  for the layout-only rule, and merge-review + pre-push + CI (now hardened
  by D2) gate the landing.

## D1 implementation

`.claude/settings.json` (workspace root, newly created — none existed before):

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "node \"$CLAUDE_PROJECT_DIR/tools/check-layout-only-classes.mjs\" --hook"
          },
          {
            "type": "command",
            "command": "node \"$CLAUDE_PROJECT_DIR/tools/nudge-m3e-skill.mjs\" --hook"
          }
        ]
      }
    ]
  }
}
```

Both hook entries share the same `Edit|Write` matcher (tool-name only — each
script does its OWN path/extension filtering internally, reading
`tool_input.file_path` off stdin JSON and no-opping on anything out of scope;
this is more robust than trying to glob-filter in the matcher itself, since
PostToolUse matchers in this harness match on tool name, not file path). JSON
shape and I/O contract are modeled directly on this exact harness version's
own REAL hooks, not invented:

- The overall `hooks.PostToolUse[].matcher` / `.hooks[].type/command` shape
  mirrors `~/.claude/settings.json`'s existing `PreToolUse` block
  (`block-external-pr.sh`) and `UserPromptSubmit` block (`liaison-hook.ts`).
- `check-layout-only-classes.mjs --hook`'s contract (read stdin JSON, exit 2
  to block with the explanation on stderr, exit 0 otherwise, NEVER block on
  an internal error) was already fully specified and implemented by the prior
  pass (see "What was implemented" below) — this pass only wired it in.
- `nudge-m3e-skill.mjs --hook`'s contract (stdout
  `{ hookSpecificOutput: { hookEventName: "PostToolUse", additionalContext } }`,
  always exit 0) is the exact documented PostToolUse context-injection
  mechanism this harness already uses for real:
  `~/code/claude-harness/router/liaison-hook.ts` emits the identical shape
  (`hookEventName: "UserPromptSubmit"`) for its `additionalContext` injection,
  and this repo's own `<system-reminder>` blocks in-session are the visible
  proof that stdout channel actually surfaces to the agent.

**Verified end-to-end in-session** (real Edit-shaped invocations, not just
unit tests): a scratch file
`packages/elm-m3e/src/Scratch/HookTest.elm` with `TA.class "text-lg flex"`
was piped through `check-layout-only-classes.mjs --hook` → exit 2, violation
explanation printed to stderr naming `text-lg` and pointing at
`m3e-okf/knowledge/styles/typography.md`. Fixed to `TA.class "flex"` → exit 0.
The same scratch file rewritten with `import M3e exposing (Element)` /
`M3e.Component.Badge.view` was piped through `nudge-m3e-skill.mjs --hook` →
exit 0 with the `additionalContext` nudge JSON on stdout. Scratch file deleted
afterward; `git status` confirmed clean (no violating file left committed).

## D2 implementation

`.github/workflows/ci.yml`'s `gate-all` job, three changes (in order, all
before the `gate-all` step itself):

```yaml
      - name: Generate docs pipeline (m3e-builder-docs) inputs
        run: pnpm --filter m3e-builder-docs run gen

      - name: Install Playwright Chromium
        working-directory: packages/elm-m3e/docs
        run: npx playwright install --with-deps chromium

      - name: gate-all
        run: node tools/gate-all.mjs
        env:
          REQUIRE_CLONE_GATES: "1"
```

There is exactly one job in this workflow (`gate-all`), so no other job needed
scoping consideration.

**What was actually verified, in order** (after a full `pnpm install
--frozen-lockfile` in this worktree — the same install CI performs):

1. `REQUIRE_CLONE_GATES=1 node tools/gate-all.mjs` with ONLY the install done
   (no `pnpm gen`, no Playwright): `elm-m3e: check` and `elm-m3e: test`
   hard-FAILED — `check:drift: data/reference.json absent and
   REQUIRE_CLONE_GATES=1` / `check-nav: data/reference.json absent and
   REQUIRE_CLONE_GATES=1`. This is the discovery D2 exists to make: CI's
   `gate-all` job claims to be "the whole workspace" gate but was silently
   never running these three checks for real.
2. `pnpm --filter m3e-builder-docs run gen` (25.6s locally) then
   `REQUIRE_CLONE_GATES=1 npm --prefix packages/elm-m3e/docs run check:nav`
   and `run check:drift`: both exit 0 for real (`check:drift: OK — 30
   generated artifact(s) match a fresh regen`; `check-nav: OK — 54 drawer
   links all resolve`).
3. `browser-guard.mjs`'s own precondition only checks that
   `node_modules/.bin/playwright` exists (true after a plain `pnpm install` —
   it's the `@playwright/test` package's bin script) — but an actual
   `test:browser` run still needs the Chromium ENGINE binary
   (`playwright.config.ts`'s only project). Confirmed: `npx playwright
   install chromium` + `REQUIRE_CLONE_GATES=1 npm run test:browser` ran the
   full ~180-test Playwright suite for real, all passing.
4. Side effect noted, not shipped: running `pnpm gen` / `test:browser` cold in
   a bare worktree regenerates `docs/data/examples.json` /
   `example-usage.json` / `config/examples.*.json` / the committed
   `docs/dist/` build with DIFFERENT content than what's currently committed
   (fewer compiled example surfaces — the exact "not cold-reproducible"
   caveat `check-data-drift.mjs`'s own comments already document and
   deliberately exclude from its gate). None of that regenerated output was
   committed by this pass; it was reverted. No existing gate compares
   committed `docs/dist/` against a fresh build, so this divergence does not
   fail anything — but it is the reason `check-data-drift.mjs` excludes
   `examples.json`/`example-usage.json`, and it's worth knowing before anyone
   is tempted to gate `docs/dist/` byte-identity in the future.

## m3e-skill-nudge hook (NEW — not in the original plan, added at Jack's request)

Not covered by the original audit's R1-R5; the audit's R4 explicitly argued
AGAINST a proactive nudge on cost/noise grounds and recommended waiting for
transcript evidence of agents flailing. Jack overrode that: the deterministic
downstream net (facts rules, compile errors, the utility manifest, D1's own
hook) only catches WRONG m3e usage after the agent has already produced it —
it does not help the agent get oriented before writing anything. A proactive
nudge closes that head-start gap even though it is not itself a gate.

**`tools/nudge-m3e-skill.mjs`** (+ `tools/nudge-m3e-skill.test.mjs`, 6/6,
auto-discovered by gate-all's `tools/*.test.mjs` scan):

- Matches `Edit|Write` on `.elm`/`.html` files (same `PostToolUse` hook entry
  as D1, second command in the same matcher block).
- Reads the file's content fresh off disk post-write (the hook runs
  AFTER the tool call, so the new content is already there) and tests it
  against a pattern list calibrated against real usage found in
  `packages/elm-m3e/docs/app/Route/Components/Compose.elm` and
  `packages/elm-m3e/docs/app/Theme.elm`: `import M3e` (bare or qualified,
  e.g. `import M3e.Component.Badge`), qualified use without an import line
  (`M3e.Component.*`), `M3e.Attributes`, raw custom-element tags (`<m3e-*`,
  seen in doc comments / embedded HTML in `Theme.elm`), and the npm package
  name `@m3e/web`.
- On a match, prints
  `{ hookSpecificOutput: { hookEventName: "PostToolUse", additionalContext: "…invoke the m3e skill…packages/m3e-okf…" } }`
  to stdout and exits 0 — the documented, already-proven-working
  `additionalContext` injection mechanism (see D1 implementation above for
  the precedent).
- **Never blocks, never spams by design choice, not enforcement:** internal
  errors are swallowed silently (no stdout, exit 0); a non-matching file
  produces zero stdout (no empty/no-op JSON noise); there is no
  cross-invocation debounce — repeated edits to the same m3e-touching file
  re-nudge every time. This is a deliberate simplicity choice (per-invocation
  hooks have no shared session-state channel to cheaply key a debounce
  cache on), not a hard requirement; revisit only if transcript evidence
  shows it's noisy in practice.
- **Verified end-to-end in-session**, same scratch file as D1's test, edited
  to contain `import M3e exposing (Element)` + `M3e.Component.Badge.view`:
  piped through `nudge-m3e-skill.mjs --hook`, produced the nudge JSON, exit 0.
  A control run with the file's original `TA.class "flex"` content (no m3e
  patterns) produced empty stdout, exit 0.

## What was implemented vs. proposed — FINAL STATE

| Item | Status |
| --- | --- |
| `tools/check-layout-only-classes.mjs` | implemented, tested (6/6), `--all` clean over 481 files |
| `tools/check-layout-only-classes.test.mjs` | implemented; auto-picked-up by gate-all's `tools/*.test.mjs` discovery |
| `.claude/settings.json` PostToolUse hook (R2 / D1) | **IMPLEMENTED** — see "D1 implementation" |
| CI `REQUIRE_CLONE_GATES=1` (R3 / D2) | **IMPLEMENTED** — see "D2 implementation" |
| m3e-okf context hook (R4 / D3) | **IMPLEMENTED as a proactive nudge hook**, not just injection-on-demand — see "m3e-skill-nudge hook" |
| `tools/nudge-m3e-skill.mjs` + `.test.mjs` | implemented, tested (6/6) — the concrete artifact for R4/D3 |
| worktree skip banner (R5) | still proposed only — out of scope for this pass, not requested |
