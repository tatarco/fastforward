// Merge fastforward settings.json into an existing one. Existing keys win; arrays union.
// usage: node merge-settings.mjs <kit-settings> <target-settings>
import { readFileSync, writeFileSync, existsSync, copyFileSync } from "node:fs";
const [kitPath, target] = process.argv.slice(2);
const kit = JSON.parse(readFileSync(kitPath, "utf8"));
const cur = existsSync(target) ? JSON.parse(readFileSync(target, "utf8")) : {};
const merge = (a, b) => {
  for (const [k, v] of Object.entries(b)) {
    if (Array.isArray(v)) a[k] = [...new Set([...(a[k] ?? []), ...v])];
    else if (v && typeof v === "object") a[k] = merge(a[k] ?? {}, v);
    else if (!(k in a)) a[k] = v;
  }
  return a;
};
if (existsSync(target)) copyFileSync(target, `${target}.bak-${Date.now()}`);
writeFileSync(target, JSON.stringify(merge(cur, kit), null, 2) + "\n");
console.log(`settings merged -> ${target}`);
