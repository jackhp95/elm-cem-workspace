/**
 * Adapted from Angular Material CDK Live Announcer
 * Source: https://github.com/angular/components/blob/main/src/cdk/a11y/live-announcer/live-announcer.ts
 *
 * @license MIT
 * Copyright (c) 2025 Google LLC
 * See LICENSE file in the project root for full license text.
 */
/** Specifies the possible politeness levels in which to announce messages. */
export type ARIALivePoliteness = "off" | "polite" | "assertive";
/** Utility for announcing messages to screen readers. */
export declare class M3eLiveAnnouncer {
    #private;
    /**
     * Announces the specified message to screen readers.
     * @param {string} message The message to announce.
     * @returns {Promise<void>} A `Promise` that resolves when `message` is added to the DOM.
     */
    static announce(message: string): Promise<void>;
    /**
     * Announces the specified message to screen readers.
     * @param {string} message The message to announce.
     * @param {ARIALivePoliteness | undefined} politeness The politeness in which to announce `message`.
     * @returns {Promise<void>} A `Promise` that resolves when `message` is added to the DOM.
     */
    static announce(message: string, politeness?: ARIALivePoliteness): Promise<void>;
    /**
     * Announces the specified message to screen readers.
     * @param {string} message The message to announce.
     * @param {number | undefined} duration The duration, in milliseconds, after which to clear the announcement. Note
     * that this takes effect after the message has been added to the DOM, which can be up to
     * 100ms after `announce` has been called.
     * @returns {Promise<void>} A `Promise` that resolves when `message` is added to the DOM.
     */
    static announce(message: string, duration?: number): Promise<void>;
    /**
     * Announces the specified message to screen readers.
     * @param {string} message The message to announce.
     * @param {ARIALivePoliteness | undefined} politeness The politeness in which to announce `message`.
     * @param {number | undefined} duration The duration, in milliseconds, after which to clear the announcement. Note
     * that this takes effect after the message has been added to the DOM, which can be up to 100ms after `announce` has been called.
     * @returns {Promise<void>} A `Promise` that resolves when `message` is added to the DOM.
     */
    static announce(message: string, politeness?: ARIALivePoliteness, duration?: number): Promise<void>;
    /**
     * Clears the current text from the announcer element. Can be used to prevent
     * screen readers from reading the text out again while the user is going
     * through page landmarks.
     */
    static clear(): void;
}
type M3eLiveAnnouncerClass = typeof M3eLiveAnnouncer;
declare global {
    /** Utility for announcing messages to screen readers. */
    var M3eLiveAnnouncer: M3eLiveAnnouncerClass;
}
export {};
//# sourceMappingURL=LiveAnnouncer.d.ts.map