import { defineConfig } from "@playwright/test";

export default defineConfig({
  testDir: "./tests",
  fullyParallel: false,
  workers: 1,
  retries: 0,
  reporter: [["list"]],
  use: {
    browserName: "chromium",
    headless: true,
    viewport: { width: 800, height: 600 },
    deviceScaleFactor: 2,
    reducedMotion: "reduce",
    colorScheme: "light",
    timezoneId: "UTC",
    locale: "en-US",
  },
});
