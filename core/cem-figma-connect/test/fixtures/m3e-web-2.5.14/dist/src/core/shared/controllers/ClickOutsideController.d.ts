import { ReactiveControllerHost } from "lit";
import { MonitorControllerBase, MonitorControllerOptions } from "./MonitorControllerBase";
/** The callback function invoked when clicking outside all observed target. */
export type ClickOutsideControllerCallback = (composedPath: EventTarget[]) => void;
/** Encapsulates options used to configure a `ClickOutsideController`. */
export interface ClickOutsideControllerOptions extends MonitorControllerOptions {
    /** The callback invoked when clicking outside an observed target. */
    callback: ClickOutsideControllerCallback;
}
/** A `ReactiveController` used to monitor whether the user clicks outside all observed elements. */
export declare class ClickOutsideController extends MonitorControllerBase {
    #private;
    /**
     * Initializes a new instance of this class.
     * @param {ReactiveControllerHost & HTMLElement} host The host element to which this controller will be added.
     * @param {FocusControllerOptions} options Options used to configure this controller.
     */
    constructor(host: ReactiveControllerHost & HTMLElement, options: ClickOutsideControllerOptions);
    /** @inheritdoc */
    protected _observe(): void;
    /** @inheritdoc */
    protected _unobserve(): void;
}
//# sourceMappingURL=ClickOutsideController.d.ts.map