# Installation

The M3E Web Component library is distributed as a single package under the **@m3e/web** namespace.

```sh
npm i @m3e/web
```

After installing the package, each component can be imported individually through its own module.

For example:

```ts
import "@m3e/web/button";
```

**Alternatively, import the `@m3e/web/all` module to load every component at once.** This option is convenient when you want full access to the M3E ecosystem without managing individual modules.

```ts
import "@m3e/web/all";
```

### Native module support

Each package uses [JavaScript Modules](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules#module_specifiers) and documents their native module support. To use a module directly in a browser without a bundler, use a module script similar to the following.

```html
<script type="module" src="/node_modules/@m3e/web/dist/button.js"></script>
```

In addition, you must also use an [import map](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/script/type/importmap) to include dependencies. The following is an example import map that imports all entry points for `@m3e/web/core`.

```html
<script type="importmap">
  {
    "imports": {
      "tslib": "https://cdn.jsdelivr.net/npm/tslib@2.8.1/+esm",
      "lit": "https://cdn.jsdelivr.net/npm/lit@3.3.0/+esm",
      "lit/": "https://cdn.jsdelivr.net/npm/lit@3.3.0/",
      "lit-html": "https://cdn.jsdelivr.net/npm/lit-html@3.3.0/+esm",
      "lit-html/directive.js": "https://cdn.jsdelivr.net/npm/lit-html@3.3.0/directive.js",
      "lit-html/directives/if-defined.js": "https://cdn.jsdelivr.net/npm/lit-html@3.3.0/directives/if-defined.js",
      "lit-html/directives/class-map.js": "https://cdn.jsdelivr.net/npm/lit-html@3.3.0/directives/class-map.js",
      "@lit/reactive-element": "https://cdn.jsdelivr.net/npm/@lit/reactive-element@2.0.4/+esm",
      "@lit/reactive-element/": "https://cdn.jsdelivr.net/npm/@lit/reactive-element@2.0.4/",
      "@m3e/web/core": "/node_modules/@m3e/web/dist/core.js",
      "@m3e/web/core/a11y": "/node_modules/@m3e/web/dist/core-a11y.js",
      "@m3e/web/core/anchoring": "/node_modules/@m3e/web/dist/core-anchoring.js",
      "@m3e/web/core/bidi": "/node_modules/@m3e/web/dist/core-bidi.js",
      "@m3e/web/core/layout": "/node_modules/@m3e/web/dist/core-layout.js",
      "@m3e/web/core/platform": "/node_modules/@m3e/web/dist/core-platform.js"
    }
  }
</script>
```

For production builds, use the minified files to ensure optimal load performance.

### Editor integration

The `@m3e/web` package includes a [Custom Elements Manifest](https://github.com/webcomponents/custom-elements-manifest) to support enhanced editor tooling and developer experience.

#### Visual Studio Code

To enable autocomplete and hover documentation, install the [Custom Elements Manifest Language Server](https://marketplace.visualstudio.com/items?itemName=pwrs.cem-language-server-vscode) extension. It will automatically detect the manifest bundled with this package and surface tag names, attributes, slots, and events in supported files.

Alternatively, you can explicitly reference the `html-custom-data.json` and `css-custom-data.json` in your workspace settings.

```json
{
  "html.customData": ["./node_modules/@m3e/web/dist/html-custom-data.json"],
  "css.customData": ["./node_modules/@m3e/web/dist/css-custom-data.json"]
}
```

---
_Source: [`docs/getting-started/installation.html`](https://github.com/matraic/m3e/blob/v2.7.3/docs/getting-started/installation.html) · `matraic/m3e` @ `v2.7.3`._
