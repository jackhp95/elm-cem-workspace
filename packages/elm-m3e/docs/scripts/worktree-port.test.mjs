import { test } from "node:test";
import assert from "node:assert/strict";
import { fnv1a, hashToPort, PORT_RANGE, resolveWorktreeRoot, resolveWorktreePort } from "./worktree-port.mjs";

test("fnv1a is deterministic for the same input", () => {
  assert.equal(fnv1a("/Users/jack/worktrees/foo"), fnv1a("/Users/jack/worktrees/foo"));
});

test("fnv1a differs for different input", () => {
  assert.notEqual(fnv1a("/Users/jack/worktrees/foo"), fnv1a("/Users/jack/worktrees/bar"));
});

test("hashToPort stays within the configured range", () => {
  const port = hashToPort("/Users/jack/worktrees/foo");
  assert.ok(port >= PORT_RANGE.min && port < PORT_RANGE.max, `${port} outside [${PORT_RANGE.min}, ${PORT_RANGE.max})`);
});

test("hashToPort is deterministic: same worktree path -> same port every call", () => {
  const seed = "/Users/jack/.paseo/worktrees/3ov4grvm/fix-playwright-port-collision";
  assert.equal(hashToPort(seed), hashToPort(seed));
});

test("hashToPort separates the actual sibling worktrees from this bug report", () => {
  // These are the real, concurrently-checked-out worktree roots that
  // triggered the collision this module fixes (see git worktree list at the
  // time of the report). None of them may share a port.
  const worktrees = [
    "/Users/jack/Documents/code/elm-cem-workspace",
    "/Users/jack/.paseo/worktrees/3ov4grvm/fix-netlify-deploy-not-picked-up",
    "/Users/jack/.paseo/worktrees/3ov4grvm/fix-playwright-port-collision",
    "/Users/jack/.paseo/worktrees/3ov4grvm/fix-publish-mirror-state-atomicity",
    "/Users/jack/.paseo/worktrees/3ov4grvm/reorg-core-brands-plan",
    "/Users/jack/Documents/code/elm-cem-workspace-fix-revendor",
  ];
  const ports = worktrees.map((seed) => hashToPort(seed));
  assert.equal(new Set(ports).size, ports.length, `expected all-distinct ports, got ${JSON.stringify(ports)}`);
});

test("hashToPort with a salt shifts the port for the same seed (collision escape hatch)", () => {
  const seed = "/Users/jack/.paseo/worktrees/3ov4grvm/fix-playwright-port-collision";
  assert.notEqual(hashToPort(seed, PORT_RANGE, 0), hashToPort(seed, PORT_RANGE, 1));
});

test("resolveWorktreeRoot returns this checkout's absolute root", () => {
  const root = resolveWorktreeRoot();
  assert.ok(root.startsWith("/"), `expected an absolute path, got ${root}`);
});

test("resolveWorktreePort honours WORKTREE_PORT_SALT for the escape hatch", () => {
  const seed = "/some/worktree";
  const unsalted = resolveWorktreePort(seed);
  process.env.WORKTREE_PORT_SALT = "7";
  try {
    assert.notEqual(resolveWorktreePort(seed), unsalted);
  } finally {
    delete process.env.WORKTREE_PORT_SALT;
  }
});
