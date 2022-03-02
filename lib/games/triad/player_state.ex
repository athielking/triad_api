defmodule Games.Triad.PlayerState do
  alias Games.Triad.PlayerState
  alias TriadApi.Decks

  defstruct [hand: [], deck: [], graveyard: []]

  def init(user_id) do

    deck_id = Decks.list_decks(user_id) |> Enum.map( fn d -> d.id end ) |> Enum.at(0)
    cards = Decks.get_cards!(deck_id) |> Enum.shuffle()

    %PlayerState{hand: [], deck: cards, graveyard: []}
  end

  def draw(%PlayerState{hand: hand, deck: deck, graveyard: graveyard} = state, n) when n > 0 and is_list(hand) and is_list(deck) and is_list(graveyard) do
    drawn = Enum.take(deck, n)

    %{state | hand: drawn |> Enum.concat(hand), deck: state.deck -- drawn, graveyard: state.graveyard}
  end
end
