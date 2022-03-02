defmodule TriadApi.Entities.UserCards do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_cards" do

    #Associations
    belongs_to :user, TriadApi.Entities.Deck, type: :binary_id
    belongs_to :card, TriadApi.Entities.Card

    timestamps()
  end

   def changeset(model, params \\ :empty) do
    model
    |> cast(params, [:user_id, :card_id])
  end
end
