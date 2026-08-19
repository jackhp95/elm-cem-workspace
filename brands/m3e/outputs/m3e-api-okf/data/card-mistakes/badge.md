**Do not wrap the badge and its target in a positioning container.** The badge positions itself relative to the element referenced by `for` — no `relative`/`absolute` wrapper needed. See [wrapping self-positioning components](/anti-patterns/wrapping-self-positioning-components).

```html
<!-- ✅ Correct -->
<m3e-icon-button id="notifications">…</m3e-icon-button>
<m3e-badge for="notifications">5</m3e-badge>

<!-- ❌ Wrong — fights the component's positioning -->
<span style="position: relative">
  <m3e-icon-button>…</m3e-icon-button>
  <m3e-badge style="position: absolute; top: 0; right: 0">5</m3e-badge>
</span>
```

