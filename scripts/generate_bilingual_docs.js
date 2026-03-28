#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

/**
 * Splits an identifier into normalized words.
 * يحول المعرّف إلى كلمات مبسطة للاستخدام داخل الوصف.
 */
function splitWords(name) {
  return name
    .replace(/^_+/, '')
    .replace(/([a-z0-9])([A-Z])/g, '$1 $2')
    .replace(/([A-Z]+)([A-Z][a-z])/g, '$1 $2')
    .replace(/[._]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim()
    .toLowerCase();
}

/**
 * Removes private prefixes from identifiers for display purposes.
 * يزيل البوادئ الخاصة من المعرّفات عند عرضها داخل التوثيق.
 */
function normalizeName(name) {
  return name.replace(/^_+/, '');
}

/**
 * Builds a generic bilingual documentation block.
 * ينشئ كتلة توثيق ثنائية اللغة بشكل موحد.
 */
function docs(en, ar, indent = '') {
  return [`${indent}/// English: ${en}`, `${indent}/// العربية: ${ar}`];
}

/**
 * Maps type declarations to readable documentation.
 * يجهز وصفًا مناسبًا لتعريفات الأنواع المختلفة.
 */
function buildTypeDocs(kind, name, indent) {
  const clean = normalizeName(name);

  if (kind === 'enum') {
    return docs(
      `Defines the available values for \`${clean}\`.`,
      `يعرّف القيم المتاحة للنوع \`${clean}\`.`,
      indent,
    );
  }

  if (kind === 'extension') {
    return docs(
      `Defines the \`${clean}\` extension.`,
      `يعرّف الامتداد \`${clean}\`.`,
      indent,
    );
  }

  if (kind === 'typedef') {
    return docs(
      `Declares the \`${clean}\` type alias.`,
      `يعرّف الاسم المستعار للنوع \`${clean}\`.`,
      indent,
    );
  }

  if (/Page$|Screen$/.test(clean)) {
    return docs(
      `Represents the \`${clean}\` page widget.`,
      `يمثل عنصر الصفحة \`${clean}\`.`,
      indent,
    );
  }

  if (/Widget$/.test(clean)) {
    return docs(
      `Represents the \`${clean}\` widget.`,
      `يمثل العنصر \`${clean}\`.`,
      indent,
    );
  }

  if (/State$/.test(clean)) {
    return docs(
      `Represents the state for \`${clean}\`.`,
      `يمثل الحالة الخاصة بـ \`${clean}\`.`,
      indent,
    );
  }

  if (/Bloc$/.test(clean)) {
    return docs(
      `Coordinates the state and events for \`${clean}\`.`,
      `ينسق الحالة والأحداث الخاصة بـ \`${clean}\`.`,
      indent,
    );
  }

  if (/Cubit$/.test(clean)) {
    return docs(
      `Coordinates the state changes for \`${clean}\`.`,
      `ينسق تغيّرات الحالة الخاصة بـ \`${clean}\`.`,
      indent,
    );
  }

  if (/Repository(?:Impl)?/.test(clean)) {
    return docs(
      `Provides repository behavior for \`${clean}\`.`,
      `يوفر سلوك المستودع الخاص بـ \`${clean}\`.`,
      indent,
    );
  }

  if (/UseCase$/.test(clean)) {
    return docs(
      `Executes the \`${clean}\` use case.`,
      `ينفذ حالة الاستخدام \`${clean}\`.`,
      indent,
    );
  }

  if (/Service$/.test(clean)) {
    return docs(
      `Provides the services implemented by \`${clean}\`.`,
      `يوفر الخدمات التي ينفذها \`${clean}\`.`,
      indent,
    );
  }

  if (/DataSource$/.test(clean)) {
    return docs(
      `Provides the data-source behavior for \`${clean}\`.`,
      `يوفر سلوك مصدر البيانات الخاص بـ \`${clean}\`.`,
      indent,
    );
  }

  if (/Model$/.test(clean)) {
    return docs(
      `Represents the data model \`${clean}\`.`,
      `يمثل نموذج البيانات \`${clean}\`.`,
      indent,
    );
  }

  if (/Entity$/.test(clean)) {
    return docs(
      `Represents the domain entity \`${clean}\`.`,
      `يمثل الكيان المجالي \`${clean}\`.`,
      indent,
    );
  }

  if (/Event$/.test(clean)) {
    return docs(
      `Represents the event definition for \`${clean}\`.`,
      `يمثل تعريف الحدث \`${clean}\`.`,
      indent,
    );
  }

  return docs(
    `Represents \`${clean}\`.`,
    `يمثل \`${clean}\`.`,
    indent,
  );
}

/**
 * Builds documentation for fields, methods, and constructors.
 * يجهز وصفًا موحدًا للحقول والدوال والبنّاءات.
 */
function buildMemberDocs(kind, name, indent) {
  const clean = normalizeName(name);
  const words = splitWords(clean);

  if (kind === 'constructor') {
    return docs(
      `Creates a new \`${clean}\` instance.`,
      `ينشئ مثيلًا جديدًا من \`${clean}\`.`,
      indent,
    );
  }

  if (kind === 'field') {
    if (/^(is|has|can|should)[A-Z_]/.test(clean)) {
      return docs(
        `Indicates whether \`${clean}\` is enabled.`,
        `يحدد ما إذا كانت القيمة \`${clean}\` مفعلة.`,
        indent,
      );
    }

    return docs(
      `Stores the \`${clean}\` value.`,
      `يخزن القيمة \`${clean}\`.`,
      indent,
    );
  }

  if (kind === 'getter') {
    if (clean === 'props') {
      return docs(
        'Returns the equality properties for this instance.',
        'يعيد خصائص المساواة الخاصة بهذا الكائن.',
        indent,
      );
    }

    return docs(
      `Returns the \`${clean}\` value.`,
      `يعيد القيمة \`${clean}\`.`,
      indent,
    );
  }

  if (kind === 'setter') {
    return docs(
      `Updates the \`${clean}\` value.`,
      `يحدّث القيمة \`${clean}\`.`,
      indent,
    );
  }

  if (clean === 'initState') {
    return docs(
      'Initializes the state for this widget.',
      'يهيئ الحالة الخاصة بهذا العنصر.',
      indent,
    );
  }

  if (clean === 'dispose') {
    return docs(
      'Releases the resources used by this instance.',
      'يحرر الموارد المستخدمة بواسطة هذا الكائن.',
      indent,
    );
  }

  if (clean === 'build') {
    return docs(
      'Builds the widget tree for this component.',
      'يبني شجرة العناصر الخاصة بهذا المكوّن.',
      indent,
    );
  }

  if (clean === 'createState') {
    return docs(
      'Creates the state object for this widget.',
      'ينشئ كائن الحالة الخاص بهذا العنصر.',
      indent,
    );
  }

  if (clean === 'copyWith') {
    return docs(
      'Creates a copy of this object with the provided overrides.',
      'ينشئ نسخة من هذا الكائن مع استبدال القيم المحددة.',
      indent,
    );
  }

  if (clean === 'call') {
    return docs(
      'Executes the main behavior exposed by this callable object.',
      'ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.',
      indent,
    );
  }

  if (clean === 'fromJson') {
    return docs(
      'Creates an instance from the provided JSON payload.',
      'ينشئ مثيلًا من بيانات JSON المقدمة.',
      indent,
    );
  }

  if (clean === 'toJson') {
    return docs(
      'Converts this instance to a JSON representation.',
      'يحول هذا الكائن إلى تمثيل JSON.',
      indent,
    );
  }

  if (clean === 'fromMap') {
    return docs(
      'Creates an instance from the provided map.',
      'ينشئ مثيلًا من الخريطة المقدمة.',
      indent,
    );
  }

  if (clean === 'toMap') {
    return docs(
      'Converts this instance to a map representation.',
      'يحول هذا الكائن إلى تمثيل من نوع Map.',
      indent,
    );
  }

  const actionMap = {
    build: ['Builds', 'يبني'],
    initialize: ['Initializes', 'يهيئ'],
    init: ['Initializes', 'يهيئ'],
    start: ['Starts', 'يبدأ'],
    stop: ['Stops', 'يوقف'],
    check: ['Checks', 'يتحقق من'],
    load: ['Loads', 'يحمل'],
    save: ['Saves', 'يحفظ'],
    update: ['Updates', 'يحدّث'],
    create: ['Creates', 'ينشئ'],
    get: ['Returns', 'يعيد'],
    set: ['Sets', 'يضبط'],
    toggle: ['Toggles', 'يبدل'],
    navigate: ['Navigates to', 'ينتقل إلى'],
    open: ['Opens', 'يفتح'],
    close: ['Closes', 'يغلق'],
    show: ['Shows', 'يعرض'],
    hide: ['Hides', 'يخفي'],
    handle: ['Handles', 'يعالج'],
    format: ['Formats', 'ينسق'],
    parse: ['Parses', 'يحلل'],
    validate: ['Validates', 'يتحقق من صحة'],
    map: ['Maps', 'يحّول'],
    convert: ['Converts', 'يحوّل'],
    dispatch: ['Dispatches', 'يرسل'],
    register: ['Registers', 'يسجل'],
    remove: ['Removes', 'يزيل'],
    delete: ['Deletes', 'يحذف'],
    send: ['Sends', 'يرسل'],
    fetch: ['Fetches', 'يجلب'],
    resolve: ['Resolves', 'يحدد'],
    generate: ['Generates', 'ينشئ'],
    share: ['Shares', 'يشارك'],
    select: ['Selects', 'يختار'],
    listen: ['Listens to', 'يستمع إلى'],
  };

  const action = Object.keys(actionMap).find((prefix) =>
    clean.startsWith(prefix),
  );

  if (action) {
    const [enVerb, arVerb] = actionMap[action];
    const target = words.slice(action.length).trim();

    if (target) {
      return docs(
        `${enVerb} the ${target}.`,
        `${arVerb} ${target}.`,
        indent,
      );
    }

    return docs(
      `${enVerb} the required operation for \`${clean}\`.`,
      `${arVerb} العملية المطلوبة لـ \`${clean}\`.`,
      indent,
    );
  }

  return docs(
    `Handles \`${clean}\`.`,
    `يعالج \`${clean}\`.`,
    indent,
  );
}

/**
 * Returns whether the output buffer already ends with bilingual docs.
 * يتحقق مما إذا كان المخزن الحالي ينتهي أصلًا بتوثيق ثنائي اللغة.
 */
function hasTrailingBilingualDocs(lines) {
  let index = lines.length - 1;
  const docLines = [];

  while (index >= 0 && lines[index].trim() === '') {
    index -= 1;
  }

  while (index >= 0 && lines[index].trim().startsWith('@')) {
    index -= 1;
  }

  while (index >= 0 && lines[index].trim().startsWith('///')) {
    docLines.unshift(lines[index].trim().replace(/^\/\/\/\s?/, ''));
    index -= 1;
  }

  if (docLines.length === 0) {
    return false;
  }

  const block = docLines.join('\n');
  return /[A-Za-z]/.test(block) && /[\u0600-\u06FF]/.test(block);
}

/**
 * Collects all Dart files recursively.
 * يجمع جميع ملفات Dart بشكل递归.
 */
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

/**
 * Processes a single file and adds missing bilingual docs.
 * يعالج ملفًا واحدًا ويضيف التوثيق الثنائي المفقود.
 */
function processFile(filePath) {
  const input = fs.readFileSync(filePath, 'utf8');
  const lines = input.split('\n');
  const output = [];

  let braceDepth = 0;
  let parenDepth = 0;
  let bracketDepth = 0;
  let directiveContinuation = false;
  let expressionContinuation = false;
  let pendingAnnotations = [];
  let pendingType = null;
  const typeStack = [];
  let insertions = 0;

  function flushAnnotations() {
    if (pendingAnnotations.length) {
      output.push(...pendingAnnotations);
      pendingAnnotations = [];
    }
  }

  function currentType() {
    return typeStack[typeStack.length - 1] || null;
  }

  function currentMemberDepth() {
    const owner = currentType();
    return owner ? owner.bodyDepth : 0;
  }

  function addDocs(docLines) {
    output.push(...docLines);
    insertions += 1;
  }

  for (let index = 0; index < lines.length; index += 1) {
    const line = lines[index];
    const trimmed = line.trim();
    const indent = line.match(/^\s*/)?.[0] || '';
    const activeType = currentType();
    const memberDepth = currentMemberDepth();
    const isBalanced = parenDepth === 0 && bracketDepth === 0;
    const canDeclare = isBalanced && !directiveContinuation && !expressionContinuation;
    const isTopLevel = !activeType && braceDepth === 0 && canDeclare;
    const isMemberLevel = activeType && braceDepth === memberDepth && canDeclare;

    if (/^@/.test(trimmed)) {
      pendingAnnotations.push(line);
      continue;
    }

    let declarationDocs = null;
    let typeOpened = null;

    let match =
      trimmed.match(/^(abstract\s+class|class|enum|mixin)\s+([A-Za-z_][A-Za-z0-9_]*)\b/) ||
      trimmed.match(/^extension\s+([A-Za-z_][A-Za-z0-9_]*)?\s+on\b/) ||
      trimmed.match(/^typedef\s+([A-Za-z_][A-Za-z0-9_]*)\b/);

    if (match && (isTopLevel || isMemberLevel)) {
      let kind = 'class';
      let name = '';

      if (trimmed.startsWith('extension')) {
        kind = 'extension';
        name = match[1] || 'extension';
      } else if (trimmed.startsWith('typedef')) {
        kind = 'typedef';
        name = match[1];
      } else {
        kind = match[1].replace(/\s+/g, ' ');
        name = match[2];
      }

      declarationDocs = buildTypeDocs(
        kind === 'enum' ? 'enum' : kind === 'extension' ? 'extension' : kind === 'typedef' ? 'typedef' : 'class',
        name,
        indent,
      );

      if (trimmed.includes('{')) {
        typeOpened = {
          name,
          bodyDepth: braceDepth + (line.match(/{/g) || []).length,
        };
      } else if (kind !== 'typedef') {
        pendingType = name;
      }
    } else if (isMemberLevel || isTopLevel) {
      const ownerName = activeType?.name;

      if (
        ownerName &&
        (match = trimmed.match(
          new RegExp(
            `^(?:const|factory)?\\s*(${ownerName}(?:\\.[A-Za-z_][A-Za-z0-9_]*)?)\\s*\\(`,
          ),
        ))
      ) {
        declarationDocs = buildMemberDocs('constructor', match[1], indent);
      } else if (
        trimmed.endsWith(';') &&
        !trimmed.includes('(') &&
        !/^(return|break|continue|assert|throw|import|export|part|library)\b/.test(
          trimmed,
        ) &&
        (match = trimmed.match(
          /^(?:static\s+)?(?:(?:late\s+)?(?:final|const|var)\s+)?(?:[A-Za-z_][A-Za-z0-9_<>,? ]+\s+)([A-Za-z_][A-Za-z0-9_]*)\s*(?:=.*)?;$/,
        ))
      ) {
        declarationDocs = buildMemberDocs('field', match[1], indent);
      } else if (
        (match = trimmed.match(
          /^(?:static\s+)?(?:[A-Za-z_][A-Za-z0-9_<>,? ]+\s+)?get\s+([A-Za-z_][A-Za-z0-9_]*)\b/,
        ))
      ) {
        declarationDocs = buildMemberDocs('getter', match[1], indent);
      } else if (
        (match = trimmed.match(
          /^(?:static\s+)?(?:[A-Za-z_][A-Za-z0-9_<>,? ]+\s+)?set\s+([A-Za-z_][A-Za-z0-9_]*)\b/,
        ))
      ) {
        declarationDocs = buildMemberDocs('setter', match[1], indent);
      } else if (
        (match = trimmed.match(
          /^(?:static\s+)?(?:FutureOr<[^>]+>|Future<[^>]+>|Future|Stream<[^>]+>|Widget|void|bool\??|int\??|double\??|String\??|Map<[^>]+>\??|List<[^>]+>\??|Set<[^>]+>\??|dynamic|[A-Za-z_][A-Za-z0-9_<>,? ]+)\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(/,
        ))
      ) {
        declarationDocs = buildMemberDocs('method', match[1], indent);
      }
    }

    if (declarationDocs && !hasTrailingBilingualDocs(output)) {
      addDocs(declarationDocs);
    }

    flushAnnotations();
    output.push(line);

    const opens = (line.match(/{/g) || []).length;
    const closes = (line.match(/}/g) || []).length;
    const parenOpens = (line.match(/\(/g) || []).length;
    const parenCloses = (line.match(/\)/g) || []).length;
    const bracketOpens = (line.match(/\[/g) || []).length;
    const bracketCloses = (line.match(/\]/g) || []).length;

    if (/^(import|export|part)\b/.test(trimmed) && !trimmed.endsWith(';')) {
      directiveContinuation = true;
    } else if (directiveContinuation && trimmed.endsWith(';')) {
      directiveContinuation = false;
    }

    if (!expressionContinuation && /=>\s*$/.test(trimmed) && !trimmed.endsWith(';')) {
      expressionContinuation = true;
    } else if (expressionContinuation && trimmed.includes(';')) {
      expressionContinuation = false;
    }

    if (pendingType && opens > 0) {
      typeStack.push({
        name: pendingType,
        bodyDepth: braceDepth + opens,
      });
      pendingType = null;
    } else if (typeOpened) {
      typeStack.push(typeOpened);
    }

    braceDepth += opens;
    braceDepth -= closes;
    parenDepth += parenOpens;
    parenDepth -= parenCloses;
    bracketDepth += bracketOpens;
    bracketDepth -= bracketCloses;

    while (typeStack.length && braceDepth < typeStack[typeStack.length - 1].bodyDepth) {
      typeStack.pop();
    }
  }

  if (pendingAnnotations.length) {
    output.push(...pendingAnnotations);
  }

  const next = output.join('\n');

  if (next !== input) {
    fs.writeFileSync(filePath, next);
  }

  return insertions;
}

function main() {
  const rootArg = process.argv[2] || 'hggzk_app/lib';
  const root = path.resolve(process.cwd(), rootArg);

  if (!fs.existsSync(root)) {
    console.error(`Path not found: ${root}`);
    process.exit(1);
  }

  const files = collectDartFiles(root);
  let totalInsertions = 0;

  for (const file of files) {
    totalInsertions += processFile(file);
  }

  console.log(`Processed ${files.length} files.`);
  console.log(`Inserted ${totalInsertions} documentation blocks.`);
}

if (require.main === module) {
  main();
}

module.exports = {
  processFile,
  collectDartFiles,
};
