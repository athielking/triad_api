defmodule Games.Triad.GameState  do
  alias Games.Triad.PlayerState

  defstruct player1: %PlayerState{}, player2: %PlayerState{}
end
