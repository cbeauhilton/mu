#!/usr/bin/env bun
// $PAI_DIR/hooks/local-repo-resolver.ts
// PreToolUse hook: Intercepts GitHub fetches, ensures local clone exists, blocks with redirect
//
// Exit codes:
//   0 = allow (not a GitHub URL, or couldn't resolve)
//   2 = block (repo ready locally, use that instead)

import { existsSync, readFileSync } from "fs";
import { join } from "path";
import { $ } from "bun";

interface PreToolUsePayload {
  session_id: string;
  tool_name: string;
  tool_input: Record<string, unknown>;
  cwd?: string;
}

interface FlakeLockNode {
  locked?: {
    owner?: string;
    repo?: string;
    rev?: string;
    type?: string;
  };
  original?: {
    owner?: string;
    repo?: string;
  };
}

interface FlakeLock {
  nodes: Record<string, FlakeLockNode>;
}

const REPOS_DIR = "/home/beau/src/.repos";

// GitHub URL patterns - extract owner/repo
const GITHUB_PATTERNS = [
  // raw.githubusercontent.com/owner/repo/ref/path
  /raw\.githubusercontent\.com\/([^\/]+)\/([^\/]+)/,
  // api.github.com/repos/owner/repo
  /api\.github\.com\/repos\/([^\/]+)\/([^\/]+)/,
  // github.com/owner/repo
  /github\.com\/([^\/]+)\/([^\/]+)/,
];

function extractRepoFromUrl(url: string): { owner: string; repo: string } | null {
  for (const pattern of GITHUB_PATTERNS) {
    const match = url.match(pattern);
    if (match) {
      const repo = match[2].replace(/\.git$/, "").split("/")[0];
      return { owner: match[1], repo };
    }
  }
  return null;
}

function getLocalPath(owner: string, repo: string): string {
  // Try owner/repo structure first, fallback to just repo name
  const ownerRepoPath = join(REPOS_DIR, owner, repo);
  const repoOnlyPath = join(REPOS_DIR, repo);

  if (existsSync(join(ownerRepoPath, ".git"))) {
    return ownerRepoPath;
  }
  if (existsSync(join(repoOnlyPath, ".git"))) {
    return repoOnlyPath;
  }
  // Default to repo-only path for new clones
  return repoOnlyPath;
}

function isRepoCloned(localPath: string): boolean {
  return existsSync(join(localPath, ".git"));
}

// Find the desired commit/version from project files
function findDesiredVersion(
  cwd: string,
  owner: string,
  repo: string
): { rev?: string; source: string } | null {
  // 1. Check flake.lock
  const flakeLockPath = join(cwd, "flake.lock");
  if (existsSync(flakeLockPath)) {
    try {
      const flakeLock: FlakeLock = JSON.parse(readFileSync(flakeLockPath, "utf-8"));
      for (const [_name, node] of Object.entries(flakeLock.nodes)) {
        if (
          node.locked?.type === "github" &&
          node.locked?.owner?.toLowerCase() === owner.toLowerCase() &&
          node.locked?.repo?.toLowerCase() === repo.toLowerCase()
        ) {
          return { rev: node.locked.rev, source: "flake.lock" };
        }
        // Also check original
        if (
          node.original?.owner?.toLowerCase() === owner.toLowerCase() &&
          node.original?.repo?.toLowerCase() === repo.toLowerCase() &&
          node.locked?.rev
        ) {
          return { rev: node.locked.rev, source: "flake.lock" };
        }
      }
    } catch {
      // Ignore parse errors
    }
  }

  // 2. Check go.mod for Go dependencies
  const goModPath = join(cwd, "go.mod");
  if (existsSync(goModPath)) {
    try {
      const goMod = readFileSync(goModPath, "utf-8");
      // Match: github.com/owner/repo v1.2.3 or github.com/owner/repo v0.0.0-timestamp-hash
      const pattern = new RegExp(
        `github\\.com/${owner}/${repo}(?:/[^\\s]*)? (v[^\\s]+)`,
        "i"
      );
      const match = goMod.match(pattern);
      if (match) {
        // Extract commit hash from pseudo-version if present (v0.0.0-20240101-abcdef123456)
        const version = match[1];
        const pseudoMatch = version.match(/-([a-f0-9]{12})$/);
        if (pseudoMatch) {
          return { rev: pseudoMatch[1], source: "go.mod (pseudo-version)" };
        }
        // For regular versions, we'd need to look up the tag - skip for now
        return { source: "go.mod (version tag, using latest)" };
      }
    } catch {
      // Ignore parse errors
    }
  }

  // 3. Check package.json for npm dependencies
  const packageJsonPath = join(cwd, "package.json");
  if (existsSync(packageJsonPath)) {
    try {
      const pkg = JSON.parse(readFileSync(packageJsonPath, "utf-8"));
      const deps = { ...pkg.dependencies, ...pkg.devDependencies };
      for (const [_name, version] of Object.entries(deps)) {
        if (typeof version === "string") {
          // Match github:owner/repo#ref or github.com/owner/repo#ref
          const ghMatch = version.match(
            new RegExp(`github(?:\\.com)?[:/]${owner}/${repo}(?:#(.+))?$`, "i")
          );
          if (ghMatch) {
            return {
              rev: ghMatch[1],
              source: ghMatch[1] ? "package.json" : "package.json (using latest)",
            };
          }
        }
      }
    } catch {
      // Ignore parse errors
    }
  }

  return null;
}

async function getCurrentCommit(localPath: string): Promise<string | null> {
  try {
    const result = await $`git -C ${localPath} rev-parse HEAD`.quiet();
    return result.text().trim();
  } catch {
    return null;
  }
}

async function cloneRepo(owner: string, repo: string, localPath: string): Promise<boolean> {
  try {
    console.error(`[local-repo-resolver] Cloning ${owner}/${repo} to ${localPath}...`);
    await $`git clone https://github.com/${owner}/${repo}.git ${localPath}`.quiet();
    return true;
  } catch (error) {
    console.error(`[local-repo-resolver] Clone failed:`, error);
    return false;
  }
}

async function fetchAndCheckout(
  localPath: string,
  rev: string
): Promise<boolean> {
  try {
    console.error(`[local-repo-resolver] Fetching and checking out ${rev}...`);
    await $`git -C ${localPath} fetch --all`.quiet();
    await $`git -C ${localPath} checkout ${rev}`.quiet();
    return true;
  } catch (error) {
    console.error(`[local-repo-resolver] Checkout failed:`, error);
    return false;
  }
}

async function updateToLatest(localPath: string): Promise<boolean> {
  try {
    // Get current branch
    const branch = (await $`git -C ${localPath} rev-parse --abbrev-ref HEAD`.quiet())
      .text()
      .trim();
    if (branch !== "HEAD") {
      // On a branch, pull latest
      await $`git -C ${localPath} pull --ff-only`.quiet();
    } else {
      // Detached HEAD, just fetch
      await $`git -C ${localPath} fetch --all`.quiet();
    }
    return true;
  } catch {
    return false;
  }
}

async function main() {
  try {
    const stdinData = await Bun.stdin.text();
    if (!stdinData.trim()) {
      process.exit(0);
    }

    const payload: PreToolUsePayload = JSON.parse(stdinData);

    // Only intercept WebFetch
    if (payload.tool_name !== "WebFetch") {
      process.exit(0);
    }

    const url = payload.tool_input?.url;
    if (typeof url !== "string") {
      process.exit(0);
    }

    const repoInfo = extractRepoFromUrl(url);
    if (!repoInfo) {
      // Not a GitHub URL, allow
      process.exit(0);
    }

    const { owner, repo } = repoInfo;
    const localPath = getLocalPath(owner, repo);
    const cwd = payload.cwd || process.cwd();

    // Find what version we need
    const desired = findDesiredVersion(cwd, owner, repo);

    if (!isRepoCloned(localPath)) {
      // Need to clone
      const success = await cloneRepo(owner, repo, localPath);
      if (!success) {
        // Clone failed, allow WebFetch to proceed
        console.error(`[local-repo-resolver] Could not clone ${owner}/${repo}, allowing WebFetch`);
        process.exit(0);
      }

      // If we have a specific revision, check it out
      if (desired?.rev) {
        await fetchAndCheckout(localPath, desired.rev);
      }
    } else {
      // Repo exists, check version
      if (desired?.rev) {
        const current = await getCurrentCommit(localPath);
        if (current && !current.startsWith(desired.rev) && !desired.rev.startsWith(current)) {
          // Different version, checkout the right one
          await fetchAndCheckout(localPath, desired.rev);
        }
      } else {
        // No specific version required, optionally update to latest
        await updateToLatest(localPath);
      }
    }

    // Block the WebFetch and redirect to local
    const versionNote = desired?.rev
      ? ` (${desired.source}: ${desired.rev.substring(0, 8)})`
      : desired?.source
        ? ` (${desired.source})`
        : "";

    console.error(`BLOCKED: Use local repository instead of WebFetch.

Repository: ${owner}/${repo}
Local path: ${localPath}${versionNote}

The repo has been cloned/updated locally. Read files directly:
  - Use Read tool: ${localPath}/path/to/file
  - Use Grep tool: pattern in ${localPath}
  - Use Glob tool: ${localPath}/**/*.go

Do NOT use WebFetch for this repository.`);

    // Exit code 2 = block the tool
    process.exit(2);
  } catch (error) {
    // Never crash - log error and allow the fetch
    console.error("[local-repo-resolver] Error:", error);
    process.exit(0);
  }
}

main();
