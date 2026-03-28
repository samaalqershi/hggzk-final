# Bilingual Documentation Style

This project uses bilingual Dart documentation comments for source declarations.

## Required Format

Every documented declaration should use consecutive `///` comments with both languages:

```dart
/// Arabic: ...
/// English: ...
```

## Scope

Apply bilingual documentation to:

- Classes, abstract classes, enums, mixins, extensions, and typedefs.
- Constructors, methods, top-level functions, getters, and setters.
- Properties and top-level constants/variables.

## Language Order

Use this order consistently:

1. `Arabic:`
2. `English:`

## Style Rules

- Keep both lines concise and API-focused.
- Mention the declaration name in backticks when useful.
- Prefer neutral, reusable wording for internal and public APIs.
- Avoid duplicating long implementation details inside the doc comment.
- Keep existing high-quality documentation when it already follows the bilingual spirit.

## Auto-Generated Baseline

For large-scale coverage, the project may generate a first-pass bilingual comment using stable templates.
That baseline is acceptable as a coverage floor, then modules can be refined later where richer wording is valuable.
