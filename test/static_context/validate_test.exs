defmodule StaticContext.ValidateTest do
  use ExUnit.Case, async: true

  alias StaticContext.Test.Category

  describe "StaticContext.Validate.validate_clauses!/2" do
    test "passes for valid keys" do
      assert :ok ==
               StaticContext.Validate.validate_clauses!(Category, id: "news", name: "News")
    end

    test "raises for unknown keys" do
      assert_raise ArgumentError, ~r/Unknown key/, fn ->
        StaticContext.Validate.validate_clauses!(Category, unknown: "value")
      end
    end
  end
end
