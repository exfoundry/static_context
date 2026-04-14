defmodule StaticContext.Test.Categories do
  import StaticContext

  alias StaticContext.Test.Category

  static_context struct: Category do
    list()
    list_by()
    get()
    get!()
    get_by()
    get_by!()
  end

  def entries do
    [
      %Category{id: "news", name: "News", label: "Latest news"},
      %Category{id: "tutorial", name: "Tutorial", label: "How-to guides"},
      %Category{id: "opinion", name: "Opinion", label: "Editorials"}
    ]
  end
end
