defmodule WikipediaGraph.Db.Neo4J do
  def findUnprocessedPages() do
    query = """
    MATCH (p:Page {processed: false})
    RETURN p.title
    """

    case Bolt.Sips.query(Bolt.Sips.conn(), query) do
      {:ok, %Bolt.Sips.Response{results: results}} ->
        results
        |> Enum.map(fn page -> page["p.title"] end)

      {:error, error} ->
        {:error, error}
    end
  end

  def init(%{parent: parent_url}) do
    query = """
      CREATE (p:Page {title: $parent_url, processed: false})
    """

    params = %{
      parent_url: parent_url
    }

    case Bolt.Sips.query(Bolt.Sips.conn(), query, params) do
      {:ok, %Bolt.Sips.Response{results: results}} ->
        {:ok, results}

      {:error, error} ->
        {:error, error}
    end
  end

  def save(%{parent: parent_url, children: children_urls}) do
    query = """
      MERGE (p:Page {title: $parent_url})
      ON CREATE SET p.processed = true
      ON MATCH SET p.processed = true
      FOREACH (child_url IN $children_urls |
        MERGE (c:Page {title: child_url})
        ON CREATE SET c.processed = false
        MERGE (p)-[:LINKS]->(c)
      )
    """

    params = %{
      parent_url: parent_url,
      children_urls: children_urls
    }

    case Bolt.Sips.query(Bolt.Sips.conn(), query, params) do
      {:ok, %Bolt.Sips.Response{results: results}} ->
        {:ok, results}

      {:error, error} ->
        {:error, error}
    end
  end
end
