/**
 * Adapted from Angular Material Datepicker
 * Source: https://github.com/angular/components/blob/main/src/material/datepicker/calendar.ts
 *
 * @license MIT
 * Copyright (c) 2025 Google LLC
 * See LICENSE file in the project root for full license text.
 */
import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import "@m3e/web/button";
import "@m3e/web/icon-button";
import "@m3e/web/tooltip";
import { CalendarView } from "./CalendarView";
import "./MonthViewElement";
import "./MultiYearViewElement";
import "./YearViewElement";
/**
 * A calendar used to select a date.
 *
 * @description
 * The `m3e-calendar` component provides structured navigation and selection across
 * month, year, and multi‑year views. It supports single‑date and range selection,
 * applies disabled rules including minimum, maximum, and blackout constraints, and
 * provides styling hooks for special date states.
 *
 * @example
 * The following example illustrates use of the `m3e-calendar`. In this example, a calendar is displayed
 * with a selected date.
 *
 * ```html
 * <m3e-calendar date="2025-12-13"></m3e-calendar>
 * ```
 *
 * @tag m3e-calendar
 *
 * @slot header - Renders the header of the calendar.
 *
 * @attr date - The selected date.
 * @attr max-date - The maximum date that can be selected.
 * @attr min-date - The minimum date that can be selected.
 * @attr range-end - End of a date range.
 * @attr range-start - Start of a date range.
 * @attr start-at - A date specifying the period (month or year) to start the calendar in.
 * @attr start-view - The initial view used to select a date.
 * @attr previous-month-label - The accessible label given to the button used to move to the previous month.
 * @attr next-month-label - The accessible label given to the button used to move to the next month.
 * @attr previous-year-label - The accessible label given to the button used to move to the previous year.
 * @attr next-year-label - The accessible label given to the button used to move to the next year.
 * @attr previous-multi-year-label - The accessible label given to the button used to move to the previous 24 years.
 * @attr next-multi-year-label - The accessible label given to the button used to move to the next 24 years.
 *
 * @fires change - Dispatched when the selected date changes.
 *
 * @cssprop --m3e-calendar-container-color - Background color of the container surface.
 * @cssprop --m3e-calendar-container-elevation - Elevation shadow applied to the container surface.
 * @cssprop --m3e-calendar-container-shape - Corner radius of the container surface.
 * @cssprop --m3e-calendar-padding - Padding applied to the calendar header and body.
 * @cssprop --m3e-calendar-period-button-text-color - Text color used for the period‑navigation buttons in the header.
 * @cssprop --m3e-calendar-weekday-font-size - Font size of weekday labels in month view.
 * @cssprop --m3e-calendar-weekday-font-weight - Font weight of weekday labels in month view.
 * @cssprop --m3e-calendar-weekday-line-height - Line height of weekday labels in month view.
 * @cssprop --m3e-calendar-weekday-tracking - Letter spacing of weekday labels in month view.
 * @cssprop --m3e-calendar-weekday-color - Text color for weekday labels in month view.
 * @cssprop --m3e-calendar-date-font-size - Font size of date cells in month view.
 * @cssprop --m3e-calendar-date-font-weight - Font weight of date cells in month view.
 * @cssprop --m3e-calendar-date-line-height - Line height of date cells in month view.
 * @cssprop --m3e-calendar-date-tracking - Letter spacing of date cells in month view.
 * @cssprop --m3e-calendar-item-font-size - Font size of items in year and multi‑year views.
 * @cssprop --m3e-calendar-item-font-weight - Font weight of items in year and multi‑year views.
 * @cssprop --m3e-calendar-item-line-height - Line height of items in year and multi‑year views.
 * @cssprop --m3e-calendar-item-tracking - Letter spacing of items in year and multi‑year views.
 * @cssprop --m3e-calendar-item-color - Text color for date items.
 * @cssprop --m3e-calendar-item-selected-color - Text color for selected date items.
 * @cssprop --m3e-calendar-item-selected-container-color - Background color for selected date items.
 * @cssprop --m3e-calendar-item-selected-ripple-color - Ripple color used when interacting with selected date items.
 * @cssprop --m3e-calendar-item-selected-hover-color - Hover color used when interacting with selected date items.
 * @cssprop --m3e-calendar-item-selected-focus-color - Focus color used when interacting with selected date items.
 * @cssprop --m3e-calendar-item-current-outline-thickness - Outline thickness used to indicate the current date.
 * @cssprop --m3e-calendar-item-current-outline-color - Outline color used to indicate the current date.
 * @cssprop --m3e-calendar-item-special-color - Text color for dates marked as special.
 * @cssprop --m3e-calendar-item-special-container-color - Background color for dates marked as special.
 * @cssprop --m3e-calendar-item-special-ripple-color - Ripple color used when interacting with dates marked as special.
 * @cssprop --m3e-calendar-item-special-hover-color - Hover color used when interacting with dates marked as special.
 * @cssprop --m3e-calendar-item-special-focus-color - Focus color used when interacting with dates marked as special.
 * @cssprop --m3e-calendar-range-container-color - Background color applied to the selected date range.
 * @cssprop --m3e-calendar-range-color - Text color for dates within a selected range.
 * @cssprop --m3e-calendar-item-disabled-color - Color used for disabled date items.
 * @cssprop --m3e-calendar-item-disabled-color-opacity - Opacity applied to the disabled item color.
 * @cssprop --m3e-calendar-slide-animation-duration - Duration of slide transitions between calendar views.
 */
export declare class M3eCalendarElement extends LitElement {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private _today;
    /** @private */ private _activeView;
    /** @private */ private _activeDate;
    /** @private */ private readonly _view?;
    /** @private */ private readonly _body;
    /**
     * The initial view used to select a date.
     * @default "month"
     */
    startView: CalendarView;
    /**
     * The selected date.
     * @default null
     */
    date: Date | null;
    /**
     * A date specifying the period (month or year) to start the calendar in.
     * @default null
     */
    startAt: Date | null;
    /**
     * The minimum date that can be selected.
     * @default null
     */
    minDate: Date | null;
    /**
     * The maximum date that can be selected.
     * @default null
     */
    maxDate: Date | null;
    /**
     * Start of a date range.
     * @default null
     */
    rangeStart: Date | null;
    /**
     * End of a date range.
     * @default null
     */
    rangeEnd: Date | null;
    /**
     * A function used to determine whether a date cannot be selected.
     * @default null
     */
    blackoutDates: ((date: Date) => boolean) | null;
    /**
     * A function used to determine whether a date is special.
     * @default null
     */
    specialDates: ((date: Date) => boolean) | null;
    /**
     * The accessible label given to the button used to move to the previous month.
     * @default "Previous month"
     */
    previousMonthLabel: string;
    /**
     * The accessible label given to the button used to move to the previous year.
     * @default "Previous year"
     */
    previousYearLabel: string;
    /**
     * The accessible label given to the button used to move to the previous 24 years.
     * @default "Previous 24 years"
     */
    previousMultiYearLabel: string;
    /**
     * The accessible label given to the button used to move to the next month.
     * @default "Next month"
     */
    nextMonthLabel: string;
    /**
     * The accessible label given to the button used to move to the next year.
     * @default "Next year"
     */
    nextYearLabel: string;
    /**
     * The accessible label given to the button used to move to the next 24 years.
     * @default "Next 24 years"
     */
    nextMultiYearLabel: string;
    /** The label to present for the current period. */
    get periodLabel(): string;
    /** Whether the calendar can move to the previous period. */
    get canMovePreviousPeriod(): boolean;
    /** Whether the calendar can move to the next period. */
    get canMoveNextPeriod(): boolean;
    /**
     * Asynchronously focuses the active date.
     * @returns {Promise<void>} A promise that resolves after the active date has been focused.
     */
    focusActiveCell(): Promise<void>;
    /** Updates today's date. */
    updateTodayDate(): void;
    /** Resets the active view. */
    resetActiveView(): void;
    /**
     * Moves the calendar to the previous period.
     * @returns {Promise<void>} A promise that resolves when the operation is complete.
     */
    movePreviousPeriod(): Promise<void>;
    /**
     * Moves the calendar to the next period.
     * @returns {Promise<void>} A promise that resolves when the operation is complete.
     */
    moveNextPeriod(): Promise<void>;
    /**
     * Toggles the current period.
     * @returns {Promise<void>} A promise that resolves when the operation is complete.
     */
    togglePeriod(): Promise<void>;
    /** @inheritdoc */
    protected willUpdate(changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected updated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-calendar": M3eCalendarElement;
    }
}
//# sourceMappingURL=CalendarElement.d.ts.map