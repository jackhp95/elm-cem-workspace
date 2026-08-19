/**
 * Adapted from Angular Material CDK Directionality
 * Source: https://github.com/angular/components/blob/main/src/cdk/bidi/directionality.ts
 *
 * @license MIT
 * Copyright (c) 2025 Google LLC
 * See LICENSE file in the project root for full license text.
 */
/** Specifies the directionalities for a document. */
export type Direction = "ltr" | "rtl";
/** Utility used to determine the directionality of the current document. */
export declare class M3eDirectionality {
    #private;
    /** The directionality of the current document. */
    static get current(): Direction;
    /**
     * Observes changes to directionality.
     * @param {()=>void} callback Function invoked when directionality changes.
     * @returns {()=>void} A function used to unobserve changes.
     */
    static observe(callback: () => void): () => void;
}
type M3eDirectionalityClass = typeof M3eDirectionality;
declare global {
    /** Utility used to determine the directionality of the current document. */
    var M3eDirectionality: M3eDirectionalityClass;
}
export {};
//# sourceMappingURL=Directionality.d.ts.map