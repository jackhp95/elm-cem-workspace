import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { ProgressIndicatorVariant } from "./ProgressIndicatorVariant";
declare const ProgressElementIndicatorBase_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").ReconnectedCallbackMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/** A base implementation for an element used to convey progress. This class must be inherited. */
export declare abstract class ProgressElementIndicatorBase extends ProgressElementIndicatorBase_base {
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /**
     * A fractional value, between 0 and `max`, indicating progress.
     * @default 0
     */
    value: number;
    /**
     * The maximum progress value.
     * @default 100
     */
    max: number;
    /**
     * The appearance of the indicator.
     * @default "flat"
     */
    variant: ProgressIndicatorVariant;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues<this>): void;
}
export {};
//# sourceMappingURL=ProgressElementIndicatorBase.d.ts.map