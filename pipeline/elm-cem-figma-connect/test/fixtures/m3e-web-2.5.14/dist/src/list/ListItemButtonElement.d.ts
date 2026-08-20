import { CSSResultGroup, PropertyValues } from "lit";
import { M3eListItemElement } from "./ListItemElement";
declare const M3eListItemButtonElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").LinkButtonMixin> & import("../core/shared/mixins/Constructor").Constructor & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & typeof M3eListItemElement;
/**
 * @internal
 * An internal interactive element used to present the content of a list item.
 */
export declare class M3eListItemButtonElement extends M3eListItemButtonElement_base {
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private readonly _focusRing?;
    /** @private */ private readonly _stateLayer?;
    /** @private */ private readonly _ripple?;
    constructor();
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
}
export {};
//# sourceMappingURL=ListItemButtonElement.d.ts.map