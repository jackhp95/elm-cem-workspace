import { CSSResultGroup } from "lit";
import { M3eFloatingPanelElement } from "@m3e/web/core/anchoring";
import { OptionPanelState } from "./OptionPanelState";
declare const M3eOptionPanelElement_base: import("../core/shared/mixins/Constructor").Constructor & typeof M3eFloatingPanelElement;
/**
 * Presents a list of options on a temporary surface.
 *
 * @description
 * The `m3e-option-panel` component renders a scrollable container for displaying selectable options
 * as a Material Design 3 menu surface. It provides dynamic positioning and anchoring to trigger elements,
 * automatic viewport boundary detection with intelligent repositioning, and smooth enter/exit animations.
 *
 * @tag m3e-option-panel
 *
 * @slot - Renders the contents of the list.
 *
 * @fires beforetoggle - Dispatched before the toggle state changes.
 * @fires toggle - Dispatched after the toggle state has changed.
 *
 * @cssprop --m3e-option-panel-container-shape - Corner radius of the panel container.
 * @cssprop --m3e-option-panel-container-min-width - Minimum width of the panel container.
 * @cssprop --m3e-option-panel-container-max-width - Maximum width of the panel container.
 * @cssprop --m3e-option-panel-container-max-height - Maximum height of the panel container.
 * @cssprop --m3e-option-panel-container-padding-block - Vertical padding inside the panel container.
 * @cssprop --m3e-option-panel-container-padding-inline - Horizontal padding inside the panel container.
 * @cssprop --m3e-option-panel-container-color - Background color of the panel container.
 * @cssprop --m3e-option-panel-container-elevation - Box shadow elevation of the panel container.
 * @cssprop --m3e-option-panel-gap - Vertical spacing between option items.
 * @cssprop --m3e-option-panel-divider-spacing - Vertical spacing around slotted `m3e-divider` elements.
 * @cssprop --m3e-option-panel-text-highlight-container-color - Background color used for text highlight matches.
 * @cssprop --m3e-option-panel-text-highlight-color - Text color used for text highlight matches.
 */
export declare class M3eOptionPanelElement extends M3eOptionPanelElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    constructor();
    /**
     * The state for which to present content.
     * @default "content"
     */
    state: OptionPanelState;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-option-panel": M3eOptionPanelElement;
    }
}
export {};
//# sourceMappingURL=OptionPanelElement.d.ts.map