defmodule TriadApi.Entities.Game do
  use TriadApi.Schema
  import Ecto.Changeset

  schema "games" do
    field :playerIdOne, :integer
    field :playerIdTwo, :integer
    field :started_at, :utc_datetime
    field :ended_at, :utc_datetime
    timestamps()
  end

  # @required_fields ~w(id playerIdOne playerIdTwo started_at)
  # @optional_fields ~w()

  def changeset(game, attrs \\ nil) do
    game
    |> cast(attrs, [:playerIdOne, :playerIdTwo, :started_at, :ended_at])
  end
end
