# React

The **@m3e/react** package provides idiomatic React bindings for all M3E Web Components. Each component is exposed as its own React module, offering typed props, event mappings, and seamless integration with the React rendering model. However, the React bindings are **client-only**. In Next.js, you **must** use them inside a `"use client"` boundary.

```sh
npm i @m3e/react
```

After installation, import the React module for any component you want to use. Each module wraps the corresponding `@m3e/web` module and exposes a familiar React component API.

For example:

```ts
import { M3eButton } from "@m3e/react/button";
```

React modules automatically register their underlying Web Component, so no additional side-effect imports from `@m3e/web` are required.

**Alternatively, import the `@m3e/react/all` module to load every React binding at once.** This option is convenient when you want full access to the M3E component suite without managing individual modules.

```ts
import "@m3e/react/all";
```

Each React module mirrors the structure of its Web Component counterpart, ensuring a consistent mental model across both ecosystems. Use individual modules for tree-shaking and minimal bundles, or the aggregated module for rapid prototyping and full-suite development.

---
_Source: [`docs/frameworks/react.html`](https://github.com/matraic/m3e/blob/v2.7.3/docs/frameworks/react.html) · `matraic/m3e` @ `v2.7.3`._
