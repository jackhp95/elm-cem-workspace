import { AnchorOptions } from "./AnchorOptions";
import { AnchorPosition } from "./AnchorPosition";
/**
 * Positions an element relative to an anchor element.
 * @param {HTMLElement} target The element to position.
 * @param {HTMLElement} anchor The element in which to anchor `target`.
 * @param {AnchorOptions} options Options that control positioning relative to the anchor.
 * @param {((x: number, y: number, position: AnchorPosition) => void)} update Callback used to position `target`.
 * @returns {Promise<() => void>} Promise that resolves to a function used to stop updating target when the position of the anchor element changes.
 */
export declare function positionAnchor(target: HTMLElement, anchor: HTMLElement, options: AnchorOptions, update: (x: number, y: number, position: AnchorPosition) => void): Promise<() => void>;
//# sourceMappingURL=positionAnchor.d.ts.map