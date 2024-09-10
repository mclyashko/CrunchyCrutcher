defmodule WikipediaGraph.Neo4JMigration.ACreateWikipediaGraphUniqueTitleConstraint do
  def run do
    """
    // Создание уникального ограничения для узлов страниц, если его не было
    CREATE CONSTRAINT page_title_unique IF NOT EXISTS ON (p:Page) ASSERT p.title IS UNIQUE;
    """
  end
end
