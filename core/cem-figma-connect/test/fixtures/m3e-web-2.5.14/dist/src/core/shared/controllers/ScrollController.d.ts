import { ReactiveControllerHost } from "lit";
import { MonitorControllerBase, MonitorControllerOptions } from "./MonitorControllerBase";
/** The callback function invoked when a scrollable ancestor is scrolled. */
export type ScrollControllerCallback = (target: Element) => void;
/** Encapsulates options used to configure a `ScrollController`. */
export interface ScrollControllerOptions extends MonitorControllerOptions {
    /** The callback invoked a scrollable ancestor is scrolled. */
    callback: ScrollControllerCallback;
    /** Whether to debounce scroll events. */
    debounce?: boolean;
}
/** A `ReactiveController` used to monitor when a scroll event is emitted from a scrollable ancestor. */
export declare class ScrollController extends MonitorControllerBase {
    #private;
    /**
     * Initializes a new instance of the `ScrollController` class.
     * @param {ReactiveControllerHost & HTMLElement} host The host element to which this controller will be added.
     * @param {ScrollControllerOptions} options Options used to configure this controller.
     */
    constructor(host: ReactiveControllerHost & HTMLElement, options: ScrollControllerOptions);
    /**
     * Returns the scrollable ancestors for a target element currently being observed by this controller.
     * @param target The element whose scroll containers are currently being observed.
     * @returns {Element[] | undefined} The scrollable ancestors, or `undefined` if `target` is not being observed.
     */
    getScrollContainers(target: HTMLElement): Element[] | undefined;
    /** @inheritdoc */
    protected _observe(target: HTMLElement): void;
    /** @inheritdoc */
    protected _unobserve(target: HTMLElement): void;
    /** @private */
    private _debounceCallback;
}
//# sourceMappingURL=ScrollController.d.ts.map