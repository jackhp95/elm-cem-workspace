import { CSSResultGroup, LitElement, PropertyValues } from "lit";
declare const M3eStateLayerElement_base: import("../mixins/Constructor").Constructor<import("..").HtmlForMixin> & import("../mixins/Constructor").Constructor & typeof LitElement;
/**
 * Provides focus and hover state layer treatment for an interactive element.
 *
 * @description
 * The `m3e-state-layer` component is an absolute positioned element used to depict hover and focus overlays.
 * The parenting element must be a relative positioned element.
 *
 * This element can be attached to an interactive element using the `for` attribute or programmatically using the `attach` method.
 * The state layer is displayed when the interactive element is either hovered or focused.  This can be disabled using
 * the `disabled` attribute.
 *
 * @example
 * The following example illustrates attaching a state layer to an interactive element. In this example, the parenting div
 * has relative positioning and is given an `id` referenced by `m3e-state-layer` using the `for` attribute.  Note that `#myDiv`
 * is not used when specifying the attached element's identifier.  The `#` is inferred.
 *
 * ```html
 * <div id="myDiv" tabindex="0" style="position: relative;">
 *  <m3e-state-layer for="myDiv"></m3e-state-layer>
 * <div>
 * ```
 *
 * @tag m3e-state-layer
 *
 * @attr disabled - Whether hover and focus events will not trigger the state layer. State layers can still be controlled manually using the `show` and `hide` methods.
 * @attr disable-hover - Whether hover events will not trigger the state layer. State layers can still be controlled manually using the `show` and `hide` methods.
 *
 * @cssprop --m3e-state-layer-duration - Duration of state layer changes.
 * @cssprop --m3e-state-layer-easing - Easing curve of state layer changes.
 * @cssprop --m3e-state-layer-focus-color - Color on hover.
 * @cssprop --m3e-state-layer-focus-opacity - Opacity on focus.
 * @cssprop --m3e-state-layer-hover-color - Color on hover.
 * @cssprop --m3e-state-layer-hover-opacity - Opacity on hover.
 */
export declare class M3eStateLayerElement extends M3eStateLayerElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private readonly _layer?;
    /**
     * Whether hover and focus events will not trigger the state layer. State layers can still
     * be controlled manually using the `show` and `hide` methods.
     * @default false
     */
    disabled: boolean;
    /**
     * Whether hover events will not trigger the state layer. State layers can still
     * be controlled manually using the `show` and `hide` methods.
     * @default false
     */
    disableHover: boolean;
    /**
     * Launches a manual state layer.
     * @param {"hover" | "focused"} state The state of the layer to show.
     */
    show(state: "hover" | "focused"): void;
    /**
     * Hides the state layer.
     * @param {"hover" | "focused"} state The state of the layer to hide.
     */
    hide(state: "hover" | "focused"): void;
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
        "m3e-state-layer": M3eStateLayerElement;
    }
}
export {};
//# sourceMappingURL=StateLayerElement.d.ts.map