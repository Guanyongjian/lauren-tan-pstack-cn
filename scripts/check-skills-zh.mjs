#!/usr/bin/env node

// Verifies that translations/skills-zh mirrors the structure of upstream/cursor-plugins/pstack
// and that every translation keeps the literals the tooling depends on.
//
// Run from the repository root:
//   node scripts/check-skills-zh.mjs
//
// Exits 1 on any violation, so it can gate a PR.
//
// Two path mappings matter here:
//   1. Upstream keeps "skills/<name>/SKILL.md" while the zh tree drops the leading "skills/".
//      Without this, every translation looks like an orphan AND every per-file literal check
//      is skipped by the `existsSync` guard, so the script passes no matter what it contains.
//   2. Links between translated skills use the zh layout ("../<name>/SKILL.md"). A partial
//      translation batch legitimately points at a skill that is not translated yet, so the
//      target is allowed to resolve to the upstream source as well.

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

const fences = (s) => (s.match(/^\s*(```|~~~)/gm) ?? []).length;

// Upstream keeps "skills/<name>/SKILL.md"; the zh tree drops the leading "skills/".
const zhPathOf = (upstreamRel) => upstreamRel.replace(/^skills\//, "");
const upstreamPathOf = (zhRel) =>
  existsSync(join(UPSTREAM, "skills", zhRel)) ? `skills/${zhRel}` : zhRel;

// Test-corpus fixtures are captured expected output, not documentation. Translating one would
// change what the fixture asserts, so they are excluded from the coverage check.
// Keep this pattern narrow: it must match only statechart's captured report fixtures.
const TEST_CORPUS_FIXTURE = /^skills\/statechart\/scripts\/test\/corpus\/[^/]+\/report\.md$/;
// 1. Every upstream doc must have a translated counterpart, and vice versa.
const upstreamDocs = walk(UPSTREAM)
  .filter((path) => path.endsWith(".md"))
  .map((path) => relative(UPSTREAM, path).split("\\").join("/"))
  .filter((path) => !path.startsWith("docs/guide/") && path !== "README.md");

const skippedFixtures = upstreamDocs.filter((path) => TEST_CORPUS_FIXTURE.test(path));
const sourceFiles = upstreamDocs.filter((path) => !TEST_CORPUS_FIXTURE.test(path));

const zhFiles = walk(ZH)
  .filter((path) => path.endsWith(".md"))
  .map((path) => relative(ZH, path).split("\\").join("/"))
  .filter((path) => path !== "_术语表.md");

const expectedZh = sourceFiles.map(zhPathOf);
for (const path of expectedZh) {
  if (!zhFiles.includes(path)) fail(`missing translation: translations/skills-zh/${path}`);
}
for (const path of zhFiles) {
  if (!expectedZh.includes(path)) fail(`translation has no upstream source: translations/skills-zh/${path}`);
}

for (const path of zhFiles) {
  const text = readFileSync(join(ZH, path), "utf8");
  const folder = posix.basename(posix.dirname(path));

  // 2. Frontmatter name must equal the folder name, or the harness generator aborts.
  const declared = frontmatter(text).match(/^name:(.*)$/m)?.[1]?.trim().replace(/^(["'])(.*)\1$/, "$2");
  if (path.endsWith("SKILL.md") && declared !== folder) {
    fail(`${path}: frontmatter name is ${JSON.stringify(declared ?? "")}, expected ${folder}`);
  }
  // Only a SKILL.md registers as a skill, so only it needs frontmatter. Playbooks and reference
  // files are plain Markdown upstream and carry none.
  if (path.endsWith("SKILL.md") && !/^---\n[\s\S]*?\n---\n/.test(text)) {
    fail(`${path}: missing or malformed frontmatter`);
  }

  // 3. Model IDs, slash commands, tool literals, and code fences must match upstream.
  //    A missing source is already reported by the set comparison above; never skip silently.
  const source = join(UPSTREAM, upstreamPathOf(path));
  if (!existsSync(source)) continue;
  const upstreamText = readFileSync(source, "utf8");

  for (const id of new Set(upstreamText.match(MODEL_ID) ?? [])) {
    if (!text.includes(id)) fail(`${path}: model id dropped or altered: ${id}`);
  }

  for (const name of new Set([...upstreamText.matchAll(SLASH)].map((m) => m[1]))) {
    if (!text.includes(`/${name}`)) fail(`${path}: slash command dropped or translated: /${name}`);
  }

  for (const term of TOOL_TERMS) {
    if (upstreamText.includes(term) && !text.includes(term)) {
      fail(`${path}: tool literal dropped or altered: ${term}`);
    }
  }

  if (fences(text) !== fences(upstreamText)) {
    fail(`${path}: code fence count ${fences(text)} != upstream ${fences(upstreamText)}`);
  }

  // 4. Relative links must resolve to a translated file or, while the batch is partial,
  //    to the upstream source. Resolving to nothing at all is still a failure.
  for (const { 1: href } of text.matchAll(/\]\(<?([^)\s>]+)>?(?:\s+"[^"]*")?\)/g)) {
    if (/^[a-z][a-z0-9+.-]*:/i.test(href)) continue;
    // Prompt templates show example output, so a sample link such as `[PR #123](url)` is a
    // placeholder rather than a file reference. Skip an unfilled `{...}` or the bare example token.
    if (href === "url" || href.includes("{")) continue;
    const target = href.split("#")[0];
    if (!target) continue;
    const goal = (s) => posix.normalize(posix.join(posix.dirname(path), s)).replace(/\/$/, "");
    const candidates = [goal(target), goal(target.replace(/^(\.\.\/)+/, ""))];
    const found = candidates.some(
      (rel) => existsSync(join(ZH, rel)) || existsSync(join(UPSTREAM, "skills", rel)) || existsSync(join(UPSTREAM, rel)),
    );
    if (!found) fail(`${path}: link ${href} resolves to nothing in either tree`);
  }

  // 5. Chapter titles keep the English original for lookup.
  const h1 = text.match(/^# (.+)$/m)?.[1] ?? "";
  if (path.startsWith("principle-") && !/[A-Za-z]/.test(h1)) {
    fail(`${path}: H1 "${h1}" drops the English original required by the glossary`);
  }
}

console.log(`upstream: ${sourceFiles.length} files (${skippedFixtures.length} test-corpus fixtures skipped), translations: ${zhFiles.length} files`);
for (const problem of problems) console.log(`FAIL ${problem}`);
console.log(`${problems.length} problems`);
if (problems.length > 0) process.exit(1);
