defmodule Triad.GameWorker do
  use GenServer
  alias Triad.GameStateWorker
  alias TriadApi.Cards

  @spec start_link(%{:game_id => any, optional(any) => any}) ::
          :ignore | {:error, any} | {:ok, pid}
  def start_link (init_args) do
    %{game_id: game_id} = init_args

    GenServer.start_link(__MODULE__, init_args, name: via_tuple(game_id))
  end

  def connect(game_id, user_id) do
    via_tuple(game_id) |> GenServer.call({:connect, user_id})
  end

  def can_rejoin(game_id) do
    #via_tuple(game_id) |> GenServer.whereis != nil
    false
  end

  def rejoin(game_id, user_id) do
    if via_tuple(game_id) |> GenServer.whereis != nil do
      via_tuple(game_id) |> GenServer.call({:rejoin, user_id})
    else
      {:error, "Game Not Found"}
    end
  end

  def get_active_player(game_id) do
    via_tuple(game_id) |> GenServer.call(:get_active_player)
  end

  def draw_card(game_id, user_id) do
    via_tuple(game_id) |> GenServer.call({:draw_card, user_id})
  end

  def valid_placements(game_id, card_id) do
    via_tuple(game_id) |> GenServer.call({:valid_placements, card_id})
  end

  def place_card(game_id, card_id, x, y, player_id) do
    via_tuple(game_id) |> GenServer.call({:place_card, %{x: x, y: y, card_id: card_id, player_id: player_id}})
  end

  def via_tuple(game_id) do
    {:via, Registry, {TriadApi.GameRegistry, "#{__MODULE__}:#{game_id}"}}
  end

  def init(init_args) do
    %{game_id: game_id} = init_args

    send(self(), {:initialize_board, init_args})

    {:ok, %{game_id: game_id}}
  end

  # Callbacks
  def handle_info({:initialize_board, init_args}, state) do
    %{game_id: game_id, rows: rows, cols: cols} = init_args

    DynamicSupervisor.start_child(Triad.GameSupervisor, {Triad.GameSlotSupervisor, init_args})

    Triad.GameSlotSupervisor.intialize_game_board(game_id, rows, cols)

    {:noreply, state}
  end

  def handle_call({:connect, player_id},  _from,  state) do
    %{game_id: game_id} = state

    {:ok, game_state} = GameStateWorker.connect_player(game_id, player_id)

    {:reply, {:ok, game_state}, state}
  end

  def handle_call({:draw_card, player_id}, _from, state) do
    %{game_id: game_id} = state

    {:ok, game_state} = GameStateWorker.get_state(game_id)
    player_state = game_state[player_id]

    [drawn] = player_state.deck |> Enum.take(1)

    card = Cards.get_card!(drawn)

    # Update State
    player_state = %{player_state | hand: [drawn] |> Enum.concat(player_state.hand), deck: player_state.deck -- [drawn], graveyard: player_state.graveyard}
    GameStateWorker.update_player(game_id, player_id, player_state)

    {:reply, {:ok, %{card: card, deck_count: player_state.deck |> Enum.count}}, state}
  end

  def handle_call({:rejoin, _player_id}, _from, state) do
    %{game_id: game_id} = state

    game_state = GameStateWorker.get_state(game_id)
    [id_one, id_two | _] = game_state.players

    # %{1 => id_one, 2 => id_two} = game_state.players
    %{
      ^id_one => %{
        hand: hand_one,
        deck: deck_one,
        graveyard: gy_one
      },
      ^id_two => %{
        hand: hand_two,
        deck: deck_two,
        graveyard: gy_two
      }
    } = game_state

    hand_one_cards = Cards.get_cards!(hand_one)
    gy_one_cards = Cards.get_cards!(gy_one)
    hand_two_cards = Cards.get_cards!(hand_two)
    gy_two_cards = Cards.get_cards!(gy_two)

    rejoin_state = %{
      id_one => %{
        hand: hand_one_cards,
        deck: deck_one,
        graveyard: gy_one_cards
      },
      id_two => %{
        hand: hand_two_cards,
        deck: deck_two,
        graveyard: gy_two_cards
      },
      game_id: game_state.game_id,
      active: game_state.active
    }

    {:reply, {:ok, rejoin_state }, state}
  end

  def handle_call(:get_active_player, _from, state) do
    {:ok, %{active: active_player}} = GameStateWorker.get_state(state.game_id)

    {:reply, {:ok, active_player}, state}
  end

  def handle_call({:valid_placements, card_id}, _from, state) do
    %{game_id: game_id} = state

    _card = TriadApi.Cards.get_card!(card_id)

    open_placements = Triad.GameSlotSupervisor.broadcast(game_id, :is_open)
      |> Enum.filter(fn resp ->
        case resp do
          {:ok, slot} -> slot.is_open
          _ -> false
        end
      end)
      |> Enum.map(fn {:ok, %{x: x, y: y}} -> %{x: x, y: y} end)

    {:reply, {:ok, open_placements}, state}
  end

  def handle_call({:place_card, %{x: x, y: y, card_id: card_id, player_id: player_id}}, _from, state) do
    %{game_id: game_id} = state

    {:ok, placed} = Triad.GameSlotWorker.place_card(%{game_id: game_id, x: x, y: y, card_id: card_id, player_id: player_id})

    {:reply, {:ok, placed}, state}
  end
end
