import { CSSResultGroup, LitElement, PropertyValues } from "lit";
declare const M3eButtonSegmentElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DirtyMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").TouchedMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").CheckedMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * A option that can be selected within a segmented button.
 *
 * @description
 * The `m3e-button-segment` component represents a single selectable option within a segmented button group.
 * It behaves like a toggle-able button, supporting icon and label content, selection state, and accessibility
 * roles. Segments are visually unified but independently interactive, adapting shape, color, and ripple feedback
 * based on their position and state.
 *
 * @example
 * The following example illustrates a single-select segmented button with four segments.
 * ```html
 * <m3e-segmented-button>
 *  <m3e-button-segment checked>8 oz</m3e-button-segment>
 *  <m3e-button-segment>12 oz</m3e-button-segment>
 *  <m3e-button-segment>16 oz</m3e-button-segment>
 *  <m3e-button-segment>20 oz</m3e-button-segment>
 * </m3e-segmented-button>
 * ```
 * @example
 * The next example illustrates a multiselect segmented button designated using the `multi` attribute.
 * ```html
 * <m3e-segmented-button multi>
 *  <m3e-button-segment checked>$</m3e-button-segment>
 *  <m3e-button-segment checked>$$</m3e-button-segment>
 *  <m3e-button-segment>$$$</m3e-button-segment>
 *  <m3e-button-segment>$$$$</m3e-button-segment>
 * </m3e-segmented-button>
 * ```
 *
 * @tag m3e-button-segment
 *
 * @slot - Renders the label of the option.
 * @slot icon - Renders an icon before the option's label.
 *
 * @attr checked - Whether the element is checked.
 * @attr disabled - Whether the element is disabled.
 * @attr value - A string representing the value of the segment.
 *
 * @fires beforeinput - Dispatched before the checked state changes.
 * @fires input - Dispatched when the checked state changes.
 * @fires change - Dispatched when the checked state changes.
 * @fires click - Dispatched when the element is clicked.
 *
 * @cssprop --m3e-segmented-button-height - Total height of the segmented button.
 * @cssprop --m3e-segmented-button-outline-thickness - Thickness of the button's border.
 * @cssprop --m3e-segmented-button-outline-color - Color of the button's border.
 * @cssprop --m3e-segmented-button-padding-start - Padding on the leading edge of the button content.
 * @cssprop --m3e-segmented-button-padding-end - Padding on the trailing edge of the button content.
 * @cssprop --m3e-segmented-button-spacing - Horizontal gap between icon and label.
 * @cssprop --m3e-segmented-button-font-size - Font size of the label text.
 * @cssprop --m3e-segmented-button-font-weight - Font weight of the label text.
 * @cssprop --m3e-segmented-button-line-height - Line height of the label text.
 * @cssprop --m3e-segmented-button-tracking - Letter spacing of the label text.
 * @cssprop --m3e-segmented-button-with-icon-padding-start - Leading padding when an icon is present.
 * @cssprop --m3e-segmented-button-selected-container-color - Background color of a selected segment.
 * @cssprop --m3e-segmented-button-selected-container-hover-color - Hover state-layer color for selected segments.
 * @cssprop --m3e-segmented-button-selected-container-focus-color - Focus state-layer color for selected segments.
 * @cssprop --m3e-segmented-button-selected-ripple-color - Ripple color for selected segments.
 * @cssprop --m3e-segmented-button-selected-label-text-color - Label text color for selected segments.
 * @cssprop --m3e-segmented-button-selected-icon-color - Icon color for selected segments.
 * @cssprop --m3e-segmented-button-unselected-container-hover-color - Hover state-layer color for unselected segments.
 * @cssprop --m3e-segmented-button-unselected-container-focus-color - Focus state-layer color for unselected segments.
 * @cssprop --m3e-segmented-button-unselected-ripple-color - Ripple color for unselected segments.
 * @cssprop --m3e-segmented-button-unselected-label-text-color - Label text color for unselected segments.
 * @cssprop --m3e-segmented-button-unselected-icon-color - Icon color for unselected segments.
 * @cssprop --m3e-segmented-button-icon-size - Font size of the icon.
 * @cssprop --m3e-segmented-button-disabled-outline-color - Base color for disabled segment borders.
 * @cssprop --m3e-segmented-button-disabled-outline-opacity - Opacity applied to disabled segment borders.
 * @cssprop --m3e-segmented-button-disabled-label-text-color - Base color for disabled label text.
 * @cssprop --m3e-segmented-button-disabled-label-text-opacity - Opacity applied to disabled label text.
 * @cssprop --m3e-segmented-button-disabled-icon-color - Base color for disabled icons.
 * @cssprop --m3e-segmented-button-disabled-icon-opacity - Opacity applied to disabled icons.
 */
export declare class M3eButtonSegmentElement extends M3eButtonSegmentElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private readonly _focusRing?;
    /** @private */ private readonly _stateLayer?;
    /** @private */ private readonly _ripple?;
    /**
     * A string representing the value of the segment.
     * @default "on"
     */
    value: string;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-button-segment": M3eButtonSegmentElement;
    }
}
export {};
//# sourceMappingURL=ButtonSegmentElement.d.ts.map