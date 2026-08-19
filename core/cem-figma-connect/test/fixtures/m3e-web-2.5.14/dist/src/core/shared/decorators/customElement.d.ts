import { CustomElementDecorator } from "lit/decorators.js";
export type Constructor<T> = {
    new (...args: unknown[]): T;
};
/**
 * Class decorator factory that defines the decorated class as a custom element.
 *
 * ```js
 * @customElement('my-element')
 * class MyElement extends LitElement {
 *   render() {
 *     return html``;
 *   }
 * }
 * ```
 * @param {string} tagName The tag name of the custom element to define.
 */
export declare const customElement: (tagName: string) => CustomElementDecorator;
//# sourceMappingURL=customElement.d.ts.map