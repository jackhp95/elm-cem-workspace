import { PropertyValues } from "lit";
import { formValue } from "@m3e/web/core";
import { SelectionManager, selectionManager } from "@m3e/web/core/a11y";
import { M3eChipSetElement } from "./ChipSetElement";
import { M3eFilterChipElement } from "./FilterChipElement";
declare const M3eFilterChipSetElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").LabelledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DirtyMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").TouchedMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").FormAssociatedMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & import("../core/shared/mixins/Constructor").Constructor & typeof M3eChipSetElement;
/**
 * A container that organizes filter chips into a cohesive group, enabling selection and
 * deselection of values used to refine content or trigger contextual behavior.
 *
 * @description
 * The `m3e-filter-chip-set` component presents a group of filter chips, enabling users to select
 * one or more options to filter content or data sets. It supports single and multi-selection,
 * keyboard navigation, accessibility, and seamless form association, providing expressive and
 * interactive filtering experiences in line with Material 3 guidelines.
 *
 * @example
 * The following example illustrates a single-select `m3e-filter-chip-set` containing multiple `m3e-filter-chip` components that
 * allow a user to choose an option. You can use the `multi` attribute to enable multiselect.
 * ```html
 * <m3e-filter-chip-set aria-label="Filter by topic">
 *  <m3e-filter-chip><m3e-icon slot="icon" name="palette"></m3e-icon>Design</m3e-filter-chip>
 *  <m3e-filter-chip><m3e-icon slot="icon" name="accessibility_new"></m3e-icon>Accessibility</m3e-filter-chip>
 *  <m3e-filter-chip><m3e-icon slot="icon" name="motion_photos_on"></m3e-icon>Motion</m3e-filter-chip>
 *  <m3e-filter-chip><m3e-icon slot="icon" name="description"></m3e-icon>Documentation</m3e-filter-chip>
 * </m3e-filter-chip-set>
 * ```
 *
 * @tag m3e-filter-chip-set
 *
 * @slot - Renders the chips of the set.
 *
 * @attr disabled - Whether the element is disabled.
 * @attr hide-selection-indicator - Whether to hide the selection indicator.
 * @attr multi - Whether multiple chips can be selected.
 * @attr name - The name that identifies the element when submitting the associated form.
 * @attr vertical - Whether the element is oriented vertically.
 *
 * @fires beforeinput - Dispatched before the selected state of a chip changes.
 * @fires input - Dispatched when the selected state of a chip changes.
 * @fires change - Dispatched when the selected state of a chip changes.
 *
 * @cssprop --m3e-chip-set-spacing - The spacing (gap) between chips in the set.
 */
export declare class M3eFilterChipSetElement extends M3eFilterChipSetElement_base {
    #private;
    /** @internal */
    readonly [selectionManager]: SelectionManager<M3eFilterChipElement>;
    /**
     * Whether multiple chips can be selected.
     * @default false
     */
    multi: boolean;
    /**
     * Whether to hide the selection indicator.
     * @default false
     */
    hideSelectionIndicator: boolean;
    /** The chips of the set. */
    get chips(): readonly M3eFilterChipElement[];
    /** The selected chip(s) of the set. */
    get selected(): readonly M3eFilterChipElement[];
    /** The selected (enabled) value(s) of the set. */
    get value(): string | readonly string[] | null;
    /** @inheritdoc @internal */
    get [formValue](): string | FormData | null;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-filter-chip-set": M3eFilterChipSetElement;
    }
}
export {};
//# sourceMappingURL=FilterChipSetElement.d.ts.map