// docs-gen — brand-agnostic docs generation core. See README.md / DESIGN.md.
// STATUS: skeleton (WIP). The data-derivation core (families, tokens, guide
// sections) is real + tested; the route-generation layer is NOT built yet.
export { deriveFamilies } from "./families.mjs";
export {
  customProps,
  deriveTypescale,
  deriveShapeCorners,
  deriveColorRoleInventory,
} from "./tokens.mjs";
export { splitSections, joinSections } from "./sections.mjs";
