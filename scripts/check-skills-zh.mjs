#!/usr/bin/env node

// Verifies that translations/skills-zh mirrors the structure of upstream/cursor-plugins/pstack
// and that every translation keeps the literals the tooling depends on.
//
// Run from the repository root:
//   node scripts/check-skills-zh.mjs
//
// Exits 1 on any violation, so it can gate a PR.

import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import { dirname, join, posix, relative } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const UPSTREAM = join(ROOT, "upstream", "cursor-plugins", "pstack");
const ZH = join(ROOT, "translations", "skills-zh");

const problems = [];
const fail = (message) => problems.push(message);

function walk(dir) {
  if (!existsSync(dir)) return [];
  return readdirSync(dir).flatMap((name) => {
    const path = join(dir, name);
    return statSync(path).isDirectory() ? walk(path) : [path];
  });
}

// Literals that must survive translation byte for byte.
const MODEL_ID = /\b(?:claude-[a-z]+-\d[\w.-]*|grok-\d[\w.-]*|gpt-\d[\w.-]*)/g;
const SLASH = /(?<=^|[\s`(|\"'>])\/(?:pstack:)?([a-z][a-z0-9-]*)(?![\\w/<-])/gm;
const TOOL_TERMS = [
  "`Task`",
  "AskQuestion",
  "readonly: true",
  'environment: "cloud"',
  "run_in_background",
  "file_attachments",
  "`resume`",
];

function frontmatter(text) {
  return text.match(/^---\n([\s\S]*?)\n---/)?.[1] ?? "";
}

// 1. Every upstream SKILL.md and doc must have a translated counterpart, and vice versa.
const sourceFiles = walk(UPSTREAM)
  .filter((path) => path.endsWith(".md"))
  .map((path) => relative(UPSTREAM, path).split("\\").join("/"))
  .filter((path) => !path.startsWith("docs/guide/") && path !== "README.md");

const zhFiles = walk(ZH)
  .filter((path) => path.endsWith(".md"))
  .map((path) => relative(ZH, path).split("\\").join("/"))
  .filter((path) => path !== "_术语表.md");

const missing = sourceFiles.filter((path) => !zhFiles.includes(path));
const orphan = zhFiles.filter((path) => !sourceFiles.includes(path));

for (const path of missing) fail(`missing translation: translations/skills-zh/${path}`);
for (const path of orphan) fail(`translation has no upstream source: translations/skills-zh/${path}`);

// 2. Frontmatter name must equal the folder name, or the harness generator aborts.
for (const path of zhFiles) {
  const full = join(ZH, path);
  const text = readFileSync(full, "utf8");
  const folder = posix.basename(posix.dirname(path));
  const declared = frontmatter(text).match(/^name:(.*)$/m)?.[1]?.trim().replace(/^([\"'])(.*)\1$/, "$2");
  if (path.endsWith("SKILL.md") && declared !== folder) {
    fail(`${path}: frontmatter name is ${JSON.stringify(declared ?? "")}, expected ${folder}`);
  }
  if (!/^---\n[\s\S]*?\n---\n/.test(text)) fail(`${path}: missing or malformed frontmatter`);

  // 3. Model IDs and tool literals must appear exactly as upstream.
  const source = join(UPSTREAM, path);
  if (!existsSync(source)) continue;
  const upstreamText = readFileSync(source, "utf8");

  const upstreamModels = new Set(upstreamText.match(MODEL_ID) ?? []);
  for (const id of upstreamModels) {
    if (!text.includes(id)) fail(`${path}: model id dropped or altered: ${id}`);
  }

  const upstreamSlashes = new Set([...upstreamText.matchAll(SLASH)].map((m) => m[1]));
  for (const name of upstreamSlashes) {
    if (!text.includes(`/${name}`)) fail(`${path}: slash command dropped or translated: /${name}`);
  }

  for (const term of TOOL_TERMS) {
    if (upstreamText.includes(term) && !text.includes(term)) fail(`${path}: tool literal dropped or altered: ${term}`);
  }

  // 4. Code fences must be preserved one for one.
  const fences = (s) => (s.match(/^\s*(```|~~~)/gm) ?? []).length;
  if (fences(text) !== fences(upstreamText)) {
    fail(`${path}: code fence count ${fences(text)} does not match upstream ${fences(upstreamText)}`);
  }

  // 5. Relative links must still resolve inside the translated tree.
  for (const { 1: href } of text.matchAll(/\]\(<?([^)\s>]+)>?(?:\s+"[^"]*")?\)/g)) {
    if (/^[a-z][a-z0-9+.-]*:/i.test(href)) continue;
    const target = href.split("#")[0];
    if (!target) continue;
    const resolved = posix.normalize(posix.join(posix.dirname(path), target)).replace(/\/$/, "");
    if (!existsSync(join(ZH, resolved)) && !existsSync(join(UPSTREAM, resolved))) {
      fail(`${path}: link ${href} resolves to nothing in either tree`);
    }
  }

  // 6. Chapter titles should keep the English original for lookup.
  const h1 = text.match(/^# (.+)$/m)?.[1] ?? "";
  if (path.startsWith("principle-") && !/[A-Za-z]/.test(h1)) {
    fail(`${path}: H1 "${h1}" drops the English original required by the glossary`);
  }
}

console.log(`upstream: ${sourceFiles.length} files, translations: ${zhFiles.length} files`);
for (const problem of problems) console.log(`FAIL ${problem}`);
console.log(`${problems.length} problems`);
if (problems.length > 0) process.exit(1);
