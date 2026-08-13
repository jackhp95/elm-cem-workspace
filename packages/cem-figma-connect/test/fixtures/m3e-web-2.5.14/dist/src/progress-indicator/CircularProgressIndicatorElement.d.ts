import { CSSResultGroup, PropertyValues } from "lit";
import { ProgressElementIndicatorBase } from "./ProgressElementIndicatorBase";
/**
 * A circular indicator of progress and activity.
 *
 * @description
 * The `m3e-circular-progress-indicator` component displays a circular progress spinner for
 * tracking the completion of a task or process. It supports determinate and indeterminate
 * modes, and can be customized with CSS custom properties for diameter, stroke width, and
 * color. The component is accessible, animates smoothly, and adapts to various use cases including
 * loading and activity indication.
 *
 * @example
 * The following example illustrates a determinate circular progress indicator.
 * ```html
 * <m3e-circular-progress-indicator value="30"></m3e-circular-progress-indicator>
 * ```
 * @example
 * The next example illustrates an indeterminate circular progress indicator using the `indeterminate` attribute.
 * ```html
 * <m3e-circular-progress-indicator indeterminate></m3e-circular-progress-indicator>
 * ```
 *
 * @tag m3e-circular-progress-indicator
 *
 * @slot - Renders the content inside the progress indicator.
 *
 * @attr indeterminate - Whether to show something is happening without conveying progress.
 * @attr max - The maximum progress value.
 * @attr value - A fractional value, between 0 and `max`, indicating progress.
 * @attr variant - The appearance of the indicator.
 *
 * @cssprop --m3e-circular-flat-progress-indicator-diameter - Diameter of the `flat` variant.
 * @cssprop --m3e-circular-wavy-progress-indicator-diameter - Diameter of the `wavy` variant.
 * @cssprop --m3e-circular-wavy-progress-indicator-amplitude - Amplitude of the `wavy` variant.
 * @cssprop --m3e-circular-wavy-progress-indicator-wavelength - Wavelength of the `wavy` variant.
 * @cssprop --m3e-circular-progress-indicator-thickness - Thickness of the progress indicator.
 * @cssprop --m3e-progress-indicator-track-color - Track color of the progress indicator (background).
 * @cssprop --m3e-progress-indicator-color - Color of the progress indicator (foreground).
 */
export declare class M3eCircularProgressIndicatorElement extends ProgressElementIndicatorBase {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private static __nextMaskId;
    /**
     * Whether to show something is happening without conveying progress.
     * @default false
     */
    indeterminate: boolean;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    reconnectedCallback(): void;
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues): void;
    /** @inheritdoc */
    updated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-circular-progress-indicator": M3eCircularProgressIndicatorElement;
    }
}
//# sourceMappingURL=CircularProgressIndicatorElement.d.ts.map