import { CSSResultGroup, LitElement, PropertyValues } from "lit";
declare const M3eContentPaneElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").ReconnectedCallbackMixin> & typeof LitElement;
/**
 * A shaped surface for vertically scrollable content.
 *
 * @description
 * The `m3e-content-pane` component renders a shaped surface with padding and vertical
 * scrolling for document‑like content.
 *
 * @example
 * The following example illustrates basic usage of the content pane.
 * ```html
 * <m3e-content-pane>
 *   <p>This is some scrollable content.</p>
 *   <p>More content here...</p>
 * </m3e-content-pane>
 * ```
 *
 * @tag m3e-content-pane
 *
 * @slot - Renders the content of the pane.
 *
 * @cssprop --m3e-content-pane-container-shape - Corner radius applied to the pane’s outer surface.
 * @cssprop --m3e-content-pane-container-color - Background color of the pane’s surface.
 * @cssprop --m3e-content-pane-container-padding - Internal padding applied to all sides of the scrollable content.
 */
export declare class M3eContentPaneElement extends M3eContentPaneElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @inheritdoc */
    reconnectedCallback(): void;
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-content-pane": M3eContentPaneElement;
    }
}
export {};
//# sourceMappingURL=ContentPaneElement.d.ts.map