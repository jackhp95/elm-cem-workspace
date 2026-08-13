/**
 * Adapted from Angular Material CDK Platform
 * Source: https://github.com/angular/components/blob/main/src/cdk/platform/platform.ts
 *
 * @license MIT
 * Copyright (c) 2025 Google LLC
 * See LICENSE file in the project root for full license text.
 */
/** Utility used to detect the current platform. */
export declare class M3ePlatform {
    /** A value indicating whether the platform is a browser. */
    static readonly isBrowser: boolean;
    /** A value indicating whether the current browser is Microsoft Edge. */
    static readonly Edge: boolean;
    /** A value indicating whether the current rendering engine is Microsoft Trident. */
    static readonly Trident: boolean;
    /** A value indicating whether the current rendering engine is Blink. */
    static readonly Blink: boolean;
    /** A value indicating whether the current rendering engine is WebKit. */
    static readonly WebKit: boolean;
    /** A value indicating whether the current platform is Apply iOS. */
    static readonly iOS: boolean;
    /** A value indicating whether the current browser is Firefox. */
    static readonly Firefox: boolean;
    /** A value indicating whether the current platform is Android. */
    static readonly Android: boolean;
    /** A value indicating whether the current browser is Safari. */
    static readonly Safari: boolean;
}
type M3ePlatformClass = typeof M3ePlatform;
declare global {
    /** Utility used to detect the current platform. */
    var M3ePlatform: M3ePlatformClass;
}
export {};
//# sourceMappingURL=Platform.d.ts.map