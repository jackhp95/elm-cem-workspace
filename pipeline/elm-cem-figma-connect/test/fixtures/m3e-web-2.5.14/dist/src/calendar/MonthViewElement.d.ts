/**
 * Adapted from Angular Material Datepicker
 * Source: https://github.com/angular/components/blob/main/src/material/datepicker/month-view.ts
 *
 * @license MIT
 * Copyright (c) 2025 Google LLC
 * See LICENSE file in the project root for full license text.
 */
import { CSSResultGroup } from "lit";
import "@m3e/web/tooltip";
import { CalendarViewElementBase } from "./CalendarViewElementBase";
/**
 * An internal component used to display a single month in a calendar.
 * @internal
 */
export declare class M3eMonthViewElement extends CalendarViewElementBase {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @internal */ _suppressFocusHighlight: boolean;
    /** Start of a date range. */
    rangeStart: Date | null;
    /** End of a date range. */
    rangeEnd: Date | null;
    /** A function used to determine whether a date cannot be selected. */
    blackoutDates: ((date: Date) => boolean) | null;
    /** A function used to determine whether a date is special. */
    specialDates: ((date: Date) => boolean) | null;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-month-view": M3eMonthViewElement;
    }
}
//# sourceMappingURL=MonthViewElement.d.ts.map