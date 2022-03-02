defmodule TriadApiWeb.GameChannel do
  alias Games.Triad.GameServer
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
  def handle_in("start", _payload, socket) do

    #{:ok, pid} = TriadApi.Registry.lookup(socket.assigns.game_id)
    {:ok, state} = GameServer.start(socket.assigns.game_id, socket.assigns.user_id)

    %{playerIdOne: id_one, playerIdTwo: id_two} = TriadApi.Games.get_game!(socket.assigns.game_id)

    if state |> Map.has_key?(id_one) && state |> Map.has_key?(id_two) do
      send self(), :game_started
    end

    {:reply, {:ok, state}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (game:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  @impl true
  def handle_info(:game_started, socket) do
    #{:ok, pid} = TriadApi.Registry.lookup(socket.assigns.game_id)
    {:ok, active_player_id} = GameServer.get_first_turn(socket.assigns.game_id)

    broadcast socket, "game_started", %{active_player: active_player_id}
  end


  # Add authorization logic here as required.
  defp authorized?(game_id, socket) do
    game = TriadApi.Games.get_game!(game_id)

    game.playerIdOne == socket.assigns.user_id ||
    game.playerIdTwo == socket.assigns.user_id
  end
end
