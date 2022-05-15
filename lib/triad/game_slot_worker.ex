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
    {:ok, game_state} = Triad.GameStateWorker.get_state(state.game_id)
    %{max_x: max_x, max_y: max_y} = game_state
    %{x: x, y: y} = state
    %{card_id: card_id, player_id: player_id} = payload

    card = TriadApi.Cards.get_card!(card_id)

    state = %{state| cards: [card], controlled_by: player_id}

    card_payload = %{card: card, controlling_player: state.controlled_by, x: x, y: y}


      if x != max_x do
        IO.puts("Checking Card to the right")
        Triad.GameSlotWorker.via_tuple(state.game_id, x + 1, y) |> GenServer.cast({:card_placed, card_payload})
      end

      if x != 1 do
        IO.puts("Checking Card to the left")
        Triad.GameSlotWorker.via_tuple(state.game_id, x-1, y) |> GenServer.cast({:card_placed, card_payload})
      end

      if y != max_y do
        IO.puts("Checking Card Below")
        Triad.GameSlotWorker.via_tuple(state.game_id, x, y + 1) |> GenServer.cast({:card_placed, card_payload})
      end

      if y != 1 do
        IO.puts("Checking Card Above")
        Triad.GameSlotWorker.via_tuple(state.game_id, x, y-1) |> GenServer.cast({:card_placed, card_payload})
      end

    {:reply, {:ok, state}, state}
  end

  def handle_cast({:card_placed, %{card: placed_card, controlling_player: player_id, x: from_x, y: from_y}}, state) do
    case state do
      %{cards: []} ->
        IO.puts("No Cards in slot")
        {:noreply, state}
      %{controlled_by: current_controller} when current_controller === player_id ->
        IO.puts("Card Controlled by Same Player")
        {:noreply, state}
      %{cards: [card | _], x: x, y: y} ->

        IO.puts("Card Placed at #{from_x},#{from_y}. Evaluating #{x},#{y}")

        {placed_power, power} = case {from_x, from_y, placed_card} do
          {from_x, _, placed_card} when from_x > x -> {placed_card.power_left, card.power_right}
          {from_x, _, placed_card} when from_x < x -> {placed_card.power_right, card.power_left}
          {_, from_y, placed_card} when from_y > y -> {placed_card.power_top, card.power_bottom}
          {_, from_y, placed_card} when from_y < y -> {placed_card.power_bottom, card.power_top}
        end

        IO.puts("Placed Power #{placed_power} Card Power #{power}")

        case {placed_power, power} do
          {placed_power, power} when placed_power > power ->
            IO.puts("Flipping Card")
            PubSub.broadcast(TriadApi.PubSub, "card_flipped", {:card_flipped, %{x: x, y: y, controlled_by: player_id}})
            {:noreply, %{state | controlled_by: player_id}}
          _ ->
            IO.puts("Power not greater, no flip")
            {:noreply, state}
        end
    end

  end
end
