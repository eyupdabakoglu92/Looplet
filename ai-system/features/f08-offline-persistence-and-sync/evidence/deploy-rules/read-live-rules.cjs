// F08-DEVOPS-RULES — read-only: prints the Firestore rules releases of a project
// and the source of the ruleset the `cloud.firestore` release points to.
// Uses the signed-in firebase-tools CLI's own library and session (no token is
// read, printed or stored by this script). Writes nothing to the project.
// Usage: node read-live-rules.cjs <projectId> [outFile]
const path = require("path");
const fs = require("fs");
const FT = "/opt/homebrew/lib/node_modules/firebase-tools/lib";
const { requireAuth } = require(path.join(FT, "requireAuth"));
const rules = require(path.join(FT, "gcp/rules"));
const auth = require(path.join(FT, "auth"));

(async () => {
  const projectId = process.argv[2];
  const outFile = process.argv[3];
  if (!projectId) throw new Error("usage: read-live-rules.cjs <projectId> [outFile]");
  // Same account selection the CLI does before a command (the signed-in
  // default account from the CLI's own store); nothing about it is printed.
  const account = auth.getGlobalDefaultAccount();
  if (!account) throw new Error("the firebase CLI is not signed in (run: firebase login)");
  await requireAuth({ project: projectId, user: account.user, tokens: account.tokens });
  const releases = await rules.listAllReleases(projectId);
  console.log(`releases (${releases.length}):`);
  for (const r of releases) console.log(`  ${r.name} -> ${r.rulesetName} (updated ${r.updateTime})`);
  const fsRelease = releases.find((r) => r.name.endsWith("/releases/cloud.firestore"));
  if (!fsRelease) { console.log("NO cloud.firestore release"); return; }
  const files = await rules.getRulesetContent(fsRelease.rulesetName);
  for (const f of files) {
    console.log(`--- ${fsRelease.rulesetName} :: ${f.name} ---`);
    console.log(f.content);
    if (outFile) fs.writeFileSync(outFile, f.content);
  }
})().catch((e) => { console.error("ERROR:", e.message); process.exit(1); });
