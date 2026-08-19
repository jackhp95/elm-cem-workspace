import { ActionElementBase } from "@m3e/web/core";
declare const M3eBottomSheetTriggerElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").HtmlForMixin> & typeof ActionElementBase;
/**
 * An element, nested within a clickable element, used to trigger a bottom sheet.
 * @tag m3e-bottom-sheet-trigger
 *
 * @slot - Renders the content of the trigger.
 *
 * @attr detent - The zero‑based index of the detent the sheet should open to.
 * @attr secondary - Marks this trigger as a secondary trigger for accessibility. Secondary triggers do not receive ARIA ownership.
 */
export declare class M3eBottomSheetTriggerElement extends M3eBottomSheetTriggerElement_base {
    /**
     * The zero‑based index of the detent the sheet should open to.
     * @default undefined
     */
    detent?: number;
    /**
     * Marks this trigger as a secondary trigger for accessibility. Secondary triggers do not receive ARIA ownership.
     * @default false
     */
    secondary: boolean;
    /** @inheritdoc */
    attach(control: HTMLElement): void;
    /** @inheritdoc */
    detach(): void;
    /** @inheritdoc */
    protected _onClick(): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-bottom-sheet-trigger": M3eBottomSheetTriggerElement;
    }
}
export {};
//# sourceMappingURL=BottomSheetTriggerElement.d.ts.map