import { CSSResultGroup, LitElement } from "lit";
declare const M3eDividerElement_base: import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * A thin line that separates content in lists or other containers.
 *
 * @description
 * The `m3e-divider` component visually separates content within layouts, lists, or containers using a thin, unobtrusive line.
 * It supports horizontal and vertical orientation, with optional inset variants to align with layout padding and visual hierarchy.
 * The divider thickness, color, and inset behavior are customizable via CSS properties to maintain consistency across surfaces.
 * It is designed to reinforce spatial relationships without drawing attention, preserving focus on primary content.
 *
 * @example
 * The following example illustrates a basic horizontal divider.
 * ```html
 * <m3e-divider></m3e-divider>
 * ```
 *
 * @tag m3e-divider
 *
 * @attr inset - Whether the divider is indented with equal padding on both sides.
 * @attr inset-start - Whether the divider is indented with padding on the leading side.
 * @attr inset-end - Whether the divider is indented with padding on the trailing side.
 * @attr vertical - Whether the divider is vertically aligned with adjacent content.
 *
 * @cssprop --m3e-divider-thickness - Thickness of the divider line.
 * @cssprop --m3e-divider-color - Color of the divider line.
 * @cssprop --m3e-divider-inset-size - When inset, fallback inset size used when no specific start or end inset is provided.
 * @cssprop --m3e-divider-inset-start-size - When inset, leading inset size.
 * @cssprop --m3e-divider-inset-end-size - When inset, trailing inset size.
 */
export declare class M3eDividerElement extends M3eDividerElement_base {
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /**
     * Whether the divider is vertically aligned with adjacent content.
     * @default false
     */
    vertical: boolean;
    /**
     * Whether the divider is indented with equal padding on both sides.
     * @default false
     */
    inset: boolean;
    /**
     * Whether the divider is indented with padding on the leading side.
     * @default false
     */
    insetStart: boolean;
    /**
     * Whether the divider is indented with padding on the trailing side.
     * @default false
     */
    insetEnd: boolean;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-divider": M3eDividerElement;
    }
}
export {};
//# sourceMappingURL=DividerElement.d.ts.map