defmodule KV.Registry do
  use GenServer


  ## Client API
  
  @doc """
  Starts the registry

  `:name` is always required
  """
  def start_link(opts) do
    # 1. Pass the name to the GenServer's init
    server = Keyword.fetch!(opts, :name)

    GenServer.start_link(__MODULE__, server, opts)    
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    # 2. Lookup is now done directly in ETS, without accessing the server
    case :ets.lookup(server, name) do
      [{^name, pid}] -> {:ok, pid}
      [] -> :error
    end
  end

  @doc """
  Ensures there is a bucket associated to the given `name` in `server`
  """
  def create(server, name) do
    GenServer.call(server, {:create, name})
  end

  ## Server Callbacks

  def init(table) do
    # 3. We have replaced the names map by the ETS table
    names = :ets.new(table, [:named_table, read_concurrency: true])
    refs = %{}

    {:ok, {names, refs}} 
  end

  # 4. The handle_call callback for lookup was removed

  def handle_call({:create, name}, _from, {names, refs}) do
    # 5. Read and write to the ETS table instead of the map

    case lookup(names, name) do
      {:ok, _pid} ->
        {:reply, {names, refs}}
      :error -> 
        {:ok, pid} = KV.BucketSupervisor.start_bucket
        ref = Process.monitor(pid)
        refs = Map.put(refs, ref, name)
        :ets.insert(names, {name, pid})
        {:reply, pid, {names, refs}}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, reasons}, {names, refs}) do
    # 6. Delete from the ETS table instread of the map

    {name, refs} = Map.pop(refs, ref)
    :ets.delete(names, name)
    {:noreply, {names, refs}}
  end

  def handle_info(msg, state) do
    {:noreply, state}  
  end
  
end