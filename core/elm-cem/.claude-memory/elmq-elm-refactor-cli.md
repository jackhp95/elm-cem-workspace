---
name: elmq-elm-refactor-cli
description: elmq (caseyWebb) + elm-lsp-rust (CharlonTank, Jack's fork) — the two broad-refactor tools Jack wants agents using; elmq=jq-for-Elm CLI, elm-lsp-rust=MCP-plugin LSP w/ 22 agent tools
metadata: 
  node_type: memory
  type: reference
  originSessionId: d25ef296-75d2-410b-b8b7-54d2e88368f6
---

**elmq** — https://github.com/caseyWebb/elmq — "CLI for querying and editing Elm files, like jq for Elm; next-gen LSP for agents and scripts, not editors." Jack explicitly wants agents using it for Elm refactoring work (2026-07-12). Installed locally via `brew install caseyWebb/tap/elmq` (also `npm i -g @caseywebb/elmq`; Claude Code plugin `/plugin install elmq@caseyWebb`; `elmq guide` prints the agent guide).

Commands: `list/get/grep/refs/variant` (read), `set/patch/rm/rename/add/expose/unexpose/mv/move-decl` (write, project-wide reference updates, parse-safe — refuses to write non-parsing output). `--format json` available.

**Verified limitation (2026-07-12):** project discovery requires an *application* elm.json — fails on package-type ("missing field `source-directories`"), and it resolves the project from the FILE's ancestors, not cwd. **App-shim recipe:** temporarily swap the package elm.json for `{"type":"application","source-directories":["src"],"elm-version":"0.19.1","dependencies":{"direct":{"elm/core":"1.0.5"},"indirect":{}},"test-dependencies":{"direct":{},"indirect":{}}}` (deps need only parse, not resolve), run the ops, restore. Works natively in app-type dirs (elm-cem `codegen/`, any `tests/`). Verified `mv` correctly rewrites imports + qualified refs.

**elm-lsp-rust** (2026-07-21 CORRECTION — the memory previously named the WRONG tool) = **CharlonTank/elm-lsp-rust**, Jack forked it as `jackhp95/elm-lsp-rust` (2026-07-03). Tree-sitter Elm LSP, binary `elm_lsp` (`cargo build --release`). **Agent-facing via 22 MCP tools** (NOT a bare editor-only LSP): semantic cross-file rename, find-refs, list-symbols, move-function-to-module, rename/move file WITH import updates, add/remove variant (auto case branches), remove field, real-compiler diagnostics via `elm make`/`lamdera make`, `elm-format`. Installs as a Claude Code plugin: `/plugin marketplace add CharlonTank/elm-lsp-plugin` then `/plugin install elm-lsp-rust@CharlonTank/elm-lsp-plugin` (auto-runs `scripts/setup.sh` → builds the binary; stdio or HTTP modes). **NOT `lue-bird/elm-language-server-rs`** — that's a different pure-LSP-no-tools project the old note confused it with.

Complement: **elmq** = pure CLI (shell-scriptable, app-shim for packages); **elm-lsp-rust** = MCP tools + REAL compiler diagnostics + tree-sitter partial-parse tolerance. Use both for broad refactors — elmq for scripted structural edits, elm-lsp-rust for semantic rename/move + diagnostics. As of 2026-07-21 elm-lsp-rust is NOT installed on Jack's machine and its MCP tools are NOT wired into Claude Code sessions yet (elmq IS, via brew).

Related: [[elm-m3e-cross-cem-branding]].
