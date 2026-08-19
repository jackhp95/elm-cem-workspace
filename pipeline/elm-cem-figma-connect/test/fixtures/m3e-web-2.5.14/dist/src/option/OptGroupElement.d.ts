import { CSSResultGroup, LitElement } from "lit";
declare const M3eOptGroupElement_base: import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * Groups options under a subheading.
 *
 * @description
 * The `m3e-optgroup` component organizes related options within an option list,
 * providing visual and semantic grouping through a customizable label. It manages `aria-labelledby`
 * associations automatically and applies Material Design 3 typography and spacing conventions to
 * the group label. The component maintains proper semantic structure by utilizing the ARIA `group` role,
 * ensuring that assistive technologies correctly interpret the hierarchical relationship between the label
 * and contained options.
 *
 * @tag m3e-optgroup
 *
 * @slot - Renders the options of the group.
 * @slot label - Renders the label of the group.
 *
 * @cssprop --m3e-option-height - The height of the group label container.
 * @cssprop --m3e-option-font-size - The font size of the group label.
 * @cssprop --m3e-option-font-weight - The font weight of the group label.
 * @cssprop --m3e-option-line-height - The line height of the group label.
 * @cssprop --m3e-option-tracking - The letter spacing of the group label.
 * @cssprop --m3e-option-padding-end - The right padding of the label.
 * @cssprop --m3e-option-padding-start - The left padding of the label.
 * @cssprop --m3e-option-color - The text color of the group label.
 */
export declare class M3eOptGroupElement extends M3eOptGroupElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private static __nextId;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-optgroup": M3eOptGroupElement;
    }
}
export {};
//# sourceMappingURL=OptGroupElement.d.ts.map