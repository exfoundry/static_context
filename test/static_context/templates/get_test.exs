defmodule StaticContext.Templates.GetTest do
  use ExUnit.Case, async: true

  alias StaticContext.Test.Categories
  alias StaticContext.Test.Category

  describe "get/1" do
    test "returns entry for known id" do
      assert %Category{id: "news", name: "News"} = Categories.get("news")
    end

    test "returns nil for unknown id" do
      assert nil == Categories.get("nonexistent")
    end

    test "raises FunctionClauseError for atom id" do
      assert_raise FunctionClauseError, fn -> apply(Categories, :get, [:news]) end
    end
  end
end
