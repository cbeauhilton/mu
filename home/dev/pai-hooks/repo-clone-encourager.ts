#!/usr/bin/env bun
// $PAI_DIR/hooks/repo-clone-encourager.ts
// PreToolUse hook: Encourages cloning repos instead of repeated WebFetch

import { existsSync, readFileSync, writeFileSync, mkdirSync } from 'fs';
import { join, dirname } from 'path';

interface PreToolUsePayload {
  session_id: string;
  tool_name: string;
  tool_input: Record<string, any>;
}

interface RepoFetchState {
  repos: Record<string, {
    count: number;
    lastFetch: string;
    suggested: boolean;
  }>;
}

const REPOS_DIR = '/home/beau/src/.repos';
const STATE_FILE = join(REPOS_DIR, '.fetch-state.json');
const FETCH_THRESHOLD = 2; // Suggest clone after this many fetches

// GitHub URL patterns
const GITHUB_PATTERNS = [
  // Raw file URLs: raw.githubusercontent.com/owner/repo/ref/path
  /raw\.githubusercontent\.com\/([^\/]+\/[^\/]+)/,
  // API URLs: api.github.com/repos/owner/repo
  /api\.github\.com\/repos\/([^\/]+\/[^\/]+)/,
  // Regular URLs: github.com/owner/repo
  /github\.com\/([^\/]+\/[^\/]+)/,
];

function extractRepoFromUrl(url: string): string | null {
  for (const pattern of GITHUB_PATTERNS) {
    const match = url.match(pattern);
    if (match) {
      // Clean up the repo path (remove trailing paths, .git, etc)
      return match[1].replace(/\.git$/, '').split('/').slice(0, 2).join('/');
    }
  }
  return null;
}

function loadState(): RepoFetchState {
  try {
    if (existsSync(STATE_FILE)) {
      return JSON.parse(readFileSync(STATE_FILE, 'utf-8'));
    }
  } catch {
    // Ignore parse errors, start fresh
  }
  return { repos: {} };
}

function saveState(state: RepoFetchState): void {
  try {
    mkdirSync(dirname(STATE_FILE), { recursive: true });
    writeFileSync(STATE_FILE, JSON.stringify(state, null, 2));
  } catch (error) {
    console.error('[repo-clone-encourager] Failed to save state:', error);
  }
}

function getClonePath(repo: string): string {
  return join(REPOS_DIR, repo);
}

function isRepoCloned(repo: string): boolean {
  const clonePath = getClonePath(repo);
  return existsSync(join(clonePath, '.git'));
}

async function main() {
  try {
    const stdinData = await Bun.stdin.text();
    if (!stdinData.trim()) {
      process.exit(0);
    }

    const payload: PreToolUsePayload = JSON.parse(stdinData);

    // Only check WebFetch calls
    if (payload.tool_name !== 'WebFetch') {
      process.exit(0);
    }

    const url = payload.tool_input?.url;
    if (!url) {
      process.exit(0);
    }

    const repo = extractRepoFromUrl(url);
    if (!repo) {
      // Not a GitHub URL
      process.exit(0);
    }

    // Check if already cloned
    if (isRepoCloned(repo)) {
      const clonePath = getClonePath(repo);
      console.log(`<system-reminder>`);
      console.log(`This repo is already cloned at: ${clonePath}`);
      console.log(`Consider reading files directly from there instead of fetching over HTTPS.`);
      console.log(`</system-reminder>`);
      process.exit(0);
    }

    // Track fetch count
    const state = loadState();
    const now = new Date().toISOString();

    if (!state.repos[repo]) {
      state.repos[repo] = { count: 0, lastFetch: now, suggested: false };
    }

    state.repos[repo].count++;
    state.repos[repo].lastFetch = now;

    // Check if we should suggest cloning
    if (state.repos[repo].count >= FETCH_THRESHOLD && !state.repos[repo].suggested) {
      state.repos[repo].suggested = true;
      const clonePath = getClonePath(repo);

      console.log(`<system-reminder>`);
      console.log(`You've fetched from github.com/${repo} ${state.repos[repo].count} times.`);
      console.log(`Consider cloning it for faster access:`);
      console.log(`  git clone https://github.com/${repo}.git ${clonePath}`);
      console.log(`Then read files directly instead of repeated WebFetch calls.`);
      console.log(`</system-reminder>`);
    }

    saveState(state);

  } catch (error) {
    // Never crash - log error and continue
    console.error('[repo-clone-encourager] Error:', error);
  }

  process.exit(0);
}

main();
