import { CSSResultGroup, PropertyValues } from "lit";
import { M3eListItemElement } from "./ListItemElement";
declare const M3eListOptionElement_base: import("../core/shared/mixins/Constructor").Constructor & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").SelectedMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & typeof M3eListItemElement;
/**
 * A selectable option in a list.
 *
 * @description
 * The `m3e-list-option` component represents a selectable item within a list container. It extends
 * the base `m3e-list-item` functionality with selection state management, providing visual feedback
 * for selected and unselected states. The component is designed for use with `m3e-selection-list`
 * and supports rich content through multiple slots, comprehensive styling via CSS custom properties,
 * and accessible interactions following Material 3 design principles.
 *
 * @tag m3e-list-option
 *
 * @slot - Renders the content of the list item.
 * @slot leading - Renders the leading content of the list item.
 * @slot overline - Renders the overline of the list item.
 * @slot supporting-text - Renders the supporting text of the list item.
 * @slot trailing - Renders the trailing content of the list item.
 *
 * @attr disabled - Whether the element is disabled.
 * @attr selected - Whether the element is selected.
 *
 * @fires beforeinput - Dispatched before the selected state changes.
 * @fires input - Dispatched when the selected state changes.
 * @fires change - Dispatched when the selected state changes.
 * @fires click - Dispatched when the element is clicked.
 *
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
 * @cssprop --m3e-list-item-disabled-container-color - Background color of the list item when disabled.
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
 * @cssprop --m3e-list-item-selected-label-text-color - Selected color for the main content.
 * @cssprop --m3e-list-item-selected-overline-color - Selected color for the overline slot.
 * @cssprop --m3e-list-item-selected-supporting-text-color - Selected color for the supporting text slot.
 * @cssprop --m3e-list-item-selected-leading-color - Selected color for the leading content.
 * @cssprop --m3e-list-item-selected-trailing-color - Selected color for the trailing content.
 * @cssprop --m3e-list-item-selected-container-color - Selected background color of the list item.
 * @cssprop --m3e-list-item-selected-container-shape - Selected border radius of the list item.
 * @cssprop --m3e-list-item-selected-disabled-container-color - Selected background color when disabled.
 * @cssprop --m3e-list-item-selected-disabled-container-opacity - Selected opacity when disabled.
 * @cssprop --m3e-list-item-selected-hover-state-layer-color - Color for the hover state layer when selected.
 * @cssprop --m3e-list-item-selected-hover-state-layer-opacity - Opacity for the hover state layer when selected.
 * @cssprop --m3e-list-item-selected-focus-state-layer-color - Color for the focus state layer when selected.
 * @cssprop --m3e-list-item-selected-focus-state-layer-opacity - Opacity for the focus state layer when selected.
 * @cssprop --m3e-list-item-selected-pressed-state-layer-color - Color for the pressed state layer when selected.
 * @cssprop --m3e-list-item-selected-pressed-state-layer-opacity - Opacity for the pressed state layer when selected.
 * @cssprop --m3e-list-item-three-line-top-offset - Top offset for media in three line items.
 * @cssprop --m3e-list-item-disabled-media-opacity - Opacity for media when disabled.
 */
export declare class M3eListOptionElement extends M3eListOptionElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private readonly _focusRing?;
    /** @private */ private readonly _stateLayer?;
    /** @private */ private readonly _ripple?;
    constructor();
    /** A string representing the value of the option. */
    get value(): string;
    set value(value: string);
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-list-option": M3eListOptionElement;
    }
}
export {};
//# sourceMappingURL=ListOptionElement.d.ts.map