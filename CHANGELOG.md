# Changelog

## [0.1.0] - 2026-04-13

### Added
- `static_context/2` macro for generating lookup functions for in-memory struct lists
- 7 generated functions: list, list_by, list_for, get, get!, get_by, get_by!
- `StaticContext.Schema` — `static_belongs_to` macro for Ecto schema integration
- `StaticContext.Type` — parameterized Ecto type bridging static lookups with Ecto
- `StaticContext.Validate` — runtime validation helpers
