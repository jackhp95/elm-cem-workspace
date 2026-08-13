import { CSSResultGroup } from "lit";
import { MenuItemElementBase } from "./MenuItemElementBase";
declare const M3eMenuItemCheckboxElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").CheckedMixin> & import("../core/shared/mixins/Constructor").Constructor & typeof MenuItemElementBase;
/**
 * An item of a menu which supports a checkable state.
 *
 * @description
 * The `m3e-menu-item-checkbox` component represents a menu item that supports an independent checkable state.
 * It allows users to toggle options on or off without affecting other items in the menu, making it ideal for
 * multi-select scenarios such as filters, visibility toggles, or feature flags. This component encodes a persistent
 * selection contract and can coexist with other checkbox or radio items within the same menu.
 *
 * @example
 * The following example illustrates use of the `m3e-menu-item-checkbox` to present multiple independent checkable
 * items in a menu.
 * ```html
 * <m3e-button>
 *   <m3e-menu-trigger for="menu">Format</m3e-menu-trigger>
 * </m3e-button>
 * <m3e-menu id="menu">
 *   <m3e-menu-item-checkbox>Bold</m3e-menu-item-checkbox>
 *   <m3e-menu-item-checkbox>Italic</m3e-menu-item-checkbox>
 *   <m3e-menu-item-checkbox>Underline</m3e-menu-item-checkbox>
 * </m3e-menu>
 * ```
 *
 * @tag m3e-menu-item-checkbox
 *
 * @slot - Renders the label of the item.
 * @slot icon - Renders an icon before the items's label.
 * @slot trailing-icon - Renders an icon after the item's label.
 *
 * @attr disabled - Whether the element is disabled.
 * @attr checked - Whether the element is checked.
 *
 * @fires click - Dispatched when the element is clicked.
 *
 * @cssprop --m3e-menu-item-container-height - Height of the menu item container.
 * @cssprop --m3e-menu-item-color - Text color for unselected, enabled menu items.
 * @cssprop --m3e-menu-item-container-hover-color - State layer hover color for unselected items.
 * @cssprop --m3e-menu-item-container-focus-color - State layer focus color for unselected items.
 * @cssprop --m3e-menu-item-ripple-color - Ripple color for unselected items.
 * @cssprop --m3e-menu-item-selected-color - Text color for selected items.
 * @cssprop --m3e-menu-item-selected-container-color - Background color for selected items.
 * @cssprop --m3e-menu-item-selected-container-hover-color - State layer hover color for selected items.
 * @cssprop --m3e-menu-item-selected-container-focus-color - State layer focus color for selected items.
 * @cssprop --m3e-menu-item-selected-ripple-color - Ripple color for selected items.
 * @cssprop --m3e-menu-item-active-state-layer-color - State layer color for expanded items.
 * @cssprop --m3e-menu-item-active-state-layer-opacity - State layer opacity for expanded items.
 * @cssprop --m3e-menu-item-disabled-color - Base color for disabled items.
 * @cssprop --m3e-menu-item-disabled-opacity - Opacity percentage for disabled item color mix.
 * @cssprop --m3e-vibrant-menu-item-color - Text color for unselected, enabled menu items for vibrant variant.
 * @cssprop --m3e-vibrant-menu-item-container-hover-color - State layer hover color for unselected items for vibrant variant.
 * @cssprop --m3e-vibrant-menu-item-container-focus-color - State layer focus color for unselected items for vibrant variant.
 * @cssprop --m3e-vibrant-menu-item-ripple-color - Ripple color for unselected items for vibrant variant.
 * @cssprop --m3e-vibrant-menu-item-selected-color - Text color for selected items for vibrant variant.
 * @cssprop --m3e-vibrant-menu-item-selected-container-color - Background color for selected items for vibrant variant.
 * @cssprop --m3e-vibrant-menu-item-selected-container-hover-color - State layer hover color for selected items for vibrant variant.
 * @cssprop --m3e-vibrant-menu-item-selected-container-focus-color - State layer focus color for selected items for vibrant variant.
 * @cssprop --m3e-vibrant-menu-item-selected-ripple-color - Ripple color for selected items for vibrant variant.
 * @cssprop --m3e-vibrant-menu-item-active-state-layer-color - State layer color for expanded items for vibrant variant.
 * @cssprop --m3e-vibrant-menu-item-disabled-color - Base color for disabled items for vibrant variant
 * @cssprop --m3e-menu-item-icon-label-space - Horizontal gap between icon and content.
 * @cssprop --m3e-menu-item-padding-start - Start padding for the item wrapper.
 * @cssprop --m3e-menu-item-padding-end - End padding for the item wrapper.
 * @cssprop --m3e-menu-item-label-text-font-size - Font size for menu item text.
 * @cssprop --m3e-menu-item-label-text-font-weight - Font weight for menu item text.
 * @cssprop --m3e-menu-item-label-text-line-height - Line height for menu item text.
 * @cssprop --m3e-menu-item-label-text-tracking - Letter spacing for menu item text.
 * @cssprop --m3e-menu-item-focus-ring-shape - Border radius for the focus ring.
 * @cssprop --m3e-menu-item-icon-size - Font size for leading and trailing icons.
 * @cssprop --m3e-menu-item-shape - Base shape of the menu item.
 * @cssprop --m3e-menu-item-selected-shape - Shape used for a selected menu item.
 * @cssprop --m3e-menu-item-first-child-shape - Shape for the first menu item in a menu.
 * @cssprop --m3e-menu-item-last-child-shape - Shape for the last menu item in a menu.
 */
export declare class M3eMenuItemCheckboxElement extends M3eMenuItemCheckboxElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @internal @inheritdoc */
    protected _renderContent(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-menu-item-checkbox": M3eMenuItemCheckboxElement;
    }
}
export {};
//# sourceMappingURL=MenuItemCheckboxElement.d.ts.map