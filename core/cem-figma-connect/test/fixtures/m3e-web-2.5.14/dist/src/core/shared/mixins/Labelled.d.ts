import { LitElement } from "lit";
import { AttachInternalsMixin } from "./AttachInternals";
import { Constructor } from "./Constructor";
/** A symbol through which to update labels to reflect a control's current state. */
export declare const updateLabels: unique symbol;
/** Defines functionality for a labelled custom element. */
export interface LabelledMixin extends AttachInternalsMixin {
    /** The label elements that the element is associated with. */
    readonly labels: NodeListOf<HTMLLabelElement>;
    /** Updates labels to reflect the current state of the control. */
    [updateLabels]?(): void;
}
/**
 * Determines whether a value is a `LabelledMixin`.
 * @param {unknown} value The value to test.
 * @returns A value indicating whether `value` is a `LabelledMixin`.
 */
export declare function isLabelledMixin(value: unknown): value is LabelledMixin;
/**
 * Mixin to augment an element with support for labelling.
 * @template T The type of the base class.
 * @param {T} base The base class.
 * @returns {Constructor<FormAssociatedMixin> & T} A constructor that implements `FormAssociatedMixin`.
 */
export declare function Labelled<T extends Constructor<LitElement & AttachInternalsMixin>>(base: T): Constructor<LabelledMixin> & T;
//# sourceMappingURL=Labelled.d.ts.map