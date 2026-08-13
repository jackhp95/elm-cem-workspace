// test/emitter-api.test.mjs ONLY (task B2 review fix) — a module that DOES
// resolve (unlike the removed does-not-exist.mjs fixture) but exports an
// object missing every required emitter field ({name, label, emit}), to
// prove src/emit/run.mjs's custom isValidEmitter/missingEmitterFields
// validation path actually fires (as opposed to Node's own ENOENT, which is
// all the old fixture could ever exercise).

export const emitter = {};
