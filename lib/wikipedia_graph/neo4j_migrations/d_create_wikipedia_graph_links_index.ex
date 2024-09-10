defmodule WikipediaGraph.Neo4JMigration.DCreateWikipediaGraphLinksIndex do
  def run do
    """
    // Создание индекса на связи links узлов страниц, если его не было
    CREATE INDEX page_links_index IF NOT EXISTS FOR (p:Page) ON (p.LINKS);
    """
  end
end
