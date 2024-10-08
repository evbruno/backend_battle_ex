defmodule BackendBattle.AppRepo do
  use GenServer

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

  def member?(key, obj) do
    GenServer.call(__MODULE__, {:get_set, key, obj})
  end

  def info do
    GenServer.call(__MODULE__, :info)
  end

  def get_by_id(id) do
    GenServer.call(__MODULE__, {:get_by_id, id})
  end

  # Server Callbacks

  @impl true
  def handle_call({:get_set, key, obj}, _from, state) do
    case :ets.insert_new(:my_cache, {key, obj}) do
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

  def handle_call(:info, _from, state) do
    data = :ets.tab2list(:my_cache) |> Stream.map(&Tuple.to_list/1)
    {:reply, data, state}
  end
end
