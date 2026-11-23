#!/usr/bin/env node

import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";

const CONFIG_PATH = "OWNERS.yaml";

function escapeRegex(character) {
  return character.replace(/[|\\{}()[\]^$+?.]/g, "\\$&");
}

function globToRegex(pattern) {
  let expression = "^";

  for (let index = 0; index < pattern.length; index += 1) {
    const character = pattern[index];
    if (character === "*" && pattern[index + 1] === "*") {
      expression += ".*";
      index += 1;
    } else if (character === "*") {
      expression += "[^/]*";
    } else if (character === "?") {
      expression += "[^/]";
    } else {
      expression += escapeRegex(character);
    }
  }

  return new RegExp(`${expression}$`);
}

export function loadOwners(path = CONFIG_PATH) {
  const config = JSON.parse(readFileSync(path, "utf8"));
  if (config.version !== 1) {
    throw new Error("OWNERS.yaml: unsupported or missing version");
  }
  if (!config.principal?.name || !config.principal?.github_login) {
    throw new Error("OWNERS.yaml: principal name and github_login are required");
  }
  if (!Array.isArray(config.rules) || config.rules.length === 0) {
    throw new Error("OWNERS.yaml: at least one ownership rule is required");
  }

  const owners = new Set();
  const patterns = new Map();
  for (const rule of config.rules) {
    if (
      !rule.owner ||
      !Array.isArray(rule.paths) ||
      rule.paths.length === 0 ||
      owners.has(rule.owner)
    ) {
      throw new Error("OWNERS.yaml: owner rules must be complete and unique");
    }
    owners.add(rule.owner);
    if (
      rule.github_actors !== undefined &&
      (!Array.isArray(rule.github_actors) ||
        rule.github_actors.some((actor) => typeof actor !== "string"))
    ) {
      throw new Error("OWNERS.yaml: github_actors must be a string array");
    }
    for (const pattern of rule.paths) {
      if (typeof pattern !== "string" || pattern.length === 0) {
        throw new Error("OWNERS.yaml: path patterns must be non-empty strings");
      }
      if (patterns.has(pattern) && patterns.get(pattern) !== rule.owner) {
        throw new Error(`OWNERS.yaml: ambiguous duplicate path pattern ${pattern}`);
      }
      patterns.set(pattern, rule.owner);
    }
  }

  return config;
}

export function matchingOwners(path, config) {
  if (
    typeof path !== "string" ||
    path.length === 0 ||
    path.startsWith("/") ||
    path.includes("\\") ||
    path.includes("\0") ||
    path.split("/").some((part) => part === "." || part === "..")
  ) {
    throw new Error(`invalid repository path: ${JSON.stringify(path)}`);
  }

  return config.rules.filter((rule) =>
    rule.paths.some((pattern) => globToRegex(pattern).test(path)),
  );
}

function branchOwner(branch, config) {
  if (!branch || !branch.includes("/")) {
    return null;
  }
  const owner = branch.slice(0, branch.indexOf("/"));
  if (!config.rules.some((rule) => rule.owner === owner)) {
    throw new Error(`unknown branch owner: ${owner}`);
  }
  return owner;
}

export function resolveAuthorizedOwners({ actor, branch }, config) {
  if (!actor) {
    throw new Error("authenticated GitHub actor is required");
  }

  if (actor === config.principal.github_login) {
    const prefix = branch?.includes("/")
      ? branch.slice(0, branch.indexOf("/"))
      : null;
    const scopedOwner = config.rules.some((rule) => rule.owner === prefix)
      ? prefix
      : null;
    const principalOwners = [config.principal.name];
    if (scopedOwner) {
      principalOwners.push(scopedOwner);
    } else {
      principalOwners.push("consolidation-steward");
    }
    return [...new Set(principalOwners)];
  }

  const scopedOwner = branchOwner(branch, config);
  if (!scopedOwner) {
    throw new Error(
      "agent ownership is unavailable: use an <owner>/<change> branch",
    );
  }
  const rule = config.rules.find((candidate) => candidate.owner === scopedOwner);
  if (!rule.github_actors?.includes(actor)) {
    throw new Error(
      `GitHub actor ${actor} is not authorized as ${scopedOwner}`,
    );
  }
  return [scopedOwner];
}

export function resolveOwner(identity, config) {
  if (identity.actor === config.principal.github_login) {
    return config.principal.name;
  }
  return resolveAuthorizedOwners(identity, config)[0];
}

export function validateFiles(files, allowedOwnerInput, config) {
  const allowedOwners = new Set(
    Array.isArray(allowedOwnerInput)
      ? allowedOwnerInput
      : [allowedOwnerInput],
  );
  if (
    allowedOwners.size === 0 ||
    [...allowedOwners].some((owner) => !config.rules.some((r) => r.owner === owner))
  ) {
    throw new Error("active authorized owner is required and must be known");
  }

  for (const path of files) {
    const matches = matchingOwners(path, config);
    if (matches.length === 0) {
      throw new Error(`unowned path: ${path}`);
    }
    if (matches.length > 1) {
      throw new Error(`ambiguous path (${matches.length} owners): ${path}`);
    }
    if (!allowedOwners.has(matches[0].owner)) {
      throw new Error(
        `owner violation: ${path} belongs to ${matches[0].owner}`,
      );
    }
  }
}

function parseArguments(arguments_) {
  let actor;
  let branch;
  const files = [];
  for (let index = 0; index < arguments_.length; index += 1) {
    const argument = arguments_[index];
    if (argument === "--actor") {
      actor = arguments_[++index];
    } else if (argument === "--branch") {
      branch = arguments_[++index];
    } else if (argument === "--") {
      files.push(...arguments_.slice(index + 1));
      break;
    } else if (argument.startsWith("-")) {
      throw new Error(`unknown argument: ${argument}`);
    } else {
      files.push(argument);
    }
  }
  return { actor, branch, files };
}

async function main() {
  const { actor, branch, files } = parseArguments(process.argv.slice(2));
  const config = loadOwners();
  const allowedOwners = resolveAuthorizedOwners({ actor, branch }, config);
  if (files.length === 0) {
    throw new Error("no changed files were supplied");
  }
  validateFiles(files, allowedOwners, config);
  console.log(
    `ownership check passed for ${allowedOwners.join(", ")}: ${files.length} path(s)`,
  );
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  main().catch((error) => {
    console.error(`BLOCK: ${error.message}`);
    process.exit(2);
  });
}
