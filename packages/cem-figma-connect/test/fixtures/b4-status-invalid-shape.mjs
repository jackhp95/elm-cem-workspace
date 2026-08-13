// Fixture for test/publish-check.test.mjs: a module that EXISTS at the
// resolved path but does not export a `status` (or `default`) function —
// resolveStatusFn must throw rather than silently treat this as
// "module absent" (warn-and-pass is only for a genuinely missing file).
export const notStatus = 42;
