defmodule Games.Triad.GameServerTest do
  use ExUnit.Case
  alias Games.Triad.GameServer
  @start_options %{player_name: 'Bob'}

  test "We start a server and get an initial game state" do

    step "I start the game and enter the default room"
    {:ok, pid} = GameServer.start_link(%{room_name: 'default'})

    step "I request to start a game and receive my initial state"
    {:ok, game_state} = pid |> GameServer.call({:start, @start_options})
  end

  def step (message) do

  end
end
