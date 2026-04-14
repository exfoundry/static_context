import Config

config :static_context, StaticContext.Test.Repo,
  database: ":memory:",
  pool_size: 1,
  log: false
