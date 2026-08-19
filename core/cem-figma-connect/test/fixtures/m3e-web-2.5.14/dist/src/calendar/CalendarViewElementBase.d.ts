import { CSSResultGroup, LitElement } from "lit";
/**
 * A base implementation for a view in a calendar. This class must be inherited.
 * @internal
 */
export declare abstract class CalendarViewElementBase extends LitElement {
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private readonly _activeItem?;
    /** Whether the view is active. */
    active: boolean;
    /** Today's date. */
    today: Date;
    /** The selected date. */
    date: Date | null;
    /** The active date. */
    activeDate: Date;
    /** The minimum date that can be selected. */
    minDate: Date | null;
    /** The maximum date that can be selected. */
    maxDate: Date | null;
    /**
     * Asynchronously focuses the active date.
     * @returns {Promise<void>} A promise that resolves after the active date has been focused.
     */
    focusActiveCell(): Promise<void>;
    /** @internal */
    protected _changeActiveDate(activeDate: Date): void;
}
//# sourceMappingURL=CalendarViewElementBase.d.ts.map