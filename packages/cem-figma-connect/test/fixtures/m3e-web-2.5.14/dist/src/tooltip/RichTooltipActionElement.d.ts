import { ActionElementBase } from "@m3e/web/core";
/**
 * An element, nested within a clickable element, used to dismiss a parenting rich tooltip.
 * @tag m3e-rich-tooltip-action
 *
 * @slot - Renders the content of the action.
 *
 * @attr disable-restore-focus - Whether to focus should not be restored to the trigger when activated.
 */
export declare class M3eRichTooltipActionElement extends ActionElementBase {
    /** Whether to focus should not be restored to the trigger when activated. */
    disableRestoreFocus: boolean;
    /** @inheritdoc */
    protected _onClick(): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-rich-tooltip-action": M3eRichTooltipActionElement;
    }
}
//# sourceMappingURL=RichTooltipActionElement.d.ts.map