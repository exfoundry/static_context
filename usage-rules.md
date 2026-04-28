# static_context usage rules

Macro DSL for in-memory lookup data (enums, types, statuses) that live in
code, not in the database. Uniform query API matching `ecto_context`'s
read functions. Pairs with `static_belongs_to` so Ecto schemas can
associate with static entries by string id.

## Minimal pattern

```elixir
defmodule MyApp.MineStates do
  import StaticContext

  alias MyApp.MineStates.MineState

  static_context struct: MineState do
    list()
    list_by()
    get()
    get!()
    get_by()
    get_by!()
  end

  def entries do
    [
      %MineState{id: "active",      name: "Active"},
      %MineState{id: "closed",      name: "Closed"},
      %MineState{id: "maintenance", name: "Maintenance"}
    ]
  end
end
```

The struct is a plain `defstruct` with `@enforce_keys [:id, :name]`:

```elixir
defmodule MyApp.MineStates.MineState do
  @enforce_keys [:id, :name]
  defstruct [:id, :name]
end
```

## Required callback

**`entries/0`** — `() -> [struct]`. Must be public (`def`, not `defp`).
Called at runtime for every query; no caching layer.

## Available functions

Declare only what you need. All ids are **strings**, not atoms.

| Function | Signature | Returns |
|---|---|---|
| `list` | `list()` | `[struct]` |
| `list_by` | `list_by(clauses)` | `[struct]` (AND match) |
| `list_for` | `list_for(assoc, id)` | `[struct]` (by generated `<assoc>_id`) |
| `get` | `get(id)` | `struct \| nil` |
| `get!` | `get!(id)` | `struct` or raises `ArgumentError` |
| `get_by` | `get_by(clauses)` | first `struct \| nil` |
| `get_by!` | `get_by!(clauses)` | first `struct` or raises |

Clauses are keyword lists (`[name: "Active"]`), not maps. Unknown keys
(field typos) raise `ArgumentError` with the invalid key listed.

## `static_belongs_to` in Ecto schemas

```elixir
use Ecto.Schema
import StaticContext.Schema

schema "mines" do
  field :name, :string
  static_belongs_to :mine_state, MyApp.MineStates
end
```

Expands to:

- `field :mine_state_id, :string` — **the real DB column**. Cast this in
  changesets, validate it, use it in forms.
- `field :mine_state, StaticContext.Type, ...` — virtual, load-only
  (`writable: :never`). Auto-resolved on DB load by calling
  `MyApp.MineStates.get!/1`.

## Do

- **Use strings for ids everywhere** — struct id, DB column, params,
  changesets. `get("active")`, never `get(:active)`.
- **`@enforce_keys`** on struct to catch missing fields at compile time.
- **Cast only the `_id` field** in changesets; validate inclusion against
  `Enum.map(MyApp.MineStates.list(), & &1.id)`.
- **Use `list_for/2`** when filtering by an association — `list_for(:category, "news")`
  matches on the generated foreign key field, not the struct.

## Don't

- **Don't pass atoms to `get` / `get!`** — `get(:active)` raises
  `FunctionClauseError`. Only binaries match the guard.
- **Don't use maps for clauses** — `list_by(%{name: "X"})` won't work.
  Keyword list: `list_by(name: "X")`.
- **Don't expect OR semantics** — `list_by(a: 1, b: 2)` filters where
  both match. For OR, call twice and merge.
- **Don't cast or write the struct field directly** — `cast(attrs, [:mine_state])`
  or `%Mine{mine_state: %MineState{...}} |> Repo.insert!()` is silently
  dropped (`writable: :never`). Only the `_id` field persists.
- **Don't preload `static_belongs_to` via `Repo.preload` or `preload:`**
  — it is NOT an Ecto association. Silently does nothing or raises.
  Resolve by calling the static context directly: `MyApp.MineStates.get(record.mine_state_id)`.
- **Don't iterate `entries/0`** from call sites — use `list/0` or
  `list_by/1`. `entries/0` is the callback, not the public API.
- **Don't `def list/0`, `def get/1`, etc. yourself** — generated names
  clash.

## Configuration

None. `entries/0` is the sole data source.

## Testing

Test the `entries/0` shape (ids unique, required fields present) and any
computed fields. The generated query functions are covered upstream.

```elixir
test "ids are unique" do
  ids = MyApp.MineStates.list() |> Enum.map(& &1.id)
  assert ids == Enum.uniq(ids)
end
```

## Debugging the macro

See the generated functions in the compiled beam or inspect via:

```
deps/static_context/priv/templates/static_context/*.eex
```

Reading the template is the fastest way to understand `list_by/1` or
`get_by!/1` expansion.
