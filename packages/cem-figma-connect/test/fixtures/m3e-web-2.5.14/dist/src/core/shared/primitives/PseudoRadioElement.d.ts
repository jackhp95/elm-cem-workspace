import { CSSResultGroup, LitElement } from "lit";
declare const M3ePseudoRadioElement_base: import("../mixins/Constructor").Constructor<import("..").CheckedMixin> & import("../mixins/Constructor").Constructor<import("..").DisabledMixin> & import("../mixins/Constructor").Constructor & typeof LitElement;
/**
 * An element which looks like a radio button.
 *
 * @description
 * The `m3e-pseudo-radio` component is a pseudo-radio supporting checked and disabled
 * states. It is customizable via CSS properties for expressive, accessible UI design.
 *
 * @example
 * The following example illustrates how to render a checked pseudo-radio.
 * ```html
 * <m3e-pseudo-radio checked></m3e-pseudo-radio>
 * ```
 *
 * @tag m3e-pseudo-radio
 *
 * @attr checked - A value indicating whether the element is checked.
 * @attr disabled - A value indicating whether the element is disabled.
 *
 * @cssprop --m3e-radio-icon-size - Size of the radio icon.
 * @cssprop --m3e-radio-unselected-icon-color - Color of the unselected radio icon.
 * @cssprop --m3e-radio-selected-icon-color - Color of the selected radio icon.
 * @cssprop --m3e-radio-disabled-icon-color - Color of the disabled radio icon.
 */
export declare class M3ePseudoRadioElement extends M3ePseudoRadioElement_base {
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-pseudo-radio": M3ePseudoRadioElement;
    }
}
export {};
//# sourceMappingURL=PseudoRadioElement.d.ts.map