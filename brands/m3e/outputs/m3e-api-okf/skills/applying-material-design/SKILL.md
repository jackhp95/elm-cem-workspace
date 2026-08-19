---
name: applying-material-design
description: >-
  Applies Material 3 / Material 3 Expressive design guidance in a
  technology-neutral way — component-class selection by intent, foundations and
  styles lookup, expressive-design application, and anti-pattern spotting. Use
  when the user asks how to design a Material 3 / M3 Expressive UI, which kind of
  component fits a job, how to apply color, typography, shape, motion, elevation,
  layout, accessibility, or expressive emphasis, or whether a design choice is a
  Material anti-pattern — on ANY stack (Compose, Flutter, plain CSS, a web
  component library, etc.). For the specific @m3e/web custom-element API (exact
  <m3e-*> tags, attributes, slots, events, CSS tokens), use the m3e skill instead.
---

# Applying Material 3 Expressive design (technology-neutral)

This skill is a **router** into the M3 Expressive **knowledge bundle** — a
technology-neutral design knowledge base. It carries no framework specifics: read
the bundle's `index.md` files, which do the disclosure, then open only the concept
page you need. All links below are **bundle-absolute** (they start with `/`).

Read the bundle index first: [`/knowledge/index.md`](/knowledge/index.md).

Then route by task:

## 1. Pick a component by intent

Don't reach for a component by name — reach by the job to be done, then confirm
the class fits. Start at the component index and read the one-line "what it covers"
column: [`/knowledge/components/index.md`](/knowledge/components/index.md).

Common intents → class:

- Perform an action → [`/knowledge/components/button`](/knowledge/components/button); the single most important action → [`/knowledge/components/fab`](/knowledge/components/fab).
- Move between top-level destinations → [`/knowledge/patterns/navigation`](/knowledge/patterns/navigation) (chooses bar vs rail vs drawer by window size).
- Choose from options → one-of exclusive: [`/knowledge/components/radio-group`](/knowledge/components/radio-group) / [`/knowledge/components/select`](/knowledge/components/select) / [`/knowledge/components/segmented-button`](/knowledge/components/segmented-button); any-of: [`/knowledge/components/checkbox`](/knowledge/components/checkbox) / [`/knowledge/components/chips`](/knowledge/components/chips); on/off: [`/knowledge/components/switch`](/knowledge/components/switch).
- Collect input → [`/knowledge/components/text-field`](/knowledge/components/text-field), assembled per [`/knowledge/patterns/forms`](/knowledge/patterns/forms).
- Interrupt for a decision → [`/knowledge/components/dialog`](/knowledge/components/dialog); a non-blocking message → [`/knowledge/components/snackbar`](/knowledge/components/snackbar).
- Group content about one subject → [`/knowledge/components/card`](/knowledge/components/card); a set of rows → [`/knowledge/components/list`](/knowledge/components/list).

When two classes seem to fit, read both pages' **Usage** sections and prefer the
lower-emphasis one that still communicates. If the intent is a whole screen, start
from a pattern (below), not a single component.

## 2. Look up a foundation or style by task

- Contrast, focus, target size, accessible names → [`/knowledge/foundations/accessibility`](/knowledge/foundations/accessibility).
- Reflow across screen sizes → [`/knowledge/foundations/adaptive-layouts`](/knowledge/foundations/adaptive-layouts) · [`/knowledge/foundations/layout`](/knowledge/foundations/layout).
- Press/hover/focus feedback → [`/knowledge/foundations/interaction-states`](/knowledge/foundations/interaction-states).
- Theming variables → [`/knowledge/foundations/design-tokens`](/knowledge/foundations/design-tokens).
- UI words, labels, alt text → [`/knowledge/foundations/content-design`](/knowledge/foundations/content-design).
- Color roles / theming → [`/knowledge/styles/color`](/knowledge/styles/color); type → [`/knowledge/styles/typography`](/knowledge/styles/typography); shape → [`/knowledge/styles/shape`](/knowledge/styles/shape); motion → [`/knowledge/styles/motion`](/knowledge/styles/motion); elevation → [`/knowledge/styles/elevation`](/knowledge/styles/elevation); icons → [`/knowledge/styles/icons`](/knowledge/styles/icons).

Browse the whole surface: [`/knowledge/foundations/index.md`](/knowledge/foundations/index.md) · [`/knowledge/styles/index.md`](/knowledge/styles/index.md).

## 3. Apply expressive design — checklist

M3 Expressive adds physics-based motion, an expanded/morphing shape system, and an
emphasized type scale. Start at [`/knowledge/expressive/index.md`](/knowledge/expressive/index.md) → [`/knowledge/expressive/what-changed`](/knowledge/expressive/what-changed), then apply:

1. Establish one clear focal point per view; use emphasis to rank, not to decorate — [`/knowledge/expressive/applying-expressive`](/knowledge/expressive/applying-expressive).
2. Push key lines forward with emphasized type, not by resizing everything — [`/knowledge/expressive/emphasized-type`](/knowledge/expressive/emphasized-type).
3. Use spring/physics motion for state changes; keep it purposeful and brief — [`/knowledge/expressive/motion-physics`](/knowledge/expressive/motion-physics).
4. Reserve shape morphing for interaction feedback on prominent controls — [`/knowledge/expressive/shape-morphing`](/knowledge/expressive/shape-morphing).
5. Honor reduced-motion and dense-workflow contexts (see anti-patterns below).

## 4. Spot anti-patterns

Before finalizing, check the design against the known misuses:
[`/knowledge/anti-patterns/index.md`](/knowledge/anti-patterns/index.md) — a FAB
used for non-primary actions, a dialog used for non-blocking info, color as the
only state signal, too many emphasis levels, and over-expressive motion in dense
workflows. Each page gives the symptom, why it hurts, and the better alternative.

---

For the *why* behind Material's evolution, see [`/knowledge/history/index.md`](/knowledge/history/index.md).
Every design claim in the bundle is cited to its source. This skill is
technology-neutral by design — to turn a decision into concrete `@m3e/web` markup,
switch to the **m3e** skill.

_Bundle: OKF v0.1. Guidance validated against the M3 knowledge bundle; last verified 2026-07-11._
