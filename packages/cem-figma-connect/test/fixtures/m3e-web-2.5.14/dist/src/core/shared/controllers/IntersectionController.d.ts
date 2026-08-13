import { ReactiveControllerHost } from "lit";
import { MonitorControllerBase, MonitorControllerOptions } from "./MonitorControllerBase";
/** The callback function for a `IntersectionController`. */
export type IntersectionControllerCallback = (...args: Parameters<IntersectionObserverCallback>) => void;
/** Encapsulates options used to configure a `IntersectionController`. */
export interface IntersectionControllerOptions extends MonitorControllerOptions {
    /** The callback used to process detected changes. */
    callback: IntersectionControllerCallback;
    /**
     * By default, the `callback` is invoked without changes when a
     * target is observed in order to help maintain initial state. Use
     * `skipInitial` to skip this step.
     */
    skipInitial?: boolean;
    /** The configuration object for the underlying `IntersectionObserver`. */
    init?: IntersectionObserverInit;
}
/** A `ReactiveController` used to monitor changes in the intersection of a target element with an ancestor element. */
export declare class IntersectionController extends MonitorControllerBase {
    #private;
    /**
     * Initializes a new instance of the `IntersectionController` class.
     * @param {ReactiveControllerHost & HTMLElement} host The host element to which this controller will be added.
     * @param {IntersectionControllerOptions} options Options used to configure this controller.
     */
    constructor(host: ReactiveControllerHost & HTMLElement, options: IntersectionControllerOptions);
    /** @inheritdoc */
    hostUpdated(): Promise<void>;
    /** @inheritdoc */
    protected _observe(target: HTMLElement): void;
    /** @inheritdoc */
    protected _unobserve(target: HTMLElement): void;
}
//# sourceMappingURL=IntersectionController.d.ts.map