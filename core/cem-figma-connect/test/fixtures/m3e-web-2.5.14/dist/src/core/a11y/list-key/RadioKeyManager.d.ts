import { LitElement } from "lit";
import { CheckedOrSelectedMixin, DisabledMixin } from "@m3e/web/core";
import { RovingTabIndexManager } from "./RovingTabIndexManager";
/**
 * Utility for managing keyboard events for selectable lists whose items behave like a radio.
 * @template T The type of managed item.
 */
export declare class RadioKeyManager<T extends LitElement & DisabledMixin & CheckedOrSelectedMixin> extends RovingTabIndexManager<T> {
    #private;
    /** A value indicating whether managed items are disabled. */
    get disabled(): boolean;
    set disabled(value: boolean);
    /** @inheritdoc */
    setItems(items: T[]): {
        added: readonly T[];
        removed: readonly T[];
    };
}
//# sourceMappingURL=RadioKeyManager.d.ts.map