# Attribution — MDN Web Docs

The native HTML **element and attribute doc-comment summaries** in this library
(`M3e.Native`) are adapted **verbatim** from MDN Web Docs:

> <https://developer.mozilla.org>

Those summaries are sourced from MDN's open-source content repository,
[`github.com/mdn/content`](https://github.com/mdn/content), by the manual refresh
script [`scripts/fetch-mdn-native-summaries.mjs`](../scripts/fetch-mdn-native-summaries.mjs),
which writes them into [`config/native-mdn.json`](./native-mdn.json). elm-cem then
merges that file under `_native.summaries` and stamps each summary as the doc
comment above the corresponding `M3e.Native` constructor / attribute setter.

## License

MDN Web Docs prose is licensed under **CC BY-SA 2.5**:

> <https://creativecommons.org/licenses/by-sa/2.5/>

Per that license, this attribution credits MDN Web Docs as the source. The
generated `M3e.Native` module also carries an inline attribution line in its
module documentation.

## Refreshing

The summaries are a **manual, periodic** refresh — not wired into CI. To update
them against current MDN content:

```
node scripts/fetch-mdn-native-summaries.mjs
```

then regenerate the library (see the script header for the exact `elm-cem`
command, which includes `--config-from=config/native-mdn.json`).
