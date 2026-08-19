import { ActionElementBase } from "@m3e/web/core";
/**
 * An element, nested within a clickable element, used to close a parenting dialog.
 * @tag m3e-dialog-action
 *
 * @slot - Renders the content of the action.
 *
 * @attr return-value - The value to return from the dialog.
 */
export declare class M3eDialogActionElement extends ActionElementBase {
    /**
     * The value to return from the dialog.
     * @default ""
     */
    returnValue: string;
    /** @inheritdoc */
    protected _onClick(): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-dialog-action": M3eDialogActionElement;
    }
}
//# sourceMappingURL=DialogActionElement.d.ts.map