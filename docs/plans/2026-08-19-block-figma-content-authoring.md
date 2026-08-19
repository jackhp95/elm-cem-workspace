# Plan: mechanically block code-driven Figma content authoring (enforce D6)

**Spec:** `core/cem-figma-connect/research/2026-08-19-structural-fidelity-ideation.md` § 7 ("a decision to re-open on purpose") plus this session's explicit ruling: **D6 stands, absolutely — no code-driven Figma authoring, ever.** On 2026-08-19 two frames were created in a shared Figma file via `use_figma` (a round-trip test); Jack ruled this must never happen again and the created content has already been deleted from the file. This plan makes that ruling mechanically enforced, not just written down — mirroring this repo's own established doctrine (`docs/plans/2026-08-19-durable-m3e-convention-enforcement.md`): **"deterministic-over-nondeterministic — machine gates over stronger prompts."**

## Scope — read carefully before writing any code

**In scope — block:** any tool call that creates or mutates Figma *content* (frames, nodes, components, instances, styles, variables, pages, files) driven from an agent session. Concretely: the `use_figma` MCP tool when its `code` parameter contains a Figma Plugin API **write** call; the `create_new_file` MCP tool; the `generate_figma_design` MCP tool.

**Out of scope — do NOT block:** read-only Figma MCP tools (`get_design_context`, `get_metadata`, `get_screenshot`, `get_code_connect_suggestions`, `search_design_system`, `get_libraries`, `whoami`, `get_code_connect_map`, `get_variable_defs`) — these never write. Also out of scope: `cem-figma-connect`'s own `publish`/`unpublish` CLI commands and the `send_code_connect_mappings`/`add_code_connect_map` MCP tools — these are the existing, *sanctioned*, gated Figma↔code bridge (Code Connect bindings, behind `core/cem-figma-connect`'s own visual gate, human-authorized token, and publish-refuses-on-drift checks). D6 is about ad hoc content authoring bypassing all of that governance, not about the governed Code Connect publish pipeline. If you find this distinction unclear or contested while implementing, say so in the report rather than guessing — this is a judgment call worth flagging, not silently resolving.

**A read-only `use_figma` call must still work.** The `figma-generate-design` skill's own documented workflow includes read-only inspection via `use_figma` (walking an existing frame's instances to harvest component keys) — that pattern must keep working. The block target is specifically **write** API calls inside `use_figma`'s `code` string, not the tool itself.

## Goal

A `PreToolUse` Claude Code hook, wired in this repo's `.claude/settings.json`, that:
1. Unconditionally blocks `create_new_file` and `generate_figma_design` (both are inherently content-creating; there is no read-only mode for either).
2. Statically inspects `use_figma`'s `code` parameter for Figma Plugin API write-call patterns and blocks the call (non-zero exit / deny) if any are found, with a clear message citing this ruling and the exact pattern(s) matched. Allows the call through if it's provably read-only.
3. Is fast (sub-100ms, no network, no Figma call of its own) and has near-zero false-positive rate on real read-only scripts — false positives that block legitimate inspection work are exactly the kind of thing that gets a hook silently disabled.

## Global Constraints

- Model this on the existing hook pattern in this exact repo: `tools/check-layout-only-classes.mjs` (`--hook` mode: reads Claude Code `PreToolUse`/`PostToolUse` JSON on stdin, blocks via a specific exit code, has its own test suite, is wired in `.claude/settings.json`). Read that file and its wiring in `.claude/settings.json` in full before writing anything — match its I/O contract and test style, don't invent a different one.
- The write-call denylist must be **comprehensive enough to catch what actually happened on 2026-08-19** — verify this concretely: this session's transcript included real `use_figma` calls that created two frames, populated them with ~56 component instances via `createInstance()`/`appendChild()`/`setProperties()`, and later deleted them via `.remove()`. The implementer must construct a test case reproducing the *shape* of those calls (a synthetic `use_figma` code string using `figma.createAutoLayout()`, `.appendChild()`, `instance.setProperties()`, `.remove()`, etc.) and confirm the hook blocks it. Do not rely on a shallow denylist that would have missed the actual incident.
- Build the denylist from the real Plugin API surface, not from memory: grep the Figma `figma-use` skill's `references/plugin-api-standalone.d.ts` (path: `~/.claude/plugins/cache/claude-plugins-official/figma/<version>/skills/figma-use/references/plugin-api-standalone.d.ts`) for mutating method/property names (creation: `create*`; mutation: `appendChild`, `insertChild`, `remove`, `resize`, `clone`, `characters =`, `setProperties(`, `setFillStyleIdAsync`, `effectStyleId =`, `textStyleId =`, `setBoundVariable`, `setVariableCodeSyntax`, `createVariable`, `.fills =`, `.strokes =`, `.visible =`, `.locked =`, `.name =`, `combineAsVariants`, `addComponentProperty`, `createSlot`, `setSharedPluginData`, `importComponent*ByKeyAsync` combined with `.createInstance()`, etc. — build the real list from the typings file, don't hand-guess it).
- Default to **block on ambiguity**, not allow — if the static check cannot confidently classify a `use_figma` code string as read-only, block it and say why, rather than letting an uncertain case through.
- A false positive must be recoverable: the block message should explain exactly what pattern triggered it and where, matching `check-layout-only-classes.mjs`'s existing error style (specific, actionable, cites line/pattern).
- Do not touch `~/.claude/settings.json` (the user's personal global config, out of scope, a different file from this repo's `.claude/settings.json`).
- Also update `core/cem-figma-connect/plans/00-mission-and-decisions.md`'s **D6** entry: its current wording ("Code-only / Figma-only gaps are logged as a first-class report; no Figma authoring in this plan") reads as scoped to "this plan" and was found ambiguous enough that it got violated once already. Reword it to be unambiguous and permanent, and add a pointer to the new hook as the mechanical enforcement. Do not soften or hedge the wording — this was a direct, explicit, "NEVER" ruling.

## Tasks

### Task 1: Build and test the write-pattern denylist as a pure function

- Write `tools/check-figma-write-block.mjs` (or find a better-fitting existing location — check if there's a more appropriate `tools/` subdirectory pattern first) exposing a pure function that takes a `use_figma` `code` string and returns `{ blocked: boolean, reason: string | null, matchedPattern: string | null }`.
- Build the denylist per Global Constraints (grep the real typings file).
- Write a comprehensive test suite (`node --test`) covering: (a) the reconstructed 2026-08-19-incident-shaped code string (must block), (b) a genuine read-only inspection script matching the `figma-generate-design` skill's own documented "2a-ii — inspect existing screens" example code (must NOT block — copy that exact example from the skill doc as a test fixture), (c) at least 5 other individual write patterns each blocking on their own (one test per pattern family: creation, appendChild, remove, setProperties, style/variable mutation), (d) an empty/trivial read-only script (must not block), (e) a script with a write call disguised inside a string literal or comment (verify it still blocks or, if that's a known limitation, document it explicitly as a limitation in the file's header comment rather than silently accepting the gap).

### Task 2: Wire the hook into `.claude/settings.json`

- Add a `PreToolUse` hook entry matching `create_new_file`, `generate_figma_design`, and `use_figma` (the exact matcher pattern for these MCP tool names — determine the real naming convention by inspecting how the existing tools appear in Claude Code's tool-call surface, e.g. `mcp__claude_ai_Figma__use_figma`; verify empirically, don't guess).
- The hook script (thin CLI wrapper around Task 1's pure function): reads the `PreToolUse` JSON off stdin, extracts `tool_name` and (for `use_figma`) `tool_input.code`, unconditionally blocks `create_new_file`/`generate_figma_design`, runs Task 1's check for `use_figma`, and exits/responds however this repo's existing `PreToolUse` hooks signal a block (check `tools/check-layout-only-classes.mjs` again — it's a `PostToolUse` hook; also check `~/.claude/hooks/block-external-pr.sh` for a real, working `PreToolUse` block example in this exact harness, and match ITS exit-code/output contract for `PreToolUse` specifically, since `PreToolUse` and `PostToolUse` blocking may signal differently).
- **Test it end-to-end for real**, not just via the unit test: actually invoke the wired hook against a real `use_figma`-shaped `PreToolUse` payload (construct the JSON yourself, pipe it to the hook script) reproducing both a blocked case and an allowed case, and show the captured output/exit code in the report. Do not just claim it works from the unit test passing — this hook's entire job is intercepting a live tool call, so prove it does.

### Task 3: Update D6's wording and cross-link the enforcement

- Reword `core/cem-figma-connect/plans/00-mission-and-decisions.md`'s D6 per Global Constraints.
- Add a one-line pointer in that same doc (or the nearest appropriate file — your call, say which and why) to `tools/check-figma-write-block.mjs` as the mechanical enforcement, matching the existing style where this repo cross-references its own enforcement mechanisms from decision docs.

## Acceptance

- The reconstructed 2026-08-19-incident-shaped `use_figma` call is blocked by the wired hook, demonstrated live (not just unit-tested).
- The `figma-generate-design` skill's own documented read-only inspection pattern is NOT blocked, demonstrated live.
- `create_new_file` and `generate_figma_design` are unconditionally blocked.
- `send_code_connect_mappings`, `add_code_connect_map`, and `cem-figma-connect`'s own `publish`/`unpublish` remain unaffected.
- D6's wording is unambiguous and cross-linked to the new enforcement.
- This repo's root `pnpm run gate` (or equivalent) stays green.
