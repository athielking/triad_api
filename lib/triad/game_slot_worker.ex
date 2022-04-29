defmodule Triad.GameSlotWorker do
  use GenServer
  alias Phoenix.PubSub

  def start_link (init_args) do
    %{game_id: game_id, x: x, y: y} = init_args

    GenServer.start_link(__MODULE__, init_args, name: via_tuple(game_id, x, y))
  end

  def place_card(args) do
    %{game_id: game_id, x: x, y: y, card_id: card_id, player_id: player_id} = args
    via_tuple(game_id, x, y) |> GenServer.call({:place_card, %{card_id: card_id, player_id: player_id}})
  end

  def via_tuple(game_id, x, y) do
    {:via, Registry, {TriadApi.GameRegistry, "#{__MODULE__}:#{game_id}::x#{x}::y#{y}"}}
  end

  def init(init_args) do
    %{game_id: game_id, x: x, y: y} = init_args

    {:ok,
      %{
        game_id: game_id,
        x: x,
        y: y,
        cards: [],
        controlled_by: nil
      }
    }
  end

  def handle_call(:is_open, _from, state) do
    response = %{
      game_id: state.game_id,
      x: state.x,
      y: state.y,
      is_open: length(state.cards) == 0
    }

    {:reply, {:ok, response}, state}
  end

  def handle_call({:place_card, payload}, _from, state) do
    %{max_x: max_x, max_y: max_y} = Triad.GameStateWorker.get_state(state.game_id)
    %{x: x, y: y} = state
    %{card_id: card_id, player_id: player_id} = payload

    card = TriadApi.Cards.get_card!(card_id)

    state = %{state| cards: [card], controlled_by: player_id}

    card_payload = %{card: card, controlling_player: state.controlled_by, x: x, y: y}

    cond do
      x != max_x -> Triad.GameSlotWorker.via_tuple(state.game_id, x + 1, y) |> GenServer.cast({:card_placed, card_payload})
      x != 1 -> Triad.GameSlotWorker.via_tuple(state.game_id, x-1, y) |> GenServer.cast({:card_placed, card_payload})
      y != max_y -> Triad.GameSlotWorker.via_tuple(state.game_id, x, y + 1) |> GenServer.cast({:card_placed, card_payload})
      y != 1 -> Triad.GameSlotWorker.via_tuple(state.game_id, x, y-1) |> GenServer.cast({:card_placed, card_payload})
    end

    {:reply, {:ok, state}, state}
  end

  def handle_cast({:card_placed, %{card: placed_card, controlled_by: player_id, x: from_x, y: from_y}}, state) do

    case state do
      %{cards: []} -> {:noreply, state}
      %{controlled_by: current_controller} when current_controller === player_id -> {:noreply, state}
      %{cards: [card | _], x: x, y: y} ->
        {placed_power, power} = case {from_x, from_y, placed_card} do
          {from_x, _, placed_card} when from_x > x -> {placed_card.power_left, card.power_right}
          {from_x, _, placed_card} when from_x < x -> {placed_card.power_right, card.power_left}
          {_, from_y, placed_card} when from_y > y -> {placed_card.power_top, card.power_bottom}
          {_, from_y, placed_card} when from_y < y -> {placed_card.power_bottom, card.power_top}
        end

        case {placed_power, power} do
          {placed_power, power} when placed_power > power ->
            PubSub.broadcast(TriadApi.PubSub, "card_flipped", {:card_flipped, %{x: x, y: y, controlled_by: player_id}})
            {:noreply, %{state | controlled_by: player_id}}
          _ -> {:noreply, state}
        end
    end

  end
end
