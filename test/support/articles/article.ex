defmodule StaticContext.Test.Article do
  use Ecto.Schema
  import StaticContext.Schema

  schema "articles" do
    field :title, :string
    field :body, :string
    field :published, :boolean, default: false
    belongs_to :user, StaticContext.Test.User
    static_belongs_to(:category, StaticContext.Test.Categories)
    timestamps()
  end
end
