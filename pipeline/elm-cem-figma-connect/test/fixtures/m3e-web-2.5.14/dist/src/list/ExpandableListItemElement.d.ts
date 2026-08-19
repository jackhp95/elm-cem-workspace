import { CSSResultGroup, PropertyValues } from "lit";
import { M3eListItemButtonElement } from "./ListItemButtonElement";
import { M3eListItemElement } from "./ListItemElement";
/**
 * An item in a list that can be expanded to show more items.
 *
 * @description
 * The `m3e-expandable-list-item` provides a hierarchical navigation structure that allows
 * users to expand and collapse content sections. It follows Material 3 design principles
 * with smooth animations, semantic color tokens, and accessible interactions. The component
 * extends the base `m3e-list-item` functionality with toggle state management and nested
 * content support.
 *
 * @example
 * The following example illustrates an expandable list item.
 * ```html
 * <m3e-action-list>
 *  <m3e-expandable-list-item>
 *    Pick up supplies
 *    <span slot="supporting-text">Due monday</span>
 *    <div slot="items">
 *      <m3e-list-action>
 *        Dry-erase board
 *        <span slot="supporting-text">$35.99</span>
 *      </m3e-list-action>
 *      <m3e-list-action>
 *        Markers
 *        <span slot="supporting-text">$8.99</span>
 *      </m3e-list-action>
 *    </div>
 *  </m3e-expandable-list-item>
 * </m3e-action-list>
 * ```
 *
 * @tag m3e-expandable-list-item
 *
 * @slot - Renders the content of the list item.
 * @slot leading - Renders the leading content of the list item.
 * @slot overline - Renders the overline of the list item.
 * @slot supporting-text - Renders the supporting text of the list item.
 * @slot toggle-icon - Renders a custom icon for the expand/collapse toggle.
 * @slot items - Container for child list items displayed when expanded.
 * @slot trailing - This component does not expose the base trailing slot.
 *
 * @attr disabled - Whether the element is disabled.
 * @attr open - Whether the item is expanded.
 *
 * @fires opening - Dispatched when the item begins to open.
 * @fires opened - Dispatched when the item has opened.
 * @fires closing - Dispatched when the item begins to close.
 * @fires closed - Dispatched when the item has closed.
 *
 * @cssprop --m3e-expandable-list-item-toggle-icon-container-width - Width of the toggle icon container.
 * @cssprop --m3e-expandable-list-item-toggle-icon-container-shape - Border radius of the toggle icon container.
 * @cssprop --m3e-expandable-list-item-toggle-icon-size - Size of the toggle icon.
 * @cssprop --m3e-expandable-list-item-expanded-toggle-icon-container-color - Background color of the toggle icon container when expanded.
 * @cssprop --m3e-expandable-list-item-bounce-duration - Duration of the bounce animation when expanding.
 * @cssprop --m3e-expandable-list-item-bounce-factor - Multiplication factor for the bounce effect.
 * @cssprop --m3e-expandable-list-item-expand-duration - Duration of the expand/collapse animation.
 * @cssprop --m3e-list-item-between-space - Horizontal gap between elements.
 * @cssprop --m3e-list-item-padding-inline - Horizontal padding for the list item.
 * @cssprop --m3e-list-item-padding-block - Vertical padding for the list item.
 * @cssprop --m3e-list-item-height - Minimum height of the list item.
 * @cssprop --m3e-list-item-font-size - Font size for main content.
 * @cssprop --m3e-list-item-font-weight - Font weight for main content.
 * @cssprop --m3e-list-item-line-height - Line height for main content.
 * @cssprop --m3e-list-item-tracking - Letter spacing for main content.
 * @cssprop --m3e-list-item-overline-font-size - Font size for overline slot.
 * @cssprop --m3e-list-item-overline-font-weight - Font weight for overline slot.
 * @cssprop --m3e-list-item-overline-line-height - Line height for overline slot.
 * @cssprop --m3e-list-item-overline-tracking - Letter spacing for overline slot.
 * @cssprop --m3e-list-item-supporting-text-font-size - Font size for supporting text slot.
 * @cssprop --m3e-list-item-supporting-text-font-weight - Font weight for supporting text slot.
 * @cssprop --m3e-list-item-supporting-text-line-height - Line height for supporting text slot.
 * @cssprop --m3e-list-item-supporting-text-tracking - Letter spacing for supporting text slot.
 * @cssprop --m3e-list-item-trailing-text-font-size - Font size for trailing supporting text slot.
 * @cssprop --m3e-list-item-trailing-text-font-weight - Font weight for trailing supporting text slot.
 * @cssprop --m3e-list-item-trailing-text-line-height - Line height for trailing supporting text slot.
 * @cssprop --m3e-list-item-trailing-text-tracking - Letter spacing for trailing supporting text slot.
 * @cssprop --m3e-list-item-icon-size - Size for leading/trailing icons.
 * @cssprop --m3e-list-item-label-text-color - Color for the main content.
 * @cssprop --m3e-list-item-overline-color - Color for the overline slot.
 * @cssprop --m3e-list-item-supporting-text-color - Color for the supporting text slot.
 * @cssprop --m3e-list-item-leading-color - Color for the leading content.
 * @cssprop --m3e-list-item-trailing-color - Color for the trailing content.
 * @cssprop --m3e-list-item-container-color - Background color of the list item.
 * @cssprop --m3e-list-item-container-shape - Border radius of the list item.
 * @cssprop --m3e-list-item-hover-container-shape - Border radius of the list item on hover.
 * @cssprop --m3e-list-item-focus-container-shape - Border radius of the list item on focus.
 * @cssprop --m3e-list-item-video-width - Width of the video slot.
 * @cssprop --m3e-list-item-video-height - Height of the video slot.
 * @cssprop --m3e-list-item-video-shape - Border radius of the video slot.
 * @cssprop --m3e-list-item-image-width - Width of the image slot.
 * @cssprop --m3e-list-item-image-height - Height of the image slot.
 * @cssprop --m3e-list-item-image-shape - Border radius of the image slot.
 * @cssprop --m3e-list-item-disabled-label-text-color - Color for the main content when disabled.
 * @cssprop --m3e-list-item-disabled-label-text-opacity - Opacity for the main content when disabled.
 * @cssprop --m3e-list-item-disabled-overline-color - Color for the overline slot when disabled.
 * @cssprop --m3e-list-item-disabled-overline-opacity - Opacity for the overline slot when disabled.
 * @cssprop --m3e-list-item-disabled-supporting-text-color - Color for the supporting text slot when disabled.
 * @cssprop --m3e-list-item-disabled-supporting-text-opacity - Opacity for the supporting text slot when disabled.
 * @cssprop --m3e-list-item-disabled-leading-color - Color for the leading icon when disabled.
 * @cssprop --m3e-list-item-disabled-leading-opacity - Opacity for the leading icon when disabled.
 * @cssprop --m3e-list-item-disabled-trailing-color - Color for the trailing icon when disabled.
 * @cssprop --m3e-list-item-disabled-trailing-opacity - Opacity for the trailing icon when disabled.
 * @cssprop --m3e-list-item-hover-state-layer-color - Color for the hover state layer.
 * @cssprop --m3e-list-item-hover-state-layer-opacity - Opacity for the hover state layer.
 * @cssprop --m3e-list-item-focus-state-layer-color - Color for the focus state layer.
 * @cssprop --m3e-list-item-focus-state-layer-opacity - Opacity for the focus state layer.
 * @cssprop --m3e-list-item-pressed-state-layer-color - Color for the pressed state layer.
 * @cssprop --m3e-list-item-pressed-state-layer-opacity - Opacity for the pressed state layer.
 * @cssprop --m3e-segmented-list-container-shape - Border radius of the segmented list container shape.
 * @cssprop --m3e-segmented-list-segment-gap - Gap between list item segments.
 * @cssprop --m3e-list-item-three-line-top-offset - Top offset for media in three line items.
 * @cssprop --m3e-list-item-disabled-media-opacity - Opacity for media when disabled.
 */
export declare class M3eExpandableListItemElement extends M3eListItemElement {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private static __nextId;
    /**
     * Whether the element is disabled.
     * @default false
     */
    disabled: boolean;
    /**
     * Whether the item is expanded.
     * @default false
     */
    open: boolean;
    /** @internal */
    readonly button: M3eListItemButtonElement;
    /** The direct child items of this item. */
    get items(): ReadonlyArray<M3eListItemElement>;
    /** @inheritdoc */
    focus(options?: FocusOptions): void;
    /** @inheritdoc */
    blur(): void;
    /** @inheritdoc */
    click(): void;
    /** @inheritdoc */
    protected updated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-expandable-list-item": M3eExpandableListItemElement;
    }
}
//# sourceMappingURL=ExpandableListItemElement.d.ts.map