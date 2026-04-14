defmodule StaticContext.Schema do
  @moduledoc """
  Schema helpers for referencing static lookup modules from Ecto schemas.

  ## Usage

      import StaticContext.Schema

      schema "articles" do
        static_belongs_to :category, Categories
      end

  """

  @doc """
  Declares a `belongs_to`-style relationship to a static lookup module.

  Generates two fields: a `_id` string field for DB storage, and a virtual field
  backed by `StaticContext.Type` that loads the full struct on read.

  ## Example

      static_belongs_to :category, Categories

  Expands to:

      field :category_id, :string
      field :category, StaticContext.Type, module: Categories, source: :category_id

  """
  defmacro static_belongs_to(name, module) do
    id_field = :"#{name}_id"

    quote do
      field(unquote(id_field), :string)

      field(unquote(name), StaticContext.Type,
        module: unquote(module),
        source: unquote(id_field)
      )
    end
  end
end
