#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

function collectDartFiles(entry) {
  const stat = fs.statSync(entry);

  if (stat.isFile()) {
    return entry.endsWith('.dart') ? [entry] : [];
  }

  const results = [];

  for (const child of fs.readdirSync(entry)) {
    results.push(...collectDartFiles(path.join(entry, child)));
  }

  return results;
}

function hasBilingualDocs(lines, index) {
  let cursor = index - 1;

  while (cursor >= 0 && lines[cursor].trim() === '') {
    cursor -= 1;
  }

  if (cursor < 0) {
    return false;
  }

  const docLines = [];

  while (cursor >= 0) {
    const trimmed = lines[cursor].trim();

    if (trimmed.startsWith('@')) {
      cursor -= 1;
      continue;
    }

    if (!trimmed.startsWith('///')) {
      break;
    }

    docLines.unshift(trimmed.replace(/^\/\/\/\s?/, ''));
    cursor -= 1;
  }

  if (docLines.length === 0) {
    return false;
  }

  const block = docLines.join('\n');
  return /[A-Za-z]/.test(block) && /[\u0600-\u06FF]/.test(block);
}

function isDeclaration(trimmed, currentType, state) {
  if (!trimmed || trimmed.startsWith('//')) {
    return false;
  }

  if (
    state.directiveContinuation ||
    state.expressionContinuation ||
    state.bracketDepth > 0
  ) {
    return false;
  }

  const memberDepth = currentType ? currentType.bodyDepth : 0;
  const isTopLevel = !currentType && state.braceDepth === 0;
  const isMemberLevel =
    currentType &&
    state.braceDepth === memberDepth &&
    state.parenDepth === 0;

  if (!isTopLevel && !isMemberLevel) {
    return false;
  }

  if (
    /^(abstract\s+class|class|enum|mixin)\s+[A-Za-z_][A-Za-z0-9_]*\b/.test(
      trimmed,
    ) ||
    /^extension\s+([A-Za-z_][A-Za-z0-9_]*)?\s+on\b/.test(trimmed) ||
    /^typedef\s+[A-Za-z_][A-Za-z0-9_]*\b/.test(trimmed)
  ) {
    return true;
  }

  const ownerName = currentType?.name;

  if (
    ownerName &&
    new RegExp(
      `^(?:const|factory)?\\s*(?:${ownerName}|${ownerName}\\.[A-Za-z_][A-Za-z0-9_]*)\\s*\\(`,
    ).test(trimmed)
  ) {
    return true;
  }

  if (
    trimmed.endsWith(';') &&
    !trimmed.includes('(') &&
    !/^(return|break|continue|assert|throw|import|export|part|library)\b/.test(
      trimmed,
    ) &&
    /^(?:static\s+)?(?:(?:late\s+)?(?:final|const|var)\s+)?(?:[A-Za-z_][A-Za-z0-9_<>,? ]+\s+)([A-Za-z_][A-Za-z0-9_]*)\s*(?:=.*)?;$/.test(
      trimmed,
    )
  ) {
    return true;
  }

  if (
    /^(?:static\s+)?(?:[A-Za-z_][A-Za-z0-9_<>,? ]+\s+)?get\s+[A-Za-z_][A-Za-z0-9_]*\b/.test(
      trimmed,
    ) ||
    /^(?:static\s+)?(?:[A-Za-z_][A-Za-z0-9_<>,? ]+\s+)?set\s+[A-Za-z_][A-Za-z0-9_]*\b/.test(
      trimmed,
    ) ||
    /^(?:static\s+)?(?:FutureOr<[^>]+>|Future<[^>]+>|Future|Stream<[^>]+>|Widget|void|bool\??|int\??|double\??|String\??|Map<[^>]+>\??|List<[^>]+>\??|Set<[^>]+>\??|dynamic|[A-Za-z_][A-Za-z0-9_<>,? ]+)\s+[A-Za-z_][A-Za-z0-9_]*\s*\(/.test(
      trimmed,
    )
  ) {
    return true;
  }

  return false;
}

function auditFile(filePath) {
  const input = fs.readFileSync(filePath, 'utf8');
  const lines = input.split('\n');
  const missing = [];
  const suspicious = [];

  const state = {
    braceDepth: 0,
    parenDepth: 0,
    bracketDepth: 0,
    directiveContinuation: false,
    expressionContinuation: false,
  };

  const typeStack = [];
  let pendingType = null;

  for (let index = 0; index < lines.length; index += 1) {
    const line = lines[index];
    const trimmed = line.trim();
    const currentType = typeStack[typeStack.length - 1] || null;

    if (
      trimmed.startsWith('/// English:') &&
      index + 1 < lines.length &&
      lines[index + 1].trim().startsWith('/// العربية:')
    ) {
      const english = trimmed;

      if (
        english.includes('Builds the build.') ||
        english.includes('Creates the state.') ||
        english.includes('Initializes the required operation for')
      ) {
        suspicious.push({
          line: index + 1,
          kind: 'awkward_doc_text',
          text: english,
        });
      }
    }

    if (isDeclaration(trimmed, currentType, state) && !hasBilingualDocs(lines, index)) {
      missing.push({
        line: index + 1,
        declaration: trimmed,
      });
    }

    const opens = (line.match(/{/g) || []).length;
    const closes = (line.match(/}/g) || []).length;
    const parenOpens = (line.match(/\(/g) || []).length;
    const parenCloses = (line.match(/\)/g) || []).length;
    const bracketOpens = (line.match(/\[/g) || []).length;
    const bracketCloses = (line.match(/\]/g) || []).length;

    const typeMatch = trimmed.match(
      /^(?:abstract\s+class|class|enum|mixin)\s+([A-Za-z_][A-Za-z0-9_]*)\b/,
    );
    const extensionMatch = trimmed.match(
      /^extension\s+([A-Za-z_][A-Za-z0-9_]*)?\s+on\b/,
    );

    if (typeMatch && opens > 0) {
      typeStack.push({
        name: typeMatch[1],
        bodyDepth: state.braceDepth + opens,
      });
    } else if (typeMatch) {
      pendingType = typeMatch[1];
    } else if (extensionMatch && opens > 0) {
      typeStack.push({
        name: extensionMatch[1] || 'extension',
        bodyDepth: state.braceDepth + opens,
      });
    } else if (extensionMatch) {
      pendingType = extensionMatch[1] || 'extension';
    }

    if (/^(import|export|part)\b/.test(trimmed) && !trimmed.endsWith(';')) {
      state.directiveContinuation = true;
    } else if (state.directiveContinuation && trimmed.endsWith(';')) {
      state.directiveContinuation = false;
    }

    if (
      !state.expressionContinuation &&
      /=>\s*$/.test(trimmed) &&
      !trimmed.endsWith(';')
    ) {
      state.expressionContinuation = true;
    } else if (state.expressionContinuation && trimmed.includes(';')) {
      state.expressionContinuation = false;
    }

    state.braceDepth += opens;
    state.braceDepth -= closes;
    state.parenDepth += parenOpens;
    state.parenDepth -= parenCloses;
    state.bracketDepth += bracketOpens;
    state.bracketDepth -= bracketCloses;

    if (pendingType && opens > 0 && !typeMatch && !extensionMatch) {
      typeStack.push({
        name: pendingType,
        bodyDepth: state.braceDepth,
      });
      pendingType = null;
    }

    while (
      typeStack.length &&
      state.braceDepth < typeStack[typeStack.length - 1].bodyDepth
    ) {
      typeStack.pop();
    }
  }

  return { missing, suspicious };
}

function main() {
  const rootArg = process.argv[2] || 'hggzk_app/lib';
  const root = path.resolve(process.cwd(), rootArg);

  if (!fs.existsSync(root)) {
    console.error(`Path not found: ${root}`);
    process.exit(1);
  }

  const files = collectDartFiles(root);
  let missingTotal = 0;
  let suspiciousTotal = 0;
  const samples = [];

  for (const file of files) {
    const result = auditFile(file);
    missingTotal += result.missing.length;
    suspiciousTotal += result.suspicious.length;

    for (const item of result.missing.slice(0, 5)) {
      if (samples.length >= 200) break;
      samples.push(`${file}:${item.line}: missing_docs: ${item.declaration}`);
    }

    for (const item of result.suspicious.slice(0, 5)) {
      if (samples.length >= 200) break;
      samples.push(`${file}:${item.line}: suspicious_docs: ${item.text}`);
    }
  }

  console.log(`FILES=${files.length}`);
  console.log(`MISSING_TOTAL=${missingTotal}`);
  console.log(`SUSPICIOUS_TOTAL=${suspiciousTotal}`);

  if (samples.length > 0) {
    console.log('SAMPLES_START');
    for (const sample of samples) {
      console.log(sample);
    }
    console.log('SAMPLES_END');
  }
}

if (require.main === module) {
  main();
}
