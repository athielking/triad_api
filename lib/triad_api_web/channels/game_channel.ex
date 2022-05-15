defmodule TriadApiWeb.GameChannel do
  alias Triad.GameSupervisor
  alias Triad.GameWorker
  use TriadApiWeb, :channel

  @impl true
  def join("game:" <> game_id, _payload, socket) do
    if authorized?(game_id, socket) do
      socket = assign(socket, :game_id, game_id)
      {:ok, socket}
    else
      {:error, %{reason: "Game Not Found"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("connect", _payload, socket) do

    #{:ok, pid} = TriadApi.Registry.lookup(socket.assigns.game_id)
    {:ok, state} = GameWorker.connect(socket.assigns.game_id, socket.assigns.user_id)

    %{playerIdOne: id_one, playerIdTwo: id_two} = TriadApi.Games.get_game!(socket.assigns.game_id)

    if state |> Map.has_key?(id_one) && state |> Map.has_key?(id_two) do
      IO.puts("Game State has both players. game_started fired")
      :ok = TriadApiWeb.Endpoint.subscribe("card_flipped")
      send self(), :game_started
    end

    {:reply, :ok, socket}
  end

  @impl true
  def handle_in("rejoin", _payload, socket) do

    #{:ok, pid} = TriadApi.Registry.lookup(socket.assigns.game_id)
    case GameWorker.rejoin(socket.assigns.game_id, socket.assigns.user_id) do
      {:ok, state} -> {:reply, {:ok, state}, socket}
      {:error, message} -> {:reply, {:error, message}, socket}
      _ -> {:reply, {:error, "Rejoin attempt resulted in unknown state"}}
    end
  end

  @impl true
  def handle_in("draw_card", _payload, socket) do
    {:ok, draw_state} = GameWorker.draw_card(socket.assigns.game_id, socket.assigns.user_id)
    %{card: card} = draw_state

    broadcast socket, "card_drawn", %{player: socket.assigns.user_id, card: card}
    {:reply, {:ok, draw_state}, socket}
  end

  @impl true
  def handle_in("valid_placements", payload, socket) do
    #payloads from Godot come in the form of string keys
    %{"card_id" => card_id} = payload

    {:ok, valid_placements} = GameWorker.valid_placements(socket.assigns.game_id, card_id)
    {:reply, {:ok, valid_placements}, socket}
  end

  @impl true
  def handle_in("place_card", payload, socket) do
    #payloads from Godot come in the form of string keys
    %{"x" => x, "y" => y, "card_id" => card_id} = payload

    {:ok, state} = GameWorker.place_card(socket.assigns.game_id, card_id, x, y, socket.assigns.user_id)

    broadcast socket, "place_card", %{x: state.x, y: state.y, card_id: card_id, controlled_by: state.controlled_by}

    #noreply here because we broadcast to all clients above (so opponent can see cards placed)
    {:noreply, socket}
  end

  @impl true
  def handle_info(:game_started, socket) do
    #{:ok, pid} = TriadApi.Registry.lookup(socket.assigns.game_id)
    {:ok, active_player_id} = GameWorker.get_active_player(socket.assigns.game_id)

    broadcast socket, "game_started", %{active_player: active_player_id}

    {:noreply, socket}
  end

  def handle_info({:card_flipped, %{x: x, y: y, controlled_by: user_id}}, socket) do

    IO.puts("Card Flipped")

    broadcast socket, "card_flipped", %{x: x, y: y, controlled_by: user_id}

    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(game_id, socket) do
    game = TriadApi.Games.get_game!(game_id)

    game.playerIdOne == socket.assigns.user_id ||
    game.playerIdTwo == socket.assigns.user_id
  end
end
