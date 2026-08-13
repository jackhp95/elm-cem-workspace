import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { ChipVariant } from "./ChipVariant";
declare const M3eChipElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & typeof LitElement;
/**
 * A non-interactive chip used to convey small pieces of information.
 *
 * @description
 * The `m3e-chip` component establishes the foundational structure for chips. It supports expressive styling,
 * accessible interaction, and flexible content projection, aligning with Material 3 guidelines. Appearance
 * variants include `elevated` and `outlined`, enabling visual differentiation and contextual emphasis.
 *
 * @example
 * The following example illustrates use of the `m3e-chip` and `m3e-chip-set` components to present non-interactive chips.
 * ```html
 * <m3e-chip-set>
 *  <m3e-chip><m3e-icon slot="icon" name="palette"></m3e-icon>Design</m3e-chip>
 *  <m3e-chip><m3e-icon slot="icon" name="accessibility_new"></m3e-icon>Accessibility</m3e-chip>
 *  <m3e-chip><m3e-icon slot="icon" name="motion_photos_on"></m3e-icon>Motion</m3e-chip>
 *  <m3e-chip><m3e-icon slot="icon" name="description"></m3e-icon>Documentation</m3e-chip>
 * </m3e-chip-set>
 * ```
 *
 * @tag m3e-chip
 *
 * @slot - Renders the label of the chip.
 * @slot icon - Renders an icon before the chip's label.
 * @slot trailing-icon - Renders an icon after the chip's label.
 *
 * @attr value - A string representing the value of the chip.
 * @attr variant - The appearance variant of the chip.
 *
 * @cssprop --m3e-chip-container-shape - Border radius of the chip container.
 * @cssprop --m3e-chip-container-height - Base height of the chip container before density adjustment.
 * @cssprop --m3e-chip-label-text-font-size - Font size of the chip label text.
 * @cssprop --m3e-chip-label-text-font-weight - Font weight of the chip label text.
 * @cssprop --m3e-chip-label-text-line-height - Line height of the chip label text.
 * @cssprop --m3e-chip-label-text-tracking - Letter spacing of the chip label text.
 * @cssprop --m3e-chip-label-text-color - Label text color in default state.
 * @cssprop --m3e-chip-icon-color - Icon color in default state.
 * @cssprop --m3e-chip-icon-size - Font size of leading/trailing icons.
 * @cssprop --m3e-chip-spacing - Horizontal gap between chip content elements.
 * @cssprop --m3e-chip-padding-start - Default start padding when no icon is present.
 * @cssprop --m3e-chip-padding-end - Default end padding when no trailing icon is present.
 * @cssprop --m3e-chip-with-icon-padding-start - Start padding when leading icon is present.
 * @cssprop --m3e-chip-with-icon-padding-end - End padding when trailing icon is present.
 * @cssprop --m3e-elevated-chip-container-color - Background color for elevated variant.
 * @cssprop --m3e-elevated-chip-elevation - Elevation level for elevated variant.
 * @cssprop --m3e-elevated-chip-hover-elevation - Elevation level on hover.
 * @cssprop --m3e-outlined-chip-outline-thickness - Outline thickness for outlined variant.
 * @cssprop --m3e-outlined-chip-outline-color - Outline color for outlined variant.
 */
export declare class M3eChipElement extends M3eChipElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private readonly _elevation?;
    /** @private */ private readonly _focusRing?;
    /** @private */ private readonly _stateLayer?;
    /** @private */ private readonly _ripple?;
    /**
     * The appearance variant of the chip.
     * @default "outlined"
     */
    variant: ChipVariant;
    /** A string representing the value of the chip. */
    get value(): string;
    set value(value: string);
    /** The textual label of the chip. */
    get label(): string;
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues): void;
    /** @inheritdoc */
    protected render(): unknown;
    /** @internal */
    protected _renderIcon(): unknown;
    /** @internal */
    protected _renderTrailingIcon(): unknown;
    /** @internal */
    protected _renderSlot(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-chip": M3eChipElement;
    }
}
export {};
//# sourceMappingURL=ChipElement.d.ts.map