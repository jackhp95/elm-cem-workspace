import { CSSResultGroup, LitElement } from "lit";
declare const M3eNavMenuItemGroupElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * A top-level semantic grouping of items in a navigation menu.
 *
 * @description
 * The `m3e-nav-menu-item-group` is a top-level semantic grouping of items in a navigation menu.
 * It encapsulates related items under a shared heading or label, supporting visual hierarchy and accessibility.
 *
 * @example
 * The following example illustrates a navigation menu with a top-level group of menu items.
 * ```html
 * <m3e-nav-menu>
 *   <m3e-nav-menu-item-group>
 *     <m3e-heading slot="label" variant="label" size="large">Mail</m3e-heading>
 *     <m3e-nav-menu-item>
 *       <m3e-icon slot="icon" name="mail"></m3e-icon>
 *       <span slot="label">Inbox</span>
 *       <span slot="badge">24</span>
 *     </m3e-nav-menu-item>
 *     <m3e-nav-menu-item>
 *       <m3e-icon slot="icon" name="send"></m3e-icon>
 *       <span slot="label">Outbox</span>
 *     </m3e-nav-menu-item>
 *     <m3e-nav-menu-item>
 *       <m3e-icon slot="icon" name="favorite"></m3e-icon>
 *       <span slot="label">Favorites</span>
 *     </m3e-nav-menu-item>
 *     <m3e-nav-menu-item>
 *       <m3e-icon slot="icon" name="delete"></m3e-icon>
 *       <span slot="label">Trash</span>
 *     </m3e-nav-menu-item>
 *   </m3e-nav-menu-item-group>
 * </m3e-nav-menu>
 * ```
 *
 * @tag m3e-nav-menu-item-group
 *
 * @slot - Renders the items of the group.
 * @slot label - Renders the label of the group.
 *
 * @cssprop --m3e-nav-menu-item-group-label-inset - Insets the label from the start edge of the group.
 * @cssprop --m3e-nav-menu-item-group-label-space - Vertical spacing around the group's label.
 */
export declare class M3eNavMenuItemGroupElement extends M3eNavMenuItemGroupElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private static __nextId;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-nav-menu-item-group": M3eNavMenuItemGroupElement;
    }
}
export {};
//# sourceMappingURL=NavMenuItemGroupElement.d.ts.map