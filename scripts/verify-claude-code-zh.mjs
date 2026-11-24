#!/usr/bin/env node
// 校验 Claude Code 中文派生树的完整性。
// 用法: node scripts/verify-claude-code-zh.mjs
import { readdirSync, readFileSync, existsSync } from "node:fs";
import { join, resolve, dirname, relative } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const SRC = join(ROOT, "upstream/cursor-plugins/harness/pstack/claude-code");
const OUT = join(ROOT, "translations/claude-code-zh");
const MARK = "docs/harness/claude-code.md";

const walk = (d) =>
  readdirSync(d, { withFileTypes: true }).flatMap((e) => {
    const p = join(d, e.name);
    return e.isDirectory() ? walk(p) : [p];
  });

if (!existsSync(SRC)) { console.error(`缺少上游: ${SRC}`); process.exit(1); }
if (!existsSync(OUT)) { console.error(`缺少派生树: ${OUT}`); process.exit(1); }

let pass = 0, fail = 0;
const check = (name, ok, detail = "") => {
  if (ok) { pass++; console.log(`  PASS  ${name}${detail ? "  " + detail : ""}`); }
  else { fail++; console.log(`  FAIL  ${name}${detail ? "  " + detail : ""}`); }
};

// 1. 文件集合
const relSrc = (p) => p.slice(SRC.length + 1);
const relOut = (p) => p.slice(OUT.length + 1);
const A = walk(SRC).map(relSrc).sort();
const B = walk(OUT).map(relOut).sort();
const onlyA = A.filter((x) => !B.includes(x));
const onlyB = B.filter((x) => !A.includes(x));
check("文件集合与上游一一对应", onlyA.length === 0 && onlyB.length === 0,
  `${A.length} 文件`);
onlyA.slice(0, 5).forEach((x) => console.log(`          缺: ${x}`));
onlyB.slice(0, 5).forEach((x) => console.log(`          多: ${x}`));

// 2. 代码块逐字一致
let blocks = 0, blockBad = 0, blockDetail = "";
for (const f of walk(SRC).filter((x) => x.endsWith(".md"))) {
  const dst = join(OUT, relSrc(f));
  if (!existsSync(dst)) continue;
  const ub = readFileSync(f, "utf8").match(/^```[\s\S]*?^```/gm) || [];
  const zb = readFileSync(dst, "utf8").match(/^```[\s\S]*?^```/gm) || [];
  if (ub.length !== zb.length) {
    blockBad++; blockDetail = `${relSrc(f)} 块数 ${ub.length} vs ${zb.length}`; continue;
  }
  for (let i = 0; i < ub.length; i++) {
    blocks++;
    if (ub[i] !== zb[i]) { blockBad++; blockDetail = `${relSrc(f)} 第 ${i} 块`; }
  }
}
check("代码块逐字一致", blockBad === 0, `${blocks} 块${blockDetail ? " — " + blockDetail : ""}`);

// 3. 非 md 资源逐字节一致（plugin.json 的 description 被有意本地化，单独校验）
const LOCALIZED = new Set([".claude-plugin/plugin.json"]);
let res = 0, resBad = 0, locBad = 0;
for (const f of walk(SRC).filter((x) => !x.endsWith(".md"))) {
  const r = relSrc(f).split("\\").join("/");
  if (LOCALIZED.has(r)) continue;
  res++;
  const dst = join(OUT, relSrc(f));
  if (!existsSync(dst) || !readFileSync(f).equals(readFileSync(dst))) resBad++;
}
check("非 md 资源逐字节一致", resBad === 0, `${res} 个`);

// 3b. plugin.json：除 description 外须与上游一致，且 description 已中文化
{
  const up = JSON.parse(readFileSync(join(SRC, ".claude-plugin/plugin.json"), "utf8"));
  const dst = join(OUT, ".claude-plugin/plugin.json");
  if (!existsSync(dst)) { locBad++; }
  else {
    const zh = JSON.parse(readFileSync(dst, "utf8"));
    for (const k of ["name", "version", "homepage", "repository", "license"]) {
      if (up[k] !== zh[k]) locBad++;
    }
    if (up.author?.name !== zh.author?.name) locBad++;
    if ((up.keywords || []).join(",") !== (zh.keywords || []).join(",")) locBad++;
    if (typeof zh.description !== "string" || !/[\u4e00-\u9fff]/.test(zh.description)) locBad++;
  }
  check("plugin.json 契约保留且描述中文化", locBad === 0);
}

// 4. adapter 段落覆盖
let upHas = 0, outHas = 0;
for (const f of walk(SRC).filter((x) => x.endsWith(".md"))) {
  if (!readFileSync(f, "utf8").includes(MARK)) continue;
  upHas++;
  const dst = join(OUT, relSrc(f));
  if (existsSync(dst) && readFileSync(dst, "utf8").includes(MARK)) outHas++;
}
check("adapter 段落覆盖", upHas === outHas, `${outHas}/${upHas}`);

// 5. 中文覆盖
const mds = walk(OUT).filter((x) => x.endsWith(".md"));
const zh = mds.filter((f) => /[\u4e00-\u9fff]/.test(readFileSync(f, "utf8"))).length;
check("中文译文覆盖", zh > 0, `${zh} 篇中文 + ${mds.length - zh} 篇英文（语料）`);

// 6. frontmatter
let fmOk = 0, fmBad = 0;
const skillsDir = join(OUT, "skills");
for (const d of readdirSync(skillsDir)) {
  const p = join(skillsDir, d, "SKILL.md");
  if (!existsSync(p)) { fmBad++; continue; }
  const t = readFileSync(p, "utf8");
  const m = t.match(/^---\r?\n([\s\S]*?)\r?\n---/);
  if (!m || !/^name:\s*\S+/m.test(m[1]) || !/^description:/m.test(m[1])) fmBad++;
  else if (m[1].match(/^name:\s*(\S+)/m)[1] !== d) fmBad++;
  else fmOk++;
}
check("SKILL.md frontmatter 正确", fmBad === 0, `${fmOk} 个`);

// 7. 编码
let encBad = 0;
for (const f of walk(OUT)) {
  const buf = readFileSync(f);
  if (buf[0] === 0xef && buf[1] === 0xbb && buf[2] === 0xbf) encBad++;
  else if (f.endsWith(".md") && buf.includes(0x0d)) encBad++;
}
check("UTF-8 无 BOM、LF 换行", encBad === 0);

// 8. 相对链接（占位模板除外）
let links = 0; const broken = [];
for (const f of walk(OUT).filter((x) => x.endsWith(".md"))) {
  const t = readFileSync(f, "utf8");
  for (const m of t.matchAll(/\]\(<?([^)\s>]+)>?(?:\s+"[^"]*")?\)/g)) {
    const href = m[1];
    if (/^[a-z][a-z0-9+.-]*:/i.test(href) || href.startsWith("#")) continue;
    const target = href.split("#")[0];
    if (!target || target === "url") continue;
    links++;
    if (!existsSync(resolve(dirname(f), target))) broken.push(`${relOut(f)} -> ${href}`);
  }
}
check("相对链接可达", broken.length === 0, `${links} 个`);
broken.slice(0, 10).forEach((x) => console.log(`          断链: ${x}`));

console.log(`\n汇总: ${pass} PASS / ${fail} FAIL`);
process.exit(fail ? 1 : 0);