import { ReactiveControllerHost } from "lit";
import { MonitorControllerBase, MonitorControllerOptions } from "./MonitorControllerBase";
/** The callback function invoked when the focused state of an element changes. */
export type FocusControllerCallback = (focused: boolean, focusVisible: boolean, target: HTMLElement) => void;
/** The callback function invoked to test whether an event should trigger a change to focused state. */
export type FocusControllerFilterCallback = (e: Event) => boolean;
/** Encapsulates options used to configure a `FocusController`. */
export interface FocusControllerOptions extends MonitorControllerOptions {
    /** The callback invoked when the focused state of an element changes. */
    callback: FocusControllerCallback;
    /** The callback function invoked to test whether an event should trigger a change to focused state. */
    filter?: FocusControllerFilterCallback;
}
/** A `ReactiveController` used to monitor the focused state of one or more elements. */
export declare class FocusController extends MonitorControllerBase {
    #private;
    /**
     * Initializes a new instance of this class.
     * @param {ReactiveControllerHost & HTMLElement} host The host element to which this controller will be added.
     * @param {FocusControllerOptions} options Options used to configure this controller.
     */
    constructor(host: ReactiveControllerHost & HTMLElement, options: FocusControllerOptions);
    /** @inheritdoc */
    protected _observe(target: HTMLElement): void;
    /** @inheritdoc */
    protected _unobserve(target: HTMLElement): void;
}
//# sourceMappingURL=FocusController.d.ts.map