import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { formValue } from "@m3e/web/core";
declare const M3eSliderThumbElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DirtyMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").TouchedMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").FormAssociatedMixin> & import("../core/shared/mixins/Constructor").Constructor & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & typeof LitElement;
/**
 * A thumb used to select a value in a slider.
 *
 * @description
 * The `m3e-slider-thumb` component is used within a `m3e-slider` to represent and select a specific value.
 * This component supports continuous and discrete input, form association, and accessibility semantics.
 * It emits `input` and `change` events to reflect value updates.
 *
 * @example
 * The following example illustrates a labelled slider with thumb used to select a single numeric value.
 * ```html
 * <m3e-slider labelled>
 *  <m3e-slider-thumb value="50"></m3e-slider-thumb>
 * </m3e-slider>
 * ```
 *
 * @example
 * The next example illustrates a labelled range slider with two thumbs used to select a minimum and maximum numeric value.
 * ```html
 * <m3e-slider labelled>
 *  <m3e-slider-thumb value="25"></m3e-slider-thumb>
 *  <m3e-slider-thumb value="75"></m3e-slider-thumb>
 * </m3e-slider>
 * ```
 *
 * @tag m3e-slider-thumb
 *
 * @attr disabled - Whether the element is disabled.
 * @attr name - The name that identifies the element when submitting the associated form.
 * @attr value - The value of the thumb.
 *
 * @fires beforeinput - Dispatched before the value changes.
 * @fires input - Dispatched when the value changes.
 * @fires change - Dispatched when the value changes.
 * @fires click - Dispatched when the element is clicked.
 *
 * @cssprop --m3e-slider-thumb-width - Width of the slider thumb.
 * @cssprop --m3e-slider-thumb-padding - Horizontal padding around the thumb.
 * @cssprop --m3e-slider-thumb-color - Active color of the slider thumb when enabled.
 * @cssprop --m3e-slider-thumb-pressed-width - Width of the thumb when pressed.
 * @cssprop --m3e-slider-thumb-disabled-color - Color of the thumb when disabled.
 * @cssprop --m3e-slider-thumb-disabled-opacity - Opacity of the thumb when disabled.
 * @cssprop --m3e-slider-label-width - Width of the floating label above the thumb.
 * @cssprop --m3e-slider-label-container-color - Background color of the label container.
 * @cssprop --m3e-slider-label-color - Text color of the label.
 * @cssprop --m3e-slider-label-font-size - Font size of the label text.
 * @cssprop --m3e-slider-label-font-weight - Font weight of the label text.
 * @cssprop --m3e-slider-label-line-height - Line height of the label text.
 * @cssprop --m3e-slider-label-tracking - Letter spacing of the label text.
 */
export declare class M3eSliderThumbElement extends M3eSliderThumbElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private readonly _focusRing?;
    /**
     * The value of the thumb.
     * @default null
     */
    value: number | null;
    /** @inheritdoc */
    get [formValue](): string | File | FormData | null;
    /** @inheritdoc */
    focus(options?: FocusOptions): void;
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-slider-thumb": M3eSliderThumbElement;
    }
}
export {};
//# sourceMappingURL=SliderThumbElement.d.ts.map