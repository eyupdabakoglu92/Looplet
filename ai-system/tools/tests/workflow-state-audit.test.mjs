import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, mkdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';

const script = fileURLToPath(new URL('../workflow-state-audit.sh', import.meta.url));
const contract = fileURLToPath(new URL('../../role-execution-contract.md', import.meta.url));
const coreTemplate = fileURLToPath(new URL('../../orchestration-template.md', import.meta.url));
const tick = String.fromCharCode(96);
const text = (status = 'In Progress', owner = 'Content Designer', next = 'QA') => [
  '# Sample feature', '## Current Status', status, '## Current Owner', owner,
  '## Next Role', next, '## Next Action', '-', '## Active Task Ledger', 'None', '',
].join('\n');

function fixture(t, orchestration = text()) {
  const parent = mkdtempSync(join(tmpdir(), 'workflow-audit-test-'));
  t.after(() => rmSync(parent, { recursive: true, force: true }));
  const root = join(parent, 'a workspace', 'ai-system');
  const feature = join(root, 'features', 'sample-feature');
  mkdirSync(feature, { recursive: true });
  writeFileSync(join(root, 'system-state.md'), '# Current snapshot\n');
  writeFileSync(join(root, 'feature-board.md'), '# Current portfolio\n');
  const path = join(feature, 'orchestration.md');
  writeFileSync(path, orchestration);
  return { root, path };
}

function audit(root, overrides = {}, args = []) {
  const env = { ...process.env };
  for (const key of Object.keys(env)) {
    if (key.startsWith('WORKFLOW_MAX_')) delete env[key];
  }
  const result = spawnSync('sh', [script, root, '--structure-only', ...args], {
    encoding: 'utf8', env: { ...env, ...overrides },
  });
  assert.equal(result.error, undefined);
  return { ...result, output: result.stdout + result.stderr };
}

test('canonical owner works with a root path containing spaces', t => {
  const { root } = fixture(t);
  assert.equal(audit(root).status, 0);
});

test('Done and Closed accept the exact dash and empty terminal ledger', t => {
  const { root, path } = fixture(t);
  for (const status of ['Done', 'Closed']) {
    writeFileSync(path, text(status, '-', '-'));
    assert.equal(audit(root).status, 0);
  }
});

test('Markdown bullets and inline emphasis preserve dash as a value', t => {
  const { root } = fixture(t, text('**Done**', '* -', tick + 'Closed' + tick));
  assert.equal(audit(root).status, 0);
});

test('one owner is required, not merely the first valid owner', t => {
  const { root } = fixture(t, text('In Progress', 'Content Designer\nQA'));
  assert.equal(audit(root).status, 2);
});

test('duplicate authoritative headings are rejected', t => {
  const { root } = fixture(t, text() + '\n## Current Owner\nQA\n');
  assert.equal(audit(root).status, 2);
});

test('fenced example headings do not become authoritative fields', t => {
  const fence = tick.repeat(3);
  const example = [fence + 'md', '## Current Status', 'Done', '## Current Owner', 'QA', fence, ''].join('\n');
  const { root } = fixture(t, example + text());
  assert.equal(audit(root).status, 0);
});

test('a missing authoritative field is rejected', t => {
  const { root } = fixture(t, text().replace('## Next Role\nQA\n', ''));
  assert.equal(audit(root).status, 2);
});

test('narrative inside a status field is rejected', t => {
  const { root } = fixture(t, text('Done — previous delivery accepted', '-', '-'));
  assert.equal(audit(root).status, 2);
});

test('Closed is a next-role sentinel, not an owner', t => {
  const { root } = fixture(t, text('In Progress', 'Closed', 'QA'));
  assert.equal(audit(root).status, 2);
});

test('terminal state rejects stale owner, routing, action and ledger', t => {
  const { root, path } = fixture(t);
  const good = text('Done', '-', '-');
  const cases = [
    text('Done', 'QA', '-'), text('Done', '-', 'QA'),
    good.replace('## Next Action\n-', '## Next Action\nRun QA'),
    good.replace('## Active Task Ledger\nNone', '## Active Task Ledger\n- [ ] Pending task'),
  ];
  for (const body of cases) {
    writeFileSync(path, body);
    assert.equal(audit(root).status, 2);
  }
});

test('Blocked preserves pending work rather than applying completed cleanup', t => {
  const { root } = fixture(t, text('Blocked', 'Tech Lead', 'Tech Lead')
    .replace('## Active Task Ledger\nNone', '## Active Task Ledger\n- [ ] Await decision'));
  assert.equal(audit(root).status, 0);
});

test('snapshot warning prose is allowed but superseded entries are rejected', t => {
  const { root } = fixture(t);
  const path = join(root, 'system-state.md');
  writeFileSync(path, '# Snapshot\nDo not append superseded status history here.\n');
  assert.equal(audit(root).status, 0);
  writeFileSync(path, '# Snapshot\nSuperseded Last Updated: a prior state\n');
  assert.equal(audit(root).status, 2);
});

test('configurable budgets measure bytes, including multilingual content', t => {
  const { root } = fixture(t);
  writeFileSync(join(root, 'system-state.md'), 'é'.repeat(20));
  assert.equal(audit(root, { WORKFLOW_MAX_SYSTEM_STATE_BYTES: '30' }).status, 2);
  assert.equal(audit(root, { WORKFLOW_MAX_SYSTEM_STATE_BYTES: '40' }).status, 0);
});

test('all budget overrides are validated and applied', t => {
  const { root } = fixture(t);
  for (const key of ['WORKFLOW_MAX_SYSTEM_STATE_BYTES', 'WORKFLOW_MAX_FEATURE_BOARD_BYTES',
    'WORKFLOW_MAX_ORCHESTRATION_BYTES']) {
    assert.equal(audit(root, { [key]: '1' }).status, 2);
    for (const invalid of ['0', '-1', 'abc']) {
      assert.equal(audit(root, { [key]: invalid }).status, 1);
    }
  }
});

test('missing root and extra arguments fail clearly', t => {
  const { root } = fixture(t);
  assert.equal(audit(resolve(root, 'missing')).status, 1);
  assert.equal(audit(root, {}, ['unexpected']).status, 1);
});

test('missing required global snapshots cannot report PASS', t => {
  const { root } = fixture(t);
  for (const name of ['system-state.md', 'feature-board.md']) {
    const path = join(root, name);
    const saved = readFileSync(path, 'utf8');
    rmSync(path);
    const result = audit(root);
    assert.equal(result.status, 2);
    assert.ok(result.output.includes(name));
    writeFileSync(path, saved);
  }
});

test('all canonical roles in the contract are accepted by the audit', t => {
  const source = readFileSync(contract, 'utf8');
  const match = source.match(/Canonical role set:\n\n((?:\* [^\n]+\n)+)/);
  assert.ok(match);
  const roles = match[1].trim().split('\n').map(line => line.slice(2));
  const { root, path } = fixture(t);
  for (const role of roles) {
    writeFileSync(path, text('In Progress', role, role));
    assert.equal(audit(root).status, 0, role);
  }
});

test('the shipped orchestration template uses single-value headers', t => {
  const { root } = fixture(t, readFileSync(coreTemplate, 'utf8'));
  assert.equal(audit(root).status, 0);
});
