defmodule TriadApi.Cards do
  import Ecto.Query
  @moduledoc """
  The Games Context
  """

  alias TriadApi.Repo
  alias TriadApi.Entities.Card

  @doc """
  Returns the list of cards.

  ## Examples

      iex> list_cards()
      [%Card{}, ...]

  """
  def list_cards do
    Repo.all(Card)
  end

  @doc """
  Gets a single Card.

  Raises `Ecto.NoResultsError` if the Card does not exist.

  ## Examples

      iex> get_card!(123)
      %Card{}

      iex> get_card!(456)
      ** (Ecto.NoResultsError)

  """
  def get_card!(id), do: Repo.get!(Card, id)

  def get_cards!(ids) when is_list(ids) do
    query = from c in Card,
      where: c.id in ^ids

    Repo.all(query)
  end

  @doc """
  Creates a Game.

  ## Examples

      iex> create_game(%{field: value})
      {:ok, %Game{}}

      iex> create_game(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_card!(attrs \\ %{}) do

    %Card{}
    |> Card.changeset(attrs)
    |> Repo.insert!()
  end
end
