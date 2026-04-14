defmodule StaticContext.Test.Tags do
  import StaticContext

  alias StaticContext.Test.Tag

  static_context struct: Tag do
    list()
    list_by()
    list_for()
    get()
    get!()
  end

  def entries do
    [
      %Tag{id: "elixir", name: "Elixir", category_id: "tutorial"},
      %Tag{id: "phoenix", name: "Phoenix", category_id: "tutorial"},
      %Tag{id: "breaking", name: "Breaking", category_id: "news"}
    ]
  end
end
