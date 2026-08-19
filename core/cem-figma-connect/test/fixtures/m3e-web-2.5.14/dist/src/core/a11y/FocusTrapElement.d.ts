import { CSSResultGroup, LitElement } from "lit";
declare const M3eFocusTrapElement_base: import("../shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & typeof LitElement;
/**
 * A non-visual element used to trap focus within nested content.
 * @tag m3e-focus-trap
 *
 * @slot - Renders content for which to trap focus.
 *
 * @attr disabled - Disables the focus trap.
 */
export declare class M3eFocusTrapElement extends M3eFocusTrapElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private readonly _firstTrap;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-focus-trap": M3eFocusTrapElement;
    }
}
export {};
//# sourceMappingURL=FocusTrapElement.d.ts.map