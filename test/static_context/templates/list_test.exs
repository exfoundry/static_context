defmodule StaticContext.Templates.ListTest do
  use ExUnit.Case, async: true

  alias StaticContext.Test.Categories
  alias StaticContext.Test.Category

  describe "list/0" do
    test "returns all entries" do
      assert length(Categories.list()) == 3
    end

    test "returns structs of the correct type" do
      assert [%Category{} | _] = Categories.list()
    end

    test "returns empty list when entries/0 is empty" do
      defmodule EmptyCategories do
        import StaticContext

        static_context struct: StaticContext.Test.Category do
          list()
        end

        def entries, do: []
      end

      assert [] = EmptyCategories.list()
    end
  end
end
