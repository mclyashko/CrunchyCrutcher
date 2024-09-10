defmodule WikipediaGraph.Neo4JMigration.BCreateWikipediaGraphProcessedIndex do
  def run do
    """
    // Создание индекса на поле processed узлов страниц, если его не было
    CREATE INDEX page_processed_index IF NOT EXISTS FOR (p:Page) ON (p.processed);
    """
  end
end
