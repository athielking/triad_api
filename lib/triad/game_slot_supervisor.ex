defmodule Triad.GameSlotSupervisor do
  use DynamicSupervisor

  def start_link(arg) do
    %{game_id: game_id} = arg

    DynamicSupervisor.start_link(__MODULE__, arg, name: via_tuple(game_id))
  end

  def init(args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def via_tuple(game_id) do
    {:via, Registry, {TriadApi.GameRegistry, "#{__MODULE__}:#{game_id}"}}
  end

  def intialize_game_board(game_id, rows, cols) do

    for x <- 1..cols, y <- 1..rows do
      DynamicSupervisor.start_child(via_tuple(game_id), {Triad.GameSlotWorker, %{game_id: game_id, x: x, y: y}})
    end

  end

  def broadcast(game_id, payload) do
    via_tuple(game_id)
      |> DynamicSupervisor.which_children
      |> Enum.map(fn {_, pid, _, _} -> pid end)
      |> Enum.map(fn pid -> Task.async(fn -> GenServer.call(pid, payload) end) end)
      |> Enum.map(&Task.await/1)
  end

end
