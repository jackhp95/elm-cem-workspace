@@@ intro
Material 3 theming is *token-driven*. You do not hand-author a palette: you give the system a small number of inputs — one seed color, a scheme, a contrast, a density — and it derives the full set of color roles (primary, secondary, tertiary, their containers, the surface ramp, outline, error…) as `--md-sys-*` CSS custom properties. Every `@m3e/web` component reads those tokens, so styling the whole app is a matter of setting the inputs once and reaching for roles, never raw colors.

For the neutral *theory* — how dynamic color derives a tonal palette from a single seed, what the tonal system and the type scale are, why design tokens decouple intent from value — read the **m3e-okf knowledge base** (`github.com/jackhp95/m3e-okf`), pages `styles/color`, `styles/typography`, and `foundations/design-tokens`. This guide is the Elm-specific how-to: the `M3e.Theme` component and the practice that keeps a theme a theme.

@@@ rootBody
Wrap the app — or any subtree — in `M3e.Theme.component`. It is a non-visual element: it emits no box of its own, it just publishes the derived token roles to everything nested inside it. The docs app themes once, at the root, in `docs/app/Shared.elm`:

@@@ rootNote
Those four inputs are the whole surface most apps need. `Theme` also carries `strongFocus` (strengthen the focus ring — an accessibility aid, see [Accessibility](/guide/accessible-by-construction)), `variant` (the dynamic-color scheme flavor), and `motion` (`M3e.Values.standard` for functional transitions, `M3e.Values.expressive` for spring-like emphasis — see [Motion](/guide/motion)). Set the theme once and inherit it; you rarely nest a second `Theme`, and when you do it is a deliberate island (a preview swatch, an inverted hero) — not a way to patch one component's color.

@@@ rolesBody
Inside a themed subtree, never paint with a hex value. Reach for the **role** the element plays. A primary action is `primary`; text on a surface is `onSurface`; de-emphasized text is `onSurfaceVariant`. The role keeps its contrast correct against whatever surface it sits on — automatically, and in both light and dark — because both sides of the pair (`surface`/`onSurface`) are derived together from the same seed.

The way you *name* a role is by **choosing the component and slot that already means it** — not by writing a color class. An `m3e-card` with `variant="filled"` IS the container-surface role, and it sets its own foreground to match. An `m3e-list-item`'s `supporting-text` slot IS the de-emphasized role, at the right type scale, with no class at all. An `m3e-button` with `variant="filled"` IS the primary action, with the state layer and focus ring that a painted `<div>` never gets:

@@@ tokenFamilies
**The `--md-sys-*` families.** A seed derives, per scheme, families like: `--md-sys-color-*` (the role palette — `primary`, `on-primary`, `primary-container`, the `surface`/`surface-container-*` ramp, `outline`, `error`, `scrim`, `surface-tint`), `--md-sys-typescale-*` (the type scale — display/headline/title/body/label at large/medium/small), `--md-sys-shape-corner-*` (the corner scale), `--md-sys-elevation-*`, `--md-sys-motion-*`, and `--md-sys-state-*`. You almost never write these names by hand — the color/typography/shape helpers and the component variants resolve to them — but knowing the families is how you read a computed style and recognize what a component is honoring.

@@@ darkBody
Dark mode is **not** a second stylesheet. It is one input flipped: `Theme.scheme` between `M3e.Values.light` and `M3e.Values.dark`. The docs app holds `scheme` in its `Shared.Model` and toggles it; the whole role palette re-derives for the new scheme and every component follows. Dynamic color is the same move on a different input: change `Theme.color` and the entire palette re-derives from the new seed — no per-role editing anywhere. Contrast is orthogonal (`standard` / `medium` / `high`) for readers who need it.

@@@ reskinBody
Put it together. Suppose a brand refresh: a new accent color, a slightly softer corner language, a touch more compactness. In a token-driven system that is a handful of `Theme` inputs and one shape default — not a sheet of overrides. Nothing in the views changes, because the views only ever named roles:

@@@ reskinNote
That is the entire re-skin. Because every surface is a component that reads its own role from the theme -- and the few non-default values go through that component's own `m3e-*` property -- the new seed and density reach every screen at once. There is nothing to find-and-replace, no stylesheet to audit, and no screen can drift from the brand because no screen ever hard-coded a brand value or hand-painted a surface.

@@@ bridgeBody
Utility CSS (Tailwind, in the docs app) is legitimate — for **layout only**: flex, grid, gap, padding, positioning, responsive visibility. It must never paint. Background, color, border, corner, elevation and type scale are **the component's job**, and there is a strict order to reach for:

1. **the m3e component itself** — a panel is an `m3e-card`, a row of items is `m3e-list` + `m3e-list-item`, a rule is an `m3e-divider`;
2. **that component's attributes and slots** — `variant`, `size`, and the named slots (`m3e-list-item`'s `supporting-text` slot already carries the de-emphasized role *and* its type scale, so it needs no class at all);
3. **that component's own CSS custom properties**, reached through the generated `m3e-*` utilities — `m3e-filled-card-container-color-primary-container`, `m3e-card-shape-md-corner-large`. These are ordinary Tailwind classes, generated one per public `--m3e-*` property, and they are the *only* sanctioned way to set a visual value from a class.

A design-token utility like `bg-primary` or `rounded-md-corner-large` is **not** on that list. It hand-paints a surface the component already knows how to paint, and a hand-painted surface inherits none of the component's state layers, motion, density or accessibility.

**And never a stylesheet.** Do not answer "the component has no knob for this" with a custom CSS class — not even one built from `var(--md-sys-color-*)`. A class in a `.css` file is invisible at the call site, cannot be purged, and hides the very gap you should be reporting. If steps 1–3 genuinely cannot express something, that is an **m3e gap worth filing**, not a licence to write CSS.

The layout boundary is enforced mechanically — the repo-local `NoProprietaryDsClasses` rule reads every `class` literal (and through `++`, `if` and `case`) and flags anything that paints — and it is the same rule that keeps [layouts](/guide/composition-text-field) honest.

@@@ recap
- Theme **once, at the root**: `M3e.Theme.component` fed a **seed color plus scheme / contrast / density** derives every `--md-sys-*` role.
- **Paint with roles, not hex** — `primary`, `onSurface`, `surfaceContainer` keep contrast correct in light *and* dark automatically.
- **Dark = flip `scheme`; dynamic = swap `color`.** One input, whole palette re-derives — never a second stylesheet.
- A **brand re-skin is a few `Theme` inputs**, not a sheet of overrides — views untouched because they named roles.
- **Let components paint; Tailwind only lays out.** Reach in order: the component, then its attributes/slots, then its own `m3e-*` property. A `bg-*`/`rounded-*` token class is already hand-painting, and a custom CSS class is never the answer -- an inexpressible style is an m3e gap to file. `NoProprietaryDsClasses` makes the layout boundary mechanical.
- Deep color-system theory lives in **m3e-okf** (`styles/color`, `foundations/design-tokens`); this page is the Elm practice.
