import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, mkdirSync, readFileSync, writeFileSync, rmSync, existsSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';
import { roles, document, parseFeature, validateFeature, resolveFeature, resolveTasks, handoff,
  qaTransition, releaseTransition, resolveDecision, audit } from '../workflow-flow-audit.mjs';

const core = fileURLToPath(new URL('../../', import.meta.url));
const wrapper = join(core, 'tools/workflow-state-audit.sh');
const row = (id = 'sample.1', role = 'Content Designer', status = 'Open', depends = '-') =>
  '- [' + (['Done', 'Cancelled'].includes(status) ? 'x' : ' ') + '] Task ID: ' + id +
  ' | Assigned Role: ' + role + ' | Status: ' + status + ' | Summary: Generic delivery | Depends On: ' + depends;

function sourceFor(overrides = {}) {
  const fields = {
    'Feature ID': 'sample', 'Current Status': 'In Progress', 'Current Owner': 'Content Designer',
    'Next Role': 'Content Designer', 'Active Task Ledger': row(), 'Open Tasks': 'None',
    'Handoff Plan': 'None', 'Delivery Review': 'Pending', 'QA Scope': 'content-only',
    'QA Stage': 'none', 'QA Result': 'None', 'Release Scope': 'none', 'Release Result': 'None',
    'Pending Evidence': 'None', 'Open Decision Gates': 'None', Blockers: 'None',
    'Next Action': 'Deliver the assigned task.', ...overrides,
  };
  return '# Generic feature\n\n' + Object.entries(fields).map(([key, value]) => '## ' + key + '\n\n' + value).join('\n\n---\n\n') + '\n';
}
const feature = overrides => parseFeature(sourceFor(overrides));
const terminalFields = {
  'Current Status': 'Done', 'Current Owner': '-', 'Next Role': '-', 'Active Task Ledger': 'None',
  'Delivery Review': 'Accepted', 'QA Stage': 'final', 'QA Result': 'Approved', 'Next Action': '-',
};
const qaFields = {
  'Current Status': 'In QA', 'Current Owner': 'QA', 'Next Role': 'QA', 'Active Task Ledger': row('sample.qa', 'QA'),
  'Delivery Review': 'Accepted', 'QA Stage': 'functional', 'Release Scope': 'staging',
};
const qaPlanFields = {
  'QA Modules': 'core, content', 'Regression Depth': 'impacted', 'Evidence Reuse': 'not-applicable',
};
const visualFields = {
  'Visual Scope': 'new-surface',
  'Design Foundation': 'ai-system/project-authority/design-foundation.md',
  'Visual Quality Gate': 'Ready for Implementation',
  'Visual Evidence': 'ui-design.md',
};
function fixture(t, sources = [sourceFor()]) {
  const root = mkdtempSync(join(tmpdir(), 'workflow-flow-test-'));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  const parsed = sources.map(parseFeature);
  sources.forEach((source, i) => {
    const dir = join(root, 'features', 'item-' + i);
    mkdirSync(dir, { recursive: true }); writeFileSync(join(dir, 'orchestration.md'), source);
  });
  const selected = parsed.find(f => !['Done', 'Closed'].includes(f.status));
  const id = selected?.id ?? '-', owner = selected?.owner ?? '-';
  const board = '# Feature Board\nActive Feature: ' + id + '\nActive Owner: ' + owner +
    '\nPending Product Revision: None\nRevision Affected Features: None\n\n## Status Table\n' +
    '| ID | Feature | Status | Owner |\n| --- | --- | --- | --- |\n' +
    parsed.map(f => '| ' + f.id + ' | Generic | ' + f.status + ' | ' + f.owner + ' |').join('\n') + '\n';
  writeFileSync(join(root, 'feature-board.md'), board);
  writeFileSync(join(root, 'system-state.md'), '# System State\n## Active Feature\n' + id + '\n## Current Role\n' + owner + '\n');
  return root;
}
function writeVisualArtifacts(root, { runtime = false, score = null, lowest = 8, motion = false } = {}) {
  mkdirSync(join(root, 'project-authority'), { recursive: true });
  writeFileSync(join(root, 'project-authority', 'design-foundation.md'),
    '# Project Design Foundation\n\n> Status: Selected\n\nSelected By: Product Owner\n');
  const featureDir = join(root, 'features', 'item-0');
  writeFileSync(join(featureDir, 'ui-design.md'), '# UI Design\n\n## Visual Evidence Manifest\n\n' +
    '| Evidence ID | Kind | Artifact |\n| --- | --- | --- |\n' +
    '| sample.UI-A | direction-render | visuals/a.png |\n' +
    '| sample.UI-B | direction-render | visuals/b.png |\n' +
    (motion ? '| sample.UI-M | motion-prototype | visuals/motion.mp4 |\n' : ''));
  if (runtime) writeFileSync(join(featureDir, 'frontend.md'), '# Delivery\n\n## Visual Parity Evidence\n\n' +
    '| Evidence ID | Kind | Artifact |\n| --- | --- | --- |\n' +
    '| sample.FE-1 | runtime-screenshot | captures/runtime.png |\n' +
    (motion ? '| sample.FE-2 | runtime-video | captures/runtime.mp4 |\n' : ''));
  if (score !== null) writeFileSync(join(featureDir, 'qa.md'), '# QA\n\n## Visual Quality Verdict\n\n' +
    'Final Score: ' + score + ' / 100\n\nLowest Dimension: Typography — ' + lowest + ' / 10\n\n' +
    'Fail Conditions: None\n\nRuntime Evidence Complete: Yes\n\nResult: PASS\n');
}
const errorsFor = fields => validateFeature(feature(fields));
const plan = (role = 'Frontend/Mobile Developer') =>
  '| After Tasks | Next Role | Activate Tasks |\n| --- | --- | --- |\n| sample.1 | ' + role + ' | sample.2 |';

test('valid active and reviewed terminal fixtures pass the full audit', t => {
  assert.deepEqual(audit(fixture(t)).errors, []);
  assert.deepEqual(audit(fixture(t, [sourceFor(terminalFields)])).errors, []);
});
test('legacy orchestration without visual fields remains compatible', t => {
  const root = fixture(t);
  assert.equal(feature().visualDeclared, false);
  assert.deepEqual(audit(root).errors, []);
});
test('declared QA plan validates modules, depth and evidence reuse without breaking legacy files', () => {
  assert.deepEqual(errorsFor({ ...qaFields, ...qaPlanFields }), []);
  assert.match(errorsFor({ ...qaFields, ...qaPlanFields, 'QA Modules': 'core' }).join('\n'), /content module/);
  assert.match(errorsFor({ ...qaFields, ...qaPlanFields, 'Regression Depth': 'not-set' }).join('\n'), /Regression Depth/);
  assert.match(errorsFor({ ...qaFields, ...qaPlanFields, 'Evidence Reuse': 'not-evaluated' }).join('\n'), /Evidence Reuse/);
});
test('final release QA plan requires full coverage and release module', () => {
  const errors = errorsFor({ ...qaFields, ...qaPlanFields, 'QA Stage': 'final', 'QA Result': 'None',
    'Release Result': 'Release Ready', 'Regression Depth': 'impacted' }).join('\n');
  assert.match(errors, /full regression coverage/);
  assert.match(errors, /release module/);
  assert.deepEqual(errorsFor({ ...qaFields, ...qaPlanFields, 'QA Stage': 'final', 'QA Result': 'None',
    'Release Result': 'Release Ready', 'Regression Depth': 'full', 'QA Modules': 'core, content, release' }), []);
});
test('visual gate cannot claim implementation readiness without foundation and rendered evidence', t => {
  const root = fixture(t, [sourceFor(visualFields)]);
  assert.match(audit(root).errors.join('\n'), /Design Foundation file missing/);
  assert.match(audit(root).errors.join('\n'), /ui-design\.md/);
});
test('selected foundation plus two real directions permits implementation readiness', t => {
  const root = fixture(t, [sourceFor(visualFields)]);
  writeVisualArtifacts(root);
  assert.deepEqual(audit(root).errors, []);
});
test('visual QA requires runtime parity evidence and Ready for QA gate', t => {
  const source = sourceFor({ ...qaFields, ...visualFields, 'Visual Quality Gate': 'Ready for QA',
    'Visual Evidence': 'ui-design.md, frontend.md' });
  const root = fixture(t, [source]);
  writeVisualArtifacts(root);
  assert.match(audit(root).errors.join('\n'), /runtime-screenshot/);
  writeVisualArtifacts(root, { runtime: true });
  assert.deepEqual(audit(root).errors, []);
  assert.match(errorsFor({ ...qaFields, ...visualFields }).join('\n'), /Ready for QA/);
});
test('terminal visual gate requires independent 93+ QA verdict and dimension floor', t => {
  const fields = { ...terminalFields, ...visualFields, 'Visual Quality Gate': 'Passed',
    'Visual Evidence': 'ui-design.md, frontend.md, qa.md' };
  const root = fixture(t, [sourceFor(fields)]);
  writeVisualArtifacts(root, { runtime: true, score: 92 });
  assert.match(audit(root).errors.join('\n'), /Final Score >= 93/);
  writeVisualArtifacts(root, { runtime: true, score: 93, lowest: 8 });
  assert.deepEqual(audit(root).errors, []);
});
test('motion-critical scope requires prototype and runtime video evidence', t => {
  const fields = { ...qaFields, ...visualFields, 'Visual Scope': 'motion-critical',
    'Visual Quality Gate': 'Ready for QA', 'Visual Evidence': 'ui-design.md, frontend.md' };
  const root = fixture(t, [sourceFor(fields)]);
  writeVisualArtifacts(root, { runtime: true });
  assert.match(audit(root).errors.join('\n'), /motion-prototype/);
  assert.match(audit(root).errors.join('\n'), /runtime-video/);
  writeVisualArtifacts(root, { runtime: true, motion: true });
  assert.deepEqual(audit(root).errors, []);
});
test('main shell entry point runs semantic checks by default', t => {
  const root = fixture(t, [sourceFor({ 'Active Task Ledger': 'None' })]);
  const full = spawnSync('sh', [wrapper, root], { encoding: 'utf8' });
  assert.equal(full.status, 2); assert.match(full.stderr, /no actionable task/);
  assert.equal(spawnSync('sh', [wrapper, root, '--structure-only']).status, 0);
});
test('counterexample: owner/task mismatch is rejected', t => {
  const root = fixture(t, [sourceFor({ 'Active Task Ledger': row('sample.1', 'Backend Developer') })]);
  assert.match(audit(root).errors.join('\n'), /active task\/owner mismatch/);
});
test('counterexample: empty ledger cannot activate a delivery owner', t => {
  assert.match(audit(fixture(t, [sourceFor({ 'Active Task Ledger': 'None' })])).errors.join('\n'), /no actionable task/);
});
test('counterexample: Done with unchecked inventory fails', t => {
  const root = fixture(t, [sourceFor({ ...terminalFields, 'Open Tasks': '### QA\n- [ ] Required check' })]);
  assert.match(audit(root).errors.join('\n'), /unchecked Open Tasks/);
});
for (const result of ['PENDING', 'FAIL']) test('counterexample: Done with ' + result + ' evidence fails', t => {
  const root = fixture(t, [sourceFor({ ...terminalFields, 'Pending Evidence': '- Evidence ID: sample.E1\n  * Result: ' + result })]);
  assert.match(audit(root).errors.join('\n'), /PENDING\/FAIL evidence/);
});
test('counterexample: Done with an open decision fails', t => {
  const root = fixture(t, [sourceFor({ ...terminalFields, 'Open Decision Gates': '- Decision ID: sample.D1\n  * Status: OPEN' })]);
  assert.match(audit(root).errors.join('\n'), /open decision/);
});
test('counterexample: multiple active QA owners fail even with global active selection', t => {
  const root = fixture(t, [sourceFor(qaFields), sourceFor({ ...qaFields, 'Feature ID': 'second' })]);
  assert.match(audit(root).errors.join('\n'), /multiple executable features assigned to QA/);
});
test('counterexample: global/local status conflict fails full audit', t => {
  const root = fixture(t), path = join(root, 'feature-board.md');
  writeFileSync(path, readFileSync(path, 'utf8').replace('| In Progress |', '| Done |'));
  assert.match(audit(root).errors.join('\n'), /board\/header/);
  assert.deepEqual(audit(root, { local: true }).errors, []);
});
test('counterexample: active global feature without orchestration fails', t => {
  const root = fixture(t);
  rmSync(join(root, 'features', 'item-0', 'orchestration.md'));
  assert.match(audit(root).errors.join('\n'), /no orchestration/);
});
test('local mode does not waive task, decision, or closure checks', t => {
  const root = fixture(t, [sourceFor({ 'Active Task Ledger': 'None' })]);
  assert.match(audit(root, { local: true }).errors.join('\n'), /no actionable task/);
});
test('present-but-empty ledger never falls back to stale inventory', () => {
  const f = feature({ 'Active Task Ledger': 'None' }); f.fallbackTasks = feature().tasks;
  assert.throws(() => resolveTasks(f, f.owner), /no actionable/);
  f.tasks = null;
  assert.equal(resolveTasks(f, f.owner).length, 1);
});
test('multiple same-role tasks keep document order', () => {
  const f = feature({ 'Active Task Ledger': row('sample.2') + '\n' + row('sample.1') });
  assert.deepEqual(resolveTasks(f, f.owner).map(t => t.id), ['sample.2', 'sample.1']);
});
test('dependency must be completed before an open task executes', () => {
  const f = feature({ 'Active Task Ledger': row('sample.1') + '\n' + row('sample.2', 'Content Designer', 'Open', 'sample.1') });
  assert.throws(() => resolveTasks(f, f.owner), /unfinished/);
});
test('unknown and cyclic dependencies fail validation', () => {
  assert.match(errorsFor({ 'Active Task Ledger': row('sample.1', 'Content Designer', 'Open', 'missing') }).join('\n'), /unknown task dependency/);
  assert.match(errorsFor({ 'Active Task Ledger': row('sample.1', 'Content Designer', 'Queued', 'sample.2') + '\n' +
    row('sample.2', 'Content Designer', 'Queued', 'sample.1') }).join('\n'), /cyclic/);
});
test('a finished role cannot self-route from its old Next Role', () => {
  const f = feature({ 'Active Task Ledger': row('sample.1', 'Content Designer', 'Done') });
  assert.equal(f.next, 'Content Designer');
  assert.deepEqual(handoff(f, 'Content Designer'), { role: 'Tech Lead', activate: [] });
});
test('an explicit developer handoff activates only planned tasks', () => {
  const f = feature({ 'Active Task Ledger': row('sample.1', 'Content Designer', 'Done') + '\n' +
    row('sample.2', 'Frontend/Mobile Developer', 'Queued', 'sample.1'), 'Handoff Plan': plan() });
  assert.deepEqual(handoff(f, 'Content Designer'), { role: 'Frontend/Mobile Developer', activate: ['sample.2'] });
});
test('QA target in a plan still requires Tech Lead review', () => {
  const f = feature({ 'Active Task Ledger': row('sample.1', 'Content Designer', 'Done') + '\n' +
    row('sample.2', 'QA', 'Queued', 'sample.1'), 'Handoff Plan': plan('QA') });
  assert.equal(handoff(f, 'Content Designer').role, 'Tech Lead');
});
test('ambiguous handoff rows return to Tech Lead', () => {
  const f = feature({ 'Active Task Ledger': row('sample.1', 'Content Designer', 'Done') + '\n' +
    row('sample.2', 'Frontend/Mobile Developer', 'Queued'), 'Handoff Plan': plan() + '\n| sample.1 | Frontend/Mobile Developer | sample.2 |' });
  assert.equal(handoff(f, f.owner).role, 'Tech Lead');
});
for (const role of ['Technical Analyst', 'QA', 'Project Setup', 'DevOps/Release Engineer']) test(role + ' completion has a mandatory Tech Lead checkpoint', () => {
  const f = feature({ 'Current Owner': role, 'Next Role': role, 'Active Task Ledger': row('sample.1', role, 'Done') });
  assert.equal(handoff(f, role).role, 'Tech Lead');
});
test('unfinished same-role tasks keep the owner, but blockers require Tech Lead', () => {
  const f = feature(); assert.equal(handoff(f, f.owner).role, f.owner);
  f.blockers = true; assert.equal(handoff(f, f.owner).role, 'Tech Lead');
});
test('QA cannot run before accepted delivery review', () => {
  assert.match(errorsFor({ ...qaFields, 'Delivery Review': 'Pending' }).join('\n'), /QA requires Tech Lead/);
});
test('functional QA does not require future release readiness', () => {
  assert.deepEqual(errorsFor(qaFields), []);
  assert.equal(qaTransition({ result: 'Functional Approved', stage: 'functional', releaseScope: 'staging' }), 'release');
});
test('release readiness leads to final QA, not closure', () => {
  for (const result of ['Release Ready', 'Release Ready with Notes']) assert.equal(releaseTransition(result), 'qa-final');
  assert.match(errorsFor({ ...qaFields, 'QA Stage': 'final' }).join('\n'), /final QA requires release/);
  assert.deepEqual(errorsFor({ ...qaFields, 'QA Stage': 'final', 'Release Result': 'Release Ready' }), []);
});
test('functional approval cannot close a feature', () => {
  assert.throws(() => qaTransition({ result: 'Approved', stage: 'functional', releaseScope: 'staging' }), /final QA stage/);
  assert.match(errorsFor({ ...terminalFields, 'QA Stage': 'functional', 'QA Result': 'Functional Approved', 'Release Scope': 'staging', 'Release Result': 'Release Ready' }).join('\n'), /final QA approval/);
});
test('QA verdicts distinguish defect, decision, and evidence recovery', () => {
  const request = { stage: 'final', releaseScope: 'none' };
  assert.equal(qaTransition({ ...request, result: 'Rejected' }), 'rework');
  assert.equal(qaTransition({ ...request, result: 'Decision Pending' }), 'decision');
  assert.equal(qaTransition({ ...request, result: 'Runtime Validation Pending' }), 'evidence-then-same-qa-stage');
  assert.equal(qaTransition({ ...request, result: 'Approved' }), 'closure-review');
});
test('Blocked retains tasks and resolves a decision without delivery gating', () => {
  const f = feature({ 'Current Status': 'Blocked', 'Current Owner': 'Tech Lead', 'Next Role': 'Tech Lead',
    'Open Decision Gates': '- Decision ID: sample.D1\n  * Status: OPEN' });
  assert.deepEqual(validateFeature(f), []);
  assert.equal(resolveDecision([f], 'sample.D1').feature, f);
  assert.equal(resolveFeature([f], 'Tech Lead'), null);
  assert.throws(() => resolveFeature([f], 'Content Designer'), /exactly one/);
});
test('duplicate or already resolved decision IDs do not execute again', () => {
  const f = feature({ 'Open Decision Gates': '- Decision ID: sample.D1\n  * Status: OPEN' });
  assert.throws(() => resolveDecision([f, f], 'sample.D1'), /exact OPEN/);
  f.decisions[0].Status = 'RESOLVED';
  assert.throws(() => resolveDecision([f], 'sample.D1'), /exact OPEN/);
});
test('revision blocks affected delivery and completed acceptance until resync', t => {
  for (const body of [sourceFor(), sourceFor(terminalFields)]) {
    const root = fixture(t, [body]), path = join(root, 'feature-board.md');
    writeFileSync(path, readFileSync(path, 'utf8').replace('Pending Product Revision: None', 'Pending Product Revision: revision-1')
      .replace('Revision Affected Features: None', 'Revision Affected Features: sample'));
    assert.match(audit(root).errors.join('\n'), /pending revision/);
  }
});
test('revision does not block an unrelated feature', t => {
  const root = fixture(t), path = join(root, 'feature-board.md');
  writeFileSync(path, readFileSync(path, 'utf8').replace('Pending Product Revision: None', 'Pending Product Revision: revision-1')
    .replace('Revision Affected Features: None', 'Revision Affected Features: other'));
  assert.deepEqual(audit(root).errors, []);
});
test('malformed evidence cannot hide missing validation', () => {
  assert.match(errorsFor({ 'Pending Evidence': '- Evidence ID: sample.E1\n  * Result: almost-pass' }).join('\n'), /invalid Evidence ID Result/);
});
test('duplicate fields, task IDs, and checkbox/status mismatches fail', () => {
  assert.match(validateFeature(parseFeature(sourceFor() + '\n## Current Owner\nQA\n')).join('\n'), /duplicate section/);
  assert.match(errorsFor({ 'Active Task Ledger': row() + '\n' + row() }).join('\n'), /duplicate\/empty Task ID/);
  assert.match(errorsFor({ 'Active Task Ledger': row().replace('[ ]', '[x]') }).join('\n'), /checkbox\/status/);
});
test('fenced examples and archived inventory do not become live tasks', () => {
  const fence = String.fromCharCode(96).repeat(3);
  const body = sourceFor(terminalFields) + '\n' + fence + 'md\n## Current Owner\nQA\n' + fence + '\n';
  assert.deepEqual(validateFeature(parseFeature(body)), []);
  assert.deepEqual(errorsFor({ ...terminalFields, 'Open Tasks': '### Archived Reference\n- [ ] Historical example' }), []);
});
test('an unclosed fence cannot conceal terminal blockers', () => {
  const fence = String.fromCharCode(96).repeat(3);
  assert.match(document(fence + '\n## Pending Evidence\nhidden').errors.join('\n'), /unclosed/);
});
test('shipped orchestration template becomes valid after supplying its feature ID', t => {
  const template = readFileSync(join(core, 'orchestration-template.md'), 'utf8').replaceAll('{feature-id}', 'sample').replaceAll('{feature-name}', 'generic');
  assert.deepEqual(audit(fixture(t, [template])).errors, []);
});
test('canonical roles agree with the normative contract and global templates', () => {
  const contract = readFileSync(join(core, 'role-execution-contract.md'), 'utf8');
  const match = contract.match(/Canonical role set:\n\n((?:\* [^\n]+\n)+)/); assert.ok(match);
  assert.deepEqual(match[1].trim().split('\n').map(line => line.slice(2)), roles);
  assert.match(readFileSync(join(core, 'templates/system-state.template.md'), 'utf8'), /Content Designer/);
});
test('QA core verdict contract and conditional domain modules remain explicit', () => {
  const qa = readFileSync(join(core, 'prompts/qa.md'), 'utf8');
  for (const heading of ['0. QA Execution Plan', '1. Evidence Ledger', '2. Acceptance & Critical Journey Coverage', '3. Findings', '5. Regression & Evidence Reuse', '6. Final Verdict']) {
    assert.ok(qa.includes('\n## ' + heading + '\n'), heading);
  }
  assert.match(qa, /Functional Approved/); assert.match(qa, /Decision Pending/);
  const modules = ['backend-security', 'client-ui', 'visual-quality', 'stateful-flow', 'unity-ios', 'content', 'release'];
  for (const module of modules) assert.ok(existsSync(join(core, 'prompts', 'qa-modules', module + '.md')), module);
  assert.match(readFileSync(join(core, 'prompts/qa-modules/visual-quality.md'), 'utf8'), /## Visual Quality Verdict/);
});

test('full release cycle replays delivery, checkpoints, QA re-entry, and closure', t => {
  const owners = ['UI Designer', 'Frontend/Mobile Developer', 'QA', 'DevOps/Release Engineer', 'QA'];
  const taskStates = ['Open', 'Queued', 'Queued', 'Queued', 'Queued'];
  const ledger = () => taskStates.map((status, i) => row('sample.' + (i + 1), owners[i], status, i ? 'sample.' + i : '-')).join('\n');
  const state = { 'Current Owner': owners[0], 'Next Role': owners[0], 'Active Task Ledger': ledger(),
    'Handoff Plan': plan(), 'Release Scope': 'staging', 'QA Scope': 'client-only' };
  const root = fixture(t, [sourceFor(state)]);
  function save(patch = {}, label = '') {
    Object.assign(state, patch);
    writeFileSync(join(root, 'features/item-0/orchestration.md'), sourceFor(state));
    const done = state['Current Status'] === 'Done', id = done ? '-' : 'sample', owner = state['Current Owner'];
    writeFileSync(join(root, 'feature-board.md'), '# Feature Board\nActive Feature: ' + id + '\nActive Owner: ' + owner +
      '\nPending Product Revision: None\nRevision Affected Features: None\n\n## Status Table\n' +
      '| ID | Feature | Status | Owner |\n| --- | --- | --- | --- |\n| sample | Generic | ' + (state['Current Status'] ?? 'In Progress') + ' | ' + owner + ' |\n');
    writeFileSync(join(root, 'system-state.md'), '# System State\n## Active Feature\n' + id + '\n## Current Role\n' + owner + '\n');
    assert.deepEqual(audit(root).errors, [], label);
    const shell = spawnSync('sh', [wrapper, root], { encoding: 'utf8' });
    assert.equal(shell.status, 0, label + '\n' + shell.stdout + shell.stderr);
  }
  function complete(i, result = {}) {
    assert.deepEqual(resolveTasks(feature(state), owners[i]).map(task => task.id), ['sample.' + (i + 1)]);
    taskStates[i] = 'Done'; state['Active Task Ledger'] = ledger();
    const next = handoff(feature(state), owners[i]);
    for (const id of next.activate) taskStates[Number(id.split('.').at(-1)) - 1] = 'Open';
    save({ ...result, 'Current Owner': next.role, 'Next Role': next.role,
      'Active Task Ledger': ledger(), 'Delivery Review': 'Pending' }, 'completed ' + owners[i]);
    return next.role;
  }
  function activate(i, patch) {
    taskStates[i] = 'Open';
    save({ ...patch, 'Current Owner': owners[i], 'Next Role': owners[i],
      'Active Task Ledger': ledger(), 'Delivery Review': 'Accepted' }, 'activated ' + owners[i]);
  }
  save({}, 'initial UI');
  assert.equal(complete(0), owners[1]); // Explicit delivery plan, no extra checkpoint.
  assert.equal(complete(1), 'Tech Lead'); // No direct QA bypass.
  activate(2, { 'Current Status': 'In QA', 'QA Stage': 'functional', 'QA Result': 'None' });
  assert.equal(qaTransition({ result: 'Functional Approved', stage: 'functional', releaseScope: 'staging' }), 'release');
  complete(2, { 'QA Result': 'Functional Approved' });
  activate(3, { 'Current Status': 'In Release' });
  complete(3, { 'Release Result': 'Release Ready' });
  assert.equal(releaseTransition(state['Release Result']), 'qa-final');
  assert.notEqual(state['Current Status'], 'Done');
  activate(4, { 'Current Status': 'In QA', 'QA Stage': 'final', 'QA Result': 'None' });
  complete(4, { 'QA Result': 'Approved' });
  save({ ...terminalFields, 'Handoff Plan': 'None' }, 'final closure after Tech Lead review');
});
test('a resolved blocked decision can resume its preserved task', t => {
  const state = { 'Current Status': 'Blocked', 'Current Owner': 'Tech Lead', 'Next Role': 'Tech Lead',
    'Open Decision Gates': '- Decision ID: sample.D1\n  * Status: OPEN' };
  const f = feature(state);
  assert.equal(resolveDecision([f], 'sample.D1').decision.Status, 'OPEN');
  assert.deepEqual(audit(fixture(t, [sourceFor(state)])).errors, []);
  const resumed = { ...state, 'Current Status': 'In Progress', 'Current Owner': 'Content Designer', 'Next Role': 'Content Designer',
    'Open Decision Gates': '- Decision ID: sample.D1\n  * Status: RESOLVED\n  * Resolution: Existing requirement confirmed\n  * Resolved At: 2026-01-01' };
  assert.deepEqual(audit(fixture(t, [sourceFor(resumed)])).errors, []);
  assert.equal(resolveTasks(feature(resumed), 'Content Designer')[0].id, 'sample.1');
});
test('QA activation rejects stale verdicts and empty scope aliases', () => {
  for (const scope of ['none', 'None', '-', '—', '']) assert.match(errorsFor({ ...qaFields, 'QA Scope': scope }).join('\n'), /scope required/);
  assert.match(errorsFor({ ...qaFields, 'QA Result': 'Functional Approved' }).join('\n'), /reset its previous verdict/);
});
test('completed features must archive their handoff plans', () => {
  assert.match(errorsFor({ ...terminalFields, 'Handoff Plan': plan() }).join('\n'), /terminal Handoff Plan/);
});
test('fenced comment syntax is opaque while live comments are ignored', t => {
  const fence = String.fromCharCode(96).repeat(4);
  const source = fence + 'md\n<!-- literal example\n' + fence + '\n<!--\n## Current Owner\nQA\n-->\n' + sourceFor();
  assert.deepEqual(validateFeature(parseFeature(source)), []);
  const root = fixture(t, [source]);
  for (const args of [[], ['--structure-only']]) {
    const result = spawnSync('sh', [wrapper, root, ...args], { encoding: 'utf8' });
    assert.equal(result.status, 0, result.stdout + result.stderr);
  }
});
test('feature board starter owner sets include every canonical role', () => {
  const files = ['templates/feature-board.template.md'];
  // Installed consumers own the live board; only the core starter duplicates this catalog.
  const liveBoard = join(core, 'feature-board.md');
  if (existsSync(liveBoard) && /Status: TEMPLATE/.test(readFileSync(liveBoard, 'utf8'))) files.push('feature-board.md');
  for (const file of files) {
    const body = readFileSync(join(core, file), 'utf8');
    for (const role of roles) assert.ok(body.includes('* ' + role + '\n'), file + ': ' + role);
  }
});

test('final approval cannot bypass pending evidence before terminal cleanup', () => {
  assert.match(errorsFor({ 'Current Owner': 'Tech Lead', 'Next Role': 'Tech Lead', 'QA Stage': 'final', 'QA Result': 'Approved',
    'Pending Evidence': '- Evidence ID: sample.E1\n  * Result: PENDING' }).join('\n'), /final approval cannot coexist/);
});
test('task schema requires explicit dependency fields even for independent work', () => {
  assert.match(errorsFor({ 'Active Task Ledger': row().replace(' | Depends On: -', '') }).join('\n'), /missing task field: Depends On/);
});
test('QA activation uses the In QA workflow status', () => {
  assert.match(errorsFor({ ...qaFields, 'Current Status': 'In Progress' }).join('\n'), /active QA requires In QA/);
});

const releaseDecision = '- Decision ID: sample.RELEASE\n  * Status: OPEN\n  * Blocking Scope: release';
test('release-only decisions do not block independent functional QA or development', () => {
  assert.deepEqual(errorsFor({ ...qaFields, 'Open Decision Gates': releaseDecision }), []);
  assert.deepEqual(errorsFor({ 'Release Scope': 'staging', 'Open Decision Gates': releaseDecision }), []);
  const f = feature({ 'Release Scope': 'staging', 'Open Decision Gates': releaseDecision,
    'Active Task Ledger': row('sample.1', 'Content Designer', 'Done') + '\n' + row('sample.2', 'Frontend/Mobile Developer', 'Queued'),
    'Handoff Plan': plan() });
  assert.equal(handoff(f, f.owner).role, 'Frontend/Mobile Developer');
});
test('release-only decisions still block DevOps, final QA, and terminal acceptance', () => {
  const decision = { 'Open Decision Gates': releaseDecision, 'Release Scope': 'staging' };
  assert.match(errorsFor({ ...decision, 'Current Owner': 'DevOps/Release Engineer', 'Next Role': 'DevOps/Release Engineer',
    'Active Task Ledger': row('sample.1', 'DevOps/Release Engineer') }).join('\n'), /blocking decision/);
  assert.match(errorsFor({ ...qaFields, ...decision, 'QA Stage': 'final', 'Release Result': 'Release Ready' }).join('\n'), /blocking decision/);
  assert.match(errorsFor({ ...terminalFields, ...decision, 'Release Result': 'Release Ready' }).join('\n'), /open decision/);
  const f = feature({ ...decision, 'Active Task Ledger': row('sample.1', 'Content Designer', 'Done') + '\n' +
    row('sample.2', 'DevOps/Release Engineer', 'Queued'), 'Handoff Plan': plan('DevOps/Release Engineer') });
  assert.equal(handoff(f, f.owner).role, 'Tech Lead');
});
test('decision scope defaults closed and malformed scope cannot bypass gating', () => {
  assert.match(errorsFor({ 'Open Decision Gates': '- Decision ID: sample.D1\n  * Status: OPEN' }).join('\n'), /blocking decision/);
  assert.match(errorsFor({ 'Open Decision Gates': releaseDecision.replace('release', 'unrelated') }).join('\n'), /invalid decision Blocking Scope/);
  assert.match(errorsFor({ 'Open Decision Gates': releaseDecision }).join('\n'), /requires Release Scope/);
});
