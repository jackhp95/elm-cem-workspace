import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    include: ["test/**/*.test.mjs"],
    snapshotFormat: { printBasicPrototype: false },
  },
});
