defmodule StaticContext.Templates.GetBangTest do
  use ExUnit.Case, async: true

  alias StaticContext.Test.Categories
  alias StaticContext.Test.Category

  describe "get!/1" do
    test "returns entry for known id" do
      assert %Category{id: "tutorial", name: "Tutorial"} = Categories.get!("tutorial")
    end

    test "raises ArgumentError for unknown id" do
      assert_raise ArgumentError, ~r/No.*entry found with id/, fn ->
        Categories.get!("nonexistent")
      end
    end

    test "raises FunctionClauseError for atom id" do
      assert_raise FunctionClauseError, fn -> apply(Categories, :get!, [:tutorial]) end
    end
  end
end
