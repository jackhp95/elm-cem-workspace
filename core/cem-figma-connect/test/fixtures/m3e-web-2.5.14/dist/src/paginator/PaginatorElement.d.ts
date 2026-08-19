/**
 * Adapted from Angular Material Paginator
 * Source: https://github.com/angular/components/blob/main/src/material/paginator/paginator.ts
 *
 * @license MIT
 * Copyright (c) 2025 Google LLC
 * See LICENSE file in the project root for full license text.
 */
import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import type { FormFieldVariant } from "@m3e/web/form-field";
import "@m3e/web/form-field";
import "@m3e/web/select";
import "@m3e/web/option";
import "@m3e/web/icon-button";
import "@m3e/web/tooltip";
import { PaginatorPageEventDetail } from "./PaginatorPageEventDetail";
declare const M3ePaginatorElement_base: import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * Provides navigation for paged information, typically used with a table.
 *
 * @description
 * The `m3e-paginator` component is a compact, accessible paginator control for navigating
 * paged data sets. It provides semantic first/previous/next/last navigation controls and an
 * optional page-size selector that integrates with Material design tokens and `m3e-form-field` variants
 * to ensure consistent typography, density, and spacing across applications.
 *
 * @example
 * The following example illustrates use of the `m3e-paginator`. In this example, there are 300 total
 * records and the first/last navigation controls are shown.
 * ```html
 * <m3e-paginator show-first-last-buttons length="300"></m3e-paginator>
 * ```
 *
 * @tag m3e-paginator
 *
 * @slot first-page-icon - Slot for a custom first-page icon.
 * @slot previous-page-icon - Slot for a custom previous-page icon.
 * @slot next-page-icon - Slot for a custom next-page icon.
 * @slot last-page-icon - Slot for a custom last-page icon.
 *
 * @attr disabled - Whether the element is disabled.
 * @attr first-page-label - The accessible label given to the button used to move to the first page.
 * @attr hide-page-size - Whether to hide page size selection.
 * @attr items-per-page-label - The label for the page size selector.
 * @attr last-page-label - The accessible label given to the button used to move to the last page.
 * @attr length - The length of the total number of items which are being paginated.
 * @attr next-page-label - The accessible label given to the button used to move to the next page.
 * @attr page-index - The zero-based page index of the displayed list of items.
 * @attr page-size - The number of items to display in a page.
 * @attr page-sizes - A comma separated list of available page sizes.
 * @attr page-size-variant - The appearance variant of the page size field.
 * @attr previous-page-label - The accessible label given to the button used to move to the previous page.
 * @attr show-first-last-buttons - Whether to show first/last buttons.
 *
 * @fires page - Dispatched when a user selects a different page size or navigates to another page.
 *
 * @cssprop --m3e-paginator-font-size - The font size used for paginator text.
 * @cssprop --m3e-paginator-font-weight - The font weight used for paginator text.
 * @cssprop --m3e-paginator-line-height - The line height used for paginator text.
 * @cssprop --m3e-paginator-tracking - The letter-spacing used for paginator text.
 */
export declare class M3ePaginatorElement extends M3ePaginatorElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    private static __nextId;
    /**
     * Whether the element is disabled.
     * @default false
     */
    disabled: boolean;
    /**
     * The zero-based page index of the displayed list of items.
     * @default 0
     */
    pageIndex: number;
    /**
     * The length of the total number of items which are being paginated.
     * @default 0
     */
    length: number;
    /**
     * The number of items to display in a page.
     * @default 50
     */
    pageSize: number | "all";
    /**
     * A comma separated list of available page sizes.
     * @default "5,10,25,50,100"
     */
    pageSizes: string;
    /**
     * Whether to hide page size selection.
     * @default false
     */
    hidePageSize: boolean;
    /**
     * Whether to show first/last buttons.
     * @default false
     */
    showFirstLastButtons: boolean;
    /**
     * The label for the page size selector.
     * @default "Items per page:"
     */
    itemsPerPageLabel: string;
    /**
     * The accessible label given to the button used to move to the previous page.
     * @default "Previous page"
     */
    previousPageLabel: string;
    /**
     * The accessible label given to the button used to move to the next page.
     * @default "Next page"
     */
    nextPageLabel: string;
    /**
     * The accessible label given to the button used to move to the first page.
     * @default "First page"
     */
    firstPageLabel: string;
    /**
     * The accessible label given to the button used to move to the last page.
     * @default "Last page"
     */
    lastPageLabel: string;
    /**
     * The appearance variant of the page size field.
     * @default "outlined"
     */
    pageSizeVariant: FormFieldVariant;
    /** The total number of pages. */
    get pageCount(): number;
    /** Whether a previous page can be displayed. */
    get hasPreviousPage(): boolean;
    /** Whether a next page can be displayed. */
    get hasNextPage(): boolean;
    /**
     * A function used to format the range label.
     * @param {number} pageIndex The zero-based index of the current page.
     * @param {number | "all"} pageSize The current number of items to display in a page.
     * @param {number} length The current length of the total number of items which are being paginated.
     * @returns {string} The range label.
     */
    rangeLabelFormatter?: (pageIndex: number, pageSize: number | "all", length: number) => string;
    /** Move to the first page. */
    firstPage(): void;
    /** Move to the previous page. */
    previousPage(): void;
    /** Move to the next page. */
    nextPage(): void;
    /** Move to the last page. */
    lastPage(): void;
    /** @inheritdoc */
    protected willUpdate(changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
}
interface M3ePaginatorElementEventMap extends HTMLElementEventMap {
    page: CustomEvent<PaginatorPageEventDetail>;
}
export interface M3ePaginatorElement {
    addEventListener<K extends keyof M3ePaginatorElementEventMap>(type: K, listener: (this: M3ePaginatorElement, ev: M3ePaginatorElementEventMap[K]) => void, options?: boolean | AddEventListenerOptions): void;
    addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void;
    removeEventListener<K extends keyof M3ePaginatorElementEventMap>(type: K, listener: (this: M3ePaginatorElement, ev: M3ePaginatorElementEventMap[K]) => void, options?: boolean | EventListenerOptions): void;
    removeEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | EventListenerOptions): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-paginator": M3ePaginatorElement;
    }
}
export {};
//# sourceMappingURL=PaginatorElement.d.ts.map