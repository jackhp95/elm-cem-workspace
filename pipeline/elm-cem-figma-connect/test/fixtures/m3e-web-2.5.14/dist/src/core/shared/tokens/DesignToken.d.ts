/** Design tokens used to style components. */
export declare const DesignToken: {
    /** Design tokens that control color. */
    readonly color: {
        readonly primary: import("lit").CSSResult;
        readonly onPrimary: import("lit").CSSResult;
        readonly primaryContainer: import("lit").CSSResult;
        readonly onPrimaryContainer: import("lit").CSSResult;
        readonly primaryFixed: import("lit").CSSResult;
        readonly primaryFixedDim: import("lit").CSSResult;
        readonly onPrimaryFixed: import("lit").CSSResult;
        readonly onPrimaryFixedVariant: import("lit").CSSResult;
        readonly secondary: import("lit").CSSResult;
        readonly onSecondary: import("lit").CSSResult;
        readonly secondaryContainer: import("lit").CSSResult;
        readonly onSecondaryContainer: import("lit").CSSResult;
        readonly secondaryFixed: import("lit").CSSResult;
        readonly secondaryFixedDim: import("lit").CSSResult;
        readonly onSecondaryFixed: import("lit").CSSResult;
        readonly onSecondaryFixedVariant: import("lit").CSSResult;
        readonly tertiary: import("lit").CSSResult;
        readonly onTertiary: import("lit").CSSResult;
        readonly tertiaryContainer: import("lit").CSSResult;
        readonly onTertiaryContainer: import("lit").CSSResult;
        readonly tertiaryFixed: import("lit").CSSResult;
        readonly tertiaryFixedDim: import("lit").CSSResult;
        readonly onTertiaryFixed: import("lit").CSSResult;
        readonly onTertiaryFixedVariant: import("lit").CSSResult;
        readonly error: import("lit").CSSResult;
        readonly onError: import("lit").CSSResult;
        readonly errorContainer: import("lit").CSSResult;
        readonly onErrorContainer: import("lit").CSSResult;
        readonly surface: import("lit").CSSResult;
        readonly onSurface: import("lit").CSSResult;
        readonly onSurfaceVariant: import("lit").CSSResult;
        readonly surfaceContainerLowest: import("lit").CSSResult;
        readonly surfaceContainerLow: import("lit").CSSResult;
        readonly surfaceContainer: import("lit").CSSResult;
        readonly surfaceContainerHigh: import("lit").CSSResult;
        readonly surfaceContainerHighest: import("lit").CSSResult;
        readonly surfaceDim: import("lit").CSSResult;
        readonly surfaceBright: import("lit").CSSResult;
        readonly surfaceVariant: import("lit").CSSResult;
        readonly inverseSurface: import("lit").CSSResult;
        readonly inverseOnSurface: import("lit").CSSResult;
        readonly inversePrimary: import("lit").CSSResult;
        readonly outline: import("lit").CSSResult;
        readonly outlineVariant: import("lit").CSSResult;
        readonly shadow: import("lit").CSSResult;
        readonly scrim: import("lit").CSSResult;
    };
    /** Design tokens that control elevation. */
    readonly elevation: {
        readonly level0: import("lit").CSSResult;
        readonly level1: import("lit").CSSResult;
        readonly level2: import("lit").CSSResult;
        readonly level3: import("lit").CSSResult;
        readonly level4: import("lit").CSSResult;
        readonly level5: import("lit").CSSResult;
    };
    /** Design tokens that control motion. */
    readonly motion: {
        readonly easing: {
            readonly emphasized: import("lit").CSSResult;
            readonly emphasizedDecelerate: import("lit").CSSResult;
            readonly emphasizedAccelerate: import("lit").CSSResult;
            readonly standard: import("lit").CSSResult;
            readonly standardDecelerate: import("lit").CSSResult;
            readonly standardAccelerate: import("lit").CSSResult;
        };
        readonly duration: {
            readonly short1: import("lit").CSSResult;
            readonly short2: import("lit").CSSResult;
            readonly short3: import("lit").CSSResult;
            readonly short4: import("lit").CSSResult;
            readonly medium1: import("lit").CSSResult;
            readonly medium2: import("lit").CSSResult;
            readonly medium3: import("lit").CSSResult;
            readonly medium4: import("lit").CSSResult;
            readonly long1: import("lit").CSSResult;
            readonly long2: import("lit").CSSResult;
            readonly long3: import("lit").CSSResult;
            readonly long4: import("lit").CSSResult;
            readonly extraLong1: import("lit").CSSResult;
            readonly extraLong2: import("lit").CSSResult;
            readonly extraLong3: import("lit").CSSResult;
            readonly extraLong4: import("lit").CSSResult;
        };
        readonly spring: {
            readonly fastSpatial: import("lit").CSSResult;
            readonly defaultSpatial: import("lit").CSSResult;
            readonly slowSpatial: import("lit").CSSResult;
            readonly fastEffects: import("lit").CSSResult;
            readonly defaultEffects: import("lit").CSSResult;
            readonly slowEffects: import("lit").CSSResult;
        };
    };
    /** Design tokens that control shape. */
    readonly shape: {
        readonly corner: {
            readonly full: import("lit").CSSResult;
            readonly extraLargeTop: import("lit").CSSResult;
            readonly extraLarge: import("lit").CSSResult;
            readonly extraLargeEnd: import("lit").CSSResult;
            readonly extraLargeStart: import("lit").CSSResult;
            readonly largeTop: import("lit").CSSResult;
            readonly largeEnd: import("lit").CSSResult;
            readonly largeStart: import("lit").CSSResult;
            readonly large: import("lit").CSSResult;
            readonly medium: import("lit").CSSResult;
            readonly mediumTop: import("lit").CSSResult;
            readonly mediumEnd: import("lit").CSSResult;
            readonly mediumStart: import("lit").CSSResult;
            readonly small: import("lit").CSSResult;
            readonly smallTop: import("lit").CSSResult;
            readonly smallEnd: import("lit").CSSResult;
            readonly smallStart: import("lit").CSSResult;
            readonly extraSmallTop: import("lit").CSSResult;
            readonly extraSmall: import("lit").CSSResult;
            readonly extraSmallEnd: import("lit").CSSResult;
            readonly extraSmallStart: import("lit").CSSResult;
            readonly extraSmallBottom: import("lit").CSSResult;
            readonly none: import("lit").CSSResult;
            readonly largeIncreased: import("lit").CSSResult;
            readonly extraLargeIncreased: import("lit").CSSResult;
            readonly extraExtraLarge: import("lit").CSSResult;
            readonly value: {
                readonly none: import("lit").CSSResult;
                readonly extraSmall: import("lit").CSSResult;
                readonly small: import("lit").CSSResult;
                readonly medium: import("lit").CSSResult;
                readonly large: import("lit").CSSResult;
                readonly largeIncreased: import("lit").CSSResult;
                readonly extraLarge: import("lit").CSSResult;
                readonly extraLargeIncreased: import("lit").CSSResult;
                readonly extraExtraLarge: import("lit").CSSResult;
            };
        };
    };
    /** Design tokens that control state layer. */
    readonly state: {
        readonly focusStateLayerOpacity: import("lit").CSSResult;
        readonly hoverStateLayerOpacity: import("lit").CSSResult;
        readonly pressedStateLayerOpacity: import("lit").CSSResult;
    };
    /** Design tokens that control typescale. */
    readonly typescale: {
        readonly standard: {
            readonly display: {
                readonly large: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
                readonly medium: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
                readonly small: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
            };
            readonly headline: {
                readonly large: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
                readonly medium: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
                readonly small: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
            };
            readonly title: {
                readonly large: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
                readonly medium: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
                readonly small: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
            };
            readonly body: {
                readonly large: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
                readonly medium: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
                readonly small: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
            };
            readonly label: {
                readonly large: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
                readonly medium: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
                readonly small: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
            };
        };
        readonly emphasized: {
            readonly display: {
                readonly large: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
                readonly medium: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
                readonly small: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
            };
            readonly headline: {
                readonly large: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
                readonly medium: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
                readonly small: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
            };
            readonly title: {
                readonly large: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
                readonly medium: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
                readonly small: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
            };
            readonly body: {
                readonly large: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
                readonly medium: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
                readonly small: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
            };
            readonly label: {
                readonly large: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
                readonly medium: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
                readonly small: {
                    readonly fontSize: import("lit").CSSResult;
                    readonly fontWeight: import("lit").CSSResult;
                    readonly lineHeight: import("lit").CSSResult;
                    readonly tracking: import("lit").CSSResult;
                };
            };
        };
    };
    /** Design tokens that control scrollbars. */
    readonly scrollbar: {
        readonly width: import("lit").CSSResult;
        readonly thinWidth: import("lit").CSSResult;
        readonly color: import("lit").CSSResult;
    };
    /** Design tokens that control density. */
    readonly density: {
        readonly calc: (minScale: number) => import("lit").CSSResult;
        readonly scale: import("lit").CSSResult;
        readonly size: import("lit").CSSResult;
    };
    /** Design tokens that control measurement. */
    readonly measurement: {
        readonly space0: import("lit").CSSResult;
        readonly space25: import("lit").CSSResult;
        readonly space50: import("lit").CSSResult;
        readonly space75: import("lit").CSSResult;
        readonly space100: import("lit").CSSResult;
        readonly space125: import("lit").CSSResult;
        readonly space150: import("lit").CSSResult;
        readonly space175: import("lit").CSSResult;
        readonly space200: import("lit").CSSResult;
        readonly space250: import("lit").CSSResult;
        readonly space300: import("lit").CSSResult;
        readonly space400: import("lit").CSSResult;
        readonly space450: import("lit").CSSResult;
        readonly space500: import("lit").CSSResult;
        readonly space600: import("lit").CSSResult;
        readonly space700: import("lit").CSSResult;
        readonly space800: import("lit").CSSResult;
        readonly space900: import("lit").CSSResult;
    };
};
//# sourceMappingURL=DesignToken.d.ts.map