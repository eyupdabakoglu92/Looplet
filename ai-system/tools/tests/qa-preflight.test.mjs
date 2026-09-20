import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, mkdirSync, writeFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { preflight } from '../qa-preflight.mjs';

function orchestration(overrides = {}, includePlan = true) {
  const fields = {
    'Feature ID': 'qa-sample', 'Current Status': 'In QA', 'Current Owner': 'QA', 'Next Role': 'QA',
    'Active Task Ledger': '- [ ] Task ID: qa-sample.qa | Assigned Role: QA | Status: Open | Summary: Validate delivery | Depends On: -',
    'Open Tasks': 'None', 'Handoff Plan': 'None', 'Delivery Review': 'Accepted', 'QA Scope': 'content-only',
    ...(includePlan ? { 'QA Modules': 'core, content', 'Regression Depth': 'impacted', 'Evidence Reuse': 'not-applicable' } : {}),
    'QA Stage': 'functional', 'QA Result': 'None', 'Release Scope': 'none', 'Release Result': 'None',
    'Pending Evidence': 'None', 'Open Decision Gates': 'None', Blockers: 'None', 'Next Action': 'Run QA.',
    ...overrides,
  };
  return '# QA Sample\n\n' + Object.entries(fields).map(([key, value]) => '## ' + key + '\n\n' + value).join('\n\n') + '\n';
}

function fixture(t, source = orchestration()) {
  const root = mkdtempSync(join(tmpdir(), 'qa-preflight-test-'));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  const featureDir = join(root, 'features', 'qa-sample');
  mkdirSync(featureDir, { recursive: true });
  writeFileSync(join(featureDir, 'orchestration.md'), source);
  writeFileSync(join(featureDir, 'prd.md'), '# PRD\n');
  writeFileSync(join(featureDir, 'architecture.md'), '# Architecture\n\nSimple authored content delivery.\n');
  writeFileSync(join(featureDir, 'content-design.md'), '# Content Delivery\n');
  return { root, featureDir };
}

test('valid declared QA plan passes preflight', t => {
  const { root } = fixture(t);
  const result = preflight(root);
  assert.deepEqual(result.errors, []);
  assert.deepEqual(result.suggested, ['core', 'content']);
});

test('missing required module fails before QA execution', t => {
  const { root } = fixture(t, orchestration({ 'QA Modules': 'core' }));
  assert.match(preflight(root).errors.join('\n'), /required QA module missing: content/);
});

test('legacy plan derives modules and remains compatible', t => {
  const { root } = fixture(t, orchestration({}, false));
  const result = preflight(root);
  assert.deepEqual(result.errors, []);
  assert.match(result.warnings.join('\n'), /legacy orchestration/);
  assert.deepEqual(result.suggested, ['core', 'content']);
});

test('final release preflight requires release inputs and accepts a complete plan', t => {
  const source = orchestration({ 'QA Stage': 'final', 'Release Scope': 'staging', 'Release Result': 'Release Ready',
    'QA Modules': 'core, content, release', 'Regression Depth': 'full', 'Evidence Reuse': 'allowed' });
  const { root, featureDir } = fixture(t, source);
  assert.match(preflight(root).errors.join('\n'), /release\.md/);
  mkdirSync(join(root, 'project-authority'), { recursive: true });
  writeFileSync(join(featureDir, 'release.md'), '# Release Evidence\n');
  writeFileSync(join(root, 'project-authority', 'release.md'), '# Release Authority\n');
  assert.deepEqual(preflight(root).errors, []);
});
