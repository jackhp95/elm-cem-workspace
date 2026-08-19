// Builds dist/search-index.json (titles + headings, no body text — see
// specs/2026-08-07-nav-rail-search-design.md) by crawling the already-built
// dist/**/index.html. Runs AFTER `elm-pages build` (chained into
// `build:site`), never before: it reads rendered output, not Elm source.
//
// The route list comes from elm-pages' own dist/all-paths.json manifest, not
// a glob over dist/**/*.html -- that directory also holds non-route files
// (template.html, elm-stuff/) a glob would have to hand-exclude.

import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { parseHTML } from "linkedom";

const here = path.dirname(fileURLToPath(import.meta.url));
const DIST = path.resolve(here, "../../dist");
const ALL_PATHS = path.resolve(DIST, "all-paths.json");
const OUT = path.resolve(DIST, "search-index.json");

const HEADING_SELECTOR = "#main-content h1, #main-content h2, #main-content h3, #main-content h4, #main-content h5, #main-content h6, #main-content m3e-heading";

/**
 * Pure: given one page's rendered HTML and its route path, returns the
 * search entries for that page (the page itself, heading = null, plus one
 * entry per non-empty heading found inside #main-content). Headings outside
 * #main-content (the rail/app-bar/drawer chrome, identical on every page)
 * are not selected in the first place -- `HEADING_SELECTOR` scopes to
 * `#main-content` directly, so there's nothing to filter out afterward.
 *
 * A page with no #main-content (the `/examples/*` routes, which render with
 * no docs shell at all) indexes its title only -- `document.querySelectorAll`
 * on a missing ancestor simply matches nothing, so this falls out of the
 * selector rather than needing a special case.
 *
 * A page with no <title> returns no entries at all (skipped, not crashed --
 * elm-pages guarantees a title on every real route, so this only guards
 * against a malformed/unexpected file, not the normal case).
 */
export function extractEntries(html, url) {
  const { document } = parseHTML(html);
  const title = document.querySelector("title")?.textContent;
  if (!title) return [];

  const entries = [{ url, title, heading: null, anchor: null }];
  for (const el of document.querySelectorAll(HEADING_SELECTOR)) {
    const heading = el.textContent.trim();
    if (!heading) continue;
    entries.push({ url, title, heading, anchor: el.id || null });
  }
  return entries;
}

function fileForPath(routePath) {
  return routePath === "/"
    ? path.join(DIST, "index.html")
    : path.join(DIST, routePath, "index.html");
}

function main() {
  const routes = JSON.parse(fs.readFileSync(ALL_PATHS, "utf8"));
  const entries = routes.flatMap((routePath) => {
    const file = fileForPath(routePath);
    if (!fs.existsSync(file)) {
      console.warn(`search-index: no HTML file for route ${routePath} (expected ${file}), skipping`);
      return [];
    }
    return extractEntries(fs.readFileSync(file, "utf8"), routePath);
  });
  fs.writeFileSync(OUT, JSON.stringify(entries));
  console.log(`search-index: wrote ${entries.length} entries (${routes.length} routes) to ${OUT}`);
}

// Only run the crawl when executed directly (`node build-search-index.mjs`),
// not when the test file imports `extractEntries`.
if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}
