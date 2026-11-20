// Owns: launching the real side browser and driver for the self-close regression, with a fresh profile and
// in-memory pages. Never starts the app entry point, uses live data, or opens a listening socket.
import { execFile } from 'node:child_process';
import { copyFile, mkdtemp, rm } from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import { promisify } from 'node:util';
import { test } from 'node:test';
import electron from 'electron';
import { build } from 'esbuild';

const root = path.resolve(import.meta.dirname, '../..');
const run = promisify(execFile);

test('self-closing side tab: reopen it, keep the other tab, and open a fresh page through the driver', { timeout: 65_000 }, async () => {
  const dir = await mkdtemp(path.join(os.tmpdir(), 'autark-side-lifecycle-'));
  try {
    await build({
      absWorkingDir: root,
      stdin: {
        contents: 'export { WorkspaceBrowser } from "./src/main/workspace-browser.ts"; export { SideDriver } from "./src/main/side-driver/driver.ts";',
        resolveDir: root,
      },
      bundle: true, platform: 'node', format: 'cjs', external: ['electron'],
      outfile: path.join(dir, 'workspace-under-test.cjs'),
    });
    const fixture = path.join(dir, 'fixture.cjs');
    await copyFile(path.join(import.meta.dirname, 'fixtures/sidebrowser-lifecycle.cjs'), fixture);
    const env = { ...process.env, SIDE_LIFECYCLE_PROFILE: path.join(dir, 'profile') };
    delete env.ELECTRON_RUN_AS_NODE;
    await run(electron, [fixture], { cwd: dir, env, timeout: 50_000, windowsHide: true });
  } finally {
    await rm(dir, { recursive: true, force: true, maxRetries: 5, retryDelay: 200 });
  }
});
