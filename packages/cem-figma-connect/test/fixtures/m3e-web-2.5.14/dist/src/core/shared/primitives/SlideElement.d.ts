import { CSSResultGroup, LitElement, PropertyValues } from "lit";
declare const M3eSlideElement_base: import("../mixins/Constructor").Constructor<import("..").AttachInternalsMixin> & typeof LitElement;
/**
 * A carousel-like container used to horizontally cycle through slotted items.
 *
 * @example
 * The following example illustrates the use of `m3e-slide` to cycle through content.
 * In this example, `selected-index` is set to `1` so that "Content at index 1" is presented
 * by the component.
 * ```html
 * <m3e-slide selected-index="1">
 *  <div>Content at index 0</div>
 *  <div>Content at index 1</div>
 *  <div>Content at index 2</div>
 *  <div>Content at index 3</div>
 * </m3e-slide>
 * ```
 *
 * @tag m3e-slide
 *
 * @slot - Renders the items through which to cycle.
 *
 * @attr selected-index - The zero-based index of the visible item.
 *
 * @cssprop --m3e-slide-animation-duration - The duration of transitions between slotted items.
 */
export declare class M3eSlideElement extends M3eSlideElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /**
     * The zero-based index of the visible item.
     * @default null
     */
    selectedIndex: number | null;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-slide": M3eSlideElement;
    }
}
export {};
//# sourceMappingURL=SlideElement.d.ts.map