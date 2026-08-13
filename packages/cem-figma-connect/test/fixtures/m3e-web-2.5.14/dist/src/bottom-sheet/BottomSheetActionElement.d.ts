import { ActionElementBase } from "@m3e/web/core";
/**
 * An element, nested within a clickable element, used to close a parenting bottom sheet.
 * @tag m3e-bottom-sheet-action
 *
 * @slot - Renders the content of the action.
 */
export declare class M3eBottomSheetActionElement extends ActionElementBase {
    /** @inheritdoc */
    protected _onClick(): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-bottom-sheet-action": M3eBottomSheetActionElement;
    }
}
//# sourceMappingURL=BottomSheetActionElement.d.ts.map