#!/usr/bin/env node
// Read-only QA plan validation. It does not run tests or mutate workflow state.
import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { parseFeature, validateFeature, qaModules as allowedModules } from './workflow-flow-audit.mjs';

const none = value => ['', '-', '—', 'None', 'none'].includes((value ?? '').trim());

export function suggestedModules(feature, featureDir) {
  const result = new Set(['core']);
  const scope = feature.qaScope.toLowerCase();
  if (scope.includes('backend') || scope.includes('end-to-end')) result.add('backend-security');
  if (scope.includes('client') || scope.includes('end-to-end') || scope.includes('ui')) result.add('client-ui');
  if (scope.includes('content')) result.add('content');
  if (feature.contentDeclared && feature.contentGate !== 'Not Required') result.add('content');
  if (feature.visualDeclared && feature.visualScope !== 'none') result.add('visual-quality');
  if (existsSync(join(featureDir, 'game-dev.md'))) result.add('unity-ios');
  const architecturePath = join(featureDir, 'architecture.md');
  if (existsSync(architecturePath)) {
    const architecture = readFileSync(architecturePath, 'utf8');
    if (/\b(persist(?:ence|ed|ing)?|hydration|hydrate|realtime|websocket|async[- ]authority|out[- ]of[- ]order|state[- ]machine|multi[- ]actor|ordered|cyclic|migration|lifecycle)\b/i.test(architecture)) result.add('stateful-flow');
  }
  if (feature.qaStage === 'final' && feature.releaseScope !== 'none') result.add('release');
  return [...result];
}

export function preflight(root) {
  const featureRoot = join(root, 'features'), entries = existsSync(featureRoot)
    ? readdirSync(featureRoot, { withFileTypes: true }).filter(entry => entry.isDirectory()) : [];
  const features = [];
  for (const entry of entries) {
    const featureDir = join(featureRoot, entry.name), orchestration = join(featureDir, 'orchestration.md');
    if (!existsSync(orchestration)) continue;
    const feature = parseFeature(readFileSync(orchestration, 'utf8'));
    features.push({ feature, featureDir, orchestration });
  }
  const active = features.filter(({ feature }) => feature.owner === 'QA' && feature.status === 'In QA');
  const errors = [], warnings = [];
  if (active.length !== 1) {
    errors.push('exactly one In QA feature owned by QA is required; found ' + active.length);
    return { errors, warnings, feature: null, suggested: [] };
  }
  const selected = active[0], feature = selected.feature;
  errors.push(...validateFeature(feature).filter(error => /QA|Regression Depth|Evidence Reuse|visual|content|release readiness/i.test(error)));
  const suggested = suggestedModules(feature, selected.featureDir);
  if (!feature.qaPlanDeclared) {
    warnings.push('legacy orchestration: QA plan fields are absent; use the derived plan and let Tech Lead normalize on the next checkpoint');
  } else {
    const declared = new Set(feature.qaModules);
    for (const module of suggested) if (!declared.has(module)) errors.push('required QA module missing: ' + module);
    for (const module of feature.qaModules) {
      if (!allowedModules.includes(module)) errors.push('unknown QA module: ' + module);
      else if (!suggested.includes(module)) warnings.push('declared module has no deterministic trigger; confirm scope: ' + module);
    }
  }
  const requiredArtifacts = [join(selected.featureDir, 'prd.md'), join(selected.featureDir, 'architecture.md')];
  if (feature.contentDeclared && feature.contentGate !== 'Not Required' && feature.contentContract) {
    requiredArtifacts.push(resolve(selected.featureDir, feature.contentContract));
  } else if (!feature.contentDeclared && suggested.includes('content')) {
    warnings.push('legacy content quality fields absent; Tech Lead must normalize new/reopened content work; this is not a content quality PASS');
  }
  if (feature.qaPlanDeclared) {
    if (feature.qaModules.includes('backend-security')) requiredArtifacts.push(join(selected.featureDir, 'backend.md'), join(root, 'project-authority', 'setup-manifest.md'));
    if (feature.qaModules.includes('client-ui')) {
      const clients = ['frontend.md', 'game-dev.md'].map(name => join(selected.featureDir, name));
      if (!clients.some(existsSync)) errors.push('client-ui module requires frontend.md or game-dev.md');
    }
    if (feature.qaModules.includes('visual-quality')) requiredArtifacts.push(join(selected.featureDir, 'ui-design.md'), join(root, 'project-authority', 'design-foundation.md'));
    if (feature.qaModules.includes('content')) requiredArtifacts.push(join(selected.featureDir, 'content-design.md'));
    if (feature.qaModules.includes('release') && feature.qaStage === 'final') requiredArtifacts.push(join(selected.featureDir, 'release.md'), join(root, 'project-authority', 'release.md'));
  }
  for (const path of requiredArtifacts) if (!existsSync(path)) errors.push('required QA input missing: ' + path);
  if (feature.evidenceReuse === 'allowed' && none(feature.qaResult) === false) warnings.push('active QA should reset the prior QA Result before execution');
  return { errors: [...new Set(errors)], warnings: [...new Set(warnings)], feature, suggested, orchestration: selected.orchestration };
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  try {
    const args = process.argv.slice(2), root = args.shift() ?? 'ai-system';
    if (args.length) throw new Error('Usage: node qa-preflight.mjs [ROOT]');
    const result = preflight(root);
    if (result.feature) {
      console.log('QA feature: ' + result.feature.id);
      console.log('Stage / Scope: ' + result.feature.qaStage + ' / ' + result.feature.qaScope);
      console.log('Declared modules: ' + (result.feature.qaPlanDeclared ? result.feature.qaModules.join(', ') || 'none' : 'legacy/absent'));
      console.log('Suggested modules: ' + result.suggested.join(', '));
      console.log('Regression depth: ' + (result.feature.regressionDepth || 'legacy/absent'));
      console.log('Evidence reuse: ' + (result.feature.evidenceReuse || 'legacy/absent'));
    }
    for (const warning of result.warnings) console.warn('WARN: ' + warning);
    for (const error of result.errors) console.error('ERROR: ' + error);
    console.log('QA preflight is read-only; no tests were executed.');
    console.log('Result: ' + (result.errors.length ? 'FAIL' : 'PASS'));
    process.exitCode = result.errors.length ? 2 : 0;
  } catch (error) {
    console.error('ERROR: ' + error.message);
    process.exitCode = 1;
  }
}
