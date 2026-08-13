import { ActionElementBase } from "@m3e/web/core";
declare const M3eDatepickerToggleElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").HtmlForMixin> & typeof ActionElementBase;
/**
 * An element, nested within a clickable element, used to toggle a datepicker.
 * @tag m3e-datepicker-toggle
 */
export declare class M3eDatepickerToggleElement extends M3eDatepickerToggleElement_base {
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    _onClick(): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-datepicker-toggle": M3eDatepickerToggleElement;
    }
}
export {};
//# sourceMappingURL=DatepickerToggleElement.d.ts.map