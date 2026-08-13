import { describe, it, expect } from "vitest";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const execFileP = promisify(execFile);
const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");

/*
 * Regression for #7: the `if (import.meta.url === pathToFileURL(process.argv[1]).href)`
 * direct-execution guard threw ERR_INVALID_ARG_TYPE when a bin was imported in a
 * context where process.argv[1] is undefined (e.g. `node --eval`). Importing a
 * module must never throw just because it was loaded, not run.
 */
describe("bin direct-execution guard", () => {
  for (const bin of ["calibrate-tones", "check-privates", "generate-component-utilities"]) {
    it(`bin/${bin}.mjs imports cleanly when process.argv[1] is undefined (node -e)`, async () => {
      // Under `node -e`, process.argv[1] is undefined — the exact crash condition.
      const { stdout } = await execFileP(
        process.execPath,
        ["-e", `import(${JSON.stringify(join(ROOT, "bin", `${bin}.mjs`))}).then(() => console.log("OK"))`],
        { cwd: ROOT, timeout: 15_000 },
      );
      expect(stdout.trim()).toBe("OK");
    });
  }
});
