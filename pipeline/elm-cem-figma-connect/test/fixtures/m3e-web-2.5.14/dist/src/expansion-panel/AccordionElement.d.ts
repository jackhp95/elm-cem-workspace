import { CSSResultGroup, LitElement } from "lit";
import { M3eExpansionPanelElement } from "./ExpansionPanelElement";
/**
 * Combines multiple expansion panels in to an accordion.
 *
 * @description
 * The `m3e-accordion` component organizes multiple expansion panels into a coordinated, accessible group.
 * It supports single or multiple open panels via the `multi` attribute, and provides expressive theming
 * and shape control for grouped layouts. The accordion manages open/close state across its child panels,
 * enabling interactive disclosure patterns for complex content.
 *
 * @example
 * The following example illustrates the basic use of the `m3e-accordion` and `m3e-expansion-panel` components.
 *
 * ```html
 * <m3e-accordion>
 *   <m3e-expansion-panel>
 *     <span slot="header">Panel 1</span>
 *     I am content for the first expansion panel
 *   </m3e-expansion-panel>
 *   <m3e-expansion-panel>
 *     <span slot="header">Panel 2</span>
 *     I am content for the second expansion panel
 *   </m3e-expansion-panel>
 * </m3e-accordion>
 * ```
 *
 * @tag m3e-accordion
 *
 * @slot - Renders the panels of the accordion.
 *
 * @attr multi - Whether multiple expansion panels can be open at the same time.
 */
export declare class M3eAccordionElement extends LitElement {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /**
     * Whether multiple expansion panels can be open at the same time.
     * @default false
     */
    multi: boolean;
    /** The panels of the accordion. */
    get panels(): M3eExpansionPanelElement[];
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-accordion": M3eAccordionElement;
    }
}
//# sourceMappingURL=AccordionElement.d.ts.map