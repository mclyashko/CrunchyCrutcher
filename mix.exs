defmodule WikipediaGraph.MixProject do
  use Mix.Project

  def project do
    [
      app: :wikipedia_graph,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {WikipediaGraph.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 2.2"},
      {:floki, "~> 0.36"},
      {:bolt_sips, "~> 2.0"}
    ]
  end
end
