import { CSSResult } from "lit";
/** Design tokens that control density. */
export declare const DensityToken: {
    /**
     * Creates a CSS `calc` that calculates a dimension based on density.
     * @param {number} minScale The minimum supported scale.
     * @returns {CSSResult} A CSS `calc` used to calculate a dimension based on density.
     */
    readonly calc: (minScale: number) => CSSResult;
    /** Base density multiplier. */
    readonly scale: CSSResult;
    /** Spatial unit used to scale component dimensions based on density. */
    readonly size: CSSResult;
};
//# sourceMappingURL=DensityToken.d.ts.map