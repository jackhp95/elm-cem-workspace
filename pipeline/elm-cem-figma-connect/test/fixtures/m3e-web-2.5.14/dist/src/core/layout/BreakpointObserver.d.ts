import { Breakpoint } from "./Breakpoint";
/** The callback function invoked when the viewport size changes. */
export type BreakpointObserverCallback = (matches: Map<Breakpoint | string, boolean>) => void;
/** Utility used to detect changes to viewport sizes. */
export declare class M3eBreakpointObserver {
    /**
     * Observes changes to viewport sizes.
     * @param {Array<Breakpoint | string>} breakpoints The breakpoints to observe.
     * @param {BreakpointObserverCallback} callback The callback function invoked when the viewport size changes.
     * @returns {() => void} A function used to stop observing changes to viewport sizes.
     */
    static observe(breakpoints: Array<Breakpoint | string>, callback: BreakpointObserverCallback): () => void;
}
type M3eBreakpointObserverClass = typeof M3eBreakpointObserver;
declare global {
    /** Utility used to detect changes to viewport sizes. */
    var M3eBreakpointObserver: M3eBreakpointObserverClass;
}
export {};
//# sourceMappingURL=BreakpointObserver.d.ts.map