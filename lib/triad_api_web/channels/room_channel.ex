defmodule TriadApiWeb.RoomChannel do
  use TriadApiWeb, :channel
  alias Games.Triad.GameServer
  alias TriadApiWeb.Presence

  @impl true
  def join("room:lobby", _payload, socket) do
    IO.puts("Player Joined Lobby")

    send self(), :after_join
    {:ok, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client

  def handle_in("create_game", payload, socket) do

    IO.puts "Create Game Message Received"
    %{"game_name" => game_name} = payload

    # Create the game record in the DB
    {:ok, game} = TriadApi.Games.create_game(%{playerIdOne: socket.assigns.user_id, started_at: DateTime.truncate(DateTime.utc_now(), :second)})

    # Start a new game server
    {:ok, _pid} = DynamicSupervisor.start_child(TriadApi.GameSupervisor, {Games.Triad.GameServer, %{game_id: game.id}})

    # Associate db id with pid
    #TriadApi.Registry.register(game.id, pid)

    Presence.track(self(), "OpenGames", game.id, %{name: game_name})
    broadcast socket, "game_created", %{game_id: game.id, name: game_name}

    {:reply, {:ok, %{game_id: game.id}}, socket}
  end

  def handle_in("join_game", payload, socket) do

    IO.puts "Join Game Message Received"
    %{"game_id" => game_id} = payload

    # get the game record in the DB
    TriadApi.Games.get_game!(game_id) |>
    TriadApi.Games.update_game(%{playerIdTwo: socket.assigns.user_id})

    Presence.untrack(self(), "OpenGames", game_id)
    broadcast socket, "game_joined", %{game_id: game_id}

    {:reply, {:ok, %{game_id: game_id}}, socket}
  end

  @impl true
  def handle_info(:after_join, socket) do

    {:ok, _} = Presence.track(socket, socket.assigns.user_id, %{name: socket.assigns.user_name})

    push socket, "presence_state", Presence.list(socket)
    push socket, "game_presence_state", Presence.list("OpenGames")
    push socket, "user_info", %{user_id: socket.assigns.user_id, name: socket.assigns.user_name}

    {:noreply, socket}
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

end
