defmodule BackendBattle.AppRepo do
  use GenServer

  alias BackendBattle.Message

  # Client API

  def start_link(_) do
    IO.puts("Starting AppCore")
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    IO.puts("Initializing AppCore")
    :ets.new(:my_cache, [:named_table, :public, read_concurrency: true])
    {:ok, %{}}
  end

  def member?(id, obj) do
    GenServer.call(__MODULE__, {:get_set, id, obj})
  end

  def info do
    GenServer.call(__MODULE__, :info)
  end

  def get_by_id(id) do
    GenServer.call(__MODULE__, {:get_by_id, id})
  end

  def find_by_term(t) do
    term = Message.term_to_search(t)
    GenServer.call(__MODULE__, {:find_by_term, term})
  end

  # Server Callbacks

  @impl true
  def handle_call({:get_set, id, obj}, _from, state) do
    txt = Message.term_to_search(obj)
    row = {txt, obj}

    case :ets.insert_new(:my_cache, {id, row}) do
      true -> {:reply, :new, state}
      false -> {:reply, :found, state}
    end
  end

  def handle_call({:get_by_id, id}, _from, state) do
    data =
      case :ets.lookup(:my_cache, id) do
        [] -> {:not_found, nil}
        [{_, obj}] -> {:ok, obj}
      end

    {:reply, data, state}
  end

  # :ets.fun2ms(fn {k, t} -> {k, t} end)
  @select_all [{{:"$1", :"$2"}, [], [{{:"$1", :"$2"}}]}]

  def handle_call({:find_by_term, term}, _from, state) do
    data =
      :ets.select(:my_cache, @select_all)
      |> Enum.reduce([], fn {id, {term0, obj}}, acc ->
        if String.contains?(term0, term) do
          [Map.put(obj, "id", id) | acc]
        else
          acc
        end
      end)
      |> case do
        [] -> {:not_found, nil}
        rows -> {:ok, rows}
      end

    {:reply, data, state}
  end

  def handle_call(:info, _from, state) do
    data = :ets.tab2list(:my_cache) |> Stream.map(&Tuple.to_list/1)
    {:reply, data, state}
  end
end
