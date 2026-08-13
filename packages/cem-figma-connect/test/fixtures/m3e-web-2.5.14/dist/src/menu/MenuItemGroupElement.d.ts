import { CSSResultGroup, LitElement } from "lit";
declare const M3eMenuItemGroupElement_base: import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * Groups related items (such a radios) in a menu.
 *
 * @description
 * The `m3e-menu-item-group` component groups related items within a menu, establishing a shared
 * context for interaction and selection. It enables separation of concerns—such as organizing radio
 * items into mutually exclusive sets.
 *
 * @tag m3e-menu-item-group
 *
 * @slot - Renders the contents of the group.
 */
export declare class M3eMenuItemGroupElement extends M3eMenuItemGroupElement_base {
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-menu-item-group": M3eMenuItemGroupElement;
    }
}
export {};
//# sourceMappingURL=MenuItemGroupElement.d.ts.map