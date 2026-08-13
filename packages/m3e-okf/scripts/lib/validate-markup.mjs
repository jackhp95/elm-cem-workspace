// validate-markup.mjs — structural validation of HTML markup against the CEM
// ground truth, shared by build-examples.mjs (gate authored/mined compositions)
// and check-skill.mjs (audit README snippets shown verbatim on cards).
//
// A markup string is CLEAN only if:
//   - it contains no custom CSS (no class= / style= anywhere),
//   - every <m3e-*> tag exists in the CEM,
//   - every attribute on an m3e element is documented (or a global like
//     slot/id/aria-*/data-*),
//   - every literal-union attribute value is a member of that union,
//   - every slot="x" targets a real slot on its nearest m3e ancestor,
//   - every non-m3e tag is a known native element.
// validateMarkup returns the list of reasons it is NOT clean (empty = clean).

/** Build the ground-truth index: tag -> { attrs:Map(name->type), props:Set, slots:Set }. */
export function buildGroundTruth(comps) {
  const GT = new Map();
  for (const c of comps)
    for (const e of c.elements)
      GT.set(e.tag, {
        attrs: new Map(e.attributes.map((a) => [a.name, a.type || ""])),
        props: new Set(e.properties.map((p) => p.name.toLowerCase())),
        slots: new Set(e.slots.map((s) => (s.name === "(default)" ? "" : s.name))),
      });
  return GT;
}

const GLOBAL_OK = (name) =>
  ["slot", "id", "role", "title", "hidden", "tabindex", "lang", "dir", "is",
   "autofocus", "inert", "contenteditable", "draggable", "spellcheck"].includes(name) ||
  name.startsWith("aria-") ||
  name.startsWith("data-") ||
  name.startsWith("on"); // inline event handlers are valid on any element
const NATIVE = new Set(["div","span","a","img","input","textarea","label","p","time","nav","main","section","header","footer","aside","article","form","fieldset","legend","figure","figcaption","table","thead","tbody","tr","th","td","ul","ol","li","h1","h2","h3","h4","h5","h6","button","slot","br","hr","strong","em","small","i","b","link","body","script","meta"]);
const VOID = new Set(["img", "input", "br", "hr", "source", "meta", "link"]);

// ---- minimal HTML tokenizer -> tree -------------------------------------
function parse(html) {
  // Strip HTML comments first: tags inside `<!-- ... -->` never render, so they
  // must not be validated (an invalid tag/attr/slot in a comment is not a real
  // markup error).
  html = html.replace(/<!--[\s\S]*?-->/g, "");
  const root = { tag: "#root", attrs: {}, children: [], parent: null };
  let cur = root;
  // The attribute-string body allows quoted runs (which may legitimately
  // contain `>`, e.g. `data-fn="a > b"`) alongside unquoted chars other than
  // `>`. Without the quoted-run alternative, a `>` inside a value would end the
  // tag early and silently drop every attribute after it.
  const re = /<\/?([a-zA-Z][\w-]*)((?:\s+(?:"[^"]*"|'[^']*'|[^<>"'])*?)?)\s*(\/?)>/g;
  let m;
  while ((m = re.exec(html))) {
    const [, tag, attrStr, selfClose] = m;
    if (m[0][1] === "/") {
      // close tag — walk up to matching
      let n = cur;
      while (n && n.tag !== tag) n = n.parent;
      if (n && n.parent) cur = n.parent;
      continue;
    }
    const attrs = {};
    const ar = /([:\w-]+)(?:=("[^"]*"|'[^']*'|[^\s>]+))?/g;
    let a;
    while ((a = ar.exec(attrStr))) {
      const val = a[2] ? a[2].replace(/^["']|["']$/g, "") : "";
      attrs[a[1]] = val;
    }
    const node = { tag, attrs, children: [], parent: cur };
    cur.children.push(node);
    if (!selfClose && !VOID.has(tag.toLowerCase())) cur = node;
  }
  return root;
}

function nearestM3eAncestor(node) {
  let n = node.parent;
  while (n && !n.tag.startsWith("m3e-")) n = n.parent;
  return n && n.tag.startsWith("m3e-") ? n : null;
}

/**
 * All literals quoted & no bare string/number/boolean => closed union we can
 * check. `null`/`undefined` members are stripped first: a nullable union (e.g.
 * `'square' | '4-leaf-clover' | null`) is still a closed enum of its literal
 * members, so the nullable marker must not disable enum checking — that gap is
 * how `<m3e-shape name="clover">` slipped through.
 */
function closedUnion(type) {
  if (!type || !type.includes("|")) return null;
  const parts = type
    .split("|")
    .map((s) => s.trim())
    .filter((p) => !/^(null|undefined)$/.test(p));
  if (parts.length === 0) return null;
  if (parts.some((p) => /^(string|number|boolean)$/.test(p))) return null;
  const lits = parts.filter((p) => /^["'].*["']$/.test(p)).map((p) => p.replace(/^["']|["']$/g, ""));
  return lits.length === parts.length ? new Set(lits) : null;
}

/**
 * Return the de-duplicated list of reasons `code` is not clean against `GT`
 * ([] = clean). With `allowCss`, the no-custom-CSS rule is skipped — use that
 * when auditing API correctness of markup that may legitimately carry styling
 * (e.g. README example snippets), as opposed to gating pure compositions.
 */
export function validateMarkup(code, GT, { allowCss = false } = {}) {
  const errs = [];
  if (!allowCss && /\b(class|style)=/.test(code)) errs.push("contains custom CSS (class/style)");
  const root = parse(code);
  const walk = (node) => {
    for (const child of node.children) {
      const t = child.tag;
      if (t.startsWith("m3e-")) {
        const gt = GT.get(t);
        if (!gt) {
          errs.push(`unknown tag <${t}>`);
        } else {
          for (const [an, av] of Object.entries(child.attrs)) {
            if (an === "class" || an === "style" || GLOBAL_OK(an)) continue;
            if (gt.attrs.has(an)) {
              const u = closedUnion(gt.attrs.get(an));
              if (u && av && !u.has(av)) errs.push(`<${t}> ${an}="${av}" not in ${gt.attrs.get(an)}`);
            } else if (!gt.props.has(an.replace(/-/g, ""))) {
              errs.push(`<${t}> has undocumented attribute "${an}"`);
            }
          }
        }
      } else if (!NATIVE.has(t.toLowerCase()) && t !== "#root") {
        errs.push(`non-standard tag <${t}>`);
      }
      // slot targeting
      if (child.attrs.slot != null) {
        const par = nearestM3eAncestor(child);
        if (par) {
          const pg = GT.get(par.tag);
          if (pg && !pg.slots.has(child.attrs.slot))
            errs.push(`slot="${child.attrs.slot}" not a slot of <${par.tag}>`);
        }
      }
      walk(child);
    }
  };
  walk(root);
  return [...new Set(errs)];
}
