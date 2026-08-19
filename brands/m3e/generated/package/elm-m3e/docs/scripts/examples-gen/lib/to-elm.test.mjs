import { test } from "node:test";
import assert from "node:assert/strict";
import { buildOracle } from "./oracle.mjs";
import { loadFacts } from "./facts.mjs";
import { toElm } from "./to-elm.mjs";

// Phase 1 (L5 revive): these assertions were re-baselined from the retired
// `M3e.<Mod>.view` / `Kit.*` / `Native.*` vocab (which targeted the DELETED
// docs/kit against an older elm-m3e API) to the CURRENT library the converter
// now emits against, sourced from Face C via the canonical elm-shape engine:
//   - component call form  `M3e.Component.<N>.component` (double-list) or the
//     `{ <requiredSlot fields…>, <requiredAttr fields…>, action? }` record form.
//   - text seam `M3e.text`; plain HTML `TypedHtml.<tag>`; raw attr
//     `TypedHtml.Unsafe.Attributes.customAttribute`; dynamic tag
//     `M3e.Unsafe.customElement`; `<a href>` -> `TypedHtml.a`.
//   - enum tokens `M3e.Values.<ctor>` (incl. the value-prefix); action
//     `M3e.Action.none` (only when the component usesAction).
const oracle = buildOracle();
const facts = loadFacts();
const conv = (h) => toElm(h, oracle, facts);

test("button with icon slot + text (record form: content + action)", () => {
  const r = conv(
    `<m3e-button variant="filled"><m3e-icon slot="icon" name="add"></m3e-icon>New</m3e-button>`,
  );
  assert.deepEqual(r, {
    code: `M3e.Component.Button.component { content = M3e.text "New", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.filled ] [ M3e.Component.Button.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "add" ] []) ]`,
  });
});

test("plain text-only button", () => {
  assert.deepEqual(conv(`<m3e-button variant="tonal">Tonal</m3e-button>`), {
    code: `M3e.Component.Button.component { content = M3e.text "Tonal", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal ] []`,
  });
});

// A checkbox (double-list form) WITHOUT aria-label converts fine — a11y
// requirements live in elm-review rules now.
test("checkbox without aria-label converts (double-list form)", () => {
  assert.deepEqual(conv(`<m3e-checkbox checked></m3e-checkbox>`), {
    code: `M3e.Component.Checkbox.component [ M3e.Component.Checkbox.checked True ] []`,
  });
});

// --- (a) record view form with a REQUIRED attr field ----------------------

// IconButton's `component` takes `{ content, ariaLabel, action }` — aria-label is
// a REQUIRED RECORD FIELD (Face C `requiredAttrs`), not a universal setter, and
// the single default icon child folds into `content`.
test("icon-button: aria-label is a required record field; icon -> content", () => {
  const r = conv(
    `<m3e-icon-button aria-label="Toggle theme"><m3e-icon name="dark_mode"></m3e-icon></m3e-icon-button>`,
  );
  assert.deepEqual(r, {
    code: `M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "dark_mode" ] [], ariaLabel = "Toggle theme", action = M3e.Action.none } [] []`,
  });
});

// For a component that does NOT make aria-label a required record field
// (checkbox), aria-label IS a universal setter (TypedHtml.Aria.label).
test("checkbox aria-label -> TypedHtml.Aria.label universal setter", () => {
  const r = conv(`<m3e-checkbox aria-label="Accept" checked></m3e-checkbox>`);
  assert.deepEqual(r, {
    code: `M3e.Component.Checkbox.component [ TypedHtml.Aria.label "Accept", M3e.Component.Checkbox.checked True ] []`,
  });
});

// A custom element in a text-admitting slot is a component the slot admits as an
// ELEMENT kind — it must NOT fold to `M3e.text` (folding dropped the element and
// misaligned the round-trip DOM-diff). Only generic wrappers fold.
test("custom element in a text-admitting slot is preserved, not folded to text", () => {
  const r = conv(
    `<m3e-nav-menu-item-group><m3e-heading m3e-toc-ignore slot="label" variant="label" size="large">Mail</m3e-heading></m3e-nav-menu-item-group>`,
  );
  assert.match(r.code, /NavMenuItemGroup\.label \(M3e\.Component\.Heading\.component /);
  assert.doesNotMatch(r.code, /NavMenuItemGroup\.label \(M3e\.text "Mail"\)/);
});

// A generic text-only wrapper folds to `M3e.text` — and for NavMenuItem the
// `label` slot is a REQUIRED RECORD FIELD (Face C requiredSlots=["label"]), so it
// lands as `{ label = M3e.text "Inbox" }`, not a trailing slot setter.
test("generic text-only wrapper in a required label slot folds into the record", () => {
  const r = conv(
    `<m3e-nav-menu-item><span slot="label">Inbox</span></m3e-nav-menu-item>`,
  );
  assert.deepEqual(r, {
    code: `M3e.Component.NavMenuItem.component { label = M3e.text "Inbox" } [] []`,
  });
});

// Universal id/class -> `M3e.Attributes` (open-row). `style` (a 2-arg setter now)
// and a non-typed `for` fall through to the raw-attribute escape rather than an
// invalid 1-arg / absent-capability setter.
test("top: universal id/class via M3e.Attributes; style/for via customAttribute", () => {
  const html = `<m3e-checkbox id="c1" class="a b" style="color: red; --x: 1px" for="ctrl" checked></m3e-checkbox>`;
  assert.deepEqual(conv(html), {
    code: `M3e.Component.Checkbox.component [ M3e.Attributes.id "c1", M3e.Attributes.class "a b", TypedHtml.Unsafe.Attributes.customAttribute "style" "color: red; --x: 1px", TypedHtml.Unsafe.Attributes.customAttribute "for" "ctrl", M3e.Component.Checkbox.checked True ] []`,
  });
});

// A component that DOES declare `for` (m3e-app-bar) keeps its TYPED setter.
test("top: typed `for` (m3e-app-bar) is preserved via Face C's setter", () => {
  assert.deepEqual(conv(`<m3e-app-bar for="scrollContainer"></m3e-app-bar>`), {
    code: `M3e.Component.AppBar.component [ M3e.Component.AppBar.for "scrollContainer" ] []`,
  });
});

// A record-form component whose required content has no source child cannot be
// honestly rendered at the top surface -> skip (it still ships its HTML surface).
test("icon-button with no default content -> skip (required content absent)", () => {
  const r = conv(`<m3e-icon-button aria-label="X"></m3e-icon-button>`);
  assert.ok(r.skip && /content/.test(r.skip), r.code || r.skip);
});

test("icon standalone (double-list form)", () => {
  assert.deepEqual(conv(`<m3e-icon name="add"></m3e-icon>`), {
    code: `M3e.Component.Icon.component [ M3e.Component.Icon.name "add" ] []`,
  });
});

test("bool attr on a double-list component (icon filled)", () => {
  assert.deepEqual(conv(`<m3e-icon name="add" filled></m3e-icon>`), {
    code: `M3e.Component.Icon.component [ M3e.Component.Icon.name "add", M3e.Component.Icon.filled True ] []`,
  });
});

test("enum attr rendered via M3e.Values with camelCase", () => {
  assert.deepEqual(conv(`<m3e-button size="extra-large">Big</m3e-button>`), {
    code: `M3e.Component.Button.component { content = M3e.text "Big", action = M3e.Action.none } [ M3e.Component.Button.size M3e.Values.extraLarge ] []`,
  });
});

// A keyword attr (`type`) targets the escaped Face C setter (`type_`).
test("keyword attr `type` -> escaped `type_` setter", () => {
  const r = conv(`<m3e-button variant="filled" type="submit">Submit</m3e-button>`);
  assert.ok(!r.skip, `expected no skip, got: ${r.skip}`);
  assert.match(r.code, /M3e\.Component\.Button\.type_ M3e\.Values\.submit/);
});

// A valid enum value emits its M3e.Values token; an INVALID one degrades to a
// grep-able comment (never a non-existent token that would null the surface).
test("enum: valid value emits token, invalid value degrades to a comment", () => {
  assert.deepEqual(conv(`<m3e-nav-bar mode="expanded"></m3e-nav-bar>`), {
    code: `M3e.Component.NavBar.component [ M3e.Component.NavBar.mode M3e.Values.expanded ] []`,
  });
  const bad = conv(`<m3e-nav-bar mode="extended"></m3e-nav-bar>`);
  assert.match(bad.code, /\{- round-trip: dropped mode="extended" on m3e-nav-bar/);
  assert.doesNotMatch(bad.code, /M3e\.Values\.extended/);
});

// Multiple default children: the FIRST default folds into the record `content`;
// the rest trail in the children list (source order preserved).
test("multiple default children -> first folds to content, rest trail", () => {
  assert.deepEqual(
    conv(`<m3e-button variant="text"><m3e-icon name="a"></m3e-icon>Hi</m3e-button>`),
    {
      code: `M3e.Component.Button.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "a" ] [], action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.text ] [ M3e.text "Hi" ]`,
    },
  );
});

test("string attr with escaping", () => {
  const r = conv(`<m3e-button href='/a"b'>Go</m3e-button>`);
  assert.deepEqual(r, {
    code: `M3e.Component.Button.component { content = M3e.text "Go", action = M3e.Action.none } [ M3e.Component.Button.href "/a\\"b" ] []`,
  });
});

// A non-typed attr is preserved through the raw-attribute escape
// (`TypedHtml.Unsafe.Attributes.customAttribute`), so data-* etc. round-trip.
test("non-typed attr is preserved via the customAttribute escape", () => {
  const r = conv(`<m3e-button data-foo="x" wibble="y">Hi</m3e-button>`);
  assert.equal(r.skip, undefined);
  assert.match(r.code, /TypedHtml\.Unsafe\.Attributes\.customAttribute "data-foo" "x"/);
  assert.match(r.code, /TypedHtml\.Unsafe\.Attributes\.customAttribute "wibble" "y"/);
});

// Universal id/class on an m3e element emit M3e.Attributes setters alongside the
// component's own typed setters.
test("m3e element with id/class emits universal M3e.Attributes setters", () => {
  const r = conv(`<m3e-button variant="filled" id="x" class="y">Go</m3e-button>`);
  assert.deepEqual(r, {
    code: `M3e.Component.Button.component { content = M3e.text "Go", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.filled, M3e.Attributes.id "x", M3e.Attributes.class "y" ] []`,
  });
});

test("skip on unknown m3e tag", () => {
  assert.ok(conv(`<m3e-nope></m3e-nope>`).skip);
});

// --- Record field sourced from a NAMED slot child --------------------------

// NavMenuItem's required `label` slot folds into the record (`{ label = … }`);
// the `slot="icon"` child stays a trailing slot setter.
test("nav-menu-item required label folds into the record; icon trails", () => {
  const r = conv(
    `<m3e-nav-menu-item selected><m3e-icon slot="icon" name="home"></m3e-icon><a slot="label" href="/">Home</a></m3e-nav-menu-item>`,
  );
  assert.deepEqual(r, {
    code: `M3e.Component.NavMenuItem.component { label = TypedHtml.a [ TypedHtml.Unsafe.Attributes.customAttribute "href" "/" ] [ M3e.text "Home" ] } [ M3e.Component.NavMenuItem.selected True ] [ M3e.Component.NavMenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "home" ] []) ]`,
  });
});

// TreeItem's `label` folds into the record; nested child tree-items trail.
test("tree-item required label + nested child tree-items", () => {
  const r = conv(
    `<m3e-tree-item open><span slot="label">Getting Started</span><m3e-tree-item><span slot="label">Overview</span></m3e-tree-item></m3e-tree-item>`,
  );
  assert.deepEqual(r, {
    code: `M3e.Component.TreeItem.component { label = M3e.text "Getting Started" } [ M3e.Component.TreeItem.open True ] [ M3e.Component.TreeItem.component { label = M3e.text "Overview" } [] [] ]`,
  });
});

// A required named slot with no matching child is an honest skip (now that the
// record folding validates each requiredSlot's presence — jackhp95/elm-m3e#211
// is resolved: skip-on-missing is decoupled from record-folding).
test("nav-menu-item missing required label slot -> skip", () => {
  const r = conv(`<m3e-nav-menu-item></m3e-nav-menu-item>`);
  assert.ok(r.skip && /label/.test(r.skip), r.code || r.skip);
});

// --- per-container child routing by produced kind (Fix C) ------------------

test("tabs: bare tab-panel child routes to named panel slot; tab -> raw element", () => {
  const r = conv(
    `<m3e-tabs><m3e-tab>One</m3e-tab><m3e-tab-panel>First panel</m3e-tab-panel></m3e-tabs>`,
  );
  assert.deepEqual(r, {
    code: `M3e.Component.Tabs.component [] [ M3e.Component.Tab.component [] [ M3e.text "One" ], M3e.Component.Tabs.panel (M3e.Component.TabPanel.component [] [ M3e.text "First panel" ]) ]`,
  });
});

test("tabs: interleaved children preserve source order (tab,tab,panel,panel)", () => {
  const r = conv(
    `<m3e-tabs><m3e-tab>A</m3e-tab><m3e-tab>B</m3e-tab><m3e-tab-panel>PA</m3e-tab-panel><m3e-tab-panel>PB</m3e-tab-panel></m3e-tabs>`,
  );
  assert.deepEqual(r, {
    code: `M3e.Component.Tabs.component [] [ M3e.Component.Tab.component [] [ M3e.text "A" ], M3e.Component.Tab.component [] [ M3e.text "B" ], M3e.Component.Tabs.panel (M3e.Component.TabPanel.component [] [ M3e.text "PA" ]), M3e.Component.Tabs.panel (M3e.Component.TabPanel.component [] [ M3e.text "PB" ]) ]`,
  });
});

// SplitButton requires BOTH the `leading-button` and `trailing-button` slots
// (Face C requiredSlots): each folds into the record, re-rendered in full, so a
// slotted child's universal `aria-label` (here IconButton's required `ariaLabel`
// record field) survives slot composition.
test("split-button folds both required slots; slotted child keeps its aria-label", () => {
  const r = conv(
    `<m3e-split-button><m3e-button slot="leading-button">Go</m3e-button><m3e-icon-button slot="trailing-button" aria-label="Keyboard arrow down"><m3e-icon name="keyboard_arrow_down"></m3e-icon></m3e-icon-button></m3e-split-button>`,
  );
  assert.deepEqual(r, {
    code: `M3e.Component.SplitButton.component { leadingButton = M3e.Component.Button.component { content = M3e.text "Go", action = M3e.Action.none } [] [], trailingButton = M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "keyboard_arrow_down" ] [], ariaLabel = "Keyboard arrow down", action = M3e.Action.none } [] [] } [] []`,
  });
});

// A slotted child's universal id/class and typed setters survive slot
// composition (same re-render path as aria above).
test("split-button slotted child keeps id/class + typed setters", () => {
  const r = conv(
    `<m3e-split-button><m3e-button slot="leading-button">Go</m3e-button><m3e-icon-button slot="trailing-button" aria-label="x" id="ib" class="c" toggle=""><m3e-icon name="x"></m3e-icon></m3e-icon-button></m3e-split-button>`,
  );
  assert.match(
    r.code,
    /trailingButton = M3e\.Component\.IconButton\.component \{ content = .*ariaLabel = "x", action = M3e\.Action\.none \} \[ M3e\.Attributes\.id "ib", M3e\.Attributes\.class "c", M3e\.Component\.IconButton\.toggle True \]/,
  );
});

// --- Card with slotted content (double-list) + folded-content children ------

test("card with header + content(div) slots", () => {
  const r = conv(
    `<m3e-card variant="outlined"><m3e-heading slot="header" variant="title" size="small">People</m3e-heading><div slot="content"><m3e-chip-set><m3e-chip>Name</m3e-chip></m3e-chip-set></div></m3e-card>`,
  );
  assert.ok(!r.skip, `expected no skip, got: ${r.skip}`);
  assert.match(r.code, /M3e\.Component\.Card\.component/);
  assert.match(r.code, /M3e\.Component\.Card\.header/);
  assert.match(r.code, /M3e\.Component\.Card\.content/);
  assert.match(r.code, /TypedHtml\.div/);
  assert.match(r.code, /M3e\.Component\.Heading\.component \{ content = M3e\.text "People" \}/);
  assert.match(r.code, /M3e\.Component\.Chip\.component \{ content = M3e\.text "Name" \}/);
});

// --- (b) plain HTML + (c) anchor -> TypedHtml.a ----------------------------

test("plain div maps to TypedHtml.div", () => {
  const r = conv(`<div><m3e-icon name="a"></m3e-icon></div>`);
  assert.deepEqual(r, {
    code: `TypedHtml.div [] [ M3e.Component.Icon.component [ M3e.Component.Icon.name "a" ] [] ]`,
  });
});

test("plain div carries its class attribute via customAttribute", () => {
  const r = conv(`<div class="grid"><m3e-icon name="a"></m3e-icon></div>`);
  assert.deepEqual(r, {
    code: `TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "grid" ] [ M3e.Component.Icon.component [ M3e.Component.Icon.name "a" ] [] ]`,
  });
});

test("input carries value/placeholder/type via customAttribute", () => {
  const r = conv(`<m3e-menu><input type="text" placeholder="Name" value="Jo"></m3e-menu>`);
  assert.match(
    r.code,
    /TypedHtml\.input \[ TypedHtml\.Unsafe\.Attributes\.customAttribute "type" "text", TypedHtml\.Unsafe\.Attributes\.customAttribute "placeholder" "Name", TypedHtml\.Unsafe\.Attributes\.customAttribute "value" "Jo" \] \[\]/,
  );
});

test("img carries src via customAttribute", () => {
  const r = conv(`<m3e-menu><img src="/x.png"></m3e-menu>`);
  assert.match(
    r.code,
    /TypedHtml\.img \[ TypedHtml\.Unsafe\.Attributes\.customAttribute "src" "\/x\.png" \] \[\]/,
  );
});

test("label maps to TypedHtml.label", () => {
  assert.deepEqual(conv(`<label>Hi</label>`), {
    code: `TypedHtml.label [] [ M3e.text "Hi" ]`,
  });
});

// A tag TypedHtml does NOT model falls through to `M3e.Unsafe.customElement` — a
// STRING tag name (the sanctioned dynamic/custom-element forge).
test("unknown tag -> M3e.Unsafe.customElement with a String tag name", () => {
  assert.deepEqual(conv(`<my-widget>Hi</my-widget>`), {
    code: `M3e.Unsafe.customElement "my-widget" [] [ M3e.text "Hi" ]`,
  });
});

test("anchor-wrapped card -> TypedHtml.a", () => {
  const r = conv(`<a href="/x"><m3e-card variant="filled">hi</m3e-card></a>`);
  assert.ok(
    r.code &&
      /TypedHtml\.a \[ TypedHtml\.Unsafe\.Attributes\.customAttribute "href" "\/x"/.test(r.code) &&
      /M3e\.Component\.Card\.component/.test(r.code),
    r.code || r.skip,
  );
});

test("numeric attribute -> Float literal (no quotes)", () => {
  assert.deepEqual(conv(`<m3e-icon name="star" optical-size="24"></m3e-icon>`), {
    code: `M3e.Component.Icon.component [ M3e.Component.Icon.name "star", M3e.Component.Icon.opticalSize 24 ] []`,
  });
});

test("void elements (<hr>) -> TypedHtml 2-arg producer with empty lists", () => {
  assert.deepEqual(conv(`<m3e-menu id="m"><hr></m3e-menu>`), {
    code: `M3e.Component.Menu.component [ M3e.Attributes.id "m" ] [ TypedHtml.hr [] [] ]`,
  });
});

test("<main> maps to TypedHtml.main_ (reserved name)", () => {
  const r = conv(`<m3e-drawer-container><main>Content</main></m3e-drawer-container>`);
  assert.ok(r.code && /TypedHtml\.main_ \[\]/.test(r.code), r.code || r.skip);
});
