defmodule TriadApi.Registry do
  use GenServer

  # Client API
  def lookup(name) do
    GenServer.call(__MODULE__, {:lookup, name})
  end

  def register(name, pid) do
    GenServer.call(__MODULE__, {:register, name, pid})
  end

  def start_link (init_args) do
    GenServer.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  @impl true
  def init(init_arg) do
    names = %{}
    refs = %{}

    {:ok, {names, refs}}
  end

  @impl true
  def handle_call({:lookup, name}, _from, state) do
    {names, _} = state
    {:reply, Map.fetch(names, name), state}
  end

  @impl true
  def handle_call({:register, name, pid}, _from, {names, refs}) do
    if Map.has_key?(names, name) do
      {:reply, name, {names, refs}}
    else
      # Db Id -> Game Pid
      names = Map.put(names, name, pid)

      # Monitor the Game Pid for crashes
      ref = Process.monitor(pid)

      # Monitor Pid -> Db Id
      refs = Map.put(refs, ref, name)

      {:reply, name, {names, refs}}
    end
  end

  # Handle Game Processes Failing.  Keep Maps up to date
  @impl true
  def handle_info({:DOWN, ref, :process, pid, reason}, {names, refs}) do
    require Logger
    Logger.debug("DOWN Message received in TriadApi.Registry. PID: #{pid} Reason: #{reason}")

    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)

    {:noreply, {names, refs}}
  end

  # Catch All
  @impl true
  def handle_info(msg, state) do
    require Logger
    Logger.debug("Unexpected message in KV.Registry: #{inspect(msg)}")
    {:noreply, state}
  end

end
