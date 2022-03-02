defmodule TriadApiWeb.UserSocket do
  use Phoenix.Socket

  alias TriadApi.Accounts
  ## Channels
  channel "room:*", TriadApiWeb.RoomChannel
  channel "game:*", TriadApiWeb.GameChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  @impl true
  def connect(params, socket, _connect_info) do
    %{"token" => token} = params
    case TriadApi.Guardian.decode_and_verify(token) do
      {:ok, %{"sub" => user_id}} ->
        user = Accounts.get_user!(user_id)
        socket = assign(socket, :user_id, user_id)
        socket = assign(socket, :user_name, user.email)
        {:ok, socket}
      {:error, _} ->
        :error
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     TriadApiWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(socket) do
    "user_socket:#{socket.assigns.user_id}"
  end
end
