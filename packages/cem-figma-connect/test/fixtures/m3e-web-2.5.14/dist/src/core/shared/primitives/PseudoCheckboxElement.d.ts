import { CSSResultGroup, LitElement } from "lit";
declare const M3ePseudoCheckboxElement_base: import("../mixins/Constructor").Constructor<import("..").CheckedIndeterminateMixin> & import("../mixins/Constructor").Constructor<import("..").DisabledMixin> & import("../mixins/Constructor").Constructor & typeof LitElement;
/**
 * An element which looks like a checkbox.
 *
 * @description
 * The `m3e-pseudo-checkbox` component is a pseudo-checkbox supporting checked, indeterminate, and disabled
 * states. It is customizable via CSS properties for expressive, accessible UI design.
 *
 * @example
 * The following example illustrates how to render a checked pseudo-checkbox.
 * ```html
 * <m3e-pseudo-checkbox checked></m3e-pseudo-checkbox>
 * ```
 *
 * @tag m3e-pseudo-checkbox
 *
 * @attr checked - A value indicating whether the element is checked.
 * @attr disabled - A value indicating whether the element is disabled.
 * @attr indeterminate - A value indicating whether the element's checked state is indeterminate.
 *
 * @cssprop --m3e-checkbox-icon-size - Size of the checkbox icon.
 * @cssprop --m3e-checkbox-container-shape - Border radius of the checkbox container.
 * @cssprop --m3e-checkbox-unselected-outline-thickness - Outline thickness for unselected state.
 * @cssprop --m3e-checkbox-unselected-outline-color - Outline color for unselected state.
 * @cssprop --m3e-checkbox-selected-container-color - Background color for selected state.
 * @cssprop --m3e-checkbox-selected-icon-color - Icon color for selected state.
 * @cssprop --m3e-checkbox-unselected-disabled-outline-color - Outline color for unselected disabled state.
 * @cssprop --m3e-checkbox-unselected-disabled-outline-opacity - Outline opacity for unselected disabled state.
 * @cssprop --m3e-checkbox-selected-disabled-container-color - Background color for selected disabled state.
 * @cssprop --m3e-checkbox-selected-disabled-container-opacity - Background opacity for selected disabled state.
 * @cssprop --m3e-checkbox-selected-disabled-icon-color - Icon color for selected disabled state.
 * @cssprop --m3e-checkbox-selected-disabled-icon-opacity - Icon opacity for selected disabled state.
 */
export declare class M3ePseudoCheckboxElement extends M3ePseudoCheckboxElement_base {
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-pseudo-checkbox": M3ePseudoCheckboxElement;
    }
}
export {};
//# sourceMappingURL=PseudoCheckboxElement.d.ts.map