import { CSSResultGroup, LitElement } from "lit";
declare const M3eBreadcrumbElement_base: import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * Displays a hierarchical navigation path and identifies the user's
 * current location within an application.
 *
 * @description
 * The `m3e-breadcrumb` component arranges `m3e-breadcrumb-item` children into
 * a trail of navigation steps. It tracks the last item as the current page and
 * supports a custom separator slot for alternate divider content.
 *
 * @example
 * The following example illustrates a simple breadcrumb with three items.
 * ```html
 * <m3e-breadcrumb>
 *   <m3e-breadcrumb-item href="/dashboard">Dashboard</m3e-breadcrumb-item>
 *   <m3e-breadcrumb-item href="/dashboard/reports">Reports</m3e-breadcrumb-item>
 *   <m3e-breadcrumb-item href="/dashboard/reports/annual">Annual</m3e-breadcrumb-item>
 * </m3e-breadcrumb>
 * ```
 *
 * @tag m3e-breadcrumb
 *
 * @slot - Renders breadcrumb items.
 * @slot separator - Renders a custom separator between breadcrumb items.
 *
 * @attr wrap - Whether breadcrumb items should wrap onto a new line.
 */
export declare class M3eBreadcrumbElement extends M3eBreadcrumbElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /**
     * Whether items wrap to a new line.
     * @default false
     */
    wrap: boolean;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-breadcrumb": M3eBreadcrumbElement;
    }
}
export {};
//# sourceMappingURL=BreadcrumbElement.d.ts.map