# M3E OKF friction issues — DRAFTS for approval

Context: during the cem-figma-connect Code Connect remediation, the agent
repeatedly got m3e component tags/attributes/slots wrong (card slots, nav
`mode`/`orientation`, `selected-icon` slot, badge `size`, multi-element
`slot="actions"`) and had to be taught by the user. Root-cause investigation
found: **every one of those facts was already correctly documented in the
`m3e` skill** — the failure was that the skill + disclosure hook were never
installed/discoverable in the consuming repo, so the agent worked from generic
Material memory. So these issues target discoverability/installation, NOT
content gaps.

Nothing is filed yet. Review, then I'll `gh issue create` the approved ones.

---

## ISSUE 1 (m3e-okf) — Consuming repos get nothing by default; the whole disclosure system was inert
**Labels:** infra, dx, priority:high

**Problem.** The disclosure hook (`hooks/m3e-disclosure.mjs`) and the four
skills require manual install: symlink each skill into `~/.claude/skills`, and
hand-edit `.claude/settings.json` with a **hardcoded absolute path** to the
checkout (the shipped snippet still says `/Users/jack/Documents/code/m3e-docs/…`).
In a real consuming repo (cem-figma-connect) none of it was installed, so the
agent never saw the `m3e` skill and hand-rolled Material from memory — getting
tags/attrs/slots wrong across ~a dozen components, *despite the skill
documenting every fact correctly*.

**Proposal.** A one-command, idempotent installer that:
1. Registers the skills (symlink or copy into `~/.claude/skills`, or ship as a
   Claude Code plugin/marketplace entry so they're discoverable without manual steps).
2. Writes the hook into `.claude/settings.local.json` (gitignored, machine-local)
   with the **resolved** path to the local checkout — no hand-editing, no
   hardcoded `/Users/jack/…`.
3. Detects the checkout location (or takes `--path`), is safe to re-run.

Acceptance: `npx m3e-okf install` (or `node hooks/install.mjs`) in any repo →
skills invocable + hook firing, verified by the hook emitting its nudge on a
`.ts` edit.

---

## ISSUE 2 (m3e-okf) — Disclosure hook misses config-driven m3e repos (`.json`)
**Labels:** hook, enhancement

**Problem.** `UI_EXT` in the hook is `.elm/.html/.js/.mjs/.ts/.jsx/.tsx/.astro/
.vue/.svelte/.css/.templ`. A Code-Connect repo defines its m3e UIs in
`examples.json` / `set-attrs.json` (`.json`), so the hook never fired on the
edits that actually author m3e markup there.

**Proposal.** Either add `.json` to `UI_EXT`, or make `UI_EXT` configurable
per repo (env var or a `.m3e-okf.json`), so config-/data-driven m3e repos get
the disclosure too.

---

## ISSUE 3 (m3e-okf) — Ship L2/L3 per-component disclosure (hook is L1-lite)
**Labels:** hook, enhancement

**Problem.** The hook only nudges "invoke the `m3e` skill" (L1-lite). The
rev-2 design (`planning/execution/2026-07-21-m3e-okf-hook-design.md` §7a) calls
for L2/L3 per-component disclosure (inline the compact card for the component
being edited). Without it, the agent still has to take a second step, and if
the skill isn't installed (Issue 1) the nudge dead-ends.

**Proposal.** Build the index + L2/L3 disclosure so the hook can inline the
relevant component's tag/attrs/slots when it detects the component in the edit.

---

## ISSUE 4 (m3e-okf) — Auto-update skill: keep the checkout current, deterministically
**Labels:** skill, infra

**Problem.** No mechanism keeps a consumer's m3e-okf checkout current, so a
stale checkout silently serves stale API facts.

**Proposal.** A deterministic script/skill (the user's request) that, when
invoked, checks `git rev-parse HEAD` vs `origin/main` (fetch), and fast-forwards
ONLY if behind — no-op if current. Non-interactive, safe, logged. Wire it to run
on skill invocation (or a SessionStart hook).

---

## NOT an m3e-okf issue — belongs in cem-figma-connect docs
The Code-Connect **extraction methodology** is this repo's concern, not m3e-okf
(the `m3e` skill is about *writing* UIs, not *extracting* from Figma):
- `get_component_properties` is the extraction layer (INSTANCE_SWAP→glyph+fill,
  VARIANT→attr, presence gated by Show-boolean / Configuration-default) — the
  flattened `contentTree` loses glyph identity.
- The kit's placeholder glyph is `stars_filled` (extract the swap default; fill matters).
- Figma Size VARIANT → code `size` attr by **visual match** (scales differ by name).
→ I'll write this into a cem-figma-connect doc (e.g. `docs/figma-extraction.md`),
  not file it on m3e-okf.
