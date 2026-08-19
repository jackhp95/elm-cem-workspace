import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import "@m3e/web/core/a11y";
import { DrawerMode } from "./DrawerMode";
declare const M3eDrawerContainerElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").ReconnectedCallbackMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & typeof LitElement;
/**
 * A container for one or two sliding drawers.
 *
 * @description
 * A responsive layout container that manages left and right drawers alongside main content.
 * Supports `over`, `push`, `side`, and `auto` modes, adapting drawer behavior based on breakpoint size.
 * Encodes spatial hierarchy, motion transitions, and accessibility semantics for modal, dismissible,
 * and permanent navigation.
 *
 * @example
 * The following example illustrates a typical drawer layout.
 * ```html
 * <m3e-drawer-container>
 *  <nav slot="start">
 *    <!-- Start drawer content -->
 *  </nav>
 *  <main>
 *    <!-- Main content -->
 *  </main>
 *  <aside slot="end">
 *    <!-- End drawer content -->
 *  </aside>
 * <m3e-drawer-container>
 * ```
 *
 * @tag m3e-drawer-container
 *
 * @slot - Renders the main content.
 * @slot start - Renders the start drawer.
 * @slot end - Renders the end drawer.
 *
 * @attr end - Whether the end drawer is open.
 * @attr end-mode - The behavior mode of the end drawer.
 * @attr end-divider - Whether to show a divider between the end drawer and content for `side` mode.
 * @attr start - Whether the start drawer is open.
 * @attr start-mode - The behavior mode of the start drawer.
 * @attr start-divider - Whether to show a divider between the start drawer and content for `side` mode.
 *
 * @fires change - Dispatched when the state of the start or end drawers change.
 *
 * @cssprop --m3e-drawer-container-color - The background color of the drawer container.
 * @cssprop --m3e-drawer-container-elevation - The elevation level of the drawer container.
 * @cssprop --m3e-drawer-container-width - The width of the drawer container.
 * @cssprop --m3e-drawer-container-scrim-opacity - The opacity of the scrim behind the drawer.
 * @cssprop --m3e-modal-drawer-start-shape - The shape of the drawer's start edge (typically left in LTR).
 * @cssprop --m3e-modal-drawer-end-shape - The shape of the drawer's end edge (typically right in LTR).
 * @cssprop --m3e-modal-drawer-container-color - The background color of the modal drawer container.
 * @cssprop --m3e-modal-drawer-elevation - The elevation level of the modal drawer container.
 * @cssprop --m3e-drawer-divider-color - The color of the divider between drawer sections.
 * @cssprop --m3e-drawer-divider-thickness - The thickness of the divider line.
 */
export declare class M3eDrawerContainerElement extends M3eDrawerContainerElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private _startMode;
    /** @private */ private _endMode;
    /**
     * Whether the start drawer is open.
     * @default false
     */
    start: boolean;
    /**
     * The behavior mode of the start drawer.
     * @default "side"
     */
    startMode: DrawerMode;
    /**
     * Whether to show a divider between the start drawer and content for `side` mode.
     * @default "side"
     */
    startDivider: boolean;
    /**
     * Whether the end drawer is open.
     * @default false
     */
    end: boolean;
    /**
     * The behavior mode of the end drawer.
     * @default "side"
     */
    endMode: DrawerMode;
    /**
     * Whether to show a divider between the end drawer and content for `side` mode.
     * @default "side"
     */
    endDivider: boolean;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected willUpdate(changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    reconnectedCallback(): void;
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-drawer-container": M3eDrawerContainerElement;
    }
}
export {};
//# sourceMappingURL=DrawerContainerElement.d.ts.map