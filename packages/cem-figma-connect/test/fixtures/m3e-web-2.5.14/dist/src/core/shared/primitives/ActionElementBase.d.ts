import { CSSResultGroup, LitElement } from "lit";
/**
 * A base implementation for an element, nested within a clickable element, used to
 * perform an action. This class must be inherited.
 */
export declare abstract class ActionElementBase extends LitElement {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected render(): unknown;
    /**
     * When implemented by a derived class, handles the specified click event.
     * @param {Event} e The click event to handle.
     */
    protected abstract _onClick(e: Event): void;
}
//# sourceMappingURL=ActionElementBase.d.ts.map