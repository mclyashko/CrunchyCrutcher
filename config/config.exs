import Config

config :wikipedia_graph, WikipediaGraph,
  request_timeout: System.get_env("WIKIPEDIA_REQUEST_TIMEOUT") || 50

config :bolt_sips, Bolt,
  url: System.get_env("NEO4J_URL", "bolt://localhost:7687"),
  basic_auth: [
    username: System.get_env("NEO4J_USERNAME", "neo4j"),
    password: System.get_env("NEO4J_PASSWORD", "password")
  ],
  pool_size:
    System.get_env("NEO4J_POOL_SIZE", "15")
    |> String.to_integer(),
  max_overflow:
    System.get_env("NEO4J_POOL_OVERFLOW", "5")
    |> String.to_integer()
