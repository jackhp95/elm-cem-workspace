---
name: thermo-nuclear-release-audit
description: "2026-07-15 pre-release audit verdict — NOT RELEASABLE, Stage F blocked; 42 blockers; report in planning/release/"
metadata: 
  node_type: memory
  type: project
  originSessionId: 74005aa3-2a38-46cb-85fe-74e0e9860f53
---

Thermo-nuclear pre-release audit of the 6 release units (elm-cem, markup-in-elm-cem, elm-m3e, elm-review-cem, m3e-okf/m3e-docs, elm-cem-template) completed 2026-07-15. 24 reviewers + adversarial panels (60 blocker panels: 51 upheld, 9 killed).

**Verdict: NOT RELEASABLE — do not begin Stage F** of [[release-planning-collection]] runbook. 42 blockers, 78 should-fix, 25 post-release.

Four gating clusters:
- **B1**: every generated facet imports `Markup.*.Internal` modules that markup-core doesn't expose → whole family fails `elm make` from registry (9 dimensions corroborated; most-found defect)
- **B2**: verification gates (isolation-probe, measure-docs, split DAG check) compile app-shaped artifacts that structurally CANNOT see B1
- **B3**: committed markup/src is a two-run half-migration of the text→sharedText flip; barrel doesn't type-check
- **C/D**: release tooling broken (mirror-release.mjs real-push unreachable, npm-release.yml stale elm-tooling action, neutrality gate red on main, elm-m3e CI references deleted files) + docs/CHANGELOG/skills teach the abandoned pre-branding root-monolith publish

**Critical caveat (audit's own critique): nothing was executed** — all compile/publish claims are source-read (sandbox blocked elm make/npm). First follow-up = empirical: `elm make` per publishable elm.json, `npm pack --dry-run`, registry-faithful temp-ELM_HOME gate. Other gaps: publish DAG unsatisfiability unchecked, markup dist-packages is gitignored with no publish provenance, exposed-modules never reviewed as frozen 1.0 API, elm-review-cem + m3e-okf thinly covered.

Report: `planning/release/thermo-nuclear-review-2026-07-15.md` (322 lines, B1–B25 merged entries, runbook-stage mapping, verification ledger). Gaps: `...-audit-gaps.md` alongside. Handoff: `planning/execution/2026-07-15-thermo-nuclear-audit-handoff.md`. Raw findings rescued to `planning/release/raw/`. Cross-machine transport DONE 2026-07-15: full planning/ pushed as `_planning-sync/` on elm-cem branch `planning-sync` (546de0e); **elm-cem flipped PRIVATE for this — flip back to public + delete branch after pickup** (steps in handoff §0). planning/ is not a git repo — open question whether it should be.

Supersedes the "ready to release" assumption in [[elm-m3e-cross-cem-branding]] — WS0–WS7 landed but the landed state does not compile from the registry.
