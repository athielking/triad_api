defmodule TriadApi.Entities.Game do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, read_after_writes: true, autogenerate: false}
  schema "games" do
    field :playerIdOne, Ecto.UUID, read_after_writes: true, autogenerate: false
    field :playerIdTwo, Ecto.UUID, read_after_writes: true, autogenerate: false
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
