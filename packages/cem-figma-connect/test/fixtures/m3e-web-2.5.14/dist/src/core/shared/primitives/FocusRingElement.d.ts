import { CSSResultGroup, LitElement, PropertyValues } from "lit";
declare const M3eFocusRingElement_base: import("../mixins/Constructor").Constructor<import("..").HtmlForMixin> & import("../mixins/Constructor").Constructor & typeof LitElement;
/**
 * A focus ring used to depict a strong focus indicator.
 *
 * @description
 * The `m3e-focus-ring` component is an absolute positioned element used to provide a strong focus indicator.
 * The parenting element must be a relative positioned focusable element and allow for overflow.
 *
 * The component can be attached to an interactive element using the `for` attribute or programmatically using the `attach` method.
 * The focus ring is displayed when the interactive element receives visible focus and hidden when focus is lost.
 * This can be disabled using the `disabled` attribute.
 *
 * Alternatively, you can use the `show` and `hide` methods to programmatically control the focus ring.
 *
 * @example
 * The following example illustrates attaching a focus ring to an interactive element. In this example, the parenting div
 * has relative positioning and is given an `id` referenced by `m3e-focus-ring` using the `for` attribute.  Note that `#myDiv`
 * is not used when specifying the attached element's identifier.  The `#` is inferred.
 *
 * ```html
 * <div id="myDiv" tabindex="0" style="position: relative;">
 *  <m3e-focus-ring for="myDiv"></m3e-focus-ring>
 * <div>
 * ```
 *
 * @tag m3e-focus-ring
 *
 * @attr disabled - Whether the focus events will not trigger the focus ring. Focus rings can be still controlled manually by using the `show` and `hide` methods.
 * @attr inward - Whether the focus ring animates inward instead of outward.
 *
 * @cssprop --m3e-focus-ring-color - The color of the focus ring.
 * @cssprop --m3e-focus-ring-duration - The duration of the focus ring animation.
 * @cssprop --m3e-focus-ring-growth-factor - The factor by which the focus ring grows.
 * @cssprop --m3e-focus-ring-thickness - The thickness of the focus ring.
 * @cssprop --m3e-focus-ring-visibility - The visibility of the focus ring.
 * @cssprop --m3e-focus-ring-outward-offset - Offset of an outward focus ring.
 * @cssprop --m3e-focus-ring-inward-offset - Offset of an inward focus ring.
 */
export declare class M3eFocusRingElement extends M3eFocusRingElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private readonly _outline?;
    /**
     * Whether the focus ring animates inward instead of outward.
     * @default false
     */
    inward: boolean;
    /**
     * Whether the focus events will not trigger the focus ring.
     * Focus rings can be still controlled manually by using the `show` and `hide` methods.
     * @default false
     */
    disabled: boolean;
    /** Launches a manual focus ring. */
    show(): void;
    /** Hides the focus ring. */
    hide(): void;
    /** @inheritdoc */
    attach(control: HTMLElement): void;
    /** @inheritdoc */
    detach(): void;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected render(): unknown;
    /** @inheritdoc */
    protected updated(_changedProperties: PropertyValues<this>): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-focus-ring": M3eFocusRingElement;
    }
}
export {};
//# sourceMappingURL=FocusRingElement.d.ts.map