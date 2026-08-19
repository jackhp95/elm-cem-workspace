import { CheckedMixin } from "./Checked";
import { SelectedMixin } from "./Selected";
/** Defines functionality for an element which supports either a checked or selected state. */
export type CheckedOrSelectedMixin = CheckedMixin | SelectedMixin;
/**
 * Determines whether a value is a `CheckedOrSelectedMixin`.
 * @param {unknown} value The value to test.
 * @returns Whether `value` is a `CheckedOrSelectedMixin`.
 */
export declare function isCheckedOrSelectedMixin(value: unknown): value is CheckedOrSelectedMixin;
/**
 * Determines whether the state of an element is checked or selected.
 * @param {CheckedOrSelectedMixin} element The element to test.
 * @return {boolean} Whether `element` is checked or selected.
 */
export declare function isCheckedOrSelected(element: CheckedOrSelectedMixin): boolean;
/**
 * Sets the checked or selected state of an element.
 * @param {CheckedOrSelectedMixin} element The element for which to set the checked or selected state.
 * @param {boolean} checkedOrSelected The checked or selected state.
 */
export declare function checkOrSelect(element: CheckedOrSelectedMixin, checkedOrSelected: boolean): void;
//# sourceMappingURL=CheckedOrSelected.d.ts.map