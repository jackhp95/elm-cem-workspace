// The brand-agnostic guide-markdown SECTION format — the contract shared by the
// authored `content/guides/*.md` files, the Elm reader (`Doc.sections`), and any
// JS validator/migration tool. A section begins at a line `@@@ <name>` and runs
// (trimmed) until the next such delimiter. Owning the split here keeps the Elm
// and JS sides provably in agreement (see the parity test).

/**
 * @param {string} raw the whole .md file contents
 * @returns {Record<string,string>} name -> section content (trimmed)
 */
export function splitSections(raw) {
  const out = {};
  const parts = ("\n" + raw).split("\n@@@ ").slice(1);
  for (const part of parts) {
    const i = part.indexOf("\n");
    const name = (i === -1 ? part : part.slice(0, i)).trim();
    out[name] = (i === -1 ? "" : part.slice(i + 1)).trim();
  }
  return out;
}

/**
 * Assemble sections back into the `@@@`-delimited file format (the inverse of
 * `splitSections`, used by a migration tool that lifts prose out of source).
 * @param {{name: string, content: string}[]} sections
 * @returns {string}
 */
export function joinSections(sections) {
  return sections.map((s) => `@@@ ${s.name}\n${s.content}\n`).join("\n");
}
