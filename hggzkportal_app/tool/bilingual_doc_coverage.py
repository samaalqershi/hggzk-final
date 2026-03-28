#!/usr/bin/env python3
"""Scans and inserts bilingual Dart documentation comments.

The script is intentionally conservative:
- it only targets declaration-looking lines
- it skips generated files
- it preserves existing `///` and block doc comments
- it can report remaining undocumented declarations after a pass
"""

from __future__ import annotations

import argparse
import re
import sys
from collections import Counter, defaultdict
from dataclasses import dataclass
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_ROOT = PROJECT_ROOT / "lib"
GENERATED_SUFFIXES = (
    ".g.dart",
    ".freezed.dart",
    ".gr.dart",
    ".config.dart",
    ".mocks.dart",
)

CLASS_PATTERN = re.compile(
    r"^(?P<prefix>(?:base\s+|final\s+|sealed\s+|interface\s+)*)"
    r"(?:(?P<abstract>abstract)\s+)?"
    r"(?P<kind>class|enum|mixin)\s+"
    r"(?P<name>[A-Za-z_]\w*)\b"
)
EXTENSION_PATTERN = re.compile(
    r"^(?:base\s+)?extension(?:\s+type)?\s+(?P<name>[A-Za-z_]\w*)\b"
)
TYPEDEF_PATTERN = re.compile(r"^typedef\s+(?P<name>[A-Za-z_]\w*)\b")
ANNOTATION_PATTERN = re.compile(r"^@\w")
CONTROL_PATTERN = re.compile(
    r"^(if|for|while|switch|catch|return|assert|else|try|do|await)\b"
)
FIELD_START_PATTERN = re.compile(
    r"^(?:static\s+)?(?:late\s+)?(?:final\s+|const\s+|var\s+|covariant\s+|"
    r"external\s+|[\w<>\?\[\],\s]+\s+)(?P<name>[A-Za-z_]\w*)\s*(?:[=;,\)])"
)
GETTER_PATTERN = re.compile(
    r"^(?:static\s+)?(?:external\s+)?[\w<>\?\[\],\s]+\s+get\s+(?P<name>[A-Za-z_]\w*)\b"
)
SETTER_PATTERN = re.compile(
    r"^(?:static\s+)?(?:external\s+)?set\s+(?P<name>[A-Za-z_]\w*)\s*\("
)
METHOD_PATTERN = re.compile(
    r"^(?:static\s+)?(?:external\s+)?"
    r"(?:[\w<>\?\[\],\s]+\s+)?"
    r"(?P<name>[A-Za-z_]\w*|operator\s+[^\s(<]+)"
    r"(?:<[^>{;]+>)?\s*\("
)
TOP_LEVEL_VAR_PATTERN = re.compile(
    r"^(?:final|const|var|late\s+final|late\s+var|late\s+[\w<>\?\[\],\s]+|"
    r"[\w<>\?\[\],\s]+)\s+(?P<name>[A-Za-z_]\w*)\s*(?:=|;)"
)


@dataclass
class ContainerContext:
    kind: str
    name: str
    body_depth: int
    enum_values_open: bool = False


@dataclass
class Declaration:
    file_path: Path
    line_index: int
    kind: str
    name: str
    owner: str | None = None


@dataclass
class DocBlockInfo:
    exists: bool
    has_arabic: bool
    has_english: bool
    insertion_index: int


def is_generated(path: Path) -> bool:
    return any(path.name.endswith(suffix) for suffix in GENERATED_SUFFIXES)


def iter_dart_files(targets: list[str]) -> list[Path]:
    roots = [Path(target) for target in targets] if targets else [DEFAULT_ROOT]
    files: list[Path] = []
    for root in roots:
        full_root = root if root.is_absolute() else PROJECT_ROOT / root
        if full_root.is_file() and full_root.suffix == ".dart":
            if not is_generated(full_root):
                files.append(full_root)
            continue
        if full_root.is_dir():
            files.extend(
                sorted(
                    path
                    for path in full_root.rglob("*.dart")
                    if path.is_file() and not is_generated(path)
                )
            )
    return sorted(set(files))


def sanitize_line(line: str, in_block_comment: bool) -> tuple[str, bool]:
    result: list[str] = []
    i = 0
    in_single = False
    in_double = False
    while i < len(line):
        ch = line[i]
        nxt = line[i + 1] if i + 1 < len(line) else ""
        if in_block_comment:
            if ch == "*" and nxt == "/":
                in_block_comment = False
                i += 2
            else:
                i += 1
            continue
        if in_single:
            if ch == "\\":
                i += 2
                continue
            if ch == "'":
                in_single = False
            i += 1
            continue
        if in_double:
            if ch == "\\":
                i += 2
                continue
            if ch == '"':
                in_double = False
            i += 1
            continue
        if ch == "/" and nxt == "/":
            break
        if ch == "/" and nxt == "*":
            in_block_comment = True
            i += 2
            continue
        if ch == "'":
            in_single = True
            i += 1
            continue
        if ch == '"':
            in_double = True
            i += 1
            continue
        result.append(ch)
        i += 1
    return "".join(result), in_block_comment


def insertion_index(lines: list[str], line_index: int) -> int:
    idx = line_index
    while idx > 0:
        previous = lines[idx - 1].strip()
        if ANNOTATION_PATTERN.match(previous):
            idx -= 1
            continue
        break
    return idx


def has_doc_comment(lines: list[str], line_index: int) -> bool:
    idx = line_index - 1
    seen_content = False
    while idx >= 0:
        stripped = lines[idx].strip()
        if not stripped:
            if seen_content:
                break
            idx -= 1
            continue
        if stripped.startswith("///"):
            return True
        if stripped.endswith("*/"):
            while idx >= 0:
                if lines[idx].strip().startswith("/**"):
                    return True
                idx -= 1
            return False
        if stripped.startswith("@"):
            seen_content = True
            idx -= 1
            continue
        return False
    return False


def doc_block_info(lines: list[str], line_index: int) -> DocBlockInfo:
    idx = line_index - 1
    has_arabic = False
    has_english = False
    exists = False

    if idx >= 0 and lines[idx].strip().startswith("///"):
        exists = True
        while idx >= 0 and lines[idx].strip().startswith("///"):
            stripped = lines[idx].strip()
            has_arabic = has_arabic or "Arabic:" in stripped
            has_english = has_english or "English:" in stripped
            idx -= 1
        return DocBlockInfo(
            exists=exists,
            has_arabic=has_arabic,
            has_english=has_english,
            insertion_index=line_index,
        )

    if idx >= 0 and lines[idx].strip().endswith("*/"):
        exists = True
        while idx >= 0:
            stripped = lines[idx].strip()
            has_arabic = has_arabic or "Arabic:" in stripped
            has_english = has_english or "English:" in stripped
            if stripped.startswith("/**"):
                break
            idx -= 1
        return DocBlockInfo(
            exists=exists,
            has_arabic=has_arabic,
            has_english=has_english,
            insertion_index=line_index,
        )

    return DocBlockInfo(
        exists=False,
        has_arabic=False,
        has_english=False,
        insertion_index=line_index,
    )


def has_bilingual_doc_comment(lines: list[str], line_index: int) -> bool:
    info = doc_block_info(lines, line_index)
    return info.exists and info.has_arabic and info.has_english


def is_continuation_line(lines: list[str], line_index: int) -> bool:
    current_line = lines[line_index]
    current_indent = len(current_line) - len(current_line.lstrip())
    idx = line_index - 1
    while idx >= 0:
        previous = lines[idx].strip()
        if not previous or previous.startswith("///"):
            idx -= 1
            continue
        previous_indent = len(lines[idx]) - len(lines[idx].lstrip())
        if current_indent <= previous_indent:
            return False
        if previous.startswith("@"):
            return False
        if previous.endswith(("=", "(", "[", "{", ",", ":", "=>")):
            return True
        if "(" in previous and ")" not in previous:
            return True
        if not previous.endswith((";", "{", "}")):
            return True
        return False
    return False


def member_doc_lines(kind: str, name: str, owner: str | None) -> list[str]:
    label = f"`{name}`"
    owner_label = f"`{owner}`" if owner else "this type"
    if kind == "class":
        return [
            f"/// Arabic: يعرّف الكلاس {label}.",
            f"/// English: Defines the {label} class.",
        ]
    if kind == "abstract_class":
        return [
            f"/// Arabic: يعرّف الكلاس المجرد {label}.",
            f"/// English: Defines the abstract {label} class.",
        ]
    if kind == "enum":
        return [
            f"/// Arabic: يعرّف التعداد {label}.",
            f"/// English: Defines the {label} enum.",
        ]
    if kind == "mixin":
        return [
            f"/// Arabic: يوفّر الـ mixin {label}.",
            f"/// English: Provides the {label} mixin.",
        ]
    if kind == "extension":
        return [
            f"/// Arabic: يضيف الامتداد {label} سلوكاً إضافياً.",
            f"/// English: Adds extra behavior through the {label} extension.",
        ]
    if kind == "typedef":
        return [
            f"/// Arabic: يعرّف النوع {label}.",
            f"/// English: Defines the {label} typedef.",
        ]
    if kind == "constructor":
        return [
            f"/// Arabic: ينشئ مثيلاً من {owner_label}.",
            f"/// English: Creates an instance of {owner_label}.",
        ]
    if kind == "getter":
        return [
            f"/// Arabic: يعيد قيمة {label}.",
            f"/// English: Returns the {label} value.",
        ]
    if kind == "setter":
        return [
            f"/// Arabic: يحدّث قيمة {label}.",
            f"/// English: Updates the {label} value.",
        ]
    if kind == "field":
        return [
            f"/// Arabic: يخزن العضو {label}.",
            f"/// English: Stores the {label} member.",
        ]
    if kind == "top_level_field":
        return [
            f"/// Arabic: يعرّف القيمة العلوية {label}.",
            f"/// English: Defines the top-level {label} value.",
        ]
    if kind == "function":
        return [
            f"/// Arabic: ينفذ الدالة {label}.",
            f"/// English: Executes the {label} function.",
        ]
    if kind == "method":
        return [
            f"/// Arabic: ينفذ العملية {label}.",
            f"/// English: Executes the {label} operation.",
        ]
    return [
        f"/// Arabic: يعرّف العنصر {label}.",
        f"/// English: Defines the {label} declaration.",
    ]


def remove_parameter_doc_blocks(lines: list[str]) -> list[str]:
    cleaned: list[str] = []
    paren_depth = 0
    in_block_comment = False
    index = 0

    while index < len(lines):
        line = lines[index]
        sanitized, in_block_comment = sanitize_line(line, in_block_comment)
        current_paren_depth = paren_depth
        stripped = line.strip()

        if current_paren_depth > 0 and stripped.startswith("///"):
            block_end = index
            has_arabic = False
            has_english = False
            while block_end < len(lines) and lines[block_end].strip().startswith("///"):
                doc_line = lines[block_end].strip()
                has_arabic = has_arabic or "Arabic:" in doc_line
                has_english = has_english or "English:" in doc_line
                block_end += 1
            if has_arabic and has_english:
                index = block_end
                continue

        cleaned.append(line)
        paren_depth += sanitized.count("(") - sanitized.count(")")
        index += 1

    return cleaned


def collect_class_like(stripped: str) -> tuple[str, str] | None:
    match = CLASS_PATTERN.match(stripped)
    if match:
        kind = match.group("kind")
        name = match.group("name")
        if kind == "class" and match.group("abstract"):
            return "abstract_class", name
        return kind, name
    extension_match = EXTENSION_PATTERN.match(stripped)
    if extension_match:
        return "extension", extension_match.group("name")
    typedef_match = TYPEDEF_PATTERN.match(stripped)
    if typedef_match:
        return "typedef", typedef_match.group("name")
    return None


def detect_member(
    stripped: str,
    container: ContainerContext | None,
    depth: int,
) -> tuple[str, str, str | None] | None:
    if not stripped or CONTROL_PATTERN.match(stripped):
        return None
    if stripped.startswith(("class ", "enum ", "mixin ", "extension ", "typedef ")):
        return None
    if stripped.startswith("part ") or stripped.startswith("import "):
        return None
    if stripped.startswith("export ") or stripped.startswith("library "):
        return None

    if container is None and depth == 0:
        method_match = METHOD_PATTERN.match(stripped)
        if method_match:
            return "function", method_match.group("name"), None
        top_var_match = TOP_LEVEL_VAR_PATTERN.match(stripped)
        if top_var_match:
            return "top_level_field", top_var_match.group("name"), None
        return None

    if container is None or depth != container.body_depth:
        return None

    if container.kind == "enum" and container.enum_values_open and ";" not in stripped:
        return None

    constructor_patterns = (
        rf"^(?:const\s+|factory\s+)?{re.escape(container.name)}(?:\.(?P<named>[A-Za-z_]\w*))?\s*\(",
        rf"^(?:external\s+)?{re.escape(container.name)}(?:\.(?P<named>[A-Za-z_]\w*))?\s*\(",
    )
    for pattern in constructor_patterns:
        constructor_match = re.match(pattern, stripped)
        if constructor_match:
            ctor_name = constructor_match.groupdict().get("named")
            return (
                "constructor",
                f"{container.name}.{ctor_name}" if ctor_name else container.name,
                container.name,
            )

    getter_match = GETTER_PATTERN.match(stripped)
    if getter_match:
        return "getter", getter_match.group("name"), container.name

    setter_match = SETTER_PATTERN.match(stripped)
    if setter_match:
        return "setter", setter_match.group("name"), container.name

    method_match = METHOD_PATTERN.match(stripped)
    if method_match:
        return "method", method_match.group("name"), container.name

    if "(" not in stripped:
        field_match = FIELD_START_PATTERN.match(stripped)
        if field_match:
            return "field", field_match.group("name"), container.name

    return None


def analyze_lines(path: Path, lines: list[str]) -> list[Declaration]:
    declarations: list[Declaration] = []
    brace_depth = 0
    paren_depth = 0
    in_block_comment = False
    current_container: ContainerContext | None = None
    pending_container: tuple[str, str] | None = None

    for index, line in enumerate(lines):
        stripped = line.strip()
        sanitized, in_block_comment = sanitize_line(line, in_block_comment)
        sanitized_stripped = sanitized.strip()
        current_depth = brace_depth
        current_paren_depth = paren_depth

        if not sanitized_stripped:
            brace_depth += sanitized.count("{") - sanitized.count("}")
            paren_depth += sanitized.count("(") - sanitized.count(")")
            if current_container and brace_depth < current_container.body_depth:
                current_container = None
            continue

        if is_continuation_line(lines, index):
            brace_depth += sanitized.count("{") - sanitized.count("}")
            paren_depth += sanitized.count("(") - sanitized.count(")")
            if current_container and brace_depth < current_container.body_depth:
                current_container = None
            continue

        class_like = None
        combined_stripped = sanitized_stripped
        if index + 1 < len(lines):
            next_line = lines[index + 1]
            next_indent = len(next_line) - len(next_line.lstrip())
            current_indent = len(line) - len(line.lstrip())
            next_sanitized, _ = sanitize_line(next_line, False)
            next_stripped = next_sanitized.strip()
            if (
                next_stripped
                and next_indent > current_indent
                and not sanitized_stripped.endswith((";", "{", "}"))
            ):
                combined_stripped = f"{sanitized_stripped} {next_stripped}"

        if current_paren_depth == 0 and current_depth == 0:
            class_like = collect_class_like(sanitized_stripped)
            if class_like:
                decl_kind, decl_name = class_like
                declarations.append(
                    Declaration(
                        file_path=path,
                        line_index=insertion_index(lines, index),
                        kind=decl_kind,
                        name=decl_name,
                    )
                )
                if "{" in sanitized_stripped:
                    current_container = ContainerContext(
                        kind="enum" if decl_kind == "enum" else decl_kind,
                        name=decl_name,
                        body_depth=current_depth + 1,
                        enum_values_open=decl_kind == "enum",
                    )
                else:
                    pending_container = (decl_kind, decl_name)
        elif current_paren_depth == 0:
            member = detect_member(combined_stripped, current_container, current_depth)
            if member:
                decl_kind, decl_name, owner = member
                declarations.append(
                    Declaration(
                        file_path=path,
                        line_index=insertion_index(lines, index),
                        kind=decl_kind,
                        name=decl_name,
                        owner=owner,
                    )
                )

        open_count = sanitized.count("{")
        close_count = sanitized.count("}")
        open_paren_count = sanitized.count("(")
        close_paren_count = sanitized.count(")")
        brace_depth += open_count - close_count
        paren_depth += open_paren_count - close_paren_count

        if pending_container and open_count > 0:
            pending_kind, pending_name = pending_container
            current_container = ContainerContext(
                kind="enum" if pending_kind == "enum" else pending_kind,
                name=pending_name,
                body_depth=brace_depth,
                enum_values_open=pending_kind == "enum",
            )
            pending_container = None

        if current_container and current_container.kind == "enum" and ";" in sanitized_stripped:
            current_container.enum_values_open = False

        if current_container and brace_depth < current_container.body_depth:
            current_container = None

    return declarations


def analyze_file(path: Path) -> list[Declaration]:
    return analyze_lines(path, path.read_text(encoding="utf-8").splitlines())


def undocumented_declarations(path: Path) -> list[Declaration]:
    lines = path.read_text(encoding="utf-8").splitlines()
    undocumented: list[Declaration] = []
    for declaration in analyze_lines(path, lines):
        if not has_bilingual_doc_comment(lines, declaration.line_index):
            undocumented.append(declaration)
    return undocumented


def apply_docs_to_file(path: Path) -> int:
    original_lines = path.read_text(encoding="utf-8").splitlines()
    lines = remove_parameter_doc_blocks(original_lines)
    declarations = analyze_lines(path, lines)
    insertions: dict[int, list[str]] = {}
    seen = set()
    for declaration in declarations:
        key = (declaration.line_index, declaration.kind, declaration.name)
        if key in seen:
            continue
        seen.add(key)
        info = doc_block_info(lines, declaration.line_index)
        if info.exists and info.has_arabic and info.has_english:
            continue
        block = member_doc_lines(
            declaration.kind,
            declaration.name,
            declaration.owner,
        )
        missing_lines: list[str] = []
        if info.exists:
            if not info.has_arabic:
                missing_lines.append(block[0])
            if not info.has_english:
                missing_lines.append(block[1])
        else:
            missing_lines = block
        if missing_lines:
            insertions[info.insertion_index] = missing_lines
    if not insertions:
        if lines != original_lines:
            path.write_text("\n".join(lines) + "\n", encoding="utf-8")
            return 1
        return 0

    updated = lines[:]
    for index in sorted(insertions.keys(), reverse=True):
        indent = re.match(r"^\s*", updated[index]).group(0)
        updated[index:index] = [f"{indent}{line}" for line in insertions[index]]
    path.write_text("\n".join(updated) + "\n", encoding="utf-8")
    return len(insertions)


def run_scan(files: list[Path]) -> int:
    total = 0
    by_kind = Counter()
    by_file: dict[str, int] = defaultdict(int)
    for path in files:
        missing = undocumented_declarations(path)
        total += len(missing)
        for declaration in missing:
            by_kind[declaration.kind] += 1
            by_file[str(path.relative_to(PROJECT_ROOT))] += 1

    print(f"FILES_SCANNED {len(files)}")
    print(f"UNDOCUMENTED_DECLARATIONS {total}")
    print("BY_KIND")
    for kind, count in sorted(by_kind.items()):
        print(f"{kind} {count}")
    print("TOP_FILES")
    for file_name, count in sorted(by_file.items(), key=lambda item: (-item[1], item[0]))[:50]:
        print(f"{count} {file_name}")
    return 0 if total == 0 else 1


def run_apply(files: list[Path]) -> int:
    changed_files = 0
    inserted_comments = 0
    for path in files:
        count = apply_docs_to_file(path)
        if count:
            changed_files += 1
            inserted_comments += count
    print(f"FILES_CHANGED {changed_files}")
    print(f"DOC_BLOCKS_INSERTED {inserted_comments}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)

    scan_parser = subparsers.add_parser("scan", help="Report undocumented declarations.")
    scan_parser.add_argument("targets", nargs="*", help="Files or directories to scan.")

    apply_parser = subparsers.add_parser("apply", help="Insert missing bilingual doc comments.")
    apply_parser.add_argument("targets", nargs="*", help="Files or directories to update.")

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    files = iter_dart_files(getattr(args, "targets", []))
    if not files:
        print("No Dart files found.", file=sys.stderr)
        return 1
    if args.command == "scan":
        return run_scan(files)
    if args.command == "apply":
        return run_apply(files)
    parser.error("Unsupported command.")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
