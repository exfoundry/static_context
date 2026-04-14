defmodule StaticContext.Templates.ListByTest do
  use ExUnit.Case, async: true

  alias StaticContext.Test.Categories
  alias StaticContext.Test.Category

  describe "list_by/1" do
    test "returns entries matching a single clause" do
      assert [%Category{id: "news"}] = Categories.list_by(name: "News")
    end

    test "returns entries matching multiple clauses" do
      assert [%Category{id: "news"}] = Categories.list_by(id: "news", name: "News")
    end

    test "returns empty list when no match" do
      assert [] = Categories.list_by(name: "Nonexistent")
    end

    test "returns empty list when one clause does not match" do
      assert [] = Categories.list_by(id: "news", name: "Tutorial")
    end

    test "raises ArgumentError on unknown key" do
      assert_raise ArgumentError, ~r/Unknown key/, fn ->
        Categories.list_by(unknown: "value")
      end
    end
  end
end
