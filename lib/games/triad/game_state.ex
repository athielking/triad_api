defmodule Games.Triad.GameState  do
  alias Games.Triad.PlayerState
  alias Games.Triad.GameState

  defstruct player1: %PlayerState{}, player2: %PlayerState{}

  @spec new :: %Games.Triad.GameState{
          player1: %Games.Triad.PlayerState{deck: list, graveyard: [], hand: []},
          player2: %Games.Triad.PlayerState{deck: list, graveyard: [], hand: []}
        }
  def new() do
    %GameState{ player1: PlayerState.new(), player2: PlayerState.new()}
  end
end
