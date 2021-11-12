defmodule TriadServerWeb.RoomChannel do
  use TriadApiWeb, :channel
  alias Games.Triad.GameServer
  alias TriadApi.Games

  @impl true
  def join("room:lobby", _payload, socket) do
    IO.puts("Player Joined Lobby")

    {:ok, socket}
  end

  @impl true
  def join("room:" <> room_name, payload, socket) do
    IO.puts("Player Joined #{room_name}")

    %{"game_name" => game_name} = payload
    {:ok, pid} = get_game_server(game_name, room_name)

    IO.puts "Game Server Joined #{pid}"
    socket = socket |> assign(:game_pid, pid)

    {:ok, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client

  def handle_in("start_game", _payload, socket) do

    IO.puts "Start Game Message Received"

    # Create the game record in the DB
    {:ok, game} = TriadApi.Games.create_game(%{playerIdOne: 1, started_at: DateTime.truncate(DateTime.utc_now(), :second)})

    # Start a new game server
    {:ok, pid} = DynamicSupervisor.start_child(TriadApi.GameSupervisor, Games.Triad.GameServer)

    # Associate db id with pid
    Registry.register(TriadApi.GameRegistry, game.id, pid)

    {:reply, {:ok, game.id}, socket}
  end


  @impl true
  def handle_in("start", payload, socket) do

    IO.puts "Start Message Received"

    game_pid = socket.assigns.game_pid
    {:ok, game_state} = game_pid |> GameServer.call({:start, payload})
    {:reply, {:ok, game_state}, socket}
  end

  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room_channel:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # Private
  defp get_game_server(_game_name, room_name \\ "default") do
    {:ok, pid} = Games.Triad.GameServer.start_link(%{room_name: room_name})
  end
end
