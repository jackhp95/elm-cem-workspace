import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { ElevationLevel } from "./ElevationLevel";
declare const M3eElevationElement_base: import("../mixins/Constructor").Constructor<import("..").HtmlForMixin> & import("../mixins/Constructor").Constructor & typeof LitElement;
/**
 * Visually depicts elevation using a shadow.
 *
 * @description
 * The `m3e-elevation` component is an absolute positioned element used to depict elevation using a shadow.
 * The parenting element must be a relative positioned element and allow for overflow. Use the `level` attribute
 * to specify the elevation level.
 *
 * The component can also be attached to another element using the `for` attribute.  When attached, elevation will
 * be lifted by 1 level on hover. This can be disabled using the `disabled` attribute.
 *
 * Alternatively, use the `attach` and `detach` methods to programmatically attach and detach this element to another.
 *
 * @example
 * The following example illustrates basic markup. Note how the parenting element's position is `relative`. A parenting
 * element's position must be `relative` and overflow must be visible.
 *
 * ```html
 * <div style="position: relative;">
 *  <m3e-elevation level="1"></m3e-elevation>
 * <div>
 * ```
 * @example
 * The following example illustrates attaching elevation to an interactive element. In this example, the parenting div
 * is given an `id` referenced by `m3e-elevation` using the `for` attribute.  Note that `#myDiv` is not used when
 * specifying the attached element's identifier.  The `#` is inferred.
 *
 * ```html
 * <div id="myDiv" style="position: relative;">
 *  <m3e-elevation for="myDiv" level="1"></m3e-elevation>
 * <div>
 * ```
 *
 * @tag m3e-elevation
 *
 * @attr disabled - Whether hover and press events will not trigger changes in elevation, when attached to an interactive element.
 * @attr for - The identifier of the interactive control to which this element is attached.
 * @attr level - The level at which to visually depict elevation.
 *
 * @cssprop --m3e-elevation-color - Color used to depict elevation.
 * @cssprop --m3e-elevation-lift-duration - Duration when lifting.
 * @cssprop --m3e-elevation-lift-easing - Easing curve when lifting.
 * @cssprop --m3e-elevation-settle-duration - Duration when settling.
 * @cssprop --m3e-elevation-settle-easing - Easing curve when settling.
 * @cssprop --m3e-elevation-level - Elevation when resting (box-shadow).
 * @cssprop --m3e-elevation-hover-level - Elevation on hover (box-shadow).
 * @cssprop --m3e-elevation-focus-level - Elevation on focus (box-shadow).
 * @cssprop --m3e-elevation-pressed-level - Elevation on pressed (box-shadow).
 */
export declare class M3eElevationElement extends M3eElevationElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    private readonly _shadow?;
    /**
     * Whether hover and press events will not trigger changes in elevation, when attached to an interactive element.
     * @default false
     */
    disabled: boolean;
    /**
     * The level at which to visually depict elevation.
     * @default null
     */
    level: ElevationLevel | null;
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
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-elevation": M3eElevationElement;
    }
}
export {};
//# sourceMappingURL=ElevationElement.d.ts.map