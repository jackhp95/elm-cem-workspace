/**
 * Adapted from Angular Material CDK ARIA Describer
 * Source: https://github.com/angular/components/blob/main/src/cdk/a11y/aria-describer/aria-describer.ts
 *
 * @license MIT
 * Copyright (c) 2025 Google LLC
 * See LICENSE file in the project root for full license text.
 */
/** Utility for generating visually hidden elements that convey descriptive messages using `aria-describedby`. */
export declare class M3eAriaDescriber {
    #private;
    /**
     * Adds an `aria-describedby` reference to a hidden element that contains the message.
     * @param {Element} element The element for which to provide a visually hidden description.
     * @param {string} message The message used to describe `element`.
     * @param {string} [role="tooltip"] The ARIA role of the message.
     */
    static describe(element: Element, message: string, role?: string): void;
    /**
     * Removes an `aria-describedby` reference to a hidden element that contains the message.
     * @param {Element} element The element from which to remove a visually hidden description.
     * @param {string} message The message used to describe `element`.
     * @param {string} [role="tooltip"] The ARIA role of the message.
     */
    static removeDescription(element: Element, message: string, role?: string): void;
}
type M3eAriaDescriberClass = typeof M3eAriaDescriber;
declare global {
    /** Utility for generating visually hidden elements that convey descriptive messages using `aria-describedby`. */
    var M3eAriaDescriber: M3eAriaDescriberClass;
}
export {};
//# sourceMappingURL=AriaDescriber.d.ts.map