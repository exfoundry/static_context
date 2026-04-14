defmodule StaticContext.Templates.GetByTest do
  use ExUnit.Case, async: true

  alias StaticContext.Test.Categories
  alias StaticContext.Test.Category

  describe "get_by/1" do
    test "returns first matching entry" do
      assert %Category{id: "opinion"} = Categories.get_by(label: "Editorials")
    end

    test "returns nil when no match" do
      assert nil == Categories.get_by(name: "Nonexistent")
    end

    test "raises ArgumentError on unknown key" do
      assert_raise ArgumentError, ~r/Unknown key/, fn ->
        Categories.get_by(unknown: "value")
      end
    end
  end

  describe "get_by!/1" do
    test "returns first matching entry" do
      assert %Category{id: "opinion"} = Categories.get_by!(label: "Editorials")
    end

    test "raises ArgumentError when no match" do
      assert_raise ArgumentError, ~r/No.*entry found matching/, fn ->
        Categories.get_by!(name: "Nonexistent")
      end
    end

    test "raises ArgumentError on unknown key" do
      assert_raise ArgumentError, ~r/Unknown key/, fn ->
        Categories.get_by!(unknown: "value")
      end
    end
  end
end
