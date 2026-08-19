import { CSSResultGroup, LitElement, PropertyValues } from "lit";
declare const M3eRippleElement_base: import("../mixins/Constructor").Constructor<import("..").HtmlForMixin> & import("../mixins/Constructor").Constructor & typeof LitElement;
/**
 * Connects user input to screen reactions using ripples.
 *
 * @description
 * The `m3e-ripple` component is an absolute positioned element used to depict a ripple.
 * The parenting element must be a relative positioned element.
 *
 * The component can be attached to an interactive element using the `for` attribute or programmatically using the `attach` method.
 * The ripple is displayed when the interactive element is pressed and hidden when released.  This can be disabled using the `disabled` attribute.
 *
 * The pressed state actives either using both pointer and keyboard events. For keyboard events, `SPACE` activate a ripple.
 *
 * Alternatively, you can use the `show` and `hide` methods to programmatically control the ripple.
 *
 * @example
 * The following example illustrates attaching a ripple to an interactive element. In this example, the parenting div
 * has relative positioning and is given an `id` referenced by `m3e-ripple` using the `for` attribute.  Note that `#myDiv`
 * is not used when specifying the attached element's identifier.  The `#` is inferred.
 *
 * ```html
 * <div id="myDiv" tabindex="0" style="position: relative;">
 *  <m3e-ripple for="myDiv"></m3e-ripple>
 * <div>
 * ```
 *
 * @tag m3e-ripple
 *
 * @attr centered - Whether the ripple always originates from the center of the element's bounds, rather than originating from the location of the click event.
 * @attr disabled - Whether click events will not trigger the ripple.  Ripples can be still controlled manually by using the `show` and 'hide' methods.
 * @attr for - The identifier of the interactive control to which this element is attached.
 * @attr radius - The radius, in pixels, of the ripple.
 * @attr unbounded - Whether the ripple is visible outside the element's bounds.
 *
 * @cssprop --m3e-ripple-color - The color of the ripple.
 * @cssprop --m3e-ripple-enter-duration - The duration for the enter animation (expansion from point of contact).
 * @cssprop --m3e-ripple-exit-duration - The duration for the exit animation (fade-out).
 * @cssprop --m3e-ripple-opacity - The opacity of the ripple.
 * @cssprop --m3e-ripple-scale-factor - The factor by which to scale the ripple.
 * @cssprop --m3e-ripple-shape - The shape of the ripple.
 */
export declare class M3eRippleElement extends M3eRippleElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /**
     * Whether click events will not trigger the ripple.
     * Ripples can be still controlled manually by using the `show` and 'hide' methods.
     * @default false
     */
    disabled: boolean;
    /**
     * Whether the ripple always originates from the center of the element's bounds, rather
     * than originating from the location of the click event.
     * @default false
     */
    centered: boolean;
    /**
     * Whether the ripple is visible outside the element's bounds.
     * @default false
     */
    unbounded: boolean;
    /**
     * The radius, in pixels, of the ripple.
     * @default null
     */
    radius: number | null;
    /** Whether the ripple is currently visible to the user. */
    get visible(): boolean;
    /**
     * Launches a manual ripple.
     * @param {number} x The x-coordinate, relative to the viewport, at which to present the ripple.
     * @param {number} y The y-coordinate, relative to the viewport, at which to present the ripple.
     * @param {boolean} [persistent=false] Whether the ripple will persist until hidden.
     */
    show(x: number, y: number, persistent?: boolean): void;
    /** Manually hides the ripple. */
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
    protected updated(_changedProperties: PropertyValues<this>): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-ripple": M3eRippleElement;
    }
}
export {};
//# sourceMappingURL=RippleElement.d.ts.map