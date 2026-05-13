defmodule Mix.Tasks.StaticContext.Install.Docs do
  @moduledoc false

  def short_doc, do: "Applies static_context setup to the project"

  def example, do: "mix static_context.install"

  def long_doc do
    """
    #{short_doc()}

    Imports static_context into the project's `.formatter.exs`. Invoked
    automatically when static_context is added via `mix igniter.install`.

    ## Example

    ```sh
    #{example()}
    ```
    """
  end
end

if Code.ensure_loaded?(Igniter) do
  defmodule Mix.Tasks.StaticContext.Install do
    @shortdoc "#{__MODULE__.Docs.short_doc()}"

    @moduledoc __MODULE__.Docs.long_doc()

    use Igniter.Mix.Task

    @impl Igniter.Mix.Task
    def info(_argv, _composing_task) do
      %Igniter.Mix.Task.Info{
        group: :static_context,
        example: __MODULE__.Docs.example()
      }
    end

    @impl Igniter.Mix.Task
    def igniter(igniter) do
      igniter
      |> Igniter.Project.Formatter.import_dep(:static_context)
    end
  end
else
  defmodule Mix.Tasks.StaticContext.Install do
    @shortdoc "#{__MODULE__.Docs.short_doc()} | Install `igniter` to use"

    @moduledoc __MODULE__.Docs.long_doc()

    use Mix.Task

    @impl Mix.Task
    def run(_argv) do
      Mix.shell().error("""
      The task 'static_context.install' requires igniter. Please install igniter and try again.
      """)

      exit({:shutdown, 1})
    end
  end
end
