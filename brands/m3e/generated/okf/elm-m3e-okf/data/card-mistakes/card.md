**Media goes in the `header` slot (or the default slot), not a custom wrapper.** The `header` slot renders without padding — it's the natural home for edge-to-edge images or media. The default (unnamed) slot also renders without padding. Do not create a separate "media seam" or clipping wrapper; the card's corner radius clips its own content.

```html
<!-- ✅ Media in the header slot — no extra clipping needed -->
<m3e-card variant="elevated">
  <img slot="header" src="photo.jpg" alt="…" />
  <div slot="content">…</div>
</m3e-card>
```

See also: [re-abstracting design tokens](/anti-patterns/re-abstracting-design-tokens).

