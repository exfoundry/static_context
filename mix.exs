defmodule StaticContext.MixProject do
  use Mix.Project

  @version "0.2.2"
  @source_url "https://github.com/exfoundry/static_context"

  def project do
    [
      app: :static_context,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      aliases: aliases(),
      description: description(),
      package: package(),
      name: "StaticContext",
      source_url: @source_url,
      docs: [
        main: "StaticContext",
        source_ref: "v#{@version}",
        extras: ["CHANGELOG.md"],
        skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  def cli do
    [preferred_envs: [precommit: :test]]
  end

  defp aliases do
    [
      precommit: [
        "compile --warning-as-errors",
        "deps.unlock --unused",
        "format --check-formatted",
        "test"
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp description do
    "In-memory lookup data with uniform query API."
  end

  defp deps do
    [
      {:ecto, "~> 3.5"},
      {:igniter, "~> 0.8", optional: true},
      {:ecto_sqlite3, "~> 0.22", only: :test},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Elias Forge"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "https://hexdocs.pm/static_context/changelog.html"
      },
      files: ~w(lib priv mix.exs .formatter.exs README.md CHANGELOG.md LICENSE usage-rules.md)
    ]
  end
end
