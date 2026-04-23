Always follow the guidelines and rules defined in the `CODING_STANDARDS.md` file located in the root of this project. Before writing or refactoring any code, ensure you review those standards:

# Coding Standards

## 1. Architecture
- **SOLID Principles**: Always write code adhering to optimal SOLID principles for separation of concerns and maintainability.

## 3. Core Models
- **Immutable**: Plain Dart classes with `final` fields and a `copyWith()` method.
- **Serialization**: Always implement `toJson()`, `fromJson()`.
