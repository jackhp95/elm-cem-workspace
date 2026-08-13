import { LitElement } from "lit";
import { ShapeName } from "./ShapeName";
/**
 * A shape used to add emphasis and decorative flair.
 *
 * @description
 * The `m3e-shape` component allows you to use abstract shapes thoughtfully to add emphasis and decorative flair,
 * including built-in shape morphing.
 *
 * All shape names are sourced from the Material Shape library: `4-leaf-clover`, `4-sided-cookie`, `6-sided-cookie`,
 * `7-sided-cookie`, `8-leaf-clover`, `9-sided-cookie`, `12-sided-cookie`, `arch`, `arrow`, `boom`, `bun`, `burst`,
 * `circle`, `diamond`, `fan`, `flower`, `gem`, `ghost-ish`, `heart`, `hexagon`, `oval`, `pentagon`, `pill`, `pixel-circle`,
 * `pixel-triangle`, `puffy`, `puffy-diamond`, `semicircle`, `slanted`, `soft-boom`, `soft-burst`, `square`, `sunny`,
 * `triangle`, and `very-sunny`. Refer to the Material Shape library for visual references and details.
 *
 * @example
 * The following example illustrates using the `m3e-shape` component to present the `sunny` shape.
 * ```html
 * <m3e-shape name="sunny"></m3e-shape>
 * ```
 *
 * @tag m3e-shape
 *
 * @slot - Renders the clipped content of the shape.
 *
 * @attr name - The name of the shape.
 *
 * @cssprop --m3e-shape-size - Default size of the shape.
 * @cssprop --m3e-shape-container-color - Container (background) color of the shape.
 * @cssprop --m3e-shape-transition - Transition used to morph between shapes.
 */
export declare class M3eShapeElement extends LitElement {
    /** The styles of the element. */
    static styles: import("lit").CSSResultGroup[];
    /**
     * The name of the shape.
     * @default null
     */
    name: ShapeName | null;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-shape": M3eShapeElement;
    }
}
//# sourceMappingURL=ShapeElement.d.ts.map