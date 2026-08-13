// Toy emitter for test/emitter-api.test.mjs (task B2). Deliberately trivial
// — its only job is to PROVE the ctx shape src/emit/emitter-api.mjs
// documents actually arrives intact through src/emit/run.mjs's
// dynamic-import registration: `ctx.profile` (profile config),
// `ctx.figma` (export views), `ctx.cem` (resolved CEM data for the entry's
// tag), and `ctx.helpers` (URL builder + slugify, exercised directly below).
//
// Pure: no fs, no network, no process.env — conforms to the same contract
// any real emitter (html-label, B3's Elm emitter) must.

export const emitter = {
  name: "toy",
  label: "toy",
  emit(entry, ctx) {
    if (!ctx || !ctx.profile || !ctx.figma || !ctx.helpers) {
      throw new Error("toy emitter: ctx is missing an expected top-level field");
    }
    if (typeof ctx.helpers.slugify !== "function" || typeof ctx.helpers.buildNodeUrl !== "function") {
      throw new Error("toy emitter: ctx.helpers is missing slugify/buildNodeUrl");
    }

    return (entry.figmaSets ?? []).map((set) => {
      const url = ctx.helpers.buildNodeUrl(
        { fileKey: ctx.profile.fileKey, fileName: ctx.figma.data.meta.fileName },
        set.nodeId
      );
      return {
        path: `${entry.cemTag}-${ctx.helpers.slugify(set.setName)}.toy.txt`,
        contents:
          `entry: ${entry.cemTag}\n` +
          `set: ${set.setName} (${set.nodeId})\n` +
          `url: ${url}\n` +
          `cem: ${ctx.cem ? ctx.cem.tag : "null"}\n`,
      };
    });
  },
};
