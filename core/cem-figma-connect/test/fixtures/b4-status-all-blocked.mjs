// Fixture for test/publish-check.test.mjs's task-C7 "every cemTag blocked"
// test: every entry resolves to "rejected" (a human explicitly blocked it),
// regardless of cemTag — exercises publish()'s "nothing publishable in this
// label, skip staging/exec entirely" path.
export function status(_entry) {
  return "rejected";
}
