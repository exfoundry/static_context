# StaticContext

In-memory lookup data with uniform query API.

For data that lives in code, not the database — statuses, categories, types,
roles, or any fixed set of values. Define your entries as structs, declare
which query functions you need, and `static_context` generates them at
compile time. String ids throughout, matching DB storage and form values
with no atom/string boundary to cross.

Part of the [ExFoundry](https://github.com/exfoundry) family.
Pairs well with [`ecto_context`](https://github.com/exfoundry/ecto_context)
for database-backed contexts — both share the same `list` / `get` / `get_by`
query conventions.

## Installation

```elixir
def deps do
  [{:static_context, "~> 0.2"}]
end
```

With [Igniter](https://hex.pm/packages/igniter), the installer wires up `.formatter.exs` automatically:

```sh
mix igniter.install static_context
```

## Usage

```elixir
defmodule MyApp.Categories do
  import StaticContext

  alias MyApp.Category

  static_context struct: Category do
    list()
    list_by()
    list_for()
    get()
    get!()
    get_by()
    get_by!()
  end

  def entries do
    [
      %Category{id: "electronics", name: "Electronics", active: true},
      %Category{id: "clothing",    name: "Clothing",    active: true},
      %Category{id: "archived",    name: "Archived",    active: false}
    ]
  end
end
```

```elixir
Categories.list()
#=> [%Category{id: "electronics", ...}, ...]

Categories.get!("electronics")
#=> %Category{id: "electronics", name: "Electronics", active: true}

Categories.list_by(active: true)
#=> [%Category{id: "electronics", ...}, %Category{id: "clothing", ...}]
```

## Generated functions

| Function   | Signature            | Notes                                   |
|------------|----------------------|-----------------------------------------|
| `list`     | `list()`             | All entries via `entries/0`             |
| `list_by`  | `list_by(clauses)`   | Filter with clause key validation       |
| `list_for` | `list_for(assoc, id)`| Filter by `assoc_id` foreign key        |
| `get`      | `get(id)`            | Returns nil if not found                |
| `get!`     | `get!(id)`           | Raises if not found                     |
| `get_by`   | `get_by(clauses)`    | First match or nil                      |
| `get_by!`  | `get_by!(clauses)`   | First match or raises                   |

`get` and `get!` enforce string ids with a `when is_binary(id)` guard —
passing an atom raises `FunctionClauseError` at the call site.

## Ecto integration

`static_belongs_to` bridges static lookup modules with Ecto schemas. It stores
the id as a plain string in the database and resolves the full struct on load:

```elixir
defmodule MyApp.Article do
  use Ecto.Schema
  import StaticContext.Schema

  schema "articles" do
    field :title, :string
    static_belongs_to :category, MyApp.Categories
  end
end
```

This expands to:

```elixir
field :category_id, :string
field :category, StaticContext.Type, module: MyApp.Categories, source: :category_id, writable: :never
```

Use `category_id` in changesets and forms. The virtual `category` field is
populated automatically when the record is loaded from the database.

## Testing with ExMachina

Since static entries live in code, not the database, factories only need the
string id. Use ExMachina's lazy attributes to resolve the full struct
automatically — the function receives the struct being built and looks up
the entry by its id:

```elixir
def article_factory do
  %Article{
    title: sequence(:title, &"Article #{&1}"),
    category_id: "electronics",
    category: &Categories.get!(&1.category_id),
    status_id: "draft",
    status: &Statuses.get!(&1.status_id)
  }
end
```

No need to `insert` or `build` static entries — they already exist in code.
Set the `_id` field, and the lazy attribute resolves the struct. Override
in tests as usual:

```elixir
insert(:article, category_id: "clothing", status_id: "published")
```

## How it works

Each function declaration maps to an EEx template in
`priv/templates/static_context/`. At compile time the macro renders the
template and injects the result into the calling module via
`Code.string_to_quoted!/1`. No runtime overhead — the generated functions
are plain Elixir operating on the list returned by your `entries/0` function.

## License

MIT
