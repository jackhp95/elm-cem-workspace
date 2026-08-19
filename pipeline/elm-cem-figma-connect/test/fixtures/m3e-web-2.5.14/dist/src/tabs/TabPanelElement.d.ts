import { CSSResultGroup, LitElement } from "lit";
declare const M3eTabPanelElement_base: import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * A panel presented for a tab.
 *
 * @description
 * The `m3e-tab-panel` component represents the content region associated with a selected tab.
 * It is conditionally rendered based on tab selection and provides a structured surface for
 * displaying contextual information, media, or interactive elements. Panels are linked to their
 * corresponding tabs via the `for` attribute on `m3e-tab`, enabling declarative control and
 * accessible navigation consistent with Material 3 guidance.
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
 * @tag m3e-tab-panel
 *
 * @slot - Renders the content of the panel.
 */
export declare class M3eTabPanelElement extends M3eTabPanelElement_base {
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-tab-panel": M3eTabPanelElement;
    }
}
export {};
//# sourceMappingURL=TabPanelElement.d.ts.map