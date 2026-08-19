import { CSSResultGroup, LitElement } from "lit";
import { SelectionManager, selectionManager } from "@m3e/web/core/a11y";
import { M3eNavMenuItemElement } from "./NavMenuItemElement";
declare const M3eNavMenuElement_base: import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * A hierarchical menu, typically used on larger devices, that allows a user to switch between views.
 *
 * @description
 * The `m3e-nav-menu` component provides a hierarchical, accessible navigation menu supporting
 * nested expandable items, keyboard navigation, and focus management. It is highly customizable
 * via slots and CSS custom properties, and is designed for use in sidebars, navigation drawers,
 * and complex menu structures.
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
 * @example
 * The next example illustrates a multilevel navigation menu.
 * ```html
 * <m3e-nav-menu>
 *   <m3e-nav-menu-item open>
 *     <m3e-icon slot="icon" name="rocket_launch"></m3e-icon>
 *     <span slot="label">Getting Started</span>
 *     <m3e-nav-menu-item>
 *       <m3e-icon slot="icon" name="widgets"></m3e-icon>
 *       <span slot="label">Overview</span>
 *     </m3e-nav-menu-item>
 *     <m3e-nav-menu-item>
 *       <m3e-icon slot="icon" name="package_2"></m3e-icon>
 *       <span slot="label">Installation</span>
 *     </m3e-nav-menu-item>
 *   </m3e-nav-menu-item>
 *   <m3e-nav-menu-item>
 *     <span slot="label">Actions</span>
 *     <m3e-nav-menu-item><span slot="label">Button</span></m3e-nav-menu-item>
 *     <m3e-nav-menu-item><span slot="label">Icon</span></m3e-nav-menu-item>
 *     <m3e-nav-menu-item><span slot="label">Icon Button</span></m3e-nav-menu-item>
 *   </m3e-nav-menu-item>
 * </m3e-nav-menu>
 * ```
 *
 * @tag m3e-nav-menu
 *
 * @slot - Renders the items of the menu.
 *
 * @cssprop --m3e-nav-menu-padding-top - Top padding for the menu.
 * @cssprop --m3e-nav-menu-padding-bottom - Bottom padding for the menu.
 * @cssprop --m3e-nav-menu-padding-left - Left padding for the menu.
 * @cssprop --m3e-nav-menu-padding-right - Right padding for the menu.
 * @cssprop --m3e-nav-menu-divider-margin - Margin for divider elements in the menu.
 * @cssprop --m3e-nav-menu-scrollbar-width - Width of the menu scrollbar.
 * @cssprop --m3e-nav-menu-scrollbar-color - Color of the menu scrollbar.
 */
export declare class M3eNavMenuElement extends M3eNavMenuElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private static __nextId;
    /** @private */
    readonly [selectionManager]: SelectionManager<M3eNavMenuItemElement>;
    constructor();
    /** The selected item of the menu. */
    get selected(): M3eNavMenuItemElement | null;
    /** All the items of the menu. */
    get items(): readonly M3eNavMenuItemElement[];
    /**
     * Expands all items, and optionally, all descendants.
     * @param {boolean} [descendants=false] Whether to expand all descendants.
     */
    expand(descendants?: boolean): void;
    /**
     * Expands the specified items, and optionally, all descendants.
     * @param {M3eNavMenuItemElement[]} items The items to expand.
     * @param {boolean} [descendants=false] Whether to expand all descendants.
     */
    expand(items: M3eNavMenuItemElement[], descendants?: boolean): void;
    /**
     * Collapses all items, and optionally, all descendants.
     * @param {boolean} [descendants=false] Whether to collapse all descendants.
     */
    collapse(descendants?: boolean): void;
    /**
     * Collapses the specified items, and optionally, all descendants.
     * @param {M3eNavMenuItemElement[]} items The items to collapse.
     * @param {boolean} [descendants=false] Whether to collapse all descendants.
     */
    collapse(items: M3eNavMenuItemElement[], descendants?: boolean): void;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-nav-menu": M3eNavMenuElement;
    }
}
export {};
//# sourceMappingURL=NavMenuElement.d.ts.map