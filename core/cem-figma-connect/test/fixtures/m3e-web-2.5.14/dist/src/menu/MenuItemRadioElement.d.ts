import { CSSResultGroup, PropertyValues } from "lit";
import { MenuItemElementBase } from "./MenuItemElementBase";
declare const M3eMenuItemRadioElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").CheckedMixin> & import("../core/shared/mixins/Constructor").Constructor & typeof MenuItemElementBase;
/**
 * An item of a menu which supports a mutually exclusive checkable state.
 *
 * @description
 * The `m3e-menu-item-radio` component represents a selectable menu item that participates in a mutually exclusive group.
 * It reflects a singular choice within a shared context—such as sort order, theme selection, or view mode—and updates
 * group state when selected. This component can be nested within an `m3e-menu-item-group`, allowing multiple exclusive
 * groups to coexist within a single menu.
 *
 * @example
 * The following example illustrates use of the `m3e-menu-item-radio` in a `m3e-menu` to allow a user to select a sort order.
 * The `m3e-menu-trigger` is used to trigger a `m3e-menu` specified by the `for` attribute when its parenting element is activated.
 * ```html
 * <m3e-button>
 *  <m3e-menu-trigger for="menu">Sort order</m3e-menu-trigger>
 * </m3e-button>
 * <m3e-menu id="menu">
 *  <m3e-menu-item-radio>Ascending</m3e-menu-item-radio>
 *  <m3e-menu-item-radio>Descending</m3e-menu-item-radio>
 * </m3e-menu>
 * ```
 *
 * @tag m3e-menu-item-radio
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
export declare class M3eMenuItemRadioElement extends M3eMenuItemRadioElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues<this>): void;
    /** @internal @inheritdoc */
    protected _renderContent(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-menu-item-radio": M3eMenuItemRadioElement;
    }
}
export {};
//# sourceMappingURL=MenuItemRadioElement.d.ts.map