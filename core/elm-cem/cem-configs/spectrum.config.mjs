export default {
  "globs": ["packages/*/src/**/*.ts"],
  "exclude": [
    "**/*.test.ts",
    "**/*.spec.ts",
    "**/test/**/*",
    "**/testing/**/*",
    "**/harness/**/*",
    "**/stories/**/*",
    "**/*.stories.ts"
  ],
  "outdir": ".",
  "litelement": true,
  "plugins": []
};