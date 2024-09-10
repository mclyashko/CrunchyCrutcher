defmodule WikipediaGraph.Application do
  use Application
  require Logger

  def start(_type, _args) do
    applications = [:bolt_sips]

    Enum.each(applications, fn app ->
      {:ok, _} = Application.ensure_all_started(app)
    end)

    case Bolt.Sips.start_link(Application.get_env(:bolt_sips, Bolt)) do
      {:ok, _pid} ->
        Logger.info("Bolt.Sips connection started successfully.")

      {:error, reason} ->
        raise("Failed to start Bolt.Sips: #{inspect(reason)}")
    end

    children = [
      %{
        id: WikipediaGraph.Processor.Fetcher,
        start: {WikipediaGraph.Processor.Fetcher, :start_link, []},
        restart: :permanent,
        type: :worker
      }
    ]

    opts = [strategy: :one_for_one, name: WikipediaGraph.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
