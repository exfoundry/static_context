# Changelog

## [0.2.1] - 2026-04-27

### Docs
- README: `static_belongs_to` expansion now reflects the `writable: :never` option.
- `usage-rules.md`: note that the struct field is load-only and warn against casting or writing it directly.

## [0.2.0] - 2026-04-27

### Changed
- **Breaking:** `static_belongs_to` now adds `writable: :never` to the struct field. The `_id` field remains the sole write path; the struct field is load-only. This fixes a duplicate-column error on `Repo.insert!` when both fields are set (e.g. via ExMachina lazy resolvers), but breaks any code that wrote the struct field directly via changeset or `struct!/2` and expected it to persist.

## [0.1.1] - 2026-04-17

### Added
- `usage-rules.md` — ships with the hex package so tools like `usage_rules`
  and memex `deps` sources can surface it to AI agents.

## [0.1.0] - 2026-04-13

### Added
- `static_context/2` macro for generating lookup functions for in-memory struct lists
- 7 generated functions: list, list_by, list_for, get, get!, get_by, get_by!
- `StaticContext.Schema` — `static_belongs_to` macro for Ecto schema integration
- `StaticContext.Type` — parameterized Ecto type bridging static lookups with Ecto
- `StaticContext.Validate` — runtime validation helpers
