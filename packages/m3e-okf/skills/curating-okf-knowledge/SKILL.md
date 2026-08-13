---
name: curating-okf-knowledge
description: >-
  Authors and curates concept pages in the technology-neutral M3 Expressive
  knowledge bundle (data/knowledge/**, OKF v0.1) for the m3e-docs repo. Use when
  adding, revising, or reviewing a knowledge/ page — writing the frontmatter
  (including sources:), choosing the Diátaxis type, keeping the prose neutral and
  properly cited, deciding whether a topic belongs in knowledge/ vs
  implementations/ vs history/, and running the validation loop (validate-okf +
  citation-presence + audit-guidance) until it is clean. This is a maintainer
  workflow for m3e-docs contributors; it is rule-bound and low-freedom — follow
  the templates exactly.
disable-model-invocation: true
---

# Curating the OKF knowledge bundle

The bundle is **generated**: you author in `data/knowledge/**`, then
`scripts/build-okf.mjs` copies concept files verbatim and derives every `index.md`.
**Never hand-edit `knowledge/**` or `implementations/**`** — edit the source and
rebuild. This skill is rule-bound: use the exact templates in
[`reference/frontmatter.md`](reference/frontmatter.md) and follow the loop below.

## 1. Decide where the topic belongs

- **`data/knowledge/`** — technology-neutral Material 3 / M3E design guidance
  (foundations, styles, per-class component concepts, expressive, patterns,
  anti-patterns). NO framework or `<m3e-*>` specifics here. Pick the section:
  foundations (cross-cutting, pre-component), styles (color/type/shape/motion/
  elevation/icons), components (one neutral page per class), expressive (what M3E
  adds), patterns (multi-component flows), anti-patterns (misuses).
- **`data/knowledge/history/`** — how Material/M3E evolved and rolled out; use
  `type: history`. Narrative, not prescriptive guidance.
- **`implementations/m3e-web/`** — the tech-specific, CEM-verified `<m3e-*>` API.
  You do NOT author these here; they are generated from `data/` by
  `build-skill.mjs`. Tags/attributes/framework code belong ONLY under
  implementations/, never in `knowledge/`.

A neutral component page links to its verified card by bundle-absolute path, e.g.
`[/implementations/m3e-web/components/button](/implementations/m3e-web/components/button)`.

## 2. Write the page

1. Create `data/knowledge/<section>/<slug>.md`.
2. Add frontmatter — copy the exact template from
   [`reference/frontmatter.md`](reference/frontmatter.md). Required: `type`.
   Recommended (fill them all — the validator warns otherwise): `title`,
   `description`, `resource`, `tags`, `timestamp`. Plus `diataxis` and `sources:`.
3. Choose the **Diátaxis** type (`diataxis:`): `explanation` (why/concept —
   default for guidance), `reference` (a factual per-class anatomy page),
   `how-to` (a task recipe), `tutorial` (a guided lesson). See `reference/`.
4. Write neutral prose that **paraphrases** the source — never paste. See the
   licensing rationale (D6) below and in `reference/frontmatter.md`.
5. Every design claim needs a citation. Any page whose prose uses directive words
   (should / prefer / avoid / never / always / must / "use … when") MUST carry a
   non-empty `sources:` list OR an inline `m3.material.io` link, or `validate-okf`
   fails it. Prefer the `sources:` block: each entry is `url` + `retrieved` +
   `note`.

## 3. Paraphrase-and-cite / licensing (D6)

Material's guidance text is not ours to redistribute verbatim. **Read the source,
then write the idea in your own words** and cite it with `sources:`. Do not copy
sentences or long phrases. The rule of thumb the repo enforces: no run of **15+
consecutive words** identical to a source. Cite the specific spec page you drew
each claim from (not just the section root). This keeps the bundle original,
attributable, and technology-neutral.

## 4. Validation loop — run until clean

From the repo root, rebuild then validate; fix; repeat:

```
npm run gen:okf              # regenerate knowledge/ + implementations/
npm run check:okf-validity   # FATAL: missing type, index/log frontmatter,
                              #        design-claim page with no citation
node scripts/audit-guidance.mjs   # coverage + uncited-guidance report
```

- `check:okf-validity` (`validate-okf.mjs`) exit 1 = a fatal error. Read the `## Errors` list and fix
  each: add `type`, add a citation, remove frontmatter from an `index.md`/`log.md`.
- Broken links and missing recommended keys are **reported, not fatal** — but fix
  the recommended-key warnings anyway (fill `title`/`description`/… ).
- `audit-guidance.mjs` lists **uncited guidance** pages (≥5 claims, no m3
  citation). CI ratchets this at `--max-uncited 1`; don't add a new offender.
- Citation-presence is checked by `check:okf-validity` (the `sources:`/inline-m3 rule).
- **Paraphrase check (D6):** run `npm run check:paraphrase -- [<section>/<slug>]`
  — it fetches each cited source and flags any 15+-word run copied verbatim (exit 1
  on a hit). It's OPT-IN, not in CI (it makes network calls; CI runs committed
  inputs only), so run it locally while authoring. If it flags a run, reword until
  clean.

Do NOT commit until `npm run check:okf` (freshness + validity) is green.

## 5. Log the change

Append a dated bullet to `data/knowledge/log.md` (newest first) noting what
entered the bundle and on what basis. `log.md` is a reserved OKF file — **no
frontmatter**.

---

Full frontmatter template, Diátaxis selection, and the citation rules:
[`reference/frontmatter.md`](reference/frontmatter.md).

_Grounded in data/knowledge/** frontmatter + scripts/lib/validate-okf.mjs; last verified 2026-07-11._
