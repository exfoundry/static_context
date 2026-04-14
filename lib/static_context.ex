defmodule StaticContext do
  @moduledoc """
  Generates standard data access functions for static lookup modules at compile time.

  Static lookup modules hold lists of structs defined in code, not the database —
  think lookup tables like states, types, or categories. The `static_context` block
  is the table of contents; everything below it is domain logic.

  String ids throughout. Matches DB storage, URL params, and form values with no
  atom/string boundary to cross.

  ## Usage

      import StaticContext

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
          %MineState{id: "production",           name: "Production"},
          %MineState{id: "care_and_maintenance", name: "Care and Maintenance"},
          %MineState{id: "closed",               name: "Closed"}
        ]
      end

  ## Generated functions

  | Function    | Signature              | Notes                                      |
  |-------------|------------------------|--------------------------------------------|
  | `list`      | `list()`               | All entries via `entries/0`                |
  | `list_by`   | `list_by(clauses)`     | Enum.filter with clause key validation     |
  | `list_for`  | `list_for(assoc, id)`  | Filter by `assoc_id` foreign key           |
  | `get`       | `get(id)`              | Binary-only guard, nil if not found        |
  | `get!`      | `get!(id)`             | Binary-only guard, raises if not found     |
  | `get_by`    | `get_by(clauses)`      | First match or nil                         |
  | `get_by!`   | `get_by!(clauses)`     | First match or raises                      |

  `get` and `get!` are guarded with `when is_binary(id)`. Passing an atom raises
  `FunctionClauseError` — intentional, enforces string ids at the call site.

  """

  @doc """
  Declares the generated functions for a static lookup module.

  Accepts a keyword list with `:struct` pointing to the struct module,
  and a `do` block containing function declarations like `list()`, `get!()`, `get_by()`.

  The calling module must define an `entries/0` function returning a list of structs.

  See the module documentation for the full list of supported functions.
  """
  defmacro static_context(context_opts_ast, do: block) do
    {context_opts, _} =
      context_opts_ast
      |> Macro.expand(__CALLER__)
      |> Code.eval_quoted([], __CALLER__)

    for declaration <- parse_declarations(block, __CALLER__) do
      declaration
      |> generate_function_string(context_opts)
      |> Code.string_to_quoted!()
    end
  end

  @doc false
  @spec generate_function_string(%{type: atom(), opts: keyword()}, keyword()) :: String.t()
  def generate_function_string(%{type: type, opts: _opts}, context_opts) do
    Path.join([
      :code.priv_dir(:static_context) |> to_string(),
      "templates",
      "static_context",
      "#{type}.ex.eex"
    ])
    |> EEx.eval_file(context_opts)
  end

  ###########################################################################
  ### AST parsing
  ###########################################################################

  @doc false
  @spec parse_declarations(Macro.t(), Macro.Env.t()) :: [%{type: atom(), opts: keyword()}]
  def parse_declarations({:__block__, _, calls}, caller_env) do
    Enum.map(calls, &parse_single_declaration(&1, caller_env))
  end

  def parse_declarations(ast_call, caller_env),
    do: [parse_single_declaration(ast_call, caller_env)]

  defp parse_single_declaration({function_name, _, raw_args}, caller_env) do
    {opts_ast} =
      case raw_args do
        [] -> {[]}
        [opts] -> {opts}
      end

    {evaluated_opts, _} = Code.eval_quoted(opts_ast, [], caller_env)

    %{type: function_name, opts: evaluated_opts}
  end
end
