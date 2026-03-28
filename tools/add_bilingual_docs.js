#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const args = process.argv.slice(2);
const checkOnly = args.includes('--check');

const targetArgs = args.filter((arg) => arg !== '--check');
const targets = targetArgs.length > 0 ? targetArgs : ['hggzk_app/lib'];

function collectDartFiles(targetPath) {
  const fullPath = path.resolve(targetPath);
  if (!fs.existsSync(fullPath)) {
    return [];
  }

  const stat = fs.statSync(fullPath);
  if (stat.isFile()) {
    return fullPath.endsWith('.dart') ? [fullPath] : [];
  }

  const files = [];
  for (const entry of fs.readdirSync(fullPath, {withFileTypes: true})) {
    if (entry.name.startsWith('.')) {
      continue;
    }

    const entryPath = path.join(fullPath, entry.name);
    if (entry.isDirectory()) {
      files.push(...collectDartFiles(entryPath));
      continue;
    }

    if (entry.isFile() && entry.name.endsWith('.dart')) {
      files.push(entryPath);
    }
  }

  return files;
}

function stripPrivatePrefix(name) {
  return name.replace(/^_+/, '');
}

function quotedName(name) {
  return `\`${stripPrivatePrefix(name)}\``;
}

function classDocs(name) {
  const clean = stripPrivatePrefix(name);

  if (/State$/.test(clean)) {
    return [
      `/// English: Represents the state for ${quotedName(clean)}.`,
      `/// العربية: يمثل الحالة الخاصة بـ ${quotedName(clean)}.`,
    ];
  }

  if (/Widget$/.test(clean)) {
    return [
      `/// English: Represents the ${quotedName(clean)} widget.`,
      `/// العربية: يمثل العنصر ${quotedName(clean)}.`,
    ];
  }

  if (/Page$|Screen$/.test(clean)) {
    return [
      `/// English: Represents the ${quotedName(clean)} page.`,
      `/// العربية: يمثل الصفحة ${quotedName(clean)}.`,
    ];
  }

  if (/Bloc$/.test(clean)) {
    return [
      `/// English: Coordinates the ${quotedName(clean)} workflow and state.`,
      `/// العربية: ينسق سير العمل والحالة الخاصة بـ ${quotedName(clean)}.`,
    ];
  }

  if (/Cubit$/.test(clean)) {
    return [
      `/// English: Coordinates the ${quotedName(clean)} state.`,
      `/// العربية: ينسق الحالة الخاصة بـ ${quotedName(clean)}.`,
    ];
  }

  if (/Repository/.test(clean)) {
    return [
      `/// English: Represents the ${quotedName(clean)} repository contract or implementation.`,
      `/// العربية: يمثل المستودع ${quotedName(clean)} كعقد أو تنفيذ.`,
    ];
  }

  if (/UseCase$/.test(clean)) {
    return [
      `/// English: Executes the ${quotedName(clean)} use case.`,
      `/// العربية: ينفذ حالة الاستخدام ${quotedName(clean)}.`,
    ];
  }

  if (/Service$/.test(clean)) {
    return [
      `/// English: Provides the ${quotedName(clean)} service behavior.`,
      `/// العربية: يوفر سلوك الخدمة ${quotedName(clean)}.`,
    ];
  }

  if (/Model$/.test(clean)) {
    return [
      `/// English: Represents the ${quotedName(clean)} model.`,
      `/// العربية: يمثل النموذج ${quotedName(clean)}.`,
    ];
  }

  if (/Entity$/.test(clean)) {
    return [
      `/// English: Represents the ${quotedName(clean)} entity.`,
      `/// العربية: يمثل الكيان ${quotedName(clean)}.`,
    ];
  }

  if (/Event$/.test(clean)) {
    return [
      `/// English: Represents the ${quotedName(clean)} event.`,
      `/// العربية: يمثل الحدث ${quotedName(clean)}.`,
    ];
  }

  if (/Exception$/.test(clean)) {
    return [
      `/// English: Represents the ${quotedName(clean)} exception.`,
      `/// العربية: يمثل الاستثناء ${quotedName(clean)}.`,
    ];
  }

  if (/Failure$/.test(clean)) {
    return [
      `/// English: Represents the ${quotedName(clean)} failure.`,
      `/// العربية: يمثل الإخفاق ${quotedName(clean)}.`,
    ];
  }

  return [
    `/// English: Represents the ${quotedName(clean)} type.`,
    `/// العربية: يمثل النوع ${quotedName(clean)}.`,
  ];
}

function fieldDocs(name) {
  const clean = stripPrivatePrefix(name);

  if (/^(is|has|can|should)[A-Z_]/.test(clean)) {
    return [
      `/// English: Indicates whether ${quotedName(clean)} is enabled or available.`,
      `/// العربية: يحدد ما إذا كانت ${quotedName(clean)} مفعلة أو متاحة.`,
    ];
  }

  return [
    `/// English: Stores the ${quotedName(clean)} value.`,
    `/// العربية: يخزن القيمة ${quotedName(clean)}.`,
  ];
}

function methodDocs(name, kind) {
  const clean = stripPrivatePrefix(name);
  const specialCases = {
    copyWith: [
      'Creates a copy with the provided overrides.',
      'ينشئ نسخة مع استبدال القيم المحددة.',
    ],
    createState: [
      'Creates the widget state instance.',
      'ينشئ مثيل حالة الودجت.',
    ],
    initState: [
      'Initializes the state lifecycle.',
      'يهيئ دورة حياة الحالة.',
    ],
    dispose: [
      'Releases the allocated resources.',
      'يحرر الموارد المخصصة.',
    ],
    build: [
      'Builds the widget tree.',
      'يبني شجرة الودجت.',
    ],
    props: [
      'Returns the value equality properties.',
      'يعيد خصائص المساواة بالقيمة.',
    ],
    toJson: [
      'Converts the object to a JSON-compatible map.',
      'يحوّل الكائن إلى خريطة متوافقة مع JSON.',
    ],
    fromJson: [
      'Creates an instance from a JSON-compatible map.',
      'ينشئ مثيلاً من خريطة متوافقة مع JSON.',
    ],
  };

  if (specialCases[clean]) {
    return [
      `/// English: ${specialCases[clean][0]}`,
      `/// العربية: ${specialCases[clean][1]}`,
    ];
  }

  const prefixes = [
    ['build', 'Builds', 'يبني'],
    ['initialize', 'Initializes', 'يهيئ'],
    ['init', 'Initializes', 'يهيئ'],
    ['start', 'Starts', 'يبدأ'],
    ['stop', 'Stops', 'يوقف'],
    ['check', 'Checks', 'يتحقق من'],
    ['load', 'Loads', 'يحمل'],
    ['save', 'Saves', 'يحفظ'],
    ['update', 'Updates', 'يحدّث'],
    ['create', 'Creates', 'ينشئ'],
    ['get', 'Returns', 'يعيد'],
    ['set', 'Sets', 'يضبط'],
    ['toggle', 'Toggles', 'يبدل'],
    ['navigate', 'Navigates to', 'ينتقل إلى'],
    ['open', 'Opens', 'يفتح'],
    ['close', 'Closes', 'يغلق'],
    ['show', 'Shows', 'يعرض'],
    ['hide', 'Hides', 'يخفي'],
    ['handle', 'Handles', 'يعالج'],
    ['format', 'Formats', 'ينسق'],
    ['parse', 'Parses', 'يحلل'],
    ['map', 'Maps', 'يربط'],
    ['convert', 'Converts', 'يحوّل'],
    ['validate', 'Validates', 'يتحقق من صحة'],
    ['register', 'Registers', 'يسجل'],
    ['fetch', 'Fetches', 'يجلب'],
  ];

  for (const [prefix, englishVerb, arabicVerb] of prefixes) {
    if (clean.toLowerCase().startsWith(prefix)) {
      return [
        `/// English: ${englishVerb} ${quotedName(clean)}.`,
        `/// العربية: ${arabicVerb} ${quotedName(clean)}.`,
      ];
    }
  }

  if (kind === 'constructor') {
    return [
      `/// English: Creates a new ${quotedName(clean)} instance.`,
      `/// العربية: ينشئ مثيلاً جديدًا من ${quotedName(clean)}.`,
    ];
  }

  if (kind === 'getter') {
    return [
      `/// English: Returns the ${quotedName(clean)} value.`,
      `/// العربية: يعيد القيمة ${quotedName(clean)}.`,
    ];
  }

  return [
    `/// English: Handles ${quotedName(clean)}.`,
    `/// العربية: يعالج ${quotedName(clean)}.`,
  ];
}

function braceDelta(line) {
  let delta = 0;
  let inSingleQuote = false;
  let inDoubleQuote = false;
  let escaped = false;

  for (const char of line) {
    if (escaped) {
      escaped = false;
      continue;
    }

    if (char === '\\') {
      escaped = true;
      continue;
    }

    if (!inDoubleQuote && char === '\'') {
      inSingleQuote = !inSingleQuote;
      continue;
    }

    if (!inSingleQuote && char === '"') {
      inDoubleQuote = !inDoubleQuote;
      continue;
    }

    if (!inSingleQuote && !inDoubleQuote) {
      if (char === '{') {
        delta += 1;
      } else if (char === '}') {
        delta -= 1;
      }
    }
  }

  return delta;
}

function findInsertionIndex(lines, index) {
  let insertionIndex = index;
  while (insertionIndex > 0 && lines[insertionIndex - 1].trim().startsWith('@')) {
    insertionIndex -= 1;
  }
  return insertionIndex;
}

function hasDocBefore(lines, index) {
  let pointer = index - 1;

  while (pointer >= 0 && lines[pointer].trim() === '') {
    pointer -= 1;
  }

  while (pointer >= 0 && lines[pointer].trim().startsWith('@')) {
    pointer -= 1;
  }

  while (pointer >= 0 && lines[pointer].trim() === '') {
    pointer -= 1;
  }

  return pointer >= 0 && (
    lines[pointer].trim().startsWith('///') ||
    lines[pointer].trim().startsWith('/**')
  );
}

function analyzeFile(filePath) {
  const lines = fs.readFileSync(filePath, 'utf8').split('\n');
  const insertions = new Map();
  const missing = [];

  let depth = 0;
  const classStack = [];
  const methodStack = [];
  let pendingMethodDepth = null;

  for (let index = 0; index < lines.length; index += 1) {
    const line = lines[index];
    const trimmed = line.trim();
    const indentation = line.match(/^\s*/)[0];
    const indentationSize = indentation.length;

    while (classStack.length > 0 && depth < classStack[classStack.length - 1].depth) {
      classStack.pop();
    }

    while (methodStack.length > 0 && depth < methodStack[methodStack.length - 1]) {
      methodStack.pop();
    }

    if (pendingMethodDepth !== null && trimmed.includes('{')) {
      methodStack.push(pendingMethodDepth);
      pendingMethodDepth = null;
    }

    const currentClass = classStack[classStack.length - 1];
    const inMethod = methodStack.length > 0;
    let detected = null;

    const classMatch = trimmed.match(/^(abstract\s+class|class|enum|mixin)\s+([A-Za-z_][A-Za-z0-9_]*)/);
    if (classMatch) {
      const name = classMatch[2];
      detected = {kind: 'class', name, docs: classDocs(name)};
      if (trimmed.includes('{')) {
        classStack.push({name, depth: depth + 1});
      }
    } else if (/^extension\b/.test(trimmed)) {
      const extensionMatch = trimmed.match(/^extension\s+([A-Za-z_][A-Za-z0-9_]*)/);
      const name = extensionMatch ? extensionMatch[1] : 'extension';
      detected = {kind: 'class', name, docs: classDocs(name)};
      if (trimmed.includes('{')) {
        classStack.push({name, depth: depth + 1});
      }
    } else if (/^typedef\s+([A-Za-z_][A-Za-z0-9_]*)/.test(trimmed)) {
      const typedefMatch = trimmed.match(/^typedef\s+([A-Za-z_][A-Za-z0-9_]*)/);
      const name = typedefMatch[1];
      detected = {kind: 'class', name, docs: classDocs(name)};
    } else if (!inMethod) {
      const targetDepth = currentClass ? currentClass.depth : 0;
      const expectedIndentation = currentClass ? 2 : 0;
      if (depth === targetDepth) {
        if (currentClass) {
          const constructorPattern = new RegExp(
            `^(?:const\\s+|factory\\s+)?(${currentClass.name}(?:\\.[A-Za-z_][A-Za-z0-9_]*)?)\\s*\\(`
          );
          const constructorMatch = trimmed.match(constructorPattern);
          if (constructorMatch && indentationSize === expectedIndentation) {
            const name = constructorMatch[1];
            detected = {kind: 'constructor', name, docs: methodDocs(name, 'constructor')};
          }
        }

        if (!detected) {
          const getterMatch = trimmed.match(
            /^(?:static\s+)?(?:[A-Za-z_<>,? ]+\s+)?get\s+([A-Za-z_][A-Za-z0-9_]*)\b/
          );
          if (getterMatch && indentationSize === expectedIndentation) {
            const name = getterMatch[1];
            detected = {kind: 'getter', name, docs: methodDocs(name, 'getter')};
          }
        }

        if (!detected) {
          const fieldMatch = trimmed.match(
            /^(?:static\s+)?(?:late\s+|final\s+|const\s+|var\s+)?(?:[A-Za-z_<>,?]+(?:\s+[A-Za-z_<>,?]+)*)\s+([A-Za-z_][A-Za-z0-9_]*)\s*(?:=[^;]*)?;$/
          );
          if (
            fieldMatch &&
            indentationSize === expectedIndentation &&
            !trimmed.startsWith('return ') &&
            !trimmed.startsWith('case ') &&
            !trimmed.startsWith('assert(')
          ) {
            const name = fieldMatch[1];
            detected = {kind: 'field', name, docs: fieldDocs(name)};
          }
        }

        if (!detected) {
          const methodMatch = trimmed.match(
            /^(?:static\s+)?(?:external\s+)?(?:Future<[^>]+>|Future|Stream<[^>]+>|Widget|void|bool|int|double|String|Map<[^>]+>|List<[^>]+>|Set<[^>]+>|dynamic|[A-Z][A-Za-z0-9_<>?, ]+)\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(/
          );
          if (
            methodMatch &&
            indentationSize === expectedIndentation &&
            !['if', 'for', 'while', 'switch'].includes(methodMatch[1])
          ) {
            const name = methodMatch[1];
            detected = {kind: 'method', name, docs: methodDocs(name, 'method')};
          }
        }

        if (detected && ['method', 'constructor', 'getter'].includes(detected.kind)) {
          if (trimmed.includes('{')) {
            methodStack.push(depth + 1);
          } else if (!trimmed.endsWith('=>') && !trimmed.endsWith(';') && trimmed.includes('(')) {
            pendingMethodDepth = depth + 1;
          }
        }
      }
    }

    if (detected && !hasDocBefore(lines, index)) {
      const insertionIndex = findInsertionIndex(lines, index);
      if (!insertions.has(insertionIndex)) {
        insertions.set(insertionIndex, []);
      }
      insertions.get(insertionIndex).push(
        ...detected.docs.map((docLine) => `${indentation}${docLine}`)
      );
      missing.push({
        filePath,
        line: index + 1,
        kind: detected.kind,
        name: detected.name,
      });
    }

    depth += braceDelta(line);
  }

  return {lines, insertions, missing};
}

function applyInsertions(lines, insertions) {
  const output = [];
  for (let index = 0; index < lines.length; index += 1) {
    if (insertions.has(index)) {
      output.push(...insertions.get(index));
    }
    output.push(lines[index]);
  }
  return output.join('\n');
}

const files = targets.flatMap(collectDartFiles).sort();
let totalMissing = 0;

for (const filePath of files) {
  const {lines, insertions, missing} = analyzeFile(filePath);
  totalMissing += missing.length;

  if (!checkOnly && insertions.size > 0) {
    fs.writeFileSync(filePath, applyInsertions(lines, insertions));
  }

  if (checkOnly && missing.length > 0) {
    for (const item of missing) {
      const relativePath = path.relative(process.cwd(), item.filePath);
      console.log(`${relativePath}:${item.line} ${item.kind} ${item.name}`);
    }
  }
}

if (checkOnly) {
  console.log(`TOTAL_MISSING=${totalMissing}`);
} else {
  console.log(`UPDATED_FILES=${files.length}`);
  console.log(`INSERTED_DOCS=${totalMissing}`);
}
