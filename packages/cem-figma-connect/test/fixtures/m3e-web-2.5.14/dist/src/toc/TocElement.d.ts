import { CSSResultGroup, LitElement, PropertyValues } from "lit";
declare const M3eTocElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").HtmlForMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * A table of contents that provides in-page scroll navigation.
 *
 * @description
 * The `m3e-toc` component generates a hierarchical table of contents for in-page navigation.
 * It automatically detects headings or sections in a target element, builds a navigable list,
 * and highlights the active section as the user scrolls. The component supports custom header
 * slots, depth limiting, smooth scrolling, and extensive theming via CSS custom properties.
 *
 * To exclude a heading from the generated table of contents, add the `m3e-toc-ignore` attribute
 * to that heading element.
 *
 * @example
 * ```html
 * <m3e-toc for="content" max-depth="3">
 *   <span slot="overline">Contents</span>
 *   <span slot="title">Documentation</span>
 * </m3e-toc>
 * <div id="content">
 *   <h2>Introduction</h2>
 *   <h2>Getting Started</h2>
 *   <h3>Installation</h3>
 *   <h3>Usage</h3>
 *   <h2>API Reference</h2>
 * </div>
 * ```
 *
 * @tag m3e-toc
 *
 * @slot - Renders content between the header and items.
 * @slot overline - Renders the overline of the table of contents.
 * @slot title - Renders the title of the table of contents.
 *
 * @attr for - The identifier of the interactive control to which this element is attached.
 * @attr max-depth - The maximum depth of the table of contents.
 *
 * @cssprop --m3e-toc-width - Width of the table of contents.
 * @cssprop --m3e-toc-container-color - Background color of the table of contents container.
 * @cssprop --m3e-toc-container-padding-inline - Inline padding of the table of contents container.
 * @cssprop --m3e-toc-container-padding-block - Block padding of the table of contents container.
 * @cssprop --m3e-toc-item-shape - Border radius of TOC items and active indicator.
 * @cssprop --m3e-toc-active-indicator-color - Border color of the active indicator.
 * @cssprop --m3e-toc-active-indicator-animation-duration - Animation duration for the active indicator.
 * @cssprop --m3e-toc-item-padding - Inline padding for TOC items and header.
 * @cssprop --m3e-toc-header-space - Block space below and between header elements.
 * @cssprop --m3e-toc-overline-font-size - Font size for the overline slot.
 * @cssprop --m3e-toc-overline-font-weight - Font weight for the overline slot.
 * @cssprop --m3e-toc-overline-line-height - Line height for the overline slot.
 * @cssprop --m3e-toc-overline-tracking - Letter spacing for the overline slot.
 * @cssprop --m3e-toc-overline-color - Text color for the overline slot.
 * @cssprop --m3e-toc-title-font-size - Font size for the title slot.
 * @cssprop --m3e-toc-title-font-weight - Font weight for the title slot.
 * @cssprop --m3e-toc-title-line-height - Line height for the title slot.
 * @cssprop --m3e-toc-title-tracking - Letter spacing for the title slot.
 * @cssprop --m3e-toc-title-color - Text color for the title slot.
 */
export declare class M3eTocElement extends M3eTocElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private _toc;
    /** @private */ private readonly _activeIndicator;
    /** @private */ private readonly _scrollContainer;
    /**
     * The maximum depth of the table of contents.
     * @default 2
     */
    maxDepth: number;
    /** @inheritdoc */
    attach(control: HTMLElement): void;
    /** @inheritdoc */
    detach(): void;
    /** @inheritdoc */
    protected willUpdate(changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected updated(_changedProperties: PropertyValues): void;
    /** @inheritdoc */
    protected render(): unknown;
    /** @private */
    private _updateToc;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-toc": M3eTocElement;
    }
}
export {};
//# sourceMappingURL=TocElement.d.ts.map