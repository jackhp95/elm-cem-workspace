import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { SelectionManager, selectionManager } from "@m3e/web/core/a11y";
import { M3eNavItemElement } from "./NavItemElement";
import { NavItemOrientation } from "./NavItemOrientation";
import { NavBarMode } from "./NavBarMode";
declare const M3eNavBarElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").ReconnectedCallbackMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * A horizontal bar, typically used on smaller devices, that allows a user to switch between 3-5 views.
 *
 * @description
 * The `m3e-nav-bar` component provides a horizontal navigation bar for switching between primary destinations in
 * an application. Designed for smaller devices, it supports 3-5 interactive items, orientation, and theming
 * via CSS custom properties.
 *
 * @example
 * The following example illustrates a nav bar with vertically oriented items.
 * ```html
 * <m3e-nav-bar>
 *   <m3e-nav-item><m3e-icon slot="icon" name="news"></m3e-icon>News</m3e-nav-item>
 *   <m3e-nav-item><m3e-icon slot="icon" name="globe"></m3e-icon>Global</m3e-nav-item>
 *   <m3e-nav-item><m3e-icon slot="icon" name="star"></m3e-icon>For you</m3e-nav-item>
 *   <m3e-nav-item><m3e-icon slot="icon" name="newsstand"></m3e-icon>Trending</m3e-nav-item>
 * </m3e-nav-bar>
 * ```
 *
 * @tag m3e-nav-bar
 *
 * @slot - Renders the items of the bar.
 *
 * @attr mode - The mode in which items in the bar are presented.
 *
 * @fires beforeinput - Dispatched before the selected state of an item changes.
 * @fires input - Dispatched when the selected state of an item changes.
 * @fires change - Dispatched when the selected state of an item changes.
 *
 * @cssprop --m3e-nav-bar-height - Height of the navigation bar.
 * @cssprop --m3e-nav-bar-container-color - Background color of the navigation bar container.
 * @cssprop --m3e-nav-bar-vertical-item-width - Minimum width of vertical nav items.
 */
export declare class M3eNavBarElement extends M3eNavBarElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @internal */ readonly [selectionManager]: SelectionManager<M3eNavItemElement>;
    /** @private */ private _mode?;
    /**
     * The mode in which items in the bar are presented.
     * @default "compact"
     */
    mode: NavBarMode;
    /** The items of the bar. */
    get items(): readonly M3eNavItemElement[];
    /** The selected item. */
    get selected(): M3eNavItemElement | null;
    /** The current mode applied to the bar. */
    get currentMode(): Exclude<NavBarMode, "auto">;
    set currentMode(value: Exclude<NavBarMode, "auto">);
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    reconnectedCallback(): void;
    /** @inheritdoc */
    protected willUpdate(changedProperties: PropertyValues): void;
    /** @inheritdoc */
    protected render(): unknown;
    /** @internal */
    protected _updateItems(): void;
    /** @internal */
    protected _updateOrientation(orientation: NavItemOrientation): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-nav-bar": M3eNavBarElement;
    }
}
export {};
//# sourceMappingURL=NavBarElement.d.ts.map