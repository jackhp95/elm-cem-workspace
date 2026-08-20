import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { BreadcrumbItemCurrent } from "./BreadcrumbItemCurrent";
declare const M3eBreadcrumbItemButtonElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").LinkButtonMixin> & import("../core/shared/mixins/Constructor").Constructor & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & typeof LitElement;
/**
 * @internal
 * An internal interactive element used to present the content of a breadcrumb item.
 */
export declare class M3eBreadcrumbItemButtonElement extends M3eBreadcrumbItemButtonElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private readonly _focusRing?;
    /** @private */ private readonly _stateLayer?;
    /** @private */ private readonly _ripple?;
    /**
     * Indicates the current item in the breadcrumb path.
     * @default undefined
     */
    current?: BreadcrumbItemCurrent;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-breadcrumb-item-button": M3eBreadcrumbItemButtonElement;
    }
}
export {};
//# sourceMappingURL=BreadcrumbItemButtonElement.d.ts.map