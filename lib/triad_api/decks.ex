defmodule TriadApi.Decks do
  import Ecto.Query
  @moduledoc """
  The Games Context
  """

  alias TriadApi.Repo
  alias TriadApi.Entities.Card
  alias TriadApi.Entities.Deck
  alias TriadApi.Entities.DeckCard

  @doc """
  Returns the list of decks for the user.

  ## Examples

      iex> list_decks()
      [%Deck{}, ...]

  """
  def list_decks(user_id) do
    query = from d in Deck, where: d.user_id == type(^user_id, :binary_id)
    Repo.all(query)
  end

  @doc """
  Gets a single Deck.

  Raises `Ecto.NoResultsError` if the Deck does not exist.

  ## Examples

      iex> get_deck!(123)
      %Deck{}

      iex> get_deck!(456)
      ** (Ecto.NoResultsError)

  """
  def get_deck!(id), do: Repo.get!(Deck, id)

  @doc """
  Gets a list of cards for a given deck.

  ## Examples

      iex> get_cards(123)
      [%Card{}, ...]

  """
  def get_cards!(deck_id) do
    query = from c in Card,
      join: dc in DeckCard, on: c.id == dc.card_id,
      join: d in Deck, on: d.id == dc.deck_id,
      where: d.id == ^deck_id

    Repo.all(query)
  end

  @doc """
  Creates a Deck.

  ## Examples

      iex> create_deck!(%{field: value})
      {:ok, %Deck{}}

      iex> create_deck(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_deck!(attrs \\ %{}) do

    %Deck{}
    |> Deck.changeset(attrs)
    |> Repo.insert!()
  end

  @doc """
  Adds cards to a deck.

  ## Examples

      iex> add_cards!(deck_id, cards)
      {:ok}

      iex> add_cards(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def add_cards!(deck_id, cards) when is_list(cards) do

    from(dc in DeckCard, where: dc.deck_id == type(^deck_id, :integer))
    |> Repo.delete_all

    Enum.each(cards,
      fn c ->
        %DeckCard{}
        |> DeckCard.changeset(%{deck_id: deck_id, card_id: c})
        |> Repo.insert!()
      end
    )
  end
end
