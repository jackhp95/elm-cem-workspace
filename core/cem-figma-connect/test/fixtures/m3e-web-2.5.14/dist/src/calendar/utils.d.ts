/** @internal */
export declare function addCalendarDays(date: Date, days: number): Date;
/** @internal */
export declare function addCalendarMonths(date: Date, months: number): Date;
/** @internal */
export declare function addCalendarYears(date: Date, years: number): Date;
/** @internal */
export declare function getNumDaysInMonth(date: Date): number;
/** @internal */
export declare function compareDate(first: Date, second: Date): number;
/** @internal */
export declare function sameDate(first: Date | null, second: Date | null): boolean;
/** @internal */
export declare function getActiveOffset(activeDate: Date, minDate: Date | null, maxDate: Date | null): number;
/** @internal */
export declare function minYearOfPage(activeDate: Date, minDate: Date | null, maxDate: Date | null): number;
/** @internal */
export declare function maxYearOfPage(activeDate: Date, minDate: Date | null, maxDate: Date | null): number;
/** @internal */
export declare function clampDate(date: Date, minDate: Date | null, maxDate: Date | null): Date;
/** @internal */ export declare const YEARS_PER_PAGE = 15;
/** @internal */ export declare const YEARS_PER_ROW = 3;
/** @internal */ export declare const MONTHS_PER_ROW = 4;
//# sourceMappingURL=utils.d.ts.map