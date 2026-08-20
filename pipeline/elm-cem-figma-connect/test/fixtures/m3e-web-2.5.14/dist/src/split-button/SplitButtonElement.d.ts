import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { ButtonSize } from "@m3e/web/button";
import "@m3e/web/button-group";
import { SplitButtonVariant } from "./SplitButtonVariant";
declare const M3eSplitButtonElement_base: import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * A button used to show an action with a menu of related actions.
 *
 * @description
 * The `m3e-split-button` component presents a primary action alongside a menu of related actions,
 * uniting two buttons in a single expressive surface. Designed for Material 3, it supports `elevated`,
 * `filled`, `tonal`, and `outlined` variants, and adapts to all button sizes. The leading button triggers
 * the main action, while the trailing icon button reveals additional options, enabling efficient workflows
 * and clear visual hierarchy. The split button ensures accessible, adaptive, and visually harmonious
 * interactions, reflecting Material 3's principles of clarity, flexibility, and expressive design.
 *
 * @example
 * The following example illustrates use of the `m3e-split-button` to combine the `m3e-button`,
 * `m3e-icon-button`, and `m3e-menu` components into a split button.
 *
 * ```html
 * <m3e-split-button>
 *  <m3e-button slot="leading-button">
 *    <m3e-icon slot="icon" name="edit"></m3e-icon>Edit
 *  </m3e-button>
 *  <m3e-icon-button slot="trailing-button">
 *  <m3e-icon name="keyboard_arrow_down"></m3e-icon>
 *  <m3e-menu-trigger for="menu1"></m3e-menu-trigger>
 * </m3e-icon-button>
 * ```
 *
 * @tag m3e-split-button
 *
 * @slot leading-button - The leading button used to perform the primary action.
 * @slot trailing-button - The trailing icon button used to open a menu of related actions.
 *
 * @attr variant - The appearance variant of the button.
 * @attr size - The size of the button.
 *
 * @cssprop --m3e-split-button-extra-small-trailing-button-unselected-leading-space - Leading space for the trailing button (extra-small, unselected).
 * @cssprop --m3e-split-button-extra-small-trailing-button-unselected-trailing-space - Trailing space for the trailing button (extra-small, unselected).
 * @cssprop --m3e-split-button-small-trailing-button-unselected-leading-space - Leading space for the trailing button (small, unselected).
 * @cssprop --m3e-split-button-small-trailing-button-unselected-trailing-space - Trailing space for the trailing button (small, unselected).
 * @cssprop --m3e-split-button-medium-trailing-button-unselected-leading-space - Leading space for the trailing button (medium, unselected).
 * @cssprop --m3e-split-button-medium-trailing-button-unselected-trailing-space - Trailing space for the trailing button (medium, unselected).
 * @cssprop --m3e-split-button-large-trailing-button-unselected-leading-space - Leading space for the trailing button (large, unselected).
 * @cssprop --m3e-split-button-large-trailing-button-unselected-trailing-space - Trailing space for the trailing button (large, unselected).
 * @cssprop --m3e-split-button-extra-large-trailing-button-unselected-leading-space - Leading space for the trailing button (extra-large, unselected).
 * @cssprop --m3e-split-button-extra-large-trailing-button-unselected-trailing-space - Trailing space for the trailing button (extra-large, unselected).
 * @cssprop --m3e-split-button-extra-small-trailing-button-selected-leading-space - Leading space for the trailing button (extra-small, selected).
 * @cssprop --m3e-split-button-extra-small-trailing-button-selected-trailing-space - Trailing space for the trailing button (extra-small, selected).
 * @cssprop --m3e-split-button-small-trailing-button-selected-leading-space - Leading space for the trailing button (small, selected).
 * @cssprop --m3e-split-button-small-trailing-button-selected-trailing-space - Trailing space for the trailing button (small, selected).
 * @cssprop --m3e-split-button-medium-trailing-button-selected-leading-space - Leading space for the trailing button (medium, selected).
 * @cssprop --m3e-split-button-medium-trailing-button-selected-trailing-space - Trailing space for the trailing button (medium, selected).
 * @cssprop --m3e-split-button-large-trailing-button-selected-leading-space - Leading space for the trailing button (large, selected).
 * @cssprop --m3e-split-button-large-trailing-button-selected-trailing-space - Trailing space for the trailing button (large, selected).
 * @cssprop --m3e-split-button-extra-large-trailing-button-selected-leading-space - Leading space for the trailing button (extra-large, selected).
 * @cssprop --m3e-split-button-extra-large-trailing-button-selected-trailing-space - Trailing space for the trailing button (extra-large, selected).
 * @cssprop --m3e-split-button-extra-small-inner-corner-size - Inner corner size for the leading/trailing button (extra-small).
 * @cssprop --m3e-split-button-small-inner-corner-size - Inner corner size for the leading/trailing button (small).
 * @cssprop --m3e-split-button-medium-inner-corner-size - Inner corner size for the leading/trailing button (medium).
 * @cssprop --m3e-split-button-large-inner-corner-size - Inner corner size for the leading/trailing button (large).
 * @cssprop --m3e-split-button-extra-large-inner-corner-size - Inner corner size for the leading/trailing button (extra-large).
 * @cssprop --m3e-split-button-extra-small-inner-corner-hover-size - Inner corner size on hover (extra-small).
 * @cssprop --m3e-split-button-small-inner-corner-hover-size - Inner corner size on hover (small).
 * @cssprop --m3e-split-button-medium-inner-corner-hover-size - Inner corner size on hover (medium).
 * @cssprop --m3e-split-button-large-inner-corner-hover-size - Inner corner size on hover (large).
 * @cssprop --m3e-split-button-extra-large-inner-corner-hover-size - Inner corner size on hover (extra-large).
 * @cssprop --m3e-split-button-extra-small-inner-corner-pressed-size - Inner corner size on press (extra-small).
 * @cssprop --m3e-split-button-small-inner-corner-pressed-size - Inner corner size on press (small).
 * @cssprop --m3e-split-button-medium-inner-corner-pressed-size - Inner corner size on press (medium).
 * @cssprop --m3e-split-button-large-inner-corner-pressed-size - Inner corner size on press (large).
 * @cssprop --m3e-split-button-extra-large-inner-corner-pressed-size - Inner corner size on press (extra-large).
 * @cssprop --m3e-split-button-extra-small-between-spacing - Spacing between leading and trailing buttons (extra-small).
 * @cssprop --m3e-split-button-small-between-spacing - Spacing between leading and trailing buttons (small).
 * @cssprop --m3e-split-button-medium-between-spacing - Spacing between leading and trailing buttons (medium).
 * @cssprop --m3e-split-button-large-between-spacing - Spacing between leading and trailing buttons (large).
 * @cssprop --m3e-split-button-extra-large-between-spacing - Spacing between leading and trailing buttons (extra-large).
 */
export declare class M3eSplitButtonElement extends M3eSplitButtonElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    private readonly _base?;
    /**
     * The appearance variant of the button.
     * @default "filled"
     */
    variant: SplitButtonVariant;
    /**
     * The size of the button.
     * @default "small"
     */
    size: ButtonSize;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-split-button": M3eSplitButtonElement;
    }
}
export {};
//# sourceMappingURL=SplitButtonElement.d.ts.map