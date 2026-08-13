/** Utility for computing gesture velocity over a rolling time window. */
export declare class VelocityTracker {
    #private;
    /**
     * @param {number} [windowMs = 100] The size of the rolling sampling window in milliseconds.
     */
    constructor(windowMs?: number);
    /**
     * Adds a new sample to the tracker.
     * @param {number} value The value in pixels.
     * @param {number} [timestamp=performance.now()] The timestamp when `value` changed.
     */
    add(value: number, timestamp?: number): void;
    /**
     * Computes the current velocity in px/s.
     * @returns The vertical velocity in pixels per second.
     */
    getVelocity(): number;
    /** Clears all stored samples. */
    reset(): void;
}
//# sourceMappingURL=VelocityTracker.d.ts.map