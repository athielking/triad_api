defmodule Games.Triad.PlayerState do
  alias Games.Triad.PlayerState

  defstruct [hand: [], deck: [], graveyard: []]

  def new() do
    %PlayerState{hand: [], deck: Enum.to_list(1..40) |> Enum.shuffle(), graveyard: []}
  end

  def draw(%PlayerState{hand: hand, deck: deck, graveyard: graveyard} = state, n) when n > 0 and is_list(hand) and is_list(deck) and is_list(graveyard) do
    drawn = Enum.take(deck, n)

    %{state | hand: drawn |> Enum.concat(hand), deck: state.deck -- drawn, graveyard: state.graveyard}
  end
end
