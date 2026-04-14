defmodule StaticContext.Test.User do
  use Ecto.Schema

  schema "users" do
    field :name, :string
    field :is_admin, :boolean, default: false
    has_many :articles, StaticContext.Test.Article
    timestamps()
  end
end
