defmodule TriadApi.Entities.Deck do
  use Ecto.Schema
  import Ecto.Changeset

  schema "decks" do
    field :name, :string

    #Associations
    belongs_to :user, TriadApi.Entities.User, type: :binary_id

    timestamps()
  end

   def changeset(model, params \\ :empty) do
    model
    |> cast(params, [:name, :user_id])
  end
end
