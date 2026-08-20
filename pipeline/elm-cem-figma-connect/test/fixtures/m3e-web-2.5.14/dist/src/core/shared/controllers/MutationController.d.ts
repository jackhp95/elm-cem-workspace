import { ReactiveControllerHost } from "lit";
import { MonitorControllerBase, MonitorControllerOptions } from "./MonitorControllerBase";
/** Encapsulates options used to configure a `MutationController`. */
export interface MutationControllerOptions extends MonitorControllerOptions {
    /** The callback used to process detected changes. */
    callback: MutationCallback;
    /**
     * By default, the `callback` is invoked without changes when a
     * target is observed in order to help maintain initial state. Use
     * `skipInitial` to skip this step.
     */
    skipInitial?: boolean;
    /** The configuration object for the underlying `MutationObserver`. */
    config?: MutationObserverInit;
}
/**
 * A `ReactiveController` that integrates a `MutationObserver` with an element's reactive update lifecycle
 * to detect arbitrary changes to DOM, including nodes being added or removed and attributes changing.
 */
export declare class MutationController extends MonitorControllerBase {
    #private;
    /**
     * Initializes a new instance of the `MutationController` class.
     * @param {ReactiveControllerHost & HTMLElement} host The host element to which this controller will be added.
     * @param {MutationControllerOptions} options Options used to configure this controller.
     */
    constructor(host: ReactiveControllerHost & HTMLElement, options: MutationControllerOptions);
    /** @inheritdoc */
    hostUpdated(): Promise<void>;
    /** @inheritdoc */
    hostDisconnected(): void;
    /** @inheritdoc */
    protected _observe(target: HTMLElement): void;
    /** @inheritdoc */
    protected _unobserve(): void;
}
//# sourceMappingURL=MutationController.d.ts.map