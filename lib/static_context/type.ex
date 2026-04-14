defmodule StaticContext.Type do
  @moduledoc """
  Parameterized Ecto type for `StaticContext` lookup modules.

  Stores the entry id as a string in the database.
  Loads the full struct via `module.get!/1` on read.
  Casts from a string id or an already-resolved struct.

  ## Usage in a schema

      field :mine_state_id, :string
      field :mine_state, StaticContext.Type, module: MineStates, source: :mine_state_id

  The `_id` field holds the raw string (used in changesets, forms, and DB storage).
  The virtual field holds the resolved struct (read-only, populated on DB load).
  """

  use Ecto.ParameterizedType

  @impl true
  @spec type(map()) :: :string
  def type(_params), do: :string

  @impl true
  @spec init(keyword()) :: map()
  def init(opts) do
    %{module: Keyword.fetch!(opts, :module)}
  end

  @impl true
  @spec cast(term(), map()) :: {:ok, struct() | nil} | {:error, keyword()} | :error
  def cast(nil, _params), do: {:ok, nil}

  def cast(value, %{module: module}) when is_binary(value) do
    {:ok, module.get!(value)}
  rescue
    ArgumentError -> {:error, message: "invalid id #{inspect(value)} for #{module}"}
  end

  def cast(value, %{module: module}) when is_struct(value) do
    case module.get!(value.id) do
      ^value -> {:ok, value}
      _ -> {:error, message: "struct does not belong to #{module}"}
    end
  rescue
    ArgumentError -> {:error, message: "struct does not belong to #{module}"}
    FunctionClauseError -> {:error, message: "struct does not belong to #{module}"}
  end

  def cast(_value, _params), do: :error

  @impl true
  @spec load(term(), function(), map()) :: {:ok, struct() | nil} | :error
  def load(nil, _loader, _params), do: {:ok, nil}

  def load(value, _loader, %{module: module}) when is_binary(value) do
    {:ok, module.get!(value)}
  rescue
    ArgumentError -> :error
  end

  def load(_value, _loader, _params), do: :error

  @impl true
  @spec dump(term(), function(), map()) :: {:ok, String.t() | nil} | :error
  def dump(nil, _dumper, _params), do: {:ok, nil}

  def dump(value, _dumper, _params) when is_binary(value) do
    {:ok, value}
  end

  def dump(value, _dumper, _params) when is_struct(value) do
    {:ok, to_string(value.id)}
  end

  def dump(_value, _dumper, _params), do: :error
end
