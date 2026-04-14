defmodule StaticContext.Templates.ListForTest do
  use ExUnit.Case, async: true

  alias StaticContext.Test.Tag
  alias StaticContext.Test.Tags

  describe "list_for/2" do
    test "returns entries matching the association" do
      assert [%Tag{id: "elixir"}, %Tag{id: "phoenix"}] = Tags.list_for(:category, "tutorial")
    end

    test "returns empty list when no entries match" do
      assert [] = Tags.list_for(:category, "nonexistent")
    end

    test "returns single entry when one matches" do
      assert [%Tag{id: "breaking"}] = Tags.list_for(:category, "news")
    end
  end
end
