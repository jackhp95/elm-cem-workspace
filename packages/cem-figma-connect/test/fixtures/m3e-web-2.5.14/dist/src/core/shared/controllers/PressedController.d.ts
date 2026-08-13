import { ReactiveControllerHost } from "lit";
import { MonitorControllerBase, MonitorControllerOptions } from "./MonitorControllerBase";
/** The callback function invoked when the pressed state of an element changes. */
export type PressedControllerCallback = (pressed: boolean, point: {
    x: number;
    y: number;
}, target: HTMLElement) => void;
/** The callback function invoked to test whether an event should trigger a change to pressed state. */
export type PressedControllerFilterCallback = (e: Event) => boolean;
/** Encapsulates options used to configure a `PressedController`. */
export interface PressedControllerOptions extends MonitorControllerOptions {
    /** The callback invoked when the pressed state of an element changes. */
    callback: PressedControllerCallback;
    /** The callback function invoked to test whether an event should trigger a change to pressed state. */
    filter?: PressedControllerFilterCallback;
    /** The minimum amount of time, in milliseconds, to retain a pressed state. */
    minPressedDuration?: number;
    /** Whether events are captured. */
    capture?: boolean;
    /**
     * A function used to determine whether a given keyboard key toggles the pressed state.
     * @param key The `KeyboardEvent.key` to test.
     * @returns Whether `key` toggles the pressed state.
     */
    isPressedKey?: (key: string) => boolean;
}
/** A `ReactiveController` used to monitor the pressed state of one or more elements. */
export declare class PressedController extends MonitorControllerBase {
    #private;
    /**
     * Initializes a new instance of this class.
     * @param {ReactiveControllerHost & HTMLElement} host The host element to which this controller will be added.
     * @param {PressedControllerOptions} options Options used to configure this controller.
     */
    constructor(host: ReactiveControllerHost & HTMLElement, options: PressedControllerOptions);
    /** @inheritdoc */
    hostConnected(): void;
    /** @inheritdoc */
    hostDisconnected(): void;
    /** @inheritdoc */
    protected _observe(target: HTMLElement): void;
    /** @inheritdoc */
    protected _unobserve(target: HTMLElement): void;
}
//# sourceMappingURL=PressedController.d.ts.map