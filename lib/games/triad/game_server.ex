defmodule Games.Triad.GameServer do

  use GenServer

  # API
  def start_link (init_args) do
      #%{game_id: game_id} = init_args
      GenServer.start_link(__MODULE__, init_args)
  end

  def init(init_args) do

  end

  def call(pid, payload), do: GenServer.call(pid, payload)

  # Callbacks

  def handle_call({:start, options},  _from,  state) do
    game_state = %{bogus: 'state'}

    {:reply, {:ok, game_state}, state}
  end
end
