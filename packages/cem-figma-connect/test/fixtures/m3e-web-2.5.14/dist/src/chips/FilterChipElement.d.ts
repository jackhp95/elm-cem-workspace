import { CSSResultGroup, PropertyValues } from "lit";
import { M3eChipElement } from "./ChipElement";
declare const M3eFilterChipElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").SelectedMixin> & import("../core/shared/mixins/Constructor").Constructor & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledInteractiveMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & typeof M3eChipElement;
/**
 * A chip users interact with to select/deselect options.
 *
 * @description
 * The `m3e-filter-chip` component presents a chip that users can select or deselect to filter
 * content or data sets. It supports single and multi-selection, keyboard interaction, accessibility,
 * and expressive state styling, providing a modern and interactive filtering experience in line
 * with Material 3 guidelines.  Appearance variants include `elevated` and `outlined`, enabling visual
 * differentiation and contextual emphasis.
 *
 * @example
 * The following example illustrates a single-select `m3e-filter-chip-set` containing multiple `m3e-filter-chip` components that
 * allow a user to choose an option. You can use the `multi` attribute to enable multiselect.
 * ```html
 * <m3e-filter-chip-set aria-label="Filter by topic">
 *  <m3e-filter-chip><m3e-icon slot="icon" name="palette"></m3e-icon>Design</m3e-filter-chip>
 *  <m3e-filter-chip><m3e-icon slot="icon" name="accessibility_new"></m3e-icon>Accessibility</m3e-filter-chip>
 *  <m3e-filter-chip><m3e-icon slot="icon" name="motion_photos_on"></m3e-icon>Motion</m3e-filter-chip>
 *  <m3e-filter-chip><m3e-icon slot="icon" name="description"></m3e-icon>Documentation</m3e-filter-chip>
 * </m3e-filter-chip-set>
 * ```
 *
 * @tag m3e-filter-chip
 *
 * @slot - Renders the label of the chip.
 * @slot icon - Renders an icon before the chip's label.
 * @slot trailing-icon - Renders an icon after the chip's label.
 *
 * @attr disabled - A value indicating whether the element is disabled.
 * @attr disabled-interactive - A value indicating whether the element is disabled and interactive.
 * @attr selected - A value indicating whether the element is selected.
 * @attr value - A string representing the value of the chip.
 * @attr variant - The appearance variant of the chip.
 *
 * @fires beforeinput - Dispatched before the selected state changes.
 * @fires input - Dispatched when the selected state changes.
 * @fires change - Dispatched when the selected state changes.
 * @fires click - Dispatched when the element is clicked.
 *
 * @cssprop --m3e-chip-container-shape - Border radius of the chip container.
 * @cssprop --m3e-chip-container-height - Base height of the chip container before density adjustment.
 * @cssprop --m3e-chip-label-text-font-size - Font size of the chip label text.
 * @cssprop --m3e-chip-label-text-font-weight - Font weight of the chip label text.
 * @cssprop --m3e-chip-label-text-line-height - Line height of the chip label text.
 * @cssprop --m3e-chip-label-text-tracking - Letter spacing of the chip label text.
 * @cssprop --m3e-chip-icon-size - Font size of leading/trailing icons.
 * @cssprop --m3e-chip-spacing - Horizontal gap between chip content elements.
 * @cssprop --m3e-chip-padding-start - Default start padding when no icon is present.
 * @cssprop --m3e-chip-padding-end - Default end padding when no trailing icon is present.
 * @cssprop --m3e-chip-with-icon-padding-start - Start padding when leading icon is present.
 * @cssprop --m3e-chip-with-icon-padding-end - End padding when trailing icon is present.
 * @cssprop --m3e-chip-disabled-label-text-color - Base color for disabled label text.
 * @cssprop --m3e-chip-disabled-label-text-opacity - Opacity applied to disabled label text.
 * @cssprop --m3e-chip-disabled-icon-color - Base color for disabled icons.
 * @cssprop --m3e-chip-disabled-icon-opacity - Opacity applied to disabled icons.
 * @cssprop --m3e-elevated-chip-container-color - Background color for elevated variant.
 * @cssprop --m3e-elevated-chip-elevation - Elevation level for elevated variant.
 * @cssprop --m3e-elevated-chip-hover-elevation - Elevation level on hover.
 * @cssprop --m3e-elevated-chip-disabled-container-color - Background color for disabled elevated variant.
 * @cssprop --m3e-elevated-chip-disabled-container-opacity - Opacity applied to disabled elevated background.
 * @cssprop --m3e-elevated-chip-disabled-elevation - Elevation level for disabled elevated variant.
 * @cssprop --m3e-outlined-chip-outline-thickness - Outline thickness for outlined variant.
 * @cssprop --m3e-outlined-chip-outline-color - Outline color for outlined variant.
 * @cssprop --m3e-outlined-chip-disabled-outline-color - Outline color for disabled outlined variant.
 * @cssprop --m3e-outlined-chip-disabled-outline-opacity - Opacity applied to disabled outline.
 * @cssprop --m3e-chip-selected-outline-thickness - Outline thickness for selected state.
 * @cssprop --m3e-chip-selected-label-text-color - Text color in selected state.
 * @cssprop --m3e-chip-selected-container-color - Background color in selected state.
 * @cssprop --m3e-chip-selected-container-hover-color - Hover state layer color in selected state.
 * @cssprop --m3e-chip-selected-container-focus-color - Focus state layer color in selected state.
 * @cssprop --m3e-chip-selected-hover-elevation - Elevation on hover in selected state.
 * @cssprop --m3e-chip-selected-ripple-color - Ripple color in selected state.
 * @cssprop --m3e-chip-selected-state-layer-focus-color - Focus state layer color in selected state.
 * @cssprop --m3e-chip-selected-state-layer-hover-color - Hover state layer color in selected state.
 * @cssprop --m3e-chip-selected-leading-icon-color - Leading icon color in selected state.
 * @cssprop --m3e-chip-selected-trailing-icon-color - Trailing icon color in selected state.
 * @cssprop --m3e-chip-unselected-label-text-color - Text color in unselected state.
 * @cssprop --m3e-chip-unselected-ripple-color - Ripple color in unselected state.
 * @cssprop --m3e-chip-unselected-state-layer-focus-color - Focus state layer color in unselected state.
 * @cssprop --m3e-chip-unselected-state-layer-hover-color - Hover state layer color in unselected state.
 * @cssprop --m3e-chip-unselected-leading-icon-color - Leading icon color in unselected state.
 * @cssprop --m3e-chip-unselected-trailing-icon-color - Trailing icon color in unselected state.
 */
export declare class M3eFilterChipElement extends M3eFilterChipElement_base {
    #private;
    /** Indicates that this custom element participates in form submission, validation, and form state restoration. */
    static readonly formAssociated = true;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues<this>): void;
    /** @inheritdoc @private */
    protected _renderIcon(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-filter-chip": M3eFilterChipElement;
    }
}
export {};
//# sourceMappingURL=FilterChipElement.d.ts.map