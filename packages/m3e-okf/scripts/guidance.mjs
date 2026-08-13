// guidance.mjs — the "when to use which" layer.
//
// Two outputs into data/guidance.json:
//   1. concepts[] — cross-cutting docs (color/density/motion/typography,
//      frameworks, getting-started) extracted from m3e's own doc pages, which
//      are authoritative for THIS library (and cite the canonical m3.material.io
//      pages, which are a JS SPA we can't scrape).
//   2. families[] — a curated taxonomy grouping the 53 components into decision
//      families with selection guidance ("use X when…"). Drives the choosing
//      guide, the grouped index, and per-card cross-links.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(fileURLToPath(import.meta.url), "../..");
const DOCS = path.join(ROOT, ".cache/m3e/docs");
const sources = JSON.parse(fs.readFileSync(path.join(ROOT, "data/sources.json"), "utf8"));
const SHA = sources.sha;

// ---------------------------------------------------------------------------
// HTML -> Markdown for the simple m3e doc pages
// ---------------------------------------------------------------------------
function htmlToMarkdown(html) {
  // isolate the main content pane
  let body = (html.match(/<m3e-content-pane[^>]*id="body"[^>]*>([\s\S]*?)<\/m3e-content-pane\s*>/) ||
    html.match(/<body[^>]*>([\s\S]*?)<\/body\s*>/) || [null, html])[1];
  body = body.replace(/<(script|style)[^>]*>[\s\S]*?<\/\1>/g, "");

  // Decode HTML entities — named plus any numeric (&#123;) — shared by inline
  // prose and code blocks. <pre> content is HTML-escaped upstream (e.g. a
  // `<script>` example arrives as `&lt;script&gt;`), so without this the code
  // blocks would render literal `&lt;`/`&quot;`/`&#123;`.
  const decodeEntities = (s) =>
    s
      .replace(/&nbsp;/g, " ")
      .replace(/&lt;/g, "<")
      .replace(/&gt;/g, ">")
      .replace(/&quot;/g, '"')
      .replace(/&#39;|&apos;/g, "'")
      .replace(/&#(\d+);/g, (_, n) => String.fromCodePoint(+n))
      .replace(/&amp;/g, "&");

  // Rewrite intra-doc links to the skill's layout: the upstream pages link to
  // sibling doc pages as `.html` (e.g. `../components/theme.html`), but in the
  // rendered skill those are `.md`. Leave external/GitHub links untouched.
  const rewriteHref = (h) =>
    /^(https?:|#|mailto:)/.test(h) ? h : h.replace(/\.html(#.*)?$/, ".md$1");

  const inline = (s) =>
    decodeEntities(
      s
        .replace(/<a[^>]*href="([^"]+)"[^>]*>([\s\S]*?)<\/a\s*>/g, (_, h, t) => `[${t.trim()}](${rewriteHref(h)})`)
        .replace(/<code[^>]*>([\s\S]*?)<\/code\s*>/g, (_, t) => `\`${t.trim()}\``)
        .replace(/<(strong|b)[^>]*>([\s\S]*?)<\/\1\s*>/g, (_, __, t) => `**${t.trim()}**`)
        .replace(/<(em|i)[^>]*>([\s\S]*?)<\/\1\s*>/g, (_, __, t) => `_${t.trim()}_`)
        .replace(/<br\s*\/?>/g, " ")
        .replace(/<[^>]+>/g, "")
    )
      .replace(/\s+/g, " ")
      .trim();

  // Infer a fenced-code language for syntax highlighting + agent signal. The
  // upstream <pre> blocks carry no language class, so this is heuristic: markup
  // (starts with `<`) -> html; JSON object/settings -> json; shell installs ->
  // sh; import/module code -> ts; otherwise leave unannotated.
  const inferLang = (code) => {
    const t = code.trim();
    if (/^</.test(t)) return "html";
    if (/^\{[\s\S]*\}$/.test(t) && /"[^"]*"\s*:/.test(t)) return "json";
    if (/^(npm|pnpm|yarn|npx)\b/m.test(t)) return "sh";
    if (/\b(import|export)\b/.test(t)) return "ts";
    return "";
  };

  const out = [];
  // token-walk the block elements in order
  // Each open tag must be followed by whitespace or `>` (`<p(?:\s[^>]*)?>`) so
  // the `<p>` branch doesn't also swallow `<pre>` (and `<li>` doesn't catch
  // `<link>`) — otherwise a paragraph match absorbs the following code block and
  // the next paragraph, inlining code into prose. Closing tags allow whitespace
  // before `>` because some upstream docs split the bracket onto its own line
  // (e.g. `</pre\n          >`, as in Angular's CUSTOM_ELEMENTS_SCHEMA example).
  const blockRe =
    /<m3e-heading[^>]*level="(\d)"[^>]*>([\s\S]*?)<\/m3e-heading\s*>|<p(?:\s[^>]*)?>([\s\S]*?)<\/p\s*>|<pre(?:\s[^>]*)?>([\s\S]*?)<\/pre\s*>|<li(?:\s[^>]*)?>([\s\S]*?)<\/li\s*>/g;
  let m;
  while ((m = blockRe.exec(body))) {
    if (m[1]) out.push(`\n${"#".repeat(Math.min(6, +m[1] + 1))} ${inline(m[2])}\n`);
    else if (m[3] != null) {
      const t = inline(m[3]);
      if (t) out.push(t + "\n");
    } else if (m[4] != null) {
      const code = decodeEntities(m[4].replace(/<[^>]+>/g, "")).trim();
      out.push("```" + inferLang(code) + "\n" + code + "\n```\n");
    }
    else if (m[5] != null) out.push(`- ${inline(m[5])}`);
  }
  return out.join("\n").replace(/\n{3,}/g, "\n\n").trim();
}

const CONCEPT_SOURCES = [
  { slug: "color", title: "Color & theming", src: "styles/color.html" },
  { slug: "density", title: "Density", src: "styles/density.html" },
  { slug: "motion", title: "Motion", src: "styles/motion.html" },
  { slug: "typography", title: "Typography", src: "styles/typography.html" },
  { slug: "getting-started", title: "Getting started", src: "getting-started/overview.html" },
  { slug: "installation", title: "Installation", src: "getting-started/installation.html" },
  { slug: "frameworks-react", title: "React", src: "frameworks/react.html" },
  { slug: "frameworks-vue", title: "Vue", src: "frameworks/vue.html" },
  { slug: "frameworks-angular", title: "Angular", src: "frameworks/angular.html" },
];

// Auditable prose corrections. Applied AFTER html->markdown so `find` strings
// match the rendered markdown (links, backticks, emphasis all present). Fail the
// build if a `find` no longer matches — a stale patch means the upstream text
// changed and a human should re-verify the correction. See data/concept-patches.json.
const patches = JSON.parse(fs.readFileSync(path.join(ROOT, "data/concept-patches.json"), "utf8"));
function applyPatches(slug, md) {
  for (const p of patches[slug] || []) {
    if (!md.includes(p.find)) {
      console.error(`✗ concept-patch for "${slug}" no longer matches (upstream changed?): ${JSON.stringify(p.find.slice(0, 80))}`);
      process.exit(1);
    }
    md = md.split(p.find).join(p.replace);
  }
  return md;
}

const concepts = CONCEPT_SOURCES.filter((c) => fs.existsSync(path.join(DOCS, c.src))).map((c) => ({
  slug: c.slug,
  title: c.title,
  source: `docs/${c.src}`,
  markdown: applyPatches(c.slug, htmlToMarkdown(fs.readFileSync(path.join(DOCS, c.src), "utf8"))),
}));

// Authored concept pages — cross-cutting topics the upstream docs don't cover as
// a page (e.g. wiring m3e form controls into a native <form>). Markdown is read
// verbatim from data/authored-concepts/; its example markup is validated against
// the CEM by check-skill like every other html block in the skill.
const AUTHORED_CONCEPTS = [
  { slug: "forms", title: "Forms & validation", file: "forms.md" },
  { slug: "accessibility", title: "Accessibility", file: "accessibility.md" },
  { slug: "layout", title: "Layout & adaptive design", file: "layout.md" },
  { slug: "interaction-states", title: "Interaction states", file: "interaction-states.md" },
  { slug: "design-tokens", title: "Design tokens", file: "design-tokens.md" },
  { slug: "elevation", title: "Elevation", file: "elevation.md" },
  { slug: "shape", title: "Shape", file: "shape.md" },
  { slug: "icons", title: "Icons", file: "icons.md" },
  { slug: "content-design", title: "Content design", file: "content-design.md" },
];
const authoredDir = path.join(ROOT, "data/authored-concepts");
for (const c of AUTHORED_CONCEPTS) {
  const p = path.join(authoredDir, c.file);
  if (!fs.existsSync(p)) continue;
  concepts.push({ slug: c.slug, title: c.title, authored: true, markdown: fs.readFileSync(p, "utf8").trim() });
}

// ---------------------------------------------------------------------------
// Curated taxonomy — selection guidance. Each component sits in exactly one
// family (for a clean grouped index); cross-family decisions live in `choosing`.
// ---------------------------------------------------------------------------
const families = [
  {
    slug: "actions",
    title: "Actions & buttons",
    blurb: "Elements users click to perform an action.",
    members: ["button", "icon-button", "fab", "fab-menu", "split-button", "button-group", "segmented-button"],
    choosing:
      "Use **button** for standard labeled actions. Drop to **icon-button** when space is tight and the icon is unambiguous. **fab** is the single most important screen action (one per screen); **fab-menu** expands a FAB into related actions. **split-button** pairs a default action with a dropdown of alternates. **button-group** visually unifies several related buttons; **segmented-button** is for picking among 2–5 mutually-exclusive options (closer to a control than an action — for on/off prefer **switch**, for many options prefer **select** or **chips**).",
  },
  {
    slug: "selection-inputs",
    title: "Selection controls",
    blurb: "Form controls for choosing values.",
    members: ["checkbox", "radio-group", "switch", "slider", "chips"],
    choosing:
      "**checkbox** = select zero-or-more from a list. **switch** = a single immediate on/off toggle (applies instantly, no Save). **slider** = a number within a range. **chips** = compact, often dynamic choices: filter-chips for multi-select filtering, input-chips for tokenized entry, suggestion/assist chips for prompts.\n\n_One-of-many — the key fork:_ use **radio-group** when all options should stay **visible** at once and there are only a few (2–5); use **[select](../components/select.md)** (a closed dropdown menu) when the list is **long or should stay collapsed** until opened. Phrases like \"closed list\", \"dropdown\", or \"pick from a menu\" → select. \"Choose one\" with a handful of always-visible options → radio-group. For an inline horizontal one-of-many that reads as a control, **[segmented-button](../components/segmented-button.md)** is a third option.",
  },
  {
    slug: "text-inputs",
    title: "Text input & forms",
    blurb: "Fields for entering and selecting text.",
    members: ["form-field", "select", "autocomplete", "search", "textarea-autosize", "option"],
    choosing:
      "Wrap text inputs in **form-field** for labels, supporting text, and validation styling. **select** = pick one value from a **closed dropdown menu** (the one-of-many control when options stay collapsed; compare with radio-group under Selection controls). **autocomplete** = a text field where the user types and filters live suggestions. **search** = a dedicated search bar/view pattern. **textarea-autosize** grows a multiline field with its content. **option** supplies the items inside select/autocomplete listboxes.",
  },
  {
    slug: "navigation",
    title: "Navigation",
    blurb: "Moving between destinations and through content.",
    members: ["app-bar", "toolbar", "nav-bar", "nav-rail", "nav-menu", "drawer-container", "tabs", "breadcrumb", "toc", "paginator", "stepper", "slide-group"],
    choosing:
      "Top-level destinations: **nav-bar** (bottom, compact/mobile), **nav-rail** (side, medium widths), **drawer-container** (expanded side drawer, large screens) — these are the responsive trio. **nav-menu** is a hierarchical nav tree. Within a page: **tabs** switch peer views; **breadcrumb** shows hierarchy depth; **toc** links to in-page sections; **stepper** walks an ordered multi-step flow; **paginator** moves through pages of data; **slide-group** is directional content paging. **app-bar** is the top header surface; **toolbar** holds contextual actions.",
  },
  {
    slug: "containers",
    title: "Containers & surfaces",
    blurb: "Surfaces that group or reveal content.",
    members: ["card", "content-pane", "dialog", "bottom-sheet", "split-pane", "expansion-panel", "divider", "menu"],
    choosing:
      "**card** groups related content/actions about one subject. **content-pane** is a plain shaped padded surface. For transient focus: **dialog** (modal prompt/decision, blocks the page), **bottom-sheet** (sheet from the bottom, mobile-friendly, supports detents), **menu** (a small contextual list of actions/commands anchored to a trigger). **expansion-panel** shows/hides sections in place. **split-pane** is a resizable two-pane layout. **divider** is a thin rule between items.",
  },
  {
    slug: "data-display",
    title: "Data & collections",
    blurb: "Showing structured or hierarchical data.",
    members: ["list", "tree", "calendar", "datepicker", "date-input", "timepicker"],
    choosing:
      "**list** renders rows of items (optionally selectable/expandable/actionable). **tree** renders nested hierarchy. **calendar** is an inline month/year date surface; **datepicker** is the text-field + popup calendar for forms; **date-input** is the segmented date/time text field (date-only, time-only, or combined) that a datepicker/timepicker wraps; **timepicker** is the field + dial/input popup for choosing a time of day.",
  },
  {
    slug: "feedback",
    title: "Feedback & status",
    blurb: "Communicating status, progress, and messages.",
    members: ["badge", "snackbar", "tooltip", "loading-indicator", "progress-indicator", "skeleton"],
    choosing:
      "**snackbar** = brief, dismissible message about a completed action (global service). **tooltip** = on-hover/focus context for a control. **badge** = a small count/dot on an icon or item. For waiting: **progress-indicator** (linear/circular, determinate or indeterminate), **loading-indicator** (expressive attention-grabbing spinner), **skeleton** (placeholder surface while content loads).",
  },
  {
    slug: "content-media",
    title: "Content & media",
    blurb: "Identity, iconography, and shape primitives.",
    members: ["avatar", "icon", "heading", "shape"],
    choosing:
      "**icon** renders Material Symbols. **avatar** shows a person/entity image or initials. **heading** gives expressive, accessible Material type-scale headings. **shape** applies Material's abstract shape system to arbitrary content.",
  },
  {
    slug: "system",
    title: "System",
    blurb: "Non-visual configuration elements.",
    members: ["theme"],
    choosing: "**theme** is a non-visual element that applies dynamic color/theming tokens to its subtree. See the Color & theming concept page.",
  },
];

fs.writeFileSync(
  path.join(ROOT, "data/guidance.json"),
  JSON.stringify({ sha: SHA, concepts, families }, null, 2)
);
const assigned = families.flatMap((f) => f.members);
console.log(
  `guidance: ${concepts.length} concept pages, ${families.length} families covering ${assigned.length} components`
);
