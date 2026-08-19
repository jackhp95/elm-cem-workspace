import { CSSResultGroup, LitElement } from "lit";
declare const M3eChipSetElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").VerticalMixin> & typeof LitElement;
/**
 * A container used to organize chips into a cohesive unit.
 *
 * @description
 * The `m3e-chip-set` component provides a flexible container for grouping chips, supporting both
 * horizontal and vertical layouts. It manages chip arrangement, spacing, and accessibility, and
 * serves as the foundation for chip set variants such as input and filter chip sets.
 *
 * @example
 * The following example illustrates use of the `m3e-chip` and `m3e-chip-set` components to present non-interactive chips.
 * ```html
 * <m3e-chip-set>
 *  <m3e-chip><m3e-icon slot="icon" name="palette"></m3e-icon>Design</m3e-chip>
 *  <m3e-chip><m3e-icon slot="icon" name="accessibility_new"></m3e-icon>Accessibility</m3e-chip>
 *  <m3e-chip><m3e-icon slot="icon" name="motion_photos_on"></m3e-icon>Motion</m3e-chip>
 *  <m3e-chip><m3e-icon slot="icon" name="description"></m3e-icon>Documentation</m3e-chip>
 * </m3e-chip-set>
 * ```
 *
 * @tag m3e-chip-set
 *
 * @slot - Renders the chips of the set.
 *
 * @attr vertical - Whether the element is oriented vertically.
 *
 * @cssprop --m3e-chip-set-spacing - The spacing (gap) between chips in the set.
 */
export declare class M3eChipSetElement extends M3eChipSetElement_base {
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-chip-set": M3eChipSetElement;
    }
}
export {};
//# sourceMappingURL=ChipSetElement.d.ts.map