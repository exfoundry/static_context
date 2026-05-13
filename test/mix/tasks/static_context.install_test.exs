defmodule Mix.Tasks.StaticContext.InstallTest do
  use ExUnit.Case, async: true
  import Igniter.Test

  describe "static_context.install" do
    test "imports static_context into .formatter.exs" do
      test_project()
      |> Igniter.compose_task("static_context.install", [])
      |> assert_has_patch(".formatter.exs", """
      + |  import_deps: [:static_context]
      """)
    end
  end
end
