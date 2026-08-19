import { CSSResultGroup, LitElement, PropertyValues } from "lit";
declare const M3eTabElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").SelectedMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").HtmlForMixin> & import("../core/shared/mixins/Constructor").Constructor & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & typeof LitElement;
/**
 * An interactive element that, when activated, presents an associated tab panel.
 *
 * @description
 * The `m3e-tab` component is an interactive control used within a tabbed interface to activate and
 * reveal an associated tab panel. It supports accessible labeling, optional iconography, and selection
 * state styling consistent with Material 3 guidance. Tabs may be disabled, selected, or linked to a
 * specific panel via the `for` attribute, enabling declarative control and semantic clarity.
 *
 * @example
 * The following example illustrates using the `m3e-tabs`, `m3e-tab`, and `m3e-tab-panel` components to present
 * secondary tabs.
 * ```html
 * <m3e-tabs>
 *  <m3e-tab selected for="videos"><m3e-icon slot="icon" name="videocam"></m3e-icon>Video</m3e-tab>
 *  <m3e-tab for="photos"><m3e-icon slot="icon" name="photo"></m3e-icon>Photos</m3e-tab>
 *  <m3e-tab for="audio"><m3e-icon slot="icon" name="music_note"></m3e-icon>Audio</m3e-tab>
 *  <m3e-tab-panel id="videos">Videos</m3e-tab-panel>
 *  <m3e-tab-panel id="photos">Photos</m3e-tab-panel>
 *  <m3e-tab-panel id="audio">Audio</m3e-tab-panel>
 * </m3e-tabs>
 * ```
 *
 * @tag m3e-tab
 *
 * @slot - Renders the label of the tab.
 * @slot icon - Renders an icon before the tab's label.
 *
 * @attr disabled - Whether the element is disabled.
 * @attr for - The identifier of the interactive control to which this element is attached.
 * @attr selected - Whether the element is selected.
 *
 * @fires beforeinput - Dispatched before the selected state changes.
 * @fires input - Dispatched when the selected state changes.
 * @fires change - Dispatched when the selected state changes.
 * @fires click - Dispatched when the element is clicked.
 *
 * @cssprop --m3e-tab-font-size - Font size for tab label.
 * @cssprop --m3e-tab-font-weight - Font weight for tab label.
 * @cssprop --m3e-tab-line-height - Line height for tab label.
 * @cssprop --m3e-tab-tracking - Letter spacing for tab label.
 * @cssprop --m3e-tab-padding-start - Padding on the inline start of the tab.
 * @cssprop --m3e-tab-padding-end - Padding on the inline end of the tab.
 * @cssprop --m3e-tab-focus-ring-shape - Border radius for the focus ring.
 * @cssprop --m3e-tab-selected-color - Text color for selected tab.
 * @cssprop --m3e-tab-selected-container-hover-color - Hover state-layer color for selected tab.
 * @cssprop --m3e-tab-selected-container-focus-color - Focus state-layer color for selected tab.
 * @cssprop --m3e-tab-selected-ripple-color - Ripple color for selected tab.
 * @cssprop --m3e-tab-unselected-color - Text color for unselected tab.
 * @cssprop --m3e-tab-unselected-container-hover-color - Hover state-layer color for unselected tab.
 * @cssprop --m3e-tab-unselected-container-focus-color - Focus state-layer color for unselected tab.
 * @cssprop --m3e-tab-unselected-ripple-color - Ripple color for unselected tab.
 * @cssprop --m3e-tab-disabled-color - Text color for disabled tab.
 * @cssprop --m3e-tab-disabled-opacity - Text opacity for disabled tab.
 * @cssprop --m3e-tab-spacing - Column gap between icon and label.
 * @cssprop --m3e-tab-icon-size - Font size for slotted icon.
 */
export declare class M3eTabElement extends M3eTabElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private static __nextId;
    /** @private */ private readonly _focusRing?;
    /** @private */ private readonly _stateLayer?;
    /** @private */ private readonly _ripple?;
    /** @internal A reference to the element that wraps the label of the tab. */
    readonly label: HTMLElement;
    /** @inheritdoc */
    attach(control: HTMLElement): void;
    /** @inheritdoc */
    detach(): void;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-tab": M3eTabElement;
    }
}
export {};
//# sourceMappingURL=TabElement.d.ts.map