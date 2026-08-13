import { ActionElementBase } from "@m3e/web/core";
declare const M3eDialogTriggerElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").HtmlForMixin> & typeof ActionElementBase;
/**
 * An element, nested within a clickable element, used to open a dialog.
 * @tag m3e-dialog-trigger
 */
export declare class M3eDialogTriggerElement extends M3eDialogTriggerElement_base {
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    _onClick(): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-dialog-trigger": M3eDialogTriggerElement;
    }
}
export {};
//# sourceMappingURL=DialogTriggerElement.d.ts.map