import { CSSResultGroup, PropertyValues } from "lit";
import { LinearProgressMode } from "./LinearProgressMode";
import { ProgressElementIndicatorBase } from "./ProgressElementIndicatorBase";
/**
 * A horizontal bar for indicating progress and activity.
 *
 * @description
 * The `m3e-linear-progress-indicator` component displays a horizontal progress bar for tracking
 * the completion of a task or process. It supports `determinate`, `indeterminate`, `buffer`,
 * and `query` modes, and can be customized with CSS custom properties for thickness, shape, and color.
 * The component is accessible, animates smoothly, and adapts to various use cases including loading,
 * buffering, and activity indication.
 *
 * @example
 * The following example illustrates a determinate linear progress indicator.
 * ```html
 * <m3e-linear-progress-indicator value="30"></m3e-linear-progress-indicator>
 * ```
 * @example
 * The next example illustrates an indeterminate linear progress indicator using the `mode` attribute.
 * ```html
 * <m3e-linear-progress-indicator mode="indeterminate"></m3e-linear-progress-indicator>
 * ```
 *
 * @tag m3e-linear-progress-indicator
 *
 * @attr buffer-value - A fractional value, between 0 and `max`, indicating buffer progress.
 * @attr max - The maximum progress value.
 * @attr mode - The mode of the progress bar.
 * @attr value - A fractional value, between 0 and `max`, indicating progress.
 * @attr variant - The appearance of the indicator.
 *
 * @cssprop --m3e-linear-progress-indicator-thickness - Thickness (height) of the progress bar.
 * @cssprop --m3e-linear-progress-indicator-shape - Border radius of the progress bar.
 * @cssprop --m3e-progress-indicator-track-color - Track color of the progress bar (background/buffer).
 * @cssprop --m3e-progress-indicator-color - Color of the progress indicator (foreground).
 * @cssprop --m3e-linear-wavy-progress-indicator-amplitude - Amplitude of the `wavy` variant.
 * @cssprop --m3e-linear-wavy-progress-indicator-wavelength - Wavelength of the `wavy` variant.
 * @cssprop --m3e-linear-wavy-indeterminate-progress-indicator-wavelength - Wavelength of the indeterminate/query `wavy` variant.
 */
export declare class M3eLinearProgressIndicatorElement extends ProgressElementIndicatorBase {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private static __nextMaskId;
    /**
     * The mode of the progress bar.
     * @default "determinate"
     */
    mode: LinearProgressMode;
    /**
     * A fractional value, between 0 and `max`, indicating buffer progress.
     * @default 0
     */
    bufferValue: number;
    /** @inheritdoc */
    reconnectedCallback(): void;
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues): void;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected updated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-linear-progress-indicator": M3eLinearProgressIndicatorElement;
    }
}
//# sourceMappingURL=LinearProgressIndicatorElement.d.ts.map