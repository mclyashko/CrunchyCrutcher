defmodule WikipediaGraph.Processor.Fetcher do
  use GenServer
  require Logger

  def start_link do
    case GenServer.start_link(__MODULE__, :ok, name: __MODULE__) do
      {:ok, pid} ->
        GenServer.cast(__MODULE__, :ready)
        {:ok, pid}

      {:error, reason} ->
        Logger.error("Failed to start Fetcher: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_cast(:ready, state) do
    {:ok, pid} =
      Task.start_link(fn ->
        fetch_data_init()
      end)

    Process.monitor(pid)

    {:noreply, state}
  end

  @url_prefix "https://en.wikipedia.org"
  @default_start_page "/wiki/Elixir_(programming_language)"

  def fetch_data_init do
    Logger.info("Start fetch_data_init")
    unprocessedPages = WikipediaGraph.Db.Neo4J.findUnprocessedPages()

    if unprocessedPages == [] do
      {:ok, _res} = WikipediaGraph.Db.Neo4J.init(%{parent: @default_start_page})
      Logger.info("Restart fetch_data_init")
      fetch_data_init()
    else
      start_fetch(unprocessedPages)
    end
  end

  def start_fetch(start_pages) do
    start_pages
    |> Enum.each(&fetch_and_save_links(&1))
  end

  defp fetch_and_save_links(page) do
    url = @url_prefix <> String.replace(page, " ", "_")
    Logger.info("Fetching #{url}")

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, parsed_body} = body |> Floki.parse_document()

        children =
          parsed_body
          |> Floki.find("a")
          |> extract_links(page)

        IO.puts("page #{page}, children")
        IO.inspect(children)

        with {:ok, _res} <- WikipediaGraph.Db.Neo4J.save(%{parent: page, children: children}) do
        else
          {:error, reason} -> raise("Failed to save #{url}: #{reason}")
          _ -> raise("Failed to save #{url}")
        end

        Enum.each(WikipediaGraph.Db.Neo4J.findUnprocessedPages(), &fetch_and_save_links(&1))

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("Failed to fetch #{url}: #{reason}")
        fetch_and_save_links(page)
    end
  end

  defp extract_links(links, from_page) do
    links
    |> Enum.map(fn link ->
      link
      |> Floki.attribute("href")
      |> List.first()
    end)
    |> Enum.filter(fn link -> is_valid_link(link, from_page) end)
    |> Enum.uniq()
  end

  def is_valid_link(link, from_page) when is_binary(link) and is_binary(from_page) do
    link != from_page && String.starts_with?(link, "/wiki/") &&
      !(link in MapSet.new(["/wiki/Main_Page"])) &&
      !String.contains?(link, ":") && !String.contains?(link, "#") && !String.contains?(link, "?")
  end

  def is_valid_link(_, _), do: false
end
