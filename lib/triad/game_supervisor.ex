defmodule Triad.GameSupervisor do
  use DynamicSupervisor

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_game(game_id, rows, cols) do
    init_args = %{game_id: game_id, rows: rows, cols: cols}

    DynamicSupervisor.start_child(__MODULE__, {Triad.GameStateWorker, init_args})
    DynamicSupervisor.start_child(__MODULE__, {Triad.GameWorker, init_args})
  end

end
