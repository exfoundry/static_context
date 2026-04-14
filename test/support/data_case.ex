defmodule StaticContext.Test.DataCase do
  @moduledoc """
  Case template for tests that hit the database.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use ExUnit.Case, async: false
      alias StaticContext.Test.Factory
      alias StaticContext.Test.Repo
    end
  end

  setup do
    StaticContext.Test.Repo.delete_all(StaticContext.Test.Article)
    StaticContext.Test.Repo.delete_all(StaticContext.Test.User)
    :ok
  end
end
