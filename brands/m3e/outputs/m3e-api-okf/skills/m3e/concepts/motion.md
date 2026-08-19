# Motion

M3E primarily applies the [Material Design 3 easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration) system to provide consistent, emotionally tuned transitions across components. A subset—including buttons, loading indicators, and switches—have adopted a spring-based motion physics system — an m3e implementation of Material's [motion physics](https://m3.material.io/styles/motion/overview/how-it-works). Exactly which components use physics-based motion (buttons, loading indicators, switches) is library behavior, not stated by the cited spec page. (m3e behavior)

### Design tokens

The [Material Design 3 design tokens](https://m3.material.io/foundations/design-tokens/overview) are implemented as custom CSS properties. Each token gives one visual decision—a color, type style, spacing step, or elevation level—a stable name, so the same value is defined once and reused consistently across platforms and components.

Motion tokens are surfaced using the standardized prefix `--md-sys-motion-*` and are defaulted to spec-aligned values. M3E provides the [Theme](../components/theme.md) component which can be used to systematically control whether **standard** or **expressive** motion schemes are used through its `motion` attribute.

### Reduced motion

M3E honors reduced motion system settings by dynamically disabling or simplifying transitions for users who prefer minimal motion. Components respond to the `prefers-reduced-motion` media query, ensuring that expressive motion never compromises comfort or accessibility.

---
_Source: [`docs/styles/motion.html`](https://github.com/matraic/m3e/blob/v2.7.3/docs/styles/motion.html) · `matraic/m3e` @ `v2.7.3`._
