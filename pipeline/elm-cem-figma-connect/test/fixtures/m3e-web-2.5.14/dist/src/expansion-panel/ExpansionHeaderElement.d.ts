import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { ExpansionTogglePosition } from "./ExpansionTogglePosition";
import { ExpansionToggleDirection } from "./ExpansionToggleDirection";
declare const M3eExpansionHeaderElement_base: import("../core/shared/mixins/Constructor").Constructor & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & typeof LitElement;
/**
 * A button used to toggle the expanded state of an expansion panel.
 *
 * @tag m3e-expansion-header
 *
 * @slot - Renders the content of the header.
 * @slot toggle-icon - Renders the icon of the expansion toggle.
 *
 * @attr hide-toggle - Whether to hide the expansion toggle.
 * @attr toggle-direction - The direction of the expansion toggle.
 * @attr toggle-position - The position of the expansion toggle.
 *
 * @fires click - Dispatched when the element is clicked.
 *
 * @cssprop --m3e-expansion-header-collapsed-height - Height of the header when the panel is collapsed.
 * @cssprop --m3e-expansion-header-expanded-height - Height of the header when the panel is expanded.
 * @cssprop --m3e-expansion-header-padding-left - Left padding inside the header.
 * @cssprop --m3e-expansion-header-padding-right - Right padding inside the header.
 * @cssprop --m3e-expansion-header-spacing - Spacing between header elements.
 * @cssprop --m3e-expansion-header-toggle-icon-size - Size of the toggle icon (e.g. chevron).
 * @cssprop --m3e-expansion-header-font-size - The font size of the header text.
 * @cssprop --m3e-expansion-header-font-weight - The font weight of the header text.
 * @cssprop --m3e-expansion-header-line-height - The line height of the header text.
 * @cssprop --m3e-expansion-header-tracking - Letter spacing (tracking) of the header text.
 */
export declare class M3eExpansionHeaderElement extends M3eExpansionHeaderElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private readonly _focusRing?;
    /** @private */ private readonly _stateLayer?;
    /**
     * The direction of the expansion toggle.
     * @default "vertical"
     */
    toggleDirection: ExpansionToggleDirection;
    /**
     * The position of the expansion toggle.
     * @default "after"
     */
    togglePosition: ExpansionTogglePosition;
    /**
     * Whether to hide the expansion toggle.
     * @default false
     */
    hideToggle: boolean;
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-expansion-header": M3eExpansionHeaderElement;
    }
}
export {};
//# sourceMappingURL=ExpansionHeaderElement.d.ts.map