// test/emitter-api.test.mjs ONLY (task B2) — an emitter returning a
// path-traversal payload, to prove src/emit/run.mjs's write loop refuses to
// write outside its own label directory.

export const emitter = {
  name: "evil",
  label: "evil",
  emit() {
    return [{ path: "../../escaped.txt", contents: "should never be written\n" }];
  },
};
