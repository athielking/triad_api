defmodule GameStateMachine do
  @behaviour :gen_statem
  alias Triad.GameWorker

  # Client API
  def start_link(init_args) do
    %{game_id: game_id} = init_args

    via_tuple(game_id) |> :gen_statem.start_link(__MODULE__, init_args, [])
  end

  def connect(game_id, player_id) do
    via_tuple(game_id) |> :gen_statem.call({:connect, player_id})
  end
  def via_tuple(game_id) do
    {:via, Registry, {TriadApi.GameRegistry, "#{__MODULE__}:#{game_id}"}}
  end

  #Callbacks
  def callback_mode, do: :state_functions

  def init(init_args) do
    %{game_id: game_id} = init_args

    {:ok, :waiting_for_players, %{game_id: game_id, players: []}}
  end

  def waiting_for_players({:call, from}, payload, state) do
    %{game_id: game_id, players: _players} = state

    connect_result = case payload do
      {:connect, player_id} ->
        {:ok, %{players: connected_players}} = GameWorker.connect(game_id, player_id)
        {:connected, connected_players}
      _ -> {:error, "Unknown Call for current state"}
    end

    case connect_result do
      {:connected, connected_players} when length(connected_players) == 2 -> {:next_state, :game_starting, %{state | players: connected_players}, [{:reply, from, :waiting_for_players}]}
      {:connected, connected_players} -> {:next_state, :waiting_for_players, %{state | players: connected_players}, [{:reply, from, :waiting_for_players}]}
      {:error, message} -> {:stop, message}
    end
  end

  def game_starting({:call, from}, payload, state) do
  
  end
end
