// Ownership contract tests: the owner map is the authority map, so it must be unambiguous and fail closed.
import test from "node:test";
import assert from "node:assert/strict";
import { mkdtempSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import {
  loadOwners,
  matchingOwners,
  resolveAuthorizedOwners,
  validateFiles,
} from "../scripts/check-owners.mjs";

const config = loadOwners();

test("owner map loads with the principal and one rule per owner", () => {
  assert.equal(config.version, 1);
  assert.equal(config.principal.github_login, "mrodgersjs-web");
  assert.ok(config.rules.length >= 5);
});

test("upstream app paths belong to the frozen upstream owner", () => {
  const owners = matchingOwners("apps/desktop/src/runtime/main.ts", config);
  assert.deepEqual(owners.map((rule) => rule.owner), ["upstream-frozen"]);
});

test("governance paths belong to the control plane", () => {
  assert.deepEqual(matchingOwners("harness/gates.py", config).map((r) => r.owner), ["control-plane"]);
  assert.deepEqual(matchingOwners("scripts/doctor.py", config).map((r) => r.owner), ["control-plane"]);
  assert.deepEqual(matchingOwners("tests/check-owners.test.mjs", config).map((r) => r.owner), ["control-plane"]);
});

test("architecture note and blueprint have exactly one owner each", () => {
  assert.deepEqual(matchingOwners("docs/ARCHITECTURE-NOTES.md", config).map((r) => r.owner), ["architecture-notes"]);
  assert.deepEqual(matchingOwners("blueprints/openautark-os-architect.json", config).map((r) => r.owner), ["architect-blueprint"]);
  assert.deepEqual(matchingOwners("docs/ARCHITECTURE.md", config).map((r) => r.owner), ["upstream-frozen"]);
});

test("principal branch resolves to the principal owner", () => {
  const owners = resolveAuthorizedOwners({ actor: "mrodgersjs-web", branch: "taste/control-plane" }, config);
  assert.ok(owners.includes("principal"));
});

test("an unauthorized actor is refused", () => {
  assert.throws(
    () => resolveAuthorizedOwners({ actor: "someone-else", branch: "control-plane/change" }, config),
    /not authorized/,
  );
});

test("an unowned path is refused", () => {
  assert.throws(() => validateFiles(["unowned/file.txt"], "control-plane", config), /unowned path/);
});

test("a duplicate path pattern is refused at load time", () => {
  const directory = mkdtempSync(path.join(tmpdir(), "owners-"));
  const file = path.join(directory, "OWNERS.yaml");
  writeFileSync(
    file,
    JSON.stringify({
      version: 1,
      principal: { name: "principal", github_login: "mrodgersjs-web" },
      rules: [
        { owner: "a", paths: ["x/**"] },
        { owner: "b", paths: ["x/**"] },
      ],
    }),
  );
  assert.throws(() => loadOwners(file), /duplicate path pattern/);
});

test("path traversal is refused", () => {
  assert.throws(() => matchingOwners("../escape.ts", config), /invalid repository path/);
});
