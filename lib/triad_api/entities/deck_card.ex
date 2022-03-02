defmodule TriadApi.Entities.DeckCard do
  use Ecto.Schema
  import Ecto.Changeset

  schema "deck_cards" do

    #Associations
    belongs_to :deck, TriadApi.Entities.Deck
    belongs_to :card, TriadApi.Entities.Card

    timestamps()
  end

   def changeset(model, params \\ :empty) do
    model
    |> cast(params, [:deck_id, :card_id])
  end
end
