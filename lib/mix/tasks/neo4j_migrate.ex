defmodule Mix.Tasks.Neo4JMigrate do
  use Mix.Task

  @shortdoc "Run database migrations"
  def run(_args) do
    Mix.Task.run("compile")

    applications = [:bolt_sips]

    Enum.each(applications, fn app ->
      {:ok, _} = Application.ensure_all_started(app)
    end)

    try do
      Mix.shell().info("Starting Bolt.Sips connection...")

      case Bolt.Sips.start_link(Application.get_env(:bolt_sips, Bolt)) do
        {:ok, _pid} ->
          Mix.shell().info("Bolt.Sips connection started successfully.")

        {:error, reason} ->
          Mix.raise("Failed to start Bolt.Sips: #{inspect(reason)}")
      end

      migrations_dir = Path.join(["lib", "wikipedia_graph", "neo4j_migrations"])

      unless File.dir?(migrations_dir) do
        Mix.raise("Migrations directory '#{migrations_dir}' does not exist")
      end

      Enum.each(Enum.sort(File.ls!(migrations_dir)), fn file ->
        module =
          Module.concat([
            WikipediaGraph,
            Neo4JMigration,
            Macro.camelize(file |> String.replace(".ex", ""))
          ])

        if Code.ensure_loaded?(module) do
          query = module.run()
          execute_query(query)
        else
          Mix.raise("Module #{module} could not be loaded")
        end
      end)
    after
      Enum.each(applications, fn app ->
        :ok = Application.stop(app)
      end)
    end
  end

  defp execute_query(query) when is_binary(query) do
    Mix.shell().info("Executing query: #{query}")

    case Bolt.Sips.transaction(Bolt.Sips.conn(), fn conn -> Bolt.Sips.query!(conn, query) end,
           timeout: 30_000
         ) do
      {:ok, _results} ->
        Mix.shell().info("Migration executed successfully")

      {:error, reason} ->
        Mix.raise("Error executing migration: #{reason}")
    end
  end
end
