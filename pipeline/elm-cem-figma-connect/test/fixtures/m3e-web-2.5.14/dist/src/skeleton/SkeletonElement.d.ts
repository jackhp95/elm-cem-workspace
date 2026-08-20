import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { SkeletonShape } from "./SkeletonShape";
import { SkeletonAnimation } from "./SkeletonAnimation";
declare const M3eSkeletonElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").ReconnectedCallbackMixin> & typeof LitElement;
/**
 * A visual placeholder that mimics the layout of content while it's still loading.
 * @description
 * The `m3e-skeleton` component provides a loading placeholder surface with flexible shape variants and
 * motion-based animations that communicate loading state while preserving layout stability. It mimics
 * the layout of content while it's still loading, ensuring a smooth user experience during data fetching
 * or rendering delays. The component supports different animation effects (`pulse`, `wave`, `none`) and
 * shape variants (`circular`, `rounded`, `square`, `auto`) to adapt to various content types. When the
 * content is loaded, the skeleton fades out with a smooth transition.
 *
 * @example
 * The following example illustrates a skeleton shaped and sized by the slotted `m3e-card`.
 * ```html
 * <m3e-skeleton>
 *  <m3e-card></m3e-card>
 * </m3e-skeleton>
 * ```
 *
 * @tag m3e-skeleton
 *
 * @attr animation - The animation effect of the skeleton.
 * @attr shape - The shape of the skeleton.
 * @attr loaded - Whether the content of the skeleton has been loaded.
 *
 * @slot - Renders the content to be mimicked by the skeleton.
 *
 * @cssprop --m3e-skeleton-color - Base fill color for the skeleton surface.
 * @cssprop --m3e-skeleton-tint-color - Tint fill color for the skeleton surface.
 * @cssprop --m3e-skeleton-tint-opacity - Tint Opacity applied when the skeleton animation is not pulsating.
 * @cssprop --m3e-skeleton-accent-color - Accent color used in wave animation.
 * @cssprop --m3e-skeleton-accent-opacity - Opacity of the accent effect in animations.
 * @cssprop --m3e-skeleton-rounded-shape - Corner radius for the rounded skeleton shape.
 * @cssprop --m3e-skeleton-circular-shape - Corner radius for the circular skeleton shape.
 * @cssprop --m3e-skeleton-square-shape - Corner radius for the square skeleton shape.
 * @cssprop --m3e-skeleton-shape - Corner radius for the skeleton shape.
 */
export declare class M3eSkeletonElement extends M3eSkeletonElement_base {
    #private;
    /** @private */ private static __pulseLoading;
    /** @private */ private static __pulseAnimation;
    /** @private */ private static __waveLoading;
    /** @private */ private static __waveAnimation;
    /** @private */ private static __reducedMediaQuery;
    /** @private */ private static __forcedColorsMediaQuery;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /**
     * The shape of the skeleton.
     * @default "auto"
     */
    shape: SkeletonShape;
    /**
     * The animation effect of the skeleton.
     * @default "wave"
     */
    animation: SkeletonAnimation;
    /**
     * Whether the content of the skeleton has been loaded.
     * @default false
     */
    loaded: boolean;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    reconnectedCallback(): void;
    /** @inheritdoc */
    protected willUpdate(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
    /** @private */
    static __updateAnimations(): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-skeleton": M3eSkeletonElement;
    }
}
export {};
//# sourceMappingURL=SkeletonElement.d.ts.map