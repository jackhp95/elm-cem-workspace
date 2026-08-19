import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { CalendarView } from "@m3e/web/calendar";
import "@m3e/web/core/a11y";
import "@m3e/web/button";
import "@m3e/web/calendar";
import { DatepickerVariant } from "./DatepickerVariant";
declare const M3eDatepickerElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").SuppressInitialAnimationMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").ReconnectedCallbackMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * Presents a date picker on a temporary surface.
 *
 * @description
 * The `m3e-datepicker` component provides a date‑selection experience
 * consistent with Material 3 guidance for layout, motion, and accessibility.
 * It displays a temporary surface that allows users to select a date or date
 * range using calendar-based views. The picker supports month, year, and
 * multi‑year views, enabling users to navigate across time efficiently.
 *
 * While open, the picker uses a focused selection flow. Users review their
 * choice and complete the interaction through confirm, dismiss, or clear
 * actions, ensuring intentional updates to the field or control that invoked it.
 *
 * It accepts and emits plain `Date` values, allowing applications to apply their
 * own formatting, parsing, and localization.
 *
 * @tag m3e-datepicker
 *
 * @attr variant - The appearance variant of the picker.
 * @attr clearable - Whether the user can clear the selected date and close the picker.
 * @attr date - The selected date.
 * @attr max-date - The maximum date that can be selected.
 * @attr min-date - The minimum date that can be selected.
 * @attr range - Whether a range of dates can be selected.
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
 * @attr clear-label - The label given to the button used clear the selected date and close the picker.
 * @attr confirm-label - The label given to the button used apply the selected date and close the picker.
 * @attr dismiss-label - The label given to the button used discard the selected date and close the picker.
 * @attr label - The label given to the the picker.
 *
 * @fires change - Dispatched when the selected date changes.
 * @fires beforetoggle - Dispatched before the toggle state changes.
 * @fires toggle - Dispatched after the toggle state has changed.
 *
 * @cssprop --m3e-datepicker-container-padding-block - Block‑axis padding of the date picker container.
 * @cssprop --m3e-datepicker-container-padding-inline - Inline‑axis padding of the date picker container.
 * @cssprop --m3e-datepicker-container-color - Background color of the standard container surface.
 * @cssprop --m3e-datepicker-container-elevation - Elevation shadow applied to the container surface.
 * @cssprop --m3e-datepicker-modal-headline-color - Color used for the modal headline text.
 * @cssprop --m3e-datepicker-modal-headline-font-size - Font size used for the modal headline text.
 * @cssprop --m3e-datepicker-modal-headline-font-weight - Font weight used for the modal headline text.
 * @cssprop --m3e-datepicker-modal-headline-line-height - Line height used for the modal headline text.
 * @cssprop --m3e-datepicker-modal-headline-tracking - Letter spacing used for the modal headline text.
 * @cssprop --m3e-datepicker-modal-supporting-text-color - Color used for supporting text in modal mode.
 * @cssprop --m3e-datepicker-modal-supporting-text-font-size - Font size used for supporting text in modal mode.
 * @cssprop --m3e-datepicker-modal-supporting-text-font-weight - Font weight used for supporting text in modal mode.
 * @cssprop --m3e-datepicker-modal-supporting-text-line-height - Line height used for supporting text in modal mode.
 * @cssprop --m3e-datepicker-modal-supporting-text-tracking - Letter spacing used for supporting text in modal mode.
 * @cssprop --m3e-datepicker-actions-padding-inline - Inline‑axis padding of the action row.
 * @cssprop --m3e-datepicker-docked-container-color - Background color of the container in docked mode.
 * @cssprop --m3e-datepicker-docked-container-shape - Corner radius of the container in docked mode.
 * @cssprop --m3e-datepicker-modal-container-color - Background color of the container in modal mode.
 * @cssprop --m3e-datepicker-modal-container-shape - Corner radius of the container in modal mode.
 * @cssprop --m3e-divider-thickness - Thickness of divider elements within the picker.
 * @cssprop --m3e-divider-color - Color of divider rules within the picker.
 * @cssprop --m3e-dialog-scrim-color - Base color used for the modal scrim behind the picker.
 * @cssprop --m3e-dialog-scrim-opacity - Opacity applied to the scrim color in modal mode.
 */
export declare class M3eDatepickerElement extends M3eDatepickerElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private _open;
    /** @private */ private _date?;
    /** @private */ private _rangeStart?;
    /** @private */ private _rangeEnd?;
    /** @private */ private readonly _calendar;
    /** @private */ private _variant?;
    /**
     * The appearance variant of the picker.
     * @default "docked"
     */
    variant: DatepickerVariant;
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
     * Whether a range of dates can be selected.
     * @default false
     */
    range: boolean;
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
    /**
     * Whether the user can clear the selected date and close the picker.
     * @default false
     */
    clearable: boolean;
    /**
     * The label given to the button used clear the selected date and close the picker.
     * @default "Clear"
     */
    clearLabel: string;
    /**
     * The label given to the button used apply the selected date and close the picker.
     * @default "OK"
     */
    confirmLabel: string;
    /**
     * The label given to the button used discard the selected date and close the picker.
     * @default "Cancel"
     */
    dismissLabel: string;
    /**
     * The label given to the the picker.
     * @default "Select date"
     */
    label: string;
    /** Whether the picker is open. */
    get isOpen(): boolean;
    /** The current variant applied to the picker. */
    get currentVariant(): Exclude<DatepickerVariant, "auto">;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    reconnectedCallback(): void;
    /**
     * Opens the picker.
     * @param {HTMLElement} trigger The element that triggered the picker.
     * @param {HTMLElement | undefined} anchor The element used to position the picker.
     * @returns {Promise<void>} A `Promise` that resolves when the picker is opened.
     */
    show(trigger: HTMLElement, anchor?: HTMLElement): Promise<void>;
    /**
     * Hides the picker.
     * @param {boolean} [restoreFocus=false] Whether to restore focus to the picker's trigger.
     */
    hide(restoreFocus?: boolean): void;
    /**
     * Toggles the picker.
     * @param {HTMLElement} trigger The element that triggered the picker.
     * @param {HTMLElement | undefined} anchor The element used to position the picker.
     * @returns {Promise<void>} A `Promise` that resolves when the picker is opened or closed.
     */
    toggle(trigger: HTMLElement, anchor?: HTMLElement): Promise<void>;
    /** @inheritdoc */
    protected render(): unknown;
    /** @inheritdoc */
    protected willUpdate(changedProperties: PropertyValues<this>): void;
}
interface M3eDatepickerElementEventMap extends HTMLElementEventMap {
    beforetoggle: ToggleEvent;
    toggle: ToggleEvent;
}
export interface M3eDatepickerElement {
    addEventListener<K extends keyof M3eDatepickerElementEventMap>(type: K, listener: (this: M3eDatepickerElement, ev: M3eDatepickerElementEventMap[K]) => void, options?: boolean | AddEventListenerOptions): void;
    addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void;
    removeEventListener<K extends keyof M3eDatepickerElementEventMap>(type: K, listener: (this: M3eDatepickerElement, ev: M3eDatepickerElementEventMap[K]) => void, options?: boolean | EventListenerOptions): void;
    removeEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | EventListenerOptions): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-datepicker": M3eDatepickerElement;
    }
}
export {};
//# sourceMappingURL=DatepickerElement.d.ts.map