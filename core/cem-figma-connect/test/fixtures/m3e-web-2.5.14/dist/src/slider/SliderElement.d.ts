import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { M3eSliderThumbElement } from "./SliderThumbElement";
import { SliderSize } from "./SliderSize";
declare const M3eSliderElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & typeof LitElement;
/**
 * Allows for the selection of numeric values from a range.
 *
 * @description
 * The `m3e-slider` component enables users to select a numeric value from a continuous or discrete range.
 * Designed according to Material 3 principles, it supports labeled value indicators, tick marks, and
 * snapping behavior.
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
 * @tag m3e-slider
 *
 * @slot - Renders the thumbs of the slider.
 *
 * @attr disabled - Whether the element is disabled.
 * @attr discrete - Whether to show tick marks.
 * @attr labelled - Whether to show value labels when activated.
 * @attr max - The maximum allowable value.
 * @attr min - The minimum allowable value.
 * @attr step - The value at which the thumb will snap.
 * @attr size - The size of the slider.
 *
 * @fires beforeinput - Dispatched before the value of a thumb changes.
 * @fires input - Dispatched when the value of a thumb changes.
 * @fires change - Dispatched when the value of a thumb changes.
 *
 * @cssprop --m3e-slider-min-width - Minimum inline size of the slider host.
 * @cssprop --m3e-slider-small-height - Height of the slider when size is small or extra-small.
 * @cssprop --m3e-slider-medium-height - Height of the slider when size is medium.
 * @cssprop --m3e-slider-large-height - Height of the slider when size is large.
 * @cssprop --m3e-slider-extra-large-height - Height of the slider when size is extra-large.
 * @cssprop --m3e-slider-small-active-track-shape - Corner shape of the active track for small sliders.
 * @cssprop --m3e-slider-small-inactive-active-track-start-shape - Corner shape of the inactive track start for small sliders.
 * @cssprop --m3e-slider-small-inactive-track-end-shape - Corner shape of the inactive track end for small sliders.
 * @cssprop --m3e-slider-medium-active-track-shape - Corner shape of the active track for medium sliders.
 * @cssprop --m3e-slider-medium-inactive-active-track-start-shape - Corner shape of the inactive track start for medium sliders.
 * @cssprop --m3e-slider-medium-inactive-track-end-shape - Corner shape of the inactive track end for medium sliders.
 * @cssprop --m3e-slider-large-active-track-shape - Corner shape of the active track for large sliders.
 * @cssprop --m3e-slider-large-inactive-active-track-start-shape - Corner shape of the inactive track start for large sliders.
 * @cssprop --m3e-slider-large-inactive-track-end-shape - Corner shape of the inactive track end for large sliders.
 * @cssprop --m3e-slider-extra-large-active-track-shape - Corner shape of the active track for extra-large sliders.
 * @cssprop --m3e-slider-extra-large-inactive-active-track-start-shape - Corner shape of the inactive track start for extra-large sliders.
 * @cssprop --m3e-slider-extra-large-inactive-track-end-shape - Corner shape of the inactive track end for extra-large sliders.
 * @cssprop --m3e-slider-extra-small-track-height - Height of the track for extra-small sliders.
 * @cssprop --m3e-slider-small-track-height - Height of the track for small sliders.
 * @cssprop --m3e-slider-medium-track-height - Height of the track for medium sliders.
 * @cssprop --m3e-slider-large-track-height - Height of the track for large sliders.
 * @cssprop --m3e-slider-extra-large-track-height - Height of the track for extra-large sliders.
 * @cssprop --m3e-slider-tick-size - Size of each tick mark.
 * @cssprop --m3e-slider-tick-shape - Corner shape of each tick mark.
 * @cssprop --m3e-slider-inactive-track-color - Background color of the inactive track when enabled.
 * @cssprop --m3e-slider-disabled-inactive-track-color - Base color of the inactive track when disabled.
 * @cssprop --m3e-slider-disabled-inactive-track-opacity - Opacity of the inactive track when disabled.
 * @cssprop --m3e-slider-active-track-color - Background color of the active track when enabled.
 * @cssprop --m3e-slider-disabled-active-track-color - Base color of the active track when disabled.
 * @cssprop --m3e-slider-disabled-active-track-opacity - Opacity of the active track when disabled.
 * @cssprop --m3e-slider-tick-active-color - Color of active ticks when enabled.
 * @cssprop --m3e-slider-disabled-tick-active-color - Color of active ticks when disabled.
 * @cssprop --m3e-slider-tick-inactive-color - Color of inactive ticks when enabled.
 * @cssprop --m3e-slider-disabled-tick-inactive-color - Color of inactive ticks when disabled.
 */
export declare class M3eSliderElement extends M3eSliderElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */
    private readonly _base?;
    /** @private */
    private _ticks;
    constructor();
    /**
     * The size of the slider.
     * @default "extra-small"
     */
    size: SliderSize;
    /**
     * Whether the element is disabled.
     * @default false
     */
    disabled: boolean;
    /**
     * Whether to show tick marks.
     * @default false
     */
    discrete: boolean;
    /**
     * The minimum allowable value.
     * @default 0
     */
    min: number;
    /**
     * The maximum allowable value.
     * @default 100
     */
    max: number;
    /**
     * The value at which the thumb will snap.
     * @default 1
     */
    step: number;
    /**
     * Whether to show value labels when activated.
     * @default false
     */
    labelled: boolean;
    /** The function used to format display values. */
    displayWith: ((value: number | null) => string) | null;
    /** The thumbs used to select values. */
    get thumbs(): readonly M3eSliderThumbElement[];
    /** Whether the slider is a range slider. */
    get isRange(): boolean;
    /** The thumb used to select a value. */
    get thumb(): M3eSliderThumbElement | null;
    /** The thumb used to select the lower value of a range slider. */
    get lowerThumb(): M3eSliderThumbElement | null;
    /** The thumb used to select the upper value of a range slider. */
    get upperThumb(): M3eSliderThumbElement | null;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected updated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-slider": M3eSliderElement;
    }
}
export {};
//# sourceMappingURL=SliderElement.d.ts.map