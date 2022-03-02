defmodule TriadApi.Entities.GameEvent do
  use Ecto.Schema
  import Ecto.Changeset

  schema "deck_cards" do

    field :event, :string
    field :data, :map

    #Associations
    belongs_to :game, TriadApi.Entities.Game, type: :binary_id
    belongs_to :user, TriadApi.Entities.User, type: :binary_id

    timestamps()
  end

   def changeset(model, params \\ :empty) do
    model
    |> cast(params, [:event, :data, :game_id, :user_id])
  end
end
