defmodule Games.Triad.GameServer do
  alias Games.Triad.GameState
  alias Games.Triad.PlayerState
  alias TriadApi.Games
  use GenServer

  # API
  def start_link (init_args) do
      %{game_id: game_id} = init_args

      GenServer.start_link(__MODULE__, init_args, name: via_tuple(game_id))
  end

  def start(game_id, user_id) do
    via_tuple(game_id) |> GenServer.call({:start, %{player_id: user_id}})
  end

  def get_state(game_id) do
    via_tuple(game_id) |> GenServer.call(:get_state)
  end

  def get_first_turn(game_id) do
    via_tuple(game_id) |> GenServer.call(:get_first_turn)
  end


  defp via_tuple(game_id) do
    {:via, Registry, {TriadApi.GameRegistry, game_id}}
  end

  def init(init_args) do
    %{game_id: game_id} = init_args

    game_state = %{game_id: game_id}
    players = %{1 => nil, 2 => nil, active: nil}
    {:ok, {game_state, players}}
  end

  def call(pid, payload), do: GenServer.call(pid, payload)

  # Callbacks

  def handle_call({:start, %{player_id: player_id}},  _from,  state) do
    {game_state, players} = state
    %{game_id: game_id} = game_state

    if players[1] === nil && players[2] === nil do
      %{playerIdOne: id_one, playerIdTwo: id_two} = Games.get_game!(game_id)
      %{players | 1 => id_one, 2 => id_two }
    end

    if not Map.has_key?(game_state, player_id) do
      game_state = game_state |> Map.put( player_id, PlayerState.init(player_id) )
    end

    {:reply, {:ok, game_state}, {game_state, players}}
  end

  def handle_call(:get_state,  _from,  state) do
    {game_state, _} = state
    {:reply, {:ok, game_state}, state}
  end

  def handle_call({:get_first_turn}, _from, state) do
    {game_state, players} = state

    if players[:active] === nil do
      rand_index = :rand.uniform(2)
      %{players | active: rand_index}
    end

    active_player_id = players[players[:active]]

    {:reply, {:ok, active_player_id}, {game_state, players}}
  end
end
