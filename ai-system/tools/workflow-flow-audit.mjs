#!/usr/bin/env node
// Read-only, product-independent workflow checks. No repository mutations.
import { readFileSync, readdirSync, existsSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
export const roles = ['Product Owner', 'Tech Lead', 'Technical Analyst', 'Content Designer', 'UI Designer', 'Backend Developer', 'Frontend/Mobile Developer', 'Game Developer (Unity)', 'DevOps/Release Engineer', 'QA', 'Project Setup'];
export const statuses = ['Not Started', 'In Progress', 'In QA', 'In Release', 'Rework', 'Done', 'Blocked', 'Closed'];
export const taskStatuses = ['Queued', 'Open', 'In Progress', 'Blocked', 'Done', 'Cancelled'];
export const qaResults = ['None', 'Functional Approved', 'Approved', 'Approved with Notes', 'Rejected', 'Runtime Validation Pending', 'Decision Pending'];
export const releaseResults = ['None', 'Release Ready', 'Release Ready with Notes', 'Release Blocked', 'Release Validation Pending'];
export const visualScopes = ['none', 'existing-parity', 'new-surface', 'motion-critical', 'design-system'];
export const visualGates = ['Not Required', 'Pending', 'Ready for Implementation', 'Ready for QA', 'Passed'];
export const qaModules = ['core', 'backend-security', 'client-ui', 'visual-quality', 'stateful-flow', 'unity-ios', 'content', 'release'];
export const regressionDepths = ['not-set', 'targeted', 'impacted', 'full'];
export const evidenceReuseValues = ['not-evaluated', 'allowed', 'invalidated', 'not-applicable'];
const controls = new Set(['Tech Lead', 'Product Owner']);
const terminal = value => ['Done', 'Closed'].includes(value);
const executable = value => statuses.includes(value) && !['Done', 'Closed', 'Blocked'].includes(value);
const active = task => ['Open', 'In Progress'].includes(task.status);
const ready = value => ['Release Ready', 'Release Ready with Notes'].includes(value);
const clean = value => value.trim().replace(/^[-*+]\s+/, '').replace(/^\*\*(.*)\*\*$/, '$1').replace(/^\x60(.*)\x60$/, '$1');
const none = value => ['', '-', '—', 'None', 'none'].includes(value);
const list = value => none(value) ? [] : value.split(',').map(clean).filter(Boolean);
const assert = (condition, message) => { if (!condition) throw new Error(message); };

export function document(source) {
  const lines = [], errors = [];
  let fence = null, comment = false;
  for (let line of source.split(/\r?\n/)) {
    // Code examples are opaque: a literal HTML comment inside one is not live markup.
    if (fence) {
      const closing = line.trim().match(/^(\x60{3,}|~{3,})(.*)$/);
      if (closing && closing[1][0] === fence[0] && closing[1].length >= fence.length && !closing[2].trim()) fence = null;
      continue;
    }
    if (comment) { const end = line.indexOf('-->'); if (end < 0) continue; line = line.slice(end + 3); comment = false; }
    while (line.includes('<!--')) {
      const start = line.indexOf('<!--'), end = line.indexOf('-->', start + 4);
      if (end < 0) { line = line.slice(0, start); comment = true; break; }
      line = line.slice(0, start) + line.slice(end + 3);
    }
    const match = line.trim().match(/^(\x60{3,}|~{3,})(.*)$/);
    if (match) { fence = match[1]; continue; }
    lines.push(line);
  }
  if (fence || comment) errors.push('unclosed code fence/comment');
  const sections = new Map(); let current = null;
  for (const line of lines) {
    const heading = line.match(/^##\s+(.+?)\s*$/);
    if (heading) {
      current = heading[1];
      if (sections.has(current)) errors.push('duplicate section: ' + current);
      else sections.set(current, []);
    } else if (/^#\s/.test(line)) current = null;
    else if (current) sections.get(current).push(line);
  }
  const body = heading => sections.has(heading) ? sections.get(heading).filter(line => line.trim() !== '---').join('\n').trim() : null;
  const scalar = (heading, required = true) => {
    const content = body(heading);
    const values = (content ?? '').split('\n').map(clean).filter(v => v && v !== '---');
    if (values.length !== 1) {
      if (required || content !== null) errors.push('exact single value required: ' + heading);
      return '';
    }
    return values[0];
  };
  const field = name => {
    if (sections.has(name)) return scalar(name);
    const prefix = name + ':', matches = lines.map(clean).filter(line => line.startsWith(prefix));
    if (matches.length > 1) errors.push('duplicate field: ' + name);
    return matches.length === 1 ? clean(matches[0].slice(prefix.length)) : '';
  };
  return { lines, sections, errors, body, scalar, field };
}
export function parseTasks(body, errors = []) {
  if (body === null) return null;
  if (none(body)) return [];
  const tasks = [];
  for (const line of body.split('\n').filter(l => l.trim() && l.trim() !== '---')) {
    const row = line.trim().match(/^[-*]\s+\[([ xX])\]\s+(.+)$/);
    if (!row) { errors.push('invalid ledger row: ' + line.trim()); continue; }
    const fields = {};
    for (const part of row[2].split('|')) {
      const colon = part.indexOf(':');
      if (colon < 0) { errors.push('invalid task field'); continue; }
      const key = part.slice(0, colon).trim();
      if (Object.hasOwn(fields, key)) errors.push('duplicate task field: ' + key);
      fields[key] = clean(part.slice(colon + 1));
    }
    for (const key of ['Task ID', 'Assigned Role', 'Status', 'Summary', 'Depends On']) {
      if (!Object.hasOwn(fields, key)) errors.push('missing task field: ' + key);
    }
    tasks.push({ id: fields['Task ID'] ?? '', role: fields['Assigned Role'] ?? '', status: fields.Status ?? '',
      summary: fields.Summary ?? '', depends: list(fields['Depends On'] ?? '-'), checked: row[1] !== ' ' });
  }
  return tasks;
}
function records(body, idKey, errors) {
  if (body === null) { errors.push('missing ' + idKey + ' section'); return []; }
  if (none(body)) return [];
  const result = []; let item;
  for (const raw of body.split('\n')) {
    const line = clean(raw);
    if (!line || line === '---') continue;
    const colon = line.indexOf(':');
    if (colon < 0) { errors.push('invalid ' + idKey + ' record'); continue; }
    const key = line.slice(0, colon), value = clean(line.slice(colon + 1));
    if (key === idKey) { item = { id: value }; result.push(item); }
    else if (!item || Object.hasOwn(item, key)) errors.push('invalid/duplicate ' + idKey + ' field: ' + key);
    else item[key] = value;
  }
  const seen = new Set();
  for (const record of result) {
    if (!record.id || seen.has(record.id)) errors.push('duplicate/empty ' + idKey);
    seen.add(record.id);
    const key = idKey === 'Evidence ID' ? 'Result' : 'Status';
    const allowed = idKey === 'Evidence ID' ? ['PENDING', 'PASS', 'FAIL'] : ['OPEN', 'RESOLVED'];
    if (!allowed.includes(record[key])) errors.push('invalid ' + idKey + ' ' + key);
    if (idKey === 'Decision ID' && record['Blocking Scope'] !== undefined && !['feature', 'release'].includes(record['Blocking Scope'])) errors.push('invalid decision Blocking Scope');
    if (idKey === 'Decision ID' && record.Status === 'RESOLVED' && (!record.Resolution || !record['Resolved At'])) errors.push('resolved decision needs resolution and timestamp');
  }
  return result;
}
export function table(body) {
  const rows = (body ?? '').split('\n').filter(line => line.trim().startsWith('|'))
    .map(line => line.trim().replace(/^\||\|$/g, '').split('|').map(clean));
  if (rows.length < 2) return [];
  const headers = rows[0];
  return rows.slice(1).filter(row => !row.every(cell => /^:?-+:?$/.test(cell)))
    .map(row => Object.fromEntries(headers.map((key, i) => [key, row[i] ?? ''])));
}
export function parseFeature(source) {
  const doc = document(source), errors = doc.errors;
  const visualHeadings = ['Visual Scope', 'Design Foundation', 'Visual Quality Gate', 'Visual Evidence'];
  const visualDeclared = visualHeadings.some(heading => doc.sections.has(heading));
  const qaPlanHeadings = ['QA Modules', 'Regression Depth', 'Evidence Reuse'];
  const qaPlanDeclared = qaPlanHeadings.some(heading => doc.sections.has(heading));
  const evidence = records(doc.body('Pending Evidence'), 'Evidence ID', errors);
  const decisions = records(doc.body('Open Decision Gates'), 'Decision ID', errors);
  const planBody = doc.body('Handoff Plan'), rows = table(planBody);
  if (planBody === null || (!none(planBody) && rows.length === 0)) errors.push('Handoff Plan must be None or a routing table');
  const blocks = doc.body('Blockers'), inventory = doc.body('Open Tasks');
  if (blocks === null) errors.push('Blockers section required');
  if (inventory === null) errors.push('Open Tasks section required');
  let ignored = false, openInventory = false;
  for (const line of (inventory ?? '').split('\n')) {
    if (/^#{3,}\s/.test(line)) ignored = /archive|reference|example|history|complete|closed/i.test(line);
    if (!ignored && /^\s*[-*]\s+\[ \]/.test(line) && !line.includes('~~')) openInventory = true;
  }
  return { id: doc.scalar('Feature ID'), status: doc.scalar('Current Status'), owner: doc.scalar('Current Owner'),
    next: doc.scalar('Next Role'), action: doc.body('Next Action')?.trim() ?? '',
    tasks: parseTasks(doc.body('Active Task Ledger'), errors), review: doc.scalar('Delivery Review'),
    qaScope: doc.scalar('QA Scope'), qaStage: doc.scalar('QA Stage'), qaResult: doc.scalar('QA Result'),
    qaPlanDeclared, qaModules: list(doc.scalar('QA Modules', qaPlanDeclared)),
    regressionDepth: doc.scalar('Regression Depth', qaPlanDeclared),
    evidenceReuse: doc.scalar('Evidence Reuse', qaPlanDeclared),
    releaseScope: doc.scalar('Release Scope'), releaseResult: doc.scalar('Release Result'),
    visualDeclared, visualScope: doc.scalar('Visual Scope', visualDeclared),
    designFoundation: doc.scalar('Design Foundation', visualDeclared),
    visualGate: doc.scalar('Visual Quality Gate', visualDeclared),
    visualEvidence: doc.body('Visual Evidence'),
    evidence, decisions, pendingEvidence: evidence.some(e => e.Result !== 'PASS'),
    openDecisions: decisions.some(d => d.Status === 'OPEN'), blockers: !none(blocks ?? ''), openInventory,
    plan: rows.map(row => ({ after: list(row['After Tasks'] ?? ''), role: row['Next Role'], activate: list(row['Activate Tasks'] ?? '') })), errors };
}
export function resolveFeature(features, role) {
  assert(roles.includes(role), 'unknown canonical role');
  if (controls.has(role)) return null;
  const candidates = features.filter(f => executable(f.status) && f.owner === role);
  assert(candidates.length === 1, 'exactly one executable feature must own the delivery role');
  return candidates[0];
}
export function resolveTasks(feature, role) {
  if (controls.has(role)) return [];
  assert(executable(feature.status) && feature.owner === role, 'delivery role is not active');
  const tasks = feature.tasks === null ? (feature.fallbackTasks ?? []) : feature.tasks;
  const available = tasks.filter(t => t.role === role && active(t));
  assert(available.length > 0, 'no actionable task');
  for (const task of available) assert(task.depends.every(id => tasks.some(t => t.id === id && t.status === 'Done')), 'unfinished task dependency');
  return available;
}
function decisionBlocks(feature, role = feature.owner) {
  return feature.decisions.some(decision => decision.Status === 'OPEN' &&
    (decision['Blocking Scope'] !== 'release' || role === 'DevOps/Release Engineer' ||
      (role === 'QA' && feature.qaStage === 'final')));
}
export function handoff(feature, fromRole) {
  assert(feature.owner === fromRole && executable(feature.status), 'inactive handoff');
  const tasks = feature.tasks ?? [];
  if (feature.blockers || feature.pendingEvidence || decisionBlocks(feature, fromRole)) return { role: 'Tech Lead', activate: [] };
  const remaining = tasks.filter(t => t.role === fromRole && active(t));
  if (remaining.length) { resolveTasks(feature, fromRole); return { role: fromRole, activate: remaining.map(t => t.id) }; }
  if (['Technical Analyst', 'QA', 'Project Setup', 'DevOps/Release Engineer'].includes(fromRole)) return { role: 'Tech Lead', activate: [] };
  const matches = (feature.plan ?? []).filter(row => row.after.length &&
    row.after.every(id => tasks.some(t => t.id === id && t.role === fromRole && t.status === 'Done')) &&
    row.activate.length && row.activate.every(id => tasks.some(t => t.id === id && t.status === 'Queued')));
  if (matches.length !== 1) return { role: 'Tech Lead', activate: [] };
  const row = matches[0];
  if (!roles.includes(row.role) || row.role === fromRole || row.role === 'QA' || controls.has(row.role) || decisionBlocks(feature, row.role)) return { role: 'Tech Lead', activate: [] };
  const valid = row.activate.every(id => tasks.some(t => t.id === id && t.role === row.role &&
    t.depends.every(dep => tasks.some(previous => previous.id === dep && previous.status === 'Done'))));
  return valid ? { role: row.role, activate: row.activate } : { role: 'Tech Lead', activate: [] };
}
export function qaTransition({ result, stage, releaseScope }) {
  assert(qaResults.includes(result) && result !== 'None', 'unknown QA verdict');
  assert(['functional', 'final'].includes(stage), 'QA stage required');
  if (result === 'Rejected') return 'rework';
  if (result === 'Decision Pending') return 'decision';
  if (result === 'Runtime Validation Pending') return 'evidence-then-same-qa-stage';
  if (result === 'Functional Approved') {
    assert(stage === 'functional' && releaseScope !== 'none', 'functional approval requires later release');
    return 'release';
  }
  assert(stage === 'final', 'final approval requires final QA stage');
  return 'closure-review';
}
export function releaseTransition(result) {
  assert(releaseResults.includes(result) && result !== 'None', 'unknown release verdict');
  return ready(result) ? 'qa-final' : result === 'Release Blocked' ? 'rework-or-decision' : 'evidence';
}
export function resolveDecision(features, id) {
  const matches = features.flatMap(feature => feature.decisions.filter(d => d.id === id).map(decision => ({ feature, decision })));
  assert(matches.length === 1 && matches[0].decision.Status === 'OPEN', 'decision must have one exact OPEN match');
  return matches[0];
}
export function validateFeature(f) {
  const errors = [...f.errors], check = (condition, message) => { if (!condition) errors.push(message); };
  check(Boolean(f.id) && !/[{}<>]/.test(f.id), 'real Feature ID required');
  check(statuses.includes(f.status), 'invalid Current Status');
  check(f.owner === '-' || roles.includes(f.owner), 'invalid Current Owner');
  check(['-', 'Closed', ...roles].includes(f.next), 'invalid Next Role');
  check(f.tasks !== null, 'Active Task Ledger required; normalize legacy inventory');
  check(['None', 'Pending', 'Accepted'].includes(f.review), 'invalid Delivery Review');
  check(['none', 'functional', 'final'].includes(f.qaStage), 'invalid QA Stage');
  check(qaResults.includes(f.qaResult), 'invalid QA Result');
  check(releaseResults.includes(f.releaseResult), 'invalid Release Result');
  check(['none', 'ci-cd-only', 'container-build', 'deploy-development', 'deploy-test', 'deploy-preview', 'staging', 'production-readiness', 'rollback-readiness'].includes(f.releaseScope), 'invalid Release Scope');
  check(f.releaseScope !== 'none' || !f.decisions.some(d => d.Status === 'OPEN' && d['Blocking Scope'] === 'release'), 'release-only decision requires Release Scope');
  if (f.visualDeclared) {
    check(visualScopes.includes(f.visualScope), 'invalid Visual Scope');
    check(visualGates.includes(f.visualGate), 'invalid Visual Quality Gate');
    check(f.visualEvidence !== null, 'Visual Evidence section required');
    if (f.visualScope === 'none') {
      check(f.designFoundation === 'Not Required', 'non-visual scope requires Design Foundation = Not Required');
      check(f.visualGate === 'Not Required', 'non-visual scope requires Visual Quality Gate = Not Required');
      check(none(f.visualEvidence ?? ''), 'non-visual scope requires Visual Evidence = None');
    } else if (visualScopes.includes(f.visualScope)) {
      check(['Pending', 'ai-system/project-authority/design-foundation.md'].includes(f.designFoundation), 'visual scope requires pending or canonical Design Foundation');
      check(f.visualGate !== 'Not Required', 'visual scope cannot use Not Required gate');
      if (['Ready for Implementation', 'Ready for QA', 'Passed'].includes(f.visualGate)) {
        check(f.designFoundation === 'ai-system/project-authority/design-foundation.md', 'ready visual gate requires selected Design Foundation reference');
        check(!none(f.visualEvidence ?? ''), 'ready visual gate requires Visual Evidence references');
      }
    }
  }
  if (f.qaPlanDeclared) {
    check(f.qaModules.every(module => qaModules.includes(module)), 'invalid QA Modules');
    check(new Set(f.qaModules).size === f.qaModules.length, 'duplicate QA Module');
    check(regressionDepths.includes(f.regressionDepth), 'invalid Regression Depth');
    check(evidenceReuseValues.includes(f.evidenceReuse), 'invalid Evidence Reuse');
  }
  const tasks = f.tasks ?? [], ids = new Set();
  for (const task of tasks) {
    check(Boolean(task.id) && !ids.has(task.id), 'duplicate/empty Task ID'); ids.add(task.id);
    check(roles.includes(task.role), 'invalid Assigned Role');
    check(taskStatuses.includes(task.status), 'invalid task Status');
    check(Boolean(task.summary), 'task Summary required');
    check(task.checked === ['Done', 'Cancelled'].includes(task.status), 'task checkbox/status mismatch');
  }
  for (const task of tasks) {
    check(task.depends.every(id => ids.has(id)), 'unknown task dependency');
    if (active(task) && executable(f.status) && !controls.has(f.owner)) {
      check(task.role === f.owner, 'active task/owner mismatch');
      check(task.depends.every(id => tasks.some(t => t.id === id && t.status === 'Done')), 'unfinished active dependency');
    }
  }
  const visiting = new Set(), visited = new Set();
  function visit(id) {
    if (visiting.has(id)) { check(false, 'cyclic task dependency'); return; }
    if (visited.has(id)) return;
    visiting.add(id);
    for (const dep of tasks.find(t => t.id === id)?.depends ?? []) visit(dep);
    visiting.delete(id); visited.add(id);
  }
  tasks.forEach(t => visit(t.id));
  for (const row of f.plan) {
    check(row.after.length && row.activate.length && roles.includes(row.role), 'invalid Handoff Plan row');
    check(row.after.every(id => ids.has(id)), 'unknown Handoff Plan predecessor');
    check(row.activate.every(id => tasks.some(t => t.id === id && t.role === row.role)), 'Handoff Plan target task/role mismatch');
  }
  if (f.status === 'Blocked') check(f.owner === 'Tech Lead' && f.next === 'Tech Lead', 'Blocked routes to Tech Lead and preserves tasks');
  else if (executable(f.status)) {
    check(f.owner === f.next, 'Current Owner and Next Role must identify the same current command');
    if (!controls.has(f.owner) && f.owner !== '-') {
      try { resolveTasks(f, f.owner); } catch (e) { check(false, e.message); }
      check(!f.blockers && !decisionBlocks(f), 'blocking decision/prerequisite prevents delivery activation');
    }
    if (f.owner === 'QA') {
      check(f.status === 'In QA', 'active QA requires In QA status');
      check(f.review === 'Accepted', 'QA requires Tech Lead delivery review');
      check(['functional', 'final'].includes(f.qaStage) && !none(f.qaScope), 'QA stage/scope required');
      check(f.qaResult === 'None', 'active QA must reset its previous verdict');
      if (f.qaStage === 'final' && f.releaseScope !== 'none') check(ready(f.releaseResult), 'final QA requires release readiness');
      if (f.visualDeclared && f.visualScope !== 'none') check(f.visualGate === 'Ready for QA', 'active visual QA requires Visual Quality Gate = Ready for QA');
      if (f.qaPlanDeclared) {
        const modules = new Set(f.qaModules), scope = f.qaScope.toLowerCase();
        check(modules.has('core'), 'active QA Modules must include core');
        check(f.regressionDepth !== 'not-set', 'active QA requires Regression Depth');
        check(f.evidenceReuse !== 'not-evaluated', 'active QA requires Evidence Reuse decision');
        if (scope.includes('backend') || scope.includes('end-to-end')) check(modules.has('backend-security'), 'backend QA scope requires backend-security module');
        if (scope.includes('client') || scope.includes('end-to-end') || scope.includes('ui')) check(modules.has('client-ui'), 'client/UI QA scope requires client-ui module');
        if (scope.includes('content')) check(modules.has('content'), 'content QA scope requires content module');
        if (f.visualDeclared && f.visualScope !== 'none') check(modules.has('visual-quality'), 'visual QA scope requires visual-quality module');
        if (f.qaStage === 'final') check(f.regressionDepth === 'full', 'final QA requires full regression coverage');
        if (f.qaStage === 'final' && f.releaseScope !== 'none') check(modules.has('release'), 'final release QA requires release module');
      }
    }
  }
  if (f.qaResult !== 'None' && qaResults.includes(f.qaResult)) {
    try { qaTransition({ result: f.qaResult, stage: f.qaStage, releaseScope: f.releaseScope }); } catch (e) { check(false, e.message); }
  }
  if (['Approved', 'Approved with Notes'].includes(f.qaResult)) {
    check(!f.pendingEvidence && !f.openDecisions && !f.blockers, 'final approval cannot coexist with required pending evidence/decision/blocker');
    check(f.releaseScope === 'none' || ready(f.releaseResult), 'final approval requires release readiness');
  }
  if (terminal(f.status)) {
    check(f.owner === '-' && ['-', 'Closed'].includes(f.next), 'terminal routing must be closed');
    check(f.tasks !== null && tasks.length === 0, 'terminal ledger must be None');
    check(f.plan.length === 0, 'terminal Handoff Plan must be None');
    check(['-', 'Closed'].includes(clean(f.action)), 'terminal Next Action must be closed');
    check(!f.openInventory, 'terminal feature contains unchecked Open Tasks');
    check(!f.pendingEvidence, 'terminal feature contains PENDING/FAIL evidence');
    check(!f.openDecisions && !f.blockers, 'terminal feature contains open decision/blocker');
    check(f.review === 'Accepted' && f.qaStage === 'final' && ['Approved', 'Approved with Notes'].includes(f.qaResult), 'terminal feature requires reviewed final QA approval');
    check(f.releaseScope === 'none' || ready(f.releaseResult), 'terminal feature requires release readiness');
    if (f.visualDeclared && f.visualScope !== 'none') check(f.visualGate === 'Passed', 'terminal visual feature requires Visual Quality Gate = Passed');
  }
  return errors;
}

function visualArtifactErrors(feature, root) {
  if (!feature.visualDeclared || feature.visualScope === 'none') return [];
  const errors = [], check = (condition, message) => { if (!condition) errors.push(message); };
  const selected = ['Ready for Implementation', 'Ready for QA', 'Passed'].includes(feature.visualGate);
  const featureDir = dirname(feature.path);
  if (selected) {
    const foundationPath = join(root, 'project-authority', 'design-foundation.md');
    check(existsSync(foundationPath), 'selected Design Foundation file missing');
    if (existsSync(foundationPath)) {
      const foundation = readFileSync(foundationPath, 'utf8');
      check(/^>\s*Status:\s*Selected\s*$/mi.test(foundation) || /^Status:\s*Selected\s*$/mi.test(foundation), 'Design Foundation must have Status: Selected');
      check(!/^Selected By:\s*(Pending|None|-)\s*$/mi.test(foundation), 'Design Foundation selection authority missing');
    }
    const uiPath = join(featureDir, 'ui-design.md');
    check(existsSync(uiPath), 'ready visual gate requires ui-design.md');
    if (existsSync(uiPath)) {
      const ui = readFileSync(uiPath, 'utf8');
      check(/^##\s+(?:\d+[a-z]?\.\s+)?Visual Evidence Manifest\s*$/mi.test(ui), 'ui-design.md requires Visual Evidence Manifest');
      const rendered = ui.match(/\|\s*[^|{}\n]+\s*\|\s*direction-render\s*\|/gi) ?? [];
      if (['new-surface', 'motion-critical', 'design-system'].includes(feature.visualScope)) check(rendered.length >= 2, 'visual exploration requires two real direction-render records');
      if (feature.visualScope === 'existing-parity') check(/\|\s*[^|{}\n]+\s*\|\s*(selected-source|canonical-reference)\s*\|/i.test(ui), 'existing-parity requires a real selected-source/canonical-reference record');
      if (feature.visualScope === 'motion-critical') check(/\|\s*[^|{}\n]+\s*\|\s*motion-prototype\s*\|/i.test(ui), 'motion-critical handoff requires motion-prototype evidence');
    }
  }
  if (['Ready for QA', 'Passed'].includes(feature.visualGate)) {
    const deliveryPaths = [join(featureDir, 'frontend.md'), join(featureDir, 'game-dev.md')].filter(existsSync);
    check(deliveryPaths.length > 0, 'Ready for QA requires frontend.md or game-dev.md');
    const delivery = deliveryPaths.map(path => readFileSync(path, 'utf8')).join('\n');
    check(/^##\s+(?:\d+[a-z]?\.\s+)?Visual Parity Evidence\s*$/mi.test(delivery), 'client delivery requires Visual Parity Evidence');
    check(/\|\s*[^|{}\n]+\s*\|\s*runtime-screenshot\s*\|/i.test(delivery), 'visual parity requires a real runtime-screenshot record');
    if (feature.visualScope === 'motion-critical') check(/\|\s*[^|{}\n]+\s*\|\s*runtime-video\s*\|/i.test(delivery), 'motion-critical parity requires runtime-video evidence');
  }
  if (feature.visualGate === 'Passed') {
    const qaPath = join(featureDir, 'qa.md');
    check(existsSync(qaPath), 'Passed visual gate requires qa.md');
    if (existsSync(qaPath)) {
      const qa = readFileSync(qaPath, 'utf8');
      check(/^##\s+Visual Quality Verdict\s*$/mi.test(qa), 'qa.md requires Visual Quality Verdict');
      const score = qa.match(/Final Score:\s*(\d+)\s*\/\s*100/i);
      const lowest = qa.match(/Lowest Dimension:\s*[^\n]*?\b(\d+)\s*\/\s*10/i);
      check(Boolean(score) && Number(score?.[1]) >= 93, 'visual PASS requires Final Score >= 93');
      check(Boolean(lowest) && Number(lowest?.[1]) >= 8, 'visual PASS requires every rubric dimension >= 8');
      check(/Fail Conditions:\s*None\b/i.test(qa), 'visual PASS requires no fail conditions');
      check(/Runtime Evidence Complete:\s*Yes\b/i.test(qa), 'visual PASS requires complete runtime evidence');
      check(/Result:\s*PASS\b/i.test(qa), 'visual PASS requires QA Result: PASS');
    }
  }
  return errors;
}
export function audit(root, { local = false } = {}) {
  const errors = [], features = [];
  const board = document(readFileSync(join(root, 'feature-board.md'), 'utf8'));
  const system = document(readFileSync(join(root, 'system-state.md'), 'utf8'));
  const dir = join(root, 'features');
  if (existsSync(dir)) for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const path = join(dir, entry.name, 'orchestration.md');
    if (!entry.isDirectory() || !existsSync(path)) continue;
    const feature = parseFeature(readFileSync(path, 'utf8')); feature.path = path; features.push(feature);
    errors.push(...validateFeature(feature).map(message => feature.id + ': ' + message));
    errors.push(...visualArtifactErrors(feature, root).map(message => feature.id + ': ' + message));
  }
  const check = (condition, message) => { if (!condition) errors.push(message); };
  const ids = new Set(), decisionIds = new Set();
  for (const feature of features) {
    check(!ids.has(feature.id), 'duplicate Feature ID: ' + feature.id); ids.add(feature.id);
    for (const decision of feature.decisions) {
      check(!decisionIds.has(decision.id), 'duplicate global Decision ID: ' + decision.id); decisionIds.add(decision.id);
    }
  }
  for (const role of roles.filter(r => !controls.has(r))) check(features.filter(f => executable(f.status) && f.owner === role).length <= 1, 'multiple executable features assigned to ' + role);
  const activeId = board.field('Active Feature'), systemId = system.field('Active Feature');
  const isPlaceholder = value => /[{}<>]/.test(value);
  const templateOnly = features.length === 0 && board.lines.some(line => /Status: TEMPLATE/.test(line)) && system.lines.some(line => /Status: TEMPLATE/.test(line));
  for (const id of [activeId, systemId]) if (!none(id) && !(templateOnly && isPlaceholder(id))) check(ids.has(id), 'active feature has no orchestration: ' + id);
  if (!templateOnly) {
    check(Boolean(activeId) && Boolean(systemId), 'global Active Feature fields required (use - when none)');
    if (!local) check(none(activeId) && none(systemId) || activeId === systemId, 'global Active Feature mismatch');
    const rows = table(board.body('Status Table'));
    for (const feature of features) {
      const matches = rows.filter(row => row.ID === feature.id);
      check(matches.length === 1, 'feature needs one board row: ' + feature.id);
      if (!local && matches.length === 1) check(matches[0].Status === feature.status && matches[0].Owner === feature.owner, 'board/header status or owner mismatch: ' + feature.id);
    }
    for (const row of rows) if (!isPlaceholder(row.ID ?? '') && row.Status !== 'Not Started') check(ids.has(row.ID), 'board feature has no orchestration: ' + row.ID);
    if (!local && ids.has(activeId)) {
      const feature = features.find(f => f.id === activeId);
      check(!terminal(feature.status), 'global active feature is already completed');
      check(board.field('Active Owner') === feature.owner && system.field('Current Role') === feature.owner, 'global current role/owner mismatch');
    }
    if (!local && none(activeId)) check(none(board.field('Active Owner')) && none(system.field('Current Role')), 'no active feature must have no active owner');
    const revision = board.field('Pending Product Revision');
    check(Boolean(revision), 'Pending Product Revision field required');
    if (!none(revision)) {
      const affected = list(board.field('Revision Affected Features'));
      check(Boolean(board.field('Revision Affected Features')), 'revision affected features required');
      for (const feature of features.filter(f => affected.includes(f.id))) {
        check(!executable(feature.status) || controls.has(feature.owner) || feature.owner === '-', 'pending revision prevents delivery: ' + feature.id);
        check(!terminal(feature.status), 'pending revision needs impact review of completed feature: ' + feature.id);
      }
    }
  }
  errors.push(...board.errors.map(e => 'feature-board: ' + e), ...system.errors.map(e => 'system-state: ' + e));
  return { errors, count: features.length, mode: local ? 'local' : 'full', templateOnly };
}
if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  try {
    const args = process.argv.slice(2), root = args.shift() ?? 'ai-system';
    assert(args.every(a => a === '--local') && args.length <= 1, 'Usage: node workflow-flow-audit.mjs [ROOT] [--local]');
    const result = audit(root, { local: args.includes('--local') });
    for (const error of result.errors) console.error('ERROR: ' + error);
    console.log('Workflow flow audit: ' + result.mode + '; features=' + result.count + (result.templateOnly ? '; starter templates only' : ''));
    console.log('Evidence contents and live agent behavior still require review.');
    console.log('Result: ' + (result.errors.length ? 'FAIL' : 'PASS'));
    process.exitCode = result.errors.length ? 2 : 0;
  } catch (error) { console.error('ERROR: ' + error.message); process.exitCode = 1; }
}
