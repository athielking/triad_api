defmodule Triad.GameStateWorker  do
  use GenServer
  alias Games.Triad.PlayerState

  def start_link (init_args) do
    %{game_id: game_id} = init_args

    GenServer.start_link(__MODULE__, init_args, name: via_tuple(game_id))
  end

  def get_state(game_id) do
    via_tuple(game_id) |> GenServer.call(:get_state)
  end

  def connect_player(game_id, player_id) do
    via_tuple(game_id) |> GenServer.call({:connect, player_id})
  end

  def update_player(game_id, player_id, state) do
    via_tuple(game_id) |> GenServer.call({:update, player_id, state})
  end
  def via_tuple(game_id) do
    {:via, Registry, {TriadApi.GameRegistry, "#{__MODULE__}:#{game_id}"}}
  end

  def init(init_args) do
    %{game_id: game_id, rows: rows, cols: cols} = init_args
    {:ok,
      %{
        game_id: game_id,
        max_x: cols,
        max_y: rows,
        players: [],
        active: nil,
      }
    }
  end

  #callbacks
  def handle_call(:get_state,  _from,  state) do
    {:reply, {:ok, state}, state}
  end

  def handle_call({:connect, player_id}, _from, state) do
    state = if length(state.players) < 2 do
      %{state| players: [player_id | state.players]}
    else
      state
    end

    state = if length(state.players) == 2 do
      index = rem(:os.system_time(:millisecond), 2)

      %{state| active: Enum.at(state.players, index)}
    else
      state
    end

    state = if not(state |> Map.has_key?(player_id)) do
      state |> Map.put(player_id, PlayerState.init(player_id))
    else
      state
    end
    {:reply, {:ok, state}, state}
  end

  def handle_call({:update, player_id, new_state},  _from,  state) do

    state = %{state| player_id => new_state}

    {:reply, {:ok, state}, state}
  end
end
