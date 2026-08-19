import { ReactiveControllerHost } from "lit";
import { MonitorControllerBase, MonitorControllerOptions } from "./MonitorControllerBase";
/** The callback function invoked when a long press gesture is detected. */
export type LongPressControllerCallback = (pressed: boolean, target: HTMLElement) => void;
/** Encapsulates options used to configure a `LongPressController`. */
export interface LongPressControllerOptions extends MonitorControllerOptions {
    /** The callback invoked when the pressed state of an element changes. */
    callback: LongPressControllerCallback;
    /** The amount of time, in milliseconds, a touch gesture must be held. */
    threshold?: number;
}
/** A `ReactiveController` used to detect a long press gesture. */
export declare class LongPressController extends MonitorControllerBase {
    #private;
    /**
     * Initializes a new instance of this class.
     * @param {ReactiveControllerHost & HTMLElement} host The host element to which this controller will be added.
     * @param {LongPressControllerOptions} options Options used to configure this controller.
     */
    constructor(host: ReactiveControllerHost & HTMLElement, options: LongPressControllerOptions);
    /** @inheritdoc */
    protected _observe(target: HTMLElement): void;
    /** @inheritdoc */
    protected _unobserve(target: HTMLElement): void;
}
//# sourceMappingURL=LongPressController.d.ts.map