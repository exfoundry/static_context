defmodule StaticContext.Test.Repo do
  use Ecto.Repo, otp_app: :static_context, adapter: Ecto.Adapters.SQLite3
end
