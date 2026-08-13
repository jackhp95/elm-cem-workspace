import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import type { M3eFabMenuElement } from "./FabMenuElement";
declare const M3eFabMenuItemElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").LinkButtonMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * An item of a floating action button (FAB) menu.
 *
 * @example
 * The following example illustrates triggering a `m3e-fab-menu` from an `m3e-fab` using a `m3e-fab-menu-trigger`.
 * ```html
 * <m3e-fab variant="primary" size="large">
 *  <m3e-fab-menu-trigger for="fabmenu">
 *    <m3e-icon name="edit"></m3e-icon>
 *  </m3e-fab-menu-trigger>
 * </m3e-fab>
 * <m3e-fab-menu id="fabmenu" variant="secondary">
 *  <m3e-fab-menu-item>First</m3e-fab-menu-item>
 *  <m3e-fab-menu-item>Second</m3e-fab-menu-item>
 *  <m3e-fab-menu-item>Third</m3e-fab-menu-item>
 *  <m3e-fab-menu-item>Forth</m3e-fab-menu-item>
 *  <m3e-fab-menu-item>Fifth</m3e-fab-menu-item>
 *  <m3e-fab-menu-item>Sixth</m3e-fab-menu-item>
 * </m3e-fab-menu>
 * ```
 *
 * @tag m3e-menu-item
 *
 * @slot - Renders the label of the item.
 * @slot icon - Renders an icon before the items's label.
 *
 * @attr disabled - Whether the element is disabled.
 * @attr download - A value indicating whether the `target` of the link button will be downloaded, optionally specifying the new name of the file.
 * @attr href - The URL to which the link button points.
 * @attr rel - The relationship between the `target` of the link button and the document.
 * @attr target - The target of the link button.
 *
 * @fires click - Dispatched when the element is clicked.
 *
 * @cssprop --m3e-fab-menu-item-height - Height of the menu item.
 * @cssprop --m3e-fab-menu-item-font-size - Font size of the menu item label.
 * @cssprop --m3e-fab-menu-item-font-weight - Font weight of the menu item label.
 * @cssprop --m3e-fab-menu-item-line-height - Line height of the menu item label.
 * @cssprop --m3e-fab-menu-item-tracking - Letter spacing of the menu item label.
 * @cssprop --m3e-fab-menu-item-shape - Border radius of the menu item.
 * @cssprop --m3e-fab-menu-item-leading-space - Padding at the start of the menu item.
 * @cssprop --m3e-fab-menu-item-trailing-space - Padding at the end of the menu item.
 * @cssprop --m3e-fab-menu-item-spacing - Gap between icon and label.
 * @cssprop --m3e-fab-menu-item-icon-size - Size of the icon in the menu item.
 */
export declare class M3eFabMenuItemElement extends M3eFabMenuItemElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private readonly _elevation?;
    /** @private */ private readonly _focusRing?;
    /** @private */ private readonly _stateLayer?;
    /** @private */ private readonly _ripple?;
    /** The floating action button (FAB) menu to which this item belongs. */
    get menu(): M3eFabMenuElement | null;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-fab-menu-item": M3eFabMenuItemElement;
    }
}
export {};
//# sourceMappingURL=FabMenuItemElement.d.ts.map