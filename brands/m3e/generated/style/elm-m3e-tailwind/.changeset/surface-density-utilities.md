---
"tailwind-m3e-web": minor
---

Surface M3 density as `density-0…density-3` scope utilities. Setting one on a container flips `--md-sys-density-scale` for the subtree, so every `@m3e/web` component inside recomputes its height (−4px per step, clamped per component). Density is intentionally not tied to Tailwind's `--spacing`; the layout grid, type, icons, and radius stay fixed. Closes #16.
