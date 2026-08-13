import { ReactiveControllerHost } from "lit";
import { MonitorControllerBase, MonitorControllerOptions } from "./MonitorControllerBase";
/** The callback function for a `ResizeController`. */
export type ResizeControllerCallback = (...args: Parameters<ResizeObserverCallback>) => void;
/** Encapsulates options used to configure a `ResizeController`. */
export interface ResizeControllerOptions extends MonitorControllerOptions {
    /** The callback used to process detected changes. */
    callback: ResizeControllerCallback;
    /**
     * By default, the `callback` is invoked without changes when a
     * target is observed in order to help maintain initial state. Use
     * `skipInitial` to skip this step.
     */
    skipInitial?: boolean;
    /** The configuration object for the underlying `ResizeObserver`. */
    config?: ResizeObserverOptions;
}
/** A `ReactiveController` used to monitor when an element is resized. */
export declare class ResizeController extends MonitorControllerBase {
    #private;
    /**
     * Initializes a new instance of the `ResizeController` class.
     * @param {ReactiveControllerHost & HTMLElement} host The host element to which this controller will be added.
     * @param {ResizeControllerOptions} options Options used to configure this controller.
     */
    constructor(host: ReactiveControllerHost & HTMLElement, options: ResizeControllerOptions);
    /** @inheritdoc */
    hostUpdated(): Promise<void>;
    /** @inheritdoc */
    protected _observe(target: HTMLElement): void;
    /** @inheritdoc */
    protected _unobserve(target: HTMLElement): void;
}
//# sourceMappingURL=ResizeController.d.ts.map