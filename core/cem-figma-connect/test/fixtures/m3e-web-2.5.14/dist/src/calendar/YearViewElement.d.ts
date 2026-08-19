/**
 * Adapted from Angular Material Datepicker
 * Source: https://github.com/angular/components/blob/main/src/material/datepicker/year-view.ts
 *
 * @license MIT
 * Copyright (c) 2025 Google LLC
 * See LICENSE file in the project root for full license text.
 */
import { CSSResultGroup } from "lit";
import { CalendarViewElementBase } from "./CalendarViewElementBase";
/**
 * An internal component used to display a single year in a calendar.
 * @internal
 */
export declare class M3eYearViewElement extends CalendarViewElementBase {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-year-view": M3eYearViewElement;
    }
}
//# sourceMappingURL=YearViewElement.d.ts.map