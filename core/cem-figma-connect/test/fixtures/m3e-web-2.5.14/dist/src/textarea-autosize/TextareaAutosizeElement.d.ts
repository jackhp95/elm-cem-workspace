/**
 * Adapted from Angular Material CDK Text Field
 * Source: https://github.com/angular/components/blob/main/src/cdk/text-field/autosize.ts
 *
 * @license MIT
 * Copyright (c) 2025 Google LLC
 * See LICENSE file in the project root for full license text.
 */
import { CSSResultGroup, LitElement, PropertyValues } from "lit";
declare const M3eTextareaAutosizeElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").HtmlForMixin> & import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * A non-visual element used to automatically resize a `textarea` to fit its content.
 *
 * @description
 * The `m3e-textarea-autosize` component automatically adjusts the height of a linked `textarea` to fit its content,
 * preserving layout integrity and user experience. This non-visual element listens to input changes and applies
 * dynamic resizing, constrained by optional row limits. It supports declarative configuration via attributes and
 * can be disabled when manual control is preferred.
 *
 * @example
 * The following example illustrates the `m3e-textarea-autosize` in conjunction with the `m3e-form-field` to
 * automatically resize a field's `textarea` with a 5 row limit.
 * ```html
 * <m3e-form-field>
 *  <label slot="label" for="fld">Textarea Autosize</label>
 *  <textarea id="fld"></textarea>
 *  <m3e-textarea-autosize for="fld" max-rows="5"></m3e-textarea-autosize>
 * </m3e-form-field>
 * ```
 *
 * @tag m3e-textarea-autosize
 *
 * @attr disabled - Whether auto-sizing is disabled.
 * @attr for - The identifier of the interactive control to which this element is attached.
 * @attr max-rows - The maximum amount of rows in the `textarea`.
 * @attr min-rows - The minimum amount of rows in the `textarea`.
 */
export declare class M3eTextareaAutosizeElement extends M3eTextareaAutosizeElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /**
     * The maximum amount of rows in the `textarea`.
     * @default 0
     */
    maxRows: number;
    /**
     * The minimum amount of rows in the `textarea`.
     * @default 0
     */
    minRows: number;
    /**
     * Whether auto-sizing is disabled.
     * @default false
     */
    disabled: boolean;
    /** @inheritdoc */
    attach(control: HTMLElement): void;
    /** @inheritdoc */
    detach(): void;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    protected updated(_changedProperties: PropertyValues<this>): void;
    /**
     * Resize the `textarea` to fit its content.
     * @param {boolean} [force=false] - Whether to force a height recalculation.
     */
    resizeToFitContent(force?: boolean): void;
    /** Resets the `textarea` to its original size. */
    reset(): void;
    /** @private */
    private _handleWindowResize;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-textarea-autosize": M3eTextareaAutosizeElement;
    }
}
export {};
//# sourceMappingURL=TextareaAutosizeElement.d.ts.map