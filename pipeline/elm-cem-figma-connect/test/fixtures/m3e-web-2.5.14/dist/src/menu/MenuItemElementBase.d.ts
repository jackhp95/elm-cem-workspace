import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import type { M3eMenuElement } from "./MenuElement";
declare const MenuItemElementBase_base: import("../core/shared/mixins/Constructor").Constructor & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & typeof LitElement;
/** A base implementation for an item of a menu. This class must be inherited. */
export declare abstract class MenuItemElementBase extends MenuItemElementBase_base {
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private readonly _focusRing?;
    /** @private */ private readonly _stateLayer?;
    /** @private */ private readonly _ripple?;
    constructor();
    /** The menu to which this item belongs. */
    get menu(): M3eMenuElement | null;
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    render(): unknown;
    /** @internal Renders the content of the item. */
    protected abstract _renderContent(): unknown;
}
export {};
//# sourceMappingURL=MenuItemElementBase.d.ts.map