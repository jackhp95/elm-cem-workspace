import { ReactiveControllerHost } from "lit";
import { MonitorControllerBase, MonitorControllerOptions } from "./MonitorControllerBase";
/** The callback function invoked when the hover state of an element changes. */
export type HoverControllerCallback = (hovering: boolean, target: HTMLElement) => void;
/** Encapsulates options used to configure a `HoverController`. */
export interface HoverControllerOptions extends MonitorControllerOptions {
    /** The callback invoked when the hover state of an element changes. */
    callback: HoverControllerCallback;
    /** The delay, in milliseconds, before reporting hover start. */
    startDelay?: number;
    /** The delay, in milliseconds, before reporting hover end. */
    endDelay?: number;
}
/** A `ReactiveController` used to monitor the hover state of one or more elements. */
export declare class HoverController extends MonitorControllerBase {
    #private;
    /** The delay, in milliseconds, before reporting hover start. */
    startDelay: number;
    /** The delay, in milliseconds, before reporting hover end. */
    endDelay: number;
    /**
     * Initializes a new instance of this class.
     * @param {ReactiveControllerHost & HTMLElement} host The host element to which this controller will be added.
     * @param {HoverControllerOptions} options Options used to configure this controller.
     */
    constructor(host: ReactiveControllerHost & HTMLElement, options: HoverControllerOptions);
    /** Clears any hover delays for all targets. */
    clearDelays(): void;
    /** @inheritdoc */
    protected _observe(target: HTMLElement): void;
    /** @inheritdoc */
    protected _unobserve(target: HTMLElement): void;
}
//# sourceMappingURL=HoverController.d.ts.map